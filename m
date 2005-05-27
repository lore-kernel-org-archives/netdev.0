From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [6/10] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Fri, 27 May 2005 21:11:40 +1000
Message-ID: <20050527111140.GF4545@gondor.apana.org.au>
References: <20050527110730.GA4424@gondor.apana.org.au> <20050527110816.GA4545@gondor.apana.org.au> <20050527110852.GB4545@gondor.apana.org.au> <20050527110929.GC4545@gondor.apana.org.au> <20050527111007.GD4545@gondor.apana.org.au> <20050527111037.GE4545@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dgjlcl3Tl+kb3YDk"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jamal <hadi@cyberus.ca>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050527111037.GE4545@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This patch removes XFRM_SAP_* and converts them over to XFRM_MSG_*.
The netlink interface is meant to map directly onto the underlying
xfrm subsystem.  Therefore rather than using a new independent
representation for the events we can simply use the existing ones
from xfrm_user.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--dgjlcl3Tl+kb3YDk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p6.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -158,18 +158,6 @@ enum {
 	XFRM_STATE_DEAD
 };
 
-/* events that could be sent by kernel */
-enum {
-	XFRM_SAP_INVALID,
-	XFRM_SAP_EXPIRED,
-	XFRM_SAP_ADDED,
-	XFRM_SAP_UPDATED,
-	XFRM_SAP_DELETED,
-	XFRM_SAP_FLUSHED,
-	__XFRM_SAP_MAX
-};
-#define XFRM_SAP_MAX (__XFRM_SAP_MAX - 1)
-
 /* callback structure passed from either netlink or pfkey */
 struct km_event
 {
diff --git a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1248,13 +1248,13 @@ static int pfkey_acquire(struct sock *sk
 static inline int event2poltype(int event)
 {
 	switch (event) {
-	case XFRM_SAP_DELETED:
+	case XFRM_MSG_DELPOLICY:
 		return SADB_X_SPDDELETE;
-	case XFRM_SAP_ADDED:
+	case XFRM_MSG_NEWPOLICY:
 		return SADB_X_SPDADD;
-	case XFRM_SAP_UPDATED:
+	case XFRM_MSG_UPDPOLICY:
 		return SADB_X_SPDUPDATE;
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_POLEXPIRE:
 	//	return SADB_X_SPDEXPIRE;
 	default:
 		printk("pfkey: Unknown policy event %d\n", event);
@@ -1267,13 +1267,13 @@ static inline int event2poltype(int even
 static inline int event2keytype(int event)
 {
 	switch (event) {
-	case XFRM_SAP_DELETED:
+	case XFRM_MSG_DELSA:
 		return SADB_DELETE;
-	case XFRM_SAP_ADDED:
+	case XFRM_MSG_NEWSA:
 		return SADB_ADD;
-	case XFRM_SAP_UPDATED:
+	case XFRM_MSG_UPDSA:
 		return SADB_UPDATE;
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_EXPIRE:
 		return SADB_EXPIRE;
 	default:
 		printk("pfkey: Unknown SA event %d\n", event);
@@ -1290,7 +1290,7 @@ static int key_notify_sa(struct xfrm_sta
 	struct sadb_msg *hdr;
 	int hsc = 3;
 
-	if (c->event == XFRM_SAP_DELETED)
+	if (c->event == XFRM_MSG_DELSA)
 		hsc = 0;
 
 	skb = pfkey_xfrm_state2msg(x, 0, hsc);
@@ -1337,9 +1337,9 @@ static int pfkey_add(struct sock *sk, st
 	}
 
 	if (hdr->sadb_msg_type == SADB_ADD)
-		c.event = XFRM_SAP_ADDED;
+		c.event = XFRM_MSG_NEWSA;
 	else
-		c.event = XFRM_SAP_UPDATED;
+		c.event = XFRM_MSG_UPDSA;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
 	km_state_notify(x, &c);
@@ -1376,7 +1376,7 @@ static int pfkey_delete(struct sock *sk,
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
 
@@ -1552,7 +1552,7 @@ static int pfkey_flush(struct sock *sk, 
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = XFRM_MSG_FLUSHSA;
 	km_state_notify(NULL, &c);
 
 	return 0;
@@ -1962,7 +1962,7 @@ static int key_notify_policy(struct xfrm
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version = PF_KEY_V2;
 
-	if (c->data.byid && c->event == XFRM_SAP_DELETED)
+	if (c->data.byid && c->event == XFRM_MSG_DELPOLICY)
 		out_hdr->sadb_msg_type = SADB_X_SPDDELETE2;
 	else
 		out_hdr->sadb_msg_type = event2poltype(c->event);
@@ -2058,9 +2058,9 @@ static int pfkey_spdadd(struct sock *sk,
 	}
 
 	if (hdr->sadb_msg_type == SADB_X_SPDUPDATE)
-		c.event = XFRM_SAP_UPDATED;
-	else
-		c.event = XFRM_SAP_ADDED;
+		c.event = XFRM_MSG_UPDPOLICY;
+	else 
+		c.event = XFRM_MSG_NEWPOLICY;
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2118,7 +2118,7 @@ static int pfkey_spddelete(struct sock *
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = XFRM_MSG_DELPOLICY;
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 
 	xfrm_pol_put(xp);
@@ -2174,7 +2174,7 @@ static int pfkey_spdget(struct sock *sk,
 	c.pid = hdr->sadb_msg_pid;
 	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
 		c.data.byid = 1;
-		c.event = XFRM_SAP_DELETED;
+		c.event = XFRM_MSG_DELPOLICY;
 		km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	} else {
 		err = key_pol_get_resp(sk, xp, hdr, pol->sadb_x_policy_dir-1);
@@ -2238,7 +2238,7 @@ static int pfkey_spdflush(struct sock *s
 	struct km_event c;
 
 	xfrm_policy_flush();
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
 	km_policy_notify(NULL, 0, &c);
@@ -2479,13 +2479,13 @@ static int key_notify_sa_expire(struct x
 static int pfkey_send_notify(struct xfrm_state *x, struct km_event *c)
 {
 	switch (c->event) {
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_EXPIRE:
 		return key_notify_sa_expire(x, c);
-	case XFRM_SAP_DELETED:
-	case XFRM_SAP_ADDED:
-	case XFRM_SAP_UPDATED:
+	case XFRM_MSG_DELSA:
+	case XFRM_MSG_NEWSA:
+	case XFRM_MSG_UPDSA:
 		return key_notify_sa(x, c);
-	case XFRM_SAP_FLUSHED:
+	case XFRM_MSG_FLUSHSA:
 		return key_notify_sa_flush(c);
 	default:
 		printk("pfkey: Unknown SA event %d\n", c->event);
@@ -2498,13 +2498,13 @@ static int pfkey_send_notify(struct xfrm
 static int pfkey_send_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	switch (c->event) {
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_POLEXPIRE:
 		return key_notify_policy_expire(xp, c);
-	case XFRM_SAP_DELETED:
-	case XFRM_SAP_ADDED:
-	case XFRM_SAP_UPDATED:
+	case XFRM_MSG_DELPOLICY:
+	case XFRM_MSG_NEWPOLICY:
+	case XFRM_MSG_UPDPOLICY:
 		return key_notify_policy(xp, dir, c);
-	case XFRM_SAP_FLUSHED:
+	case XFRM_MSG_FLUSHPOLICY:
 		return key_notify_policy_flush(c);
 	default:
 		printk("pfkey: Unknown policy event %d\n", c->event);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -836,7 +836,7 @@ static void km_state_expired(struct xfrm
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.event = XFRM_SAP_EXPIRED;
+	c.event = XFRM_MSG_EXPIRE;
 	km_state_notify(x, &c);
 
 	if (hard)
@@ -884,7 +884,7 @@ void km_policy_expired(struct xfrm_polic
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.event = XFRM_SAP_EXPIRED;
+	c.event = XFRM_MSG_POLEXPIRE;
 	km_policy_notify(pol, dir, &c);
 
 	if (hard)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -292,10 +292,7 @@ static int xfrm_add_sa(struct sk_buff *s
 
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
-	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
-		c.event = XFRM_SAP_ADDED;
-	else
-		c.event = XFRM_SAP_UPDATED;
+	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
@@ -327,7 +324,7 @@ static int xfrm_del_sa(struct sk_buff *s
 
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = nlh->nlmsg_type;
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
 
@@ -719,11 +716,7 @@ static int xfrm_add_policy(struct sk_buf
 		return err;
 	}
 
-	if (!excl)
-		c.event = XFRM_SAP_UPDATED;
-	else
-		c.event = XFRM_SAP_ADDED;
-
+	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	km_policy_notify(xp, p->dir, &c);
@@ -875,7 +868,7 @@ static int xfrm_get_policy(struct sk_buf
 		}
 	} else {
 		c.data.byid = p->index;
-		c.event = XFRM_SAP_DELETED;
+		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
 		c.pid = nlh->nlmsg_pid;
 		km_policy_notify(xp, p->dir, &c);
@@ -893,7 +886,7 @@ static int xfrm_flush_sa(struct sk_buff 
 
 	xfrm_state_flush(p->proto);
 	c.data.proto = p->proto;
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	km_state_notify(NULL, &c);
@@ -906,7 +899,7 @@ static int xfrm_flush_policy(struct sk_b
 	struct km_event c;
 
 	xfrm_policy_flush();
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	km_policy_notify(NULL, 0, &c);
@@ -1184,7 +1177,6 @@ static int xfrm_notify_sa(struct xfrm_st
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	u32 nlt;
 	unsigned char *b;
 	int len = xfrm_sa_len(x);
 
@@ -1193,16 +1185,7 @@ static int xfrm_notify_sa(struct xfrm_st
 		return -ENOMEM;
 	b = skb->tail;
 
-	if (c->event == XFRM_SAP_ADDED)
-		nlt = XFRM_MSG_NEWSA;
-	else if (c->event == XFRM_SAP_UPDATED)
-		nlt = XFRM_MSG_UPDSA;
-	else if (c->event == XFRM_SAP_DELETED)
-		nlt = XFRM_MSG_DELSA;
-	else
-		goto nlmsg_failure;
-
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, nlt, sizeof(*p));
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, sizeof(*p));
 	nlh->nlmsg_flags = 0;
 
 	p = NLMSG_DATA(nlh);
@@ -1234,13 +1217,13 @@ static int xfrm_send_state_notify(struct
 {
 
 	switch (c->event) {
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_EXPIRE:
 		return xfrm_exp_state_notify(x, c);
-	case XFRM_SAP_DELETED:
-	case XFRM_SAP_UPDATED:
-	case XFRM_SAP_ADDED:
+	case XFRM_MSG_DELSA:
+	case XFRM_MSG_UPDSA:
+	case XFRM_MSG_NEWSA:
 		return xfrm_notify_sa(x, c);
-	case XFRM_SAP_FLUSHED:
+	case XFRM_MSG_FLUSHSA:
 		return xfrm_notify_sa_flush(c);
 	default:
 		 printk("xfrm_user: Unknown SA event %d\n", c->event);
@@ -1408,7 +1391,6 @@ static int xfrm_notify_policy(struct xfr
 	struct xfrm_userpolicy_info *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	u32 nlt = 0 ;
 	unsigned char *b;
 	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_info));
@@ -1418,16 +1400,7 @@ static int xfrm_notify_policy(struct xfr
 		return -ENOMEM;
 	b = skb->tail;
 
-	if (c->event == XFRM_SAP_ADDED)
-		nlt = XFRM_MSG_NEWPOLICY;
-	else if (c->event == XFRM_SAP_UPDATED)
-		nlt = XFRM_MSG_UPDPOLICY;
-	else if (c->event == XFRM_SAP_DELETED)
-		nlt = XFRM_MSG_DELPOLICY;
-	else
-		goto nlmsg_failure;
-
-	nlh = NLMSG_PUT(skb, c->pid, c->seq, nlt, sizeof(*p));
+	nlh = NLMSG_PUT(skb, c->pid, c->seq, c->event, sizeof(*p));
 
 	p = NLMSG_DATA(nlh);
 
@@ -1474,13 +1447,13 @@ static int xfrm_send_policy_notify(struc
 {
 
 	switch (c->event) {
-	case XFRM_SAP_ADDED:
-	case XFRM_SAP_UPDATED:
-	case XFRM_SAP_DELETED:
+	case XFRM_MSG_NEWPOLICY:
+	case XFRM_MSG_UPDPOLICY:
+	case XFRM_MSG_DELPOLICY:
 		return xfrm_notify_policy(xp, dir, c);
-	case XFRM_SAP_FLUSHED:
+	case XFRM_MSG_FLUSHPOLICY:
 		return xfrm_notify_policy_flush(c);
-	case XFRM_SAP_EXPIRED:
+	case XFRM_MSG_POLEXPIRE:
 		return xfrm_exp_policy_notify(xp, dir, c);
 	default:
 		printk("xfrm_user: Unknown Policy event %d\n", c->event);

--dgjlcl3Tl+kb3YDk--
