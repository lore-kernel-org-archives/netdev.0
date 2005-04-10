From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Sun, 10 Apr 2005 19:02:50 +1000
Message-ID: <20050410090250.GA26022@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <20050409111551.GA7378@gondor.apana.org.au> <20050410074849.GA13259@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050410074849.GA13259@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I spotted some more issues while preparing the last patch of the
series.  So I'll extend it a little further.

This patch removes XFRM_SAP_* and converts them over to XFRM_MSG_*.
The netlink interface is meant to map directly onto the underlying
xfrm subsystem.  Therefore rather than using a new independent
representation for the events we can simply use the existing ones
from xfrm_user.

I also killed a couple of inline's in af_key since

1) They are not performance critical.
2) None of the other x2y functions here are inlined.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

 include/net/xfrm.h    |   12 --------
 net/key/af_key.c      |   70 +++++++++++++++++++++++++-------------------------
 net/xfrm/xfrm_state.c |    4 +-
 net/xfrm/xfrm_user.c  |   63 ++++++++++++---------------------------------
 4 files changed, 55 insertions(+), 94 deletions(-)
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-event-5

===== include/net/xfrm.h 1.82 vs edited =====
--- 1.82/include/net/xfrm.h	2005-04-09 20:40:43 +10:00
+++ edited/include/net/xfrm.h	2005-04-10 18:01:39 +10:00
@@ -157,18 +157,6 @@
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
===== net/key/af_key.c 1.75 vs edited =====
--- 1.75/net/key/af_key.c	2005-04-09 20:40:43 +10:00
+++ edited/net/key/af_key.c	2005-04-10 18:51:51 +10:00
@@ -1245,38 +1245,38 @@
 	return 0;
 }
 
-static inline int event2poltype (int event)
+static int event2poltype(int event)
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
-		printk("pfkey: Unknown policy event %d\n",event);
+		printk("pfkey: Unknown policy event %d\n", event);
 		break;
 	}
 
 	return 0;
 }
 
-static inline int event2keytype (int event)
+static int event2keytype(int event)
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
-		printk("pfkey: Unknown SA event %d\n",event);
+		printk("pfkey: Unknown SA event %d\n", event);
 		break;
 	}
 
@@ -1290,7 +1290,7 @@
 	struct sadb_msg *hdr;
 	int hsc = 3;
 
-	if (c->event == XFRM_SAP_DELETED)
+	if (c->event == XFRM_MSG_DELSA)
 		hsc = 0;
 
 	skb = pfkey_xfrm_state2msg(x, 0, hsc);
@@ -1337,9 +1337,9 @@
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
@@ -1376,7 +1376,7 @@
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
 
@@ -1552,7 +1552,7 @@
 	c.data.proto = proto;
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = XFRM_MSG_FLUSHSA;
 	km_state_notify(NULL, &c);
 
 	return 0;
@@ -1962,7 +1962,7 @@
 	out_hdr = (struct sadb_msg *) out_skb->data;
 	out_hdr->sadb_msg_version =  PF_KEY_V2;
 
-	if (c->data.byid && c->event == XFRM_SAP_DELETED)
+	if (c->data.byid && c->event == XFRM_MSG_DELPOLICY)
 		out_hdr->sadb_msg_type = SADB_X_SPDDELETE2;
 	else
 		out_hdr->sadb_msg_type = event2poltype(c->event);
@@ -2060,9 +2060,9 @@
 	}
 
 	if (hdr->sadb_msg_type == SADB_X_SPDUPDATE) 
-		c.event = XFRM_SAP_UPDATED;
+		c.event = XFRM_MSG_UPDPOLICY;
 	else 
-		c.event = XFRM_SAP_ADDED;
+		c.event = XFRM_MSG_NEWPOLICY;
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
@@ -2120,7 +2120,7 @@
 
 	c.seq = hdr->sadb_msg_seq;
 	c.pid = hdr->sadb_msg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = XFRM_MSG_DELPOLICY;
 	km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 
 	xfrm_pol_put(xp);
