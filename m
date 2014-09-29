From: Tobias Brunner <tobias@strongswan.org>
Subject: Re: [PATCH RFC ipsec-next] xfrm: Add sysctl option to enforce inbound
 policies for transport mode
Date: Mon, 29 Sep 2014 15:39:31 +0200
Message-ID: <54296113.3080106@strongswan.org>
References: <541815C3.7080509@strongswan.org> <20140919092437.GX6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sifsv-80046.hsr.ch ([152.96.80.46]:46389 "EHLO
	mail.strongswan.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753620AbaI2Nje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:39:34 -0400
In-Reply-To: <20140919092437.GX6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> Currently inbound policies for transport mode SAs are not enforced.
>> If no policy is found or if the templates don't match this is not
>> considered an error for transport mode SAs.
>>
> 
> The strict inbound policy enforcement was implemented by Herbert.
> The commit predates our git history but can be found in the history
> tree:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git
> 
> It was the following commit:
> 
> commit 8fe7ee2ba983fd89b2555dce5930ffd0f7f6c361
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Oct 23 14:57:11 2003 -0700
> 
>     [IPSEC]: Strengthen policy checks.
> 
> Maybe Herbert remembers why this was done only for tunnel mode.

Would be great to hear from Herbert about this.

> If I read section 5.2.1 of RFC 2401 correct, the inbound policy
> must be enforced regardless of the mode.

It looks like the wording changed with RFC 4301.  The SPD and its
policies are not mentioned explicitly anymore in section 5.2 (like
they were in step 3 in section 5.2.1 of RFC 2401).  Instead, packets
must be matched against the "selectors identified by the SAD entry".
It's not entirely clear to me whether these selectors are part of the
SPD or properties of the SAD entries themselves, like the single
selector that can currently be configured on SAs in the kernel.
Also, section 4.4.2 explicitly states that manually keyed SAD entries
do not necessarily need to have a corresponding SPD entry.  Which might
make sense for simple host-host (transport mode) SAs, but this wouldn't
be possible anymore when enforcing inbound policies for transport mode.

>> The new sysctl option (net.core.xfrm_enforce_policies_transport_mode)
>> allows enforcing the inbound policies also for transport mode SAs.
>> By default this option remains disabled.
> 
> I'd not like to have a sysctl for this. I consider it as a bug
> if an installed policy can not be enforced, and we don't fix bugs
> with sysctls :).

Alright, the patch below simplifies the whole thing by treating
transport mode policies like those in other modes.

----

Subject: [PATCH] xfrm: Enforce inbound transport mode policies like those in other modes

Currently inbound policies for transport mode SAs are not enforced.
If no policy is found or if the templates don't match this is not
considered an error for transport mode SAs.

With these changes the inbound policies are also enforced for transport
mode SAs like they are already for other modes.

Signed-off-by: Tobias Brunner <tobias@strongswan.org>
---
 net/xfrm/xfrm_policy.c | 38 ++++++++++----------------------------
 1 file changed, 10 insertions(+), 28 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 55bcb8604bc6..74ce57e7b53b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2348,9 +2348,8 @@ xfrm_state_ok(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x,
 }
 
 /*
- * 0 or more than 0 is returned when validation is succeeded (either bypass
- * because of optional transport mode, or next index of the mathced secpath
- * state with the template.
+ * 0 or more than 0 is returned when validation succeeded (next index of the
+ * matched secpath state with the template).
  * -1 is returned when no matching template is found.
  * Otherwise "-2 - errored_index" is returned.
  */
@@ -2360,19 +2359,13 @@ xfrm_policy_ok(const struct xfrm_tmpl *tmpl, const struct sec_path *sp, int star
 {
 	int idx = start;
 
-	if (tmpl->optional) {
-		if (tmpl->mode == XFRM_MODE_TRANSPORT)
-			return start;
-	} else
+	if (!tmpl->optional)
 		start = -1;
-	for (; idx < sp->len; idx++) {
+	if (idx < sp->len) {
 		if (xfrm_state_ok(tmpl, sp->xvec[idx], family))
 			return ++idx;
-		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT) {
-			if (start == -1)
-				start = -2-idx;
-			break;
-		}
+		if (start == -1)
+			start = -2-idx;
 	}
 	return start;
 }
@@ -2393,18 +2386,6 @@ int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 }
 EXPORT_SYMBOL(__xfrm_decode_session);
 
-static inline int secpath_has_nontransport(const struct sec_path *sp, int k, int *idxp)
-{
-	for (; k < sp->len; k++) {
-		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
-			*idxp = k;
-			return 1;
-		}
-	}
-
-	return 0;
-}
-
 int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			unsigned short family)
 {
@@ -2469,8 +2450,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	if (!pol) {
-		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
-			xfrm_secpath_reject(xerr_idx, skb, &fl);
+		if (skb->sp && skb->sp->len) {
+			xfrm_secpath_reject(0, skb, &fl);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOPOLS);
 			return 0;
 		}
@@ -2545,7 +2526,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			}
 		}
 
-		if (secpath_has_nontransport(sp, k, &xerr_idx)) {
+		if (k < sp->len) {
+			xerr_idx = k;
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINTMPLMISMATCH);
 			goto reject;
 		}
-- 
1.9.1
