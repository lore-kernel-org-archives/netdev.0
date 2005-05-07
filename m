From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/7] [IPSEC] Turn km_event.data into a union
Date: Sat, 7 May 2005 17:21:39 +1000
Message-ID: <20050507072139.GE5753@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050507071434.GA5716@gondor.apana.org.au> <20050507071824.GA5753@gondor.apana.org.au> <20050507071930.GC5753@gondor.apana.org.au> <20050507072058.GD5753@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DqhR8hV3EnoxUkKN"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050507072058.GD5753@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--DqhR8hV3EnoxUkKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch turns km_event.data into a union.  This makes code that
uses it clearer.
  
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--DqhR8hV3EnoxUkKN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-4

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -173,7 +173,12 @@ enum {
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
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1293,13 +1293,6 @@ static int key_notify_sa(struct xfrm_sta
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
@@ -1534,7 +1527,7 @@ static int key_notify_sa_flush(struct km
 	if (!skb)
 		return -ENOBUFS;
 	hdr = (struct sadb_msg *) skb_put(skb, sizeof(struct sadb_msg));
-	hdr->sadb_msg_satype = pfkey_proto2satype(c->data);
+	hdr->sadb_msg_satype = pfkey_proto2satype(c->data.proto);
 	hdr->sadb_msg_seq = c->seq;
 	hdr->sadb_msg_pid = c->pid;
 	hdr->sadb_msg_version = PF_KEY_V2;
@@ -1556,7 +1549,7 @@ static int pfkey_flush(struct sock *sk, 
 		return -EINVAL;
 
 	xfrm_state_flush(proto);
-	c.data = proto;
+	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	c.event = XFRM_SAP_FLUSHED;
@@ -1969,7 +1962,7 @@ static int key_notify_policy(struct xfrm
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = PF_KEY_V2;
 
-	if (c->data && c->event == XFRM_SAP_DELETED)
+	if (c->data.byid && c->event == XFRM_SAP_DELETED)
 		out_hdr->sadb_msg_type = SADB_X_SPDDELETE2;
 	else
 		out_hdr->sadb_msg_type = event2poltype(c->event);
@@ -2180,7 +2173,7 @@ static int pfkey_spdget(struct sock *sk,
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
-		c.data = 1; // to signal pfkey of SADB_X_SPDDELETE2
+		c.data.byid = 1;
 		c.event = XFRM_SAP_DELETED;
 		km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	} else {
@@ -2460,7 +2453,7 @@ static int key_notify_sa_expire(struct x
 	int hard;
 	int hsc;
 
-	hard = c->data;
+	hard = c->data.hard;
 	if (hard)
 		hsc = 2;
 	else
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -835,7 +835,7 @@ static void km_state_expired(struct xfrm
 {
 	struct km_event c;
 
-	c.data = hard;
+	c.data.hard = hard;
 	c.event = XFRM_SAP_EXPIRED;
 	km_state_notify(x, &c);
 
@@ -883,8 +883,7 @@ void km_policy_expired(struct xfrm_polic
 {
 	struct km_event c;
 
-	c.data = hard;
-	c.data = hard;
+	c.data.hard = hard;
 	c.event = XFRM_SAP_EXPIRED;
 	km_policy_notify(pol, dir, &c);
 
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -891,7 +891,7 @@ static int xfrm_flush_sa(struct sk_buff 
 	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
 
 	xfrm_state_flush(p->proto);
-	c.data = p->proto;
+	c.data.proto = p->proto;
 	c.event = XFRM_SAP_FLUSHED;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
@@ -1120,14 +1120,13 @@ nlmsg_failure:
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct sk_buff *skb;
-	int hard = c ->data;
 
 	/* fix to do alloc using NLM macros */
 	skb = alloc_skb(sizeof(struct xfrm_user_expire) + 16, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_expire(skb, x, hard) < 0)
+	if (build_expire(skb, x, c->data.hard) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;
@@ -1153,7 +1152,7 @@ static int xfrm_notify_sa_flush(struct k
 	nlh->nlmsg_flags = 0;
 
 	p = NLMSG_DATA(nlh);
-	p->proto = c->data;
+	p->proto = c->data.proto;
 
 	nlh->nlmsg_len = skb->tail - b;
 
@@ -1395,7 +1394,7 @@ static int xfrm_exp_policy_notify(struct
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c->data) < 0)
+	if (build_polexpire(skb, xp, dir, c->data.hard) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;

--DqhR8hV3EnoxUkKN--