@@ -2177,7 +2177,7 @@
 	c.pid = hdr->sadb_msg_pid;
 	if (hdr->sadb_msg_type == SADB_X_SPDDELETE2) {
 		c.data.byid = 1;
-		c.event = XFRM_SAP_DELETED;
+		c.event = XFRM_MSG_DELPOLICY;
 		km_policy_notify(xp, pol->sadb_x_policy_dir-1, &c);
 	} else {
 		err = key_pol_get_resp(sk, xp, hdr, pol->sadb_x_policy_dir-1);
@@ -2240,7 +2240,7 @@
 	struct km_event c;
 
 	xfrm_policy_flush();
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = XFRM_MSG_FLUSHPOLICY;
 	c.pid = hdr->sadb_msg_pid;
 	c.seq = hdr->sadb_msg_seq;
 	km_policy_notify(NULL, 0, &c);
@@ -2482,16 +2482,16 @@
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
-		printk("pfkey: Unknown SA event %d\n",c->event);
+		printk("pfkey: Unknown SA event %d\n", c->event);
 		break;
 	}
 
@@ -2501,16 +2501,16 @@
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
-		printk("pfkey: Unknown policy event %d\n",c->event);
+		printk("pfkey: Unknown policy event %d\n", c->event);
 		break;
 	}
 
===== net/xfrm/xfrm_state.c 1.63 vs edited =====
--- 1.63/net/xfrm/xfrm_state.c	2005-04-09 20:40:43 +10:00
+++ edited/net/xfrm/xfrm_state.c	2005-04-10 18:55:01 +10:00
@@ -836,7 +836,7 @@
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.event = XFRM_SAP_EXPIRED;
+	c.event = XFRM_MSG_EXPIRE;
 	km_state_notify(x, &c);
 
 	if (hard)
@@ -884,7 +884,7 @@
 	struct km_event c;
 
 	c.data.hard = hard;
-	c.event = XFRM_SAP_EXPIRED;
+	c.event = XFRM_MSG_POLEXPIRE;
 	km_policy_notify(pol, dir, &c);
 
 	if (hard)
===== net/xfrm/xfrm_user.c 1.55 vs edited =====
--- 1.55/net/xfrm/xfrm_user.c	2005-04-10 17:45:12 +10:00
+++ edited/net/xfrm/xfrm_user.c	2005-04-10 18:05:53 +10:00
@@ -292,10 +292,7 @@
 
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
-	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
-		c.event = XFRM_SAP_ADDED;
-	else
-		c.event = XFRM_SAP_UPDATED;
+	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
@@ -327,7 +324,7 @@
 
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
-	c.event = XFRM_SAP_DELETED;
+	c.event = nlh->nlmsg_type;
 	km_state_notify(x, &c);
 	xfrm_state_put(x);
 
@@ -721,11 +718,7 @@
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
@@ -878,7 +871,7 @@
 		}
 	} else {
 		c.data.byid = p->index;
-		c.event = XFRM_SAP_DELETED;
+		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
 		c.pid = nlh->nlmsg_pid;
 		km_policy_notify(xp, p->dir, &c);
@@ -896,7 +889,7 @@
 
 	xfrm_state_flush(p->proto);
 	c.data.proto = p->proto;
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	km_state_notify(NULL, &c);
@@ -909,7 +902,7 @@
 	struct km_event c;
 
 	xfrm_policy_flush();
-	c.event = XFRM_SAP_FLUSHED;
+	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.pid = nlh->nlmsg_pid;
 	km_policy_notify(NULL, 0, &c);
@@ -1180,7 +1173,6 @@
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	u32 nlt;
 	unsigned char *b;
 	int len = xfrm_sa_len(x);
 
@@ -1189,16 +1181,7 @@
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
@@ -1230,13 +1213,13 @@
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
 		 printk("xfrm_user: Unknown SA event %d\n",c->event);
@@ -1405,7 +1388,6 @@
 	struct xfrm_userpolicy_info *p;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
-	u32 nlt = 0 ;
 	unsigned char *b;
 	int len = RTA_SPACE(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_info));
@@ -1415,16 +1397,7 @@
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
 
@@ -1471,13 +1444,13 @@
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
 		printk("xfrm_user: Unknown Policy event %d\n",c->event);

--PNTmBPCT7hxwcZjr--
