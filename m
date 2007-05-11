From: Mark Huth <mhuth@mvista.com>
Subject: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Thu, 10 May 2007 18:56:52 -0700
Message-ID: <4643CD64.4090000@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:36534 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758540AbXEKB4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 21:56:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry about previous html/non-inline version which escaped.

This patch provides a performance optimization in the pfkey_add path.
Prior versions have a serious performance problem when adding a large
number of SAs to a node.  For example, if a backup node needs to be
loaded with the SAs previously held by a failed active node, thousands
of SAs may need to be added as rapidly as possible.  Tests show that
without this patch, such additions may take several minutes.  The
cause is that the available algorithm modules are probed each time
instead of only when needed.  This patch changes the unconditional
call to xfrm_probe_algs() to only be done when it may be needed.

An example that loads 2000 SAs gives the following results:

Without patch

real	0m42.643s
user	0m0.120s
sys	0m0.800s

With patch

real	0m0.537s
user	0m0.076s
sys	0m0.276s

Signed-Off-By: Mark Huth <mhuth@mvista.com>
===============================================
diff --git a/net/key/af_key.c b/net/key/af_key.c
index a994441..c970d5e 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1445,16 +1445,15 @@ static int key_notify_sa(struct xfrm_state *x, 
struct km_event *c)
  static int pfkey_add(struct sock *sk, struct sk_buff *skb, struct 
sadb_msg *hdr, void **ext_hdrs)
  {
  	struct xfrm_state *x;
-	int err;
+	int err, probe_done = 0;
  	struct km_event c;

-	xfrm_probe_algs();
-
  	x = pfkey_msg2xfrm_state(hdr, ext_hdrs);
  	if (IS_ERR(x))
  		return PTR_ERR(x);

  	xfrm_state_hold(x);
+try_again:
  	if (hdr->sadb_msg_type == SADB_ADD)
  		err = xfrm_state_add(x);
  	else
@@ -1464,6 +1463,11 @@ static int pfkey_add(struct sock *sk, struct 
sk_buff *skb, struct sadb_msg *hdr,
  		       AUDIT_MAC_IPSEC_ADDSA, err ? 0 : 1, NULL, x);

  	if (err < 0) {
+		if (!probe_done) {
+			xfrm_probe_algs();
+			probe_done = 1;
+			goto try_again;
+		}
  		x->km.state = XFRM_STATE_DEAD;
  		__xfrm_state_put(x);
  		goto out;
