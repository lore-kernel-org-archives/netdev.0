From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH RFC ipsec-next] xfrm: Add sysctl option to enforce inbound
 policies for transport mode
Date: Tue, 16 Sep 2014 12:49:39 +0200
Message-ID: <541815C3.7080509@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sifsv-80046.hsr.ch ([152.96.80.46]:44875 "EHLO
	mail.strongswan.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbaIPK6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 06:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently inbound policies for transport mode SAs are not enforced.
If no policy is found or if the templates don't match this is not
considered an error for transport mode SAs.

The new sysctl option (net.core.xfrm_enforce_policies_transport_mode)
allows enforcing the inbound policies also for transport mode SAs.
By default this option remains disabled.

Signed-off-by: Tobias Brunner <tobias@strongswan.org>
---
Consider a transport mode SA between two peers over which only TCP and
ICMP traffic should be allowed.  Because two protocols are involved the
selector on the SA itself (xfrm_usersa_info.sel) can't be set.  Instead
one either has to negotiate separate SAs for each protocol (with a
selector on each) or negotiate one SA and install two policies that
use it.  The problem with the latter is that the peer does not have to
adhere to the negotiated traffic selectors, it is basically free to
send anything over the SA e.g. UDP packets.  So if no selectors are
installed on the SA itself, the current implementation would accept
such packets, even though the installed policies don't allow UDP
traffic (some might consider this a security issue - at the very least
it is not very intuitive, especially because the behavior is different
for tunnel mode SAs).
By enabling the new sysctl option the UDP packets would get dropped,
exactly as they would if the SA were negotiated in tunnel mode.

The behavior for optional transport mode templates also changes when
the option is enabled.  Basically, the special treatment of transport
mode SAs is disabled and the behavior is like it is for other modes.
I tested this with IPComp/ESP and strongSwan where the optional IPComp
transform is installed in transport or tunnel mode depending on the
negotiated mode of the SA (the ESP SA is always installed in transport
mode in this combination).  But I'm not sure if there are other uses
for optional transport mode transforms that might rely on the current
behavior (i.e. why are optional templates treated differently depending
on their mode in the first place?).

With this patch the default behavior remains as it is, but I wondered
why it is like that and if we could perhaps change it so that policies
are enforced by default, thus making such setups more secure out of
the box.  Or if we could even change the whole inbound processing so
that transport mode SAs are treated exactly like their counterparts
in other modes, without an option to change it.

 Documentation/networking/xfrm_sysctl.txt |  4 ++++
 include/net/netns/xfrm.h                 |  1 +
 net/xfrm/xfrm_policy.c                   | 24 +++++++++++++++---------
 net/xfrm/xfrm_sysctl.c                   |  8 ++++++++
 4 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/xfrm_sysctl.txt b/Documentation/networking/xfrm_sysctl.txt
index 5bbd167..2fbe539 100644
--- a/Documentation/networking/xfrm_sysctl.txt
+++ b/Documentation/networking/xfrm_sysctl.txt
@@ -2,3 +2,7 @@
  xfrm_acq_expires - INTEGER
 	default 30 - hard timeout in seconds for acquire requests
+
+xfrm_enforce_policies_transport_mode - BOOLEAN
+	default 0 (disabled) - whether to enforce inbound policies for transport
+	mode SAs
\ No newline at end of file
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 9da7982..e045ecc 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -64,6 +64,7 @@ struct netns_xfrm {
 	u32			sysctl_aevent_rseqth;
 	int			sysctl_larval_drop;
 	u32			sysctl_acq_expires;
+	int			sysctl_enforce_policies_transport_mode;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_hdr;
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 55bcb86..5296f6b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2355,20 +2355,22 @@ xfrm_state_ok(const struct xfrm_tmpl *tmpl, const struct xfrm_state *x,
  * Otherwise "-2 - errored_index" is returned.
  */
 static inline int
-xfrm_policy_ok(const struct xfrm_tmpl *tmpl, const struct sec_path *sp, int start,
-	       unsigned short family)
+xfrm_policy_ok(const struct net *net, const struct xfrm_tmpl *tmpl,
+	       const struct sec_path *sp, int start, unsigned short family)
 {
 	int idx = start;
  	if (tmpl->optional) {
-		if (tmpl->mode == XFRM_MODE_TRANSPORT)
+		if (tmpl->mode == XFRM_MODE_TRANSPORT &&
+		    !net->xfrm.sysctl_enforce_policies_transport_mode)
 			return start;
 	} else
 		start = -1;
 	for (; idx < sp->len; idx++) {
 		if (xfrm_state_ok(tmpl, sp->xvec[idx], family))
 			return ++idx;
-		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT) {
+		if (sp->xvec[idx]->props.mode != XFRM_MODE_TRANSPORT ||
+		    net->xfrm.sysctl_enforce_policies_transport_mode) {
 			if (start == -1)
 				start = -2-idx;
 			break;
@@ -2393,10 +2395,13 @@ int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
 }
 EXPORT_SYMBOL(__xfrm_decode_session);
 -static inline int secpath_has_nontransport(const struct sec_path *sp, int k, int *idxp)
+static inline int secpath_has_nontransport(const struct net *net,
+					   const struct sec_path *sp,
+					   int k, int *idxp)
 {
 	for (; k < sp->len; k++) {
-		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT) {
+		if (sp->xvec[k]->props.mode != XFRM_MODE_TRANSPORT ||
+		    net->xfrm.sysctl_enforce_policies_transport_mode) {
 			*idxp = k;
 			return 1;
 		}
@@ -2469,7 +2474,8 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
  	if (!pol) {
-		if (skb->sp && secpath_has_nontransport(skb->sp, 0, &xerr_idx)) {
+		if (skb->sp &&
+		    secpath_has_nontransport(net, skb->sp, 0, &xerr_idx)) {
 			xfrm_secpath_reject(xerr_idx, skb, &fl);
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINNOPOLS);
 			return 0;
@@ -2535,7 +2541,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 		 * are implied between each two transformations.
 		 */
 		for (i = xfrm_nr-1, k = 0; i >= 0; i--) {
-			k = xfrm_policy_ok(tpp[i], sp, k, family);
+			k = xfrm_policy_ok(net, tpp[i], sp, k, family);
 			if (k < 0) {
 				if (k < -1)
 					/* "-2 - errored_index" returned */
@@ -2545,7 +2551,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 			}
 		}
 -		if (secpath_has_nontransport(sp, k, &xerr_idx)) {
+		if (secpath_has_nontransport(net, sp, k, &xerr_idx)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINTMPLMISMATCH);
 			goto reject;
 		}
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05a6e3d..17671af 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -9,6 +9,7 @@ static void __net_init __xfrm_sysctl_init(struct net *net)
 	net->xfrm.sysctl_aevent_rseqth = XFRM_AE_SEQT_SIZE;
 	net->xfrm.sysctl_larval_drop = 1;
 	net->xfrm.sysctl_acq_expires = 30;
+	net->xfrm.sysctl_enforce_policies_transport_mode = 0;
 }
  #ifdef CONFIG_SYSCTL
@@ -37,6 +38,12 @@ static struct ctl_table xfrm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "xfrm_enforce_policies_transport_mode",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{}
 };
 @@ -53,6 +60,7 @@ int __net_init xfrm_sysctl_init(struct net *net)
 	table[1].data = &net->xfrm.sysctl_aevent_rseqth;
 	table[2].data = &net->xfrm.sysctl_larval_drop;
 	table[3].data = &net->xfrm.sysctl_acq_expires;
+	table[4].data = &net->xfrm.sysctl_enforce_policies_transport_mode;
  	/* Don't export sysctls to unprivileged users */
 	if (net->user_ns != &init_user_ns)
-- 
1.9.1
