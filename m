From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XFRM] Add FLUSHSA and FLUSHPOLICY
Date: Fri, 9 Jul 2004 20:13:27 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709101327.GA12291@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch adds FLUSHSA and FLUSHPOLICY to xfrm_user which are
analagous to SADB_FLUSH and SADB_X_SPDFLUSH in af_key.

This is useful in KMs on startup/shutdown so that the system is
reset to a known state.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/xfrm.h 1.22 vs edited =====
--- 1.22/include/linux/xfrm.h	2004-07-03 20:12:21 +10:00
+++ edited/include/linux/xfrm.h	2004-07-03 20:25:50 +10:00
@@ -135,6 +135,11 @@
 	XFRM_MSG_POLEXPIRE,
 #define XFRM_MSG_POLEXPIRE XFRM_MSG_POLEXPIRE
 
+	XFRM_MSG_FLUSHSA,
+#define XFRM_MSG_FLUSHSA XFRM_MSG_FLUSHSA
+	XFRM_MSG_FLUSHPOLICY,
+#define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FLUSHPOLICY
+
 	XFRM_MSG_MAX
 };
 
@@ -240,6 +245,10 @@
 struct xfrm_user_polexpire {
 	struct xfrm_userpolicy_info	pol;
 	__u8				hard;
+};
+
+struct xfrm_usersa_flush {
+	__u8				proto;
 };
 
 #define XFRMGRP_ACQUIRE		1
===== net/xfrm/xfrm_user.c 1.44 vs edited =====
--- 1.44/net/xfrm/xfrm_user.c	2004-06-28 19:34:34 +10:00
+++ edited/net/xfrm/xfrm_user.c	2004-07-06 19:34:17 +10:00
@@ -814,6 +814,20 @@
 	return err;
 }
 
+static int xfrm_flush_sa(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+{
+	struct xfrm_usersa_flush *p = NLMSG_DATA(nlh);
+
+	xfrm_state_flush(p->proto);
+	return 0;
+}
+
+static int xfrm_flush_policy(struct sk_buff *skb, struct nlmsghdr *nlh, void **xfrma)
+{
+	xfrm_policy_flush();
+	return 0;
+}
+
 static const int xfrm_msg_min[(XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)] = {
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* NEW SA */
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_id)),	/* DEL SA */
@@ -826,6 +840,9 @@
 	NLMSG_LENGTH(sizeof(struct xfrm_user_expire)),	/* EXPIRE */
 	NLMSG_LENGTH(sizeof(struct xfrm_userpolicy_info)),/* UPD POLICY */
 	NLMSG_LENGTH(sizeof(struct xfrm_usersa_info)),	/* UPD SA */
+	NLMSG_LENGTH(sizeof(struct xfrm_user_polexpire)), /* POLEXPIRE */
+	NLMSG_LENGTH(sizeof(struct xfrm_usersa_flush)),	/* FLUSH SA */
+	NLMSG_LENGTH(0),				/* FLUSH POLICY */
 };
 
 static struct xfrm_link {
@@ -849,6 +866,9 @@
 	{},
 	{	.doit	=	xfrm_add_policy 	},
 	{	.doit	=	xfrm_add_sa, 		},
+	{},
+	{	.doit	=	xfrm_flush_sa		},
+	{	.doit	=	xfrm_flush_policy	},
 };
 
 static int xfrm_done(struct netlink_callback *cb)

--J/dobhs11T7y2rNN--
