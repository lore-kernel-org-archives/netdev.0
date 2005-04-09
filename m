From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/4] [IPSEC] Turn km_event.data into a union
Date: Sat, 9 Apr 2005 21:15:51 +1000
Message-ID: <20050409111551.GA7378@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cNdxnHkX5QqsyA0e"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050409111244.GB7171@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch turns km_event.data into a union.  This makes code that
uses it clearer.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

 include/net/xfrm.h    |    7 ++++++-
 net/key/af_key.c      |   17 +++++------------
 net/xfrm/xfrm_state.c |    5 ++---
 net/xfrm/xfrm_user.c  |   10 +++++-----
 4 files changed, 18 insertions(+), 21 deletions(-)
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--cNdxnHkX5QqsyA0e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-3

===== include/net/xfrm.h 1.81 vs edited =====
--- 1.81/include/net/xfrm.h	2005-04-09 20:21:15 +10:00
+++ edited/include/net/xfrm.h	2005-04-09 20:37:05 +10:00
@@ -172,7 +172,12 @@
 /* callback structure passed from either netlink or pfkey */
 struct km_event
 {
-	u32	data; 
+	union {
+		u32 hard;
+		u32 proto; 
+		u32 byid;
+	} data;
+
 	u32	seq; 
 	u32	pid; 
 	u32	event; 
===== net/key/af_key.c 1.74 vs edited =====
--- 1.74/net/key/af_key.c	2005-04-09 14:39:58 +10:00
+++ edited/net/key/af_key.c	2005-04-09 20:32:54 +10:00
@@ -1293,13 +1293,6 @@
 	if (c->event == XFRM_SAP_DELETED)
 		hsc = 0;
 
-	if (c->event == XFRM_SAP_EXPIRED) {
-		if (c->data)
-			hsc = 2;
-		else
-			hsc = 1;
-	}
-
 	skb = pfkey_xfrm_state2msg(x, 0, hsc);
 
 	if (IS_ERR(skb))
@@ -1534,7 +1527,7 @@
 	if (!skb)
 		return -ENOBUFS;
 	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
-	hdr->sadb_msg_satype = pfkey_proto2satype(c->data);
+	hdr->sadb_msg_satype = pfkey_proto2satype(c->data.proto);
 	hdr->sadb_msg_seq = c->seq;
 	hdr->sadb_msg_pid = c->pid;
 	hdr->sadb_msg_version = PF_KEY_V2;
@@ -1556,7 +1549,7 @@
 		return -EINVAL;
 
 	xfrm_state_flush(proto);
-	c.data = proto;
+	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_SAP_FLUSHED;
@@ -1969,7 +1962,7 @@
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version =  PF_KEY_V2;
 
-	if (c->data && c->event == XFRM_SAP_DELETED)
+	if (c->data.byid && c->event == XFRM_SAP_DELETED)
 		out_hdr->sadb_msg_type = SADB_X_SPDDELETE2;
 	else
 		out_hdr->sadb_msg_type = event2poltype(c->event);
@@ -2183,7 +2176,7 @@
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
-		c.data = 1; // to signal pfkey of SADB_X_SPDDELETE2
+		c.data.byid = 1;
 		c.event = XFRM_SAP_DELETED;
 		km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	} else {
@@ -2463,7 +2456,7 @@
 	int hard;
 	int hsc;
 
-	hard = c->data;
+	hard = c->data.hard;
 	if (hard)
 		hsc = 2;
 	else
===== net/xfrm/xfrm_state.c 1.62 vs edited =====
--- 1.62/net/xfrm/xfrm_state.c	2005-04-09 20:21:15 +10:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-09 20:38:54 +10:00
@@ -835,7 +835,7 @@
 {
 	struct km_event c;
 
-	c.data = hard;
+	c.data.hard = hard;
 	c.event = XFRM_SAP_EXPIRED;
 	km_state_notify(x, &c);
 
@@ -883,8 +883,7 @@
 {
 	struct km_event c;
 
-	c.data = hard;
-	c.data = hard;
+	c.data.hard = hard;
 	c.event = XFRM_SAP_EXPIRED;
 	km_policy_notify(pol, dir, &c);
 
===== net/xfrm/xfrm_user.c 1.53 vs edited =====
--- 1.53/net/xfrm/xfrm_user.c	2005-04-08 23:08:26 +10:00
+++ edited/net/xfrm/xfrm_user.c	2005-04-09 20:35:06 +10:00
@@ -894,7 +894,7 @@
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
 
 	xfrm_state_flush(p->proto);
-	c.data = p->proto;
+	c.data.proto = p->proto;
 	c.event = XFRM_SAP_FLUSHED;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
@@ -1116,13 +1116,13 @@
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
-	int hard = c ->data;
+
 	/* fix to do alloc using NLM macros */
 	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_expire(skb, x, hard) < 0)
+	if (build_expire(skb, x, c->data.hard) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;
@@ -1148,7 +1148,7 @@
 	nlh->nlmsg_flags = 0;
 
 	p = NLMSG_DATA(nlh);
-	p->proto = c->data;
+	p->proto = c->data.proto;
 
 	nlh->nlmsg_len = skb->tail - b;
 
@@ -1391,7 +1391,7 @@
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c->data) < 0)
+	if (build_polexpire(skb, xp, dir, c->data.hard) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;

--cNdxnHkX5QqsyA0e--
