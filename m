From: jamal <hadi@cyberus.ca>
Subject: RFC: IPSEC patch 0 for netlink events
Date: 26 Mar 2005 14:22:51 -0500
Message-ID: <1111864971.1092.904.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-xsC9sMkxzwA3vZ2+ptU5"
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        Patrick McHardy <kaber@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-xsC9sMkxzwA3vZ2+ptU5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Folks,

first patch that changes internal api slightly to allow for next
patch which will add other events. It includes the other acquire patch i
posted earlier - please ignore that - Or if you like this patch use it
instead.
This patch also adds a few new groups.

I am dependent on this before going to next steps so please comment
if you can - the patch is very small

cheers,
jamal

--=-xsC9sMkxzwA3vZ2+ptU5
Content-Disposition: attachment; filename=ipsec_p0
Content-Type: text/plain; name=ipsec_p0; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/include/linux/xfrm.h	2005/03/26 18:30:26	1.1
+++ b/include/linux/xfrm.h	2005/03/26 18:47:48
@@ -254,5 +254,8 @@
 
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
+#define XFRMGRP_POLEXPIRE	4
+#define XFRMGRP_SA		8
+#define XFRMGRP_POLICY		0x10
 
 #endif /* _LINUX_XFRM_H */
--- a/include/net/xfrm.h	2005/03/26 17:04:48	1.1
+++ b/include/net/xfrm.h	2005/03/26 18:28:47
@@ -157,6 +157,18 @@
 	XFRM_STATE_DEAD
 };
 
+/* events that could be sent by kernel */
+enum {
+	XFRM_SA_INVALID,
+	XFRM_SA_EXPIRED,
+	XFRM_SA_ADDED,
+	XFRM_SA_UPDATED,
+	XFRM_SA_DELETED,
+	XFRM_SA_FLUSHED,
+	__XFRM_SA_MAX
+};
+
+#define XFRM_SA_MAX (__XFRM_SA_MAX - 1)
 struct xfrm_type;
 struct xfrm_dst;
 struct xfrm_policy_afinfo {
@@ -289,7 +301,7 @@
 {
 	struct list_head	list;
 	char			*id;
-	int			(*notify)(struct xfrm_state *x, int event);
+	int			(*notify)(struct xfrm_state *x, int event, int cb_id);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp, int dir);
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
--- a/net/xfrm/xfrm_state.c	2005-03-19 01:35:00.000000000 -0500
+++ b/net/xfrm/xfrm_state.c	2005-03-26 13:22:34.000000000 -0500
@@ -778,23 +778,27 @@
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list)
-		km->notify(x, hard);
+		km->notify(x, XFRM_SA_EXPIRED, hard);
 	read_unlock(&xfrm_km_lock);
 
 	if (hard)
 		wake_up(&km_waitq);
 }
 
+/*
+ * We send to all registered managers regardless of failure
+ * We are happy with one success
+*/
 static int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol)
 {
-	int err = -EINVAL;
+	int err = -EINVAL, acqret = -EINVAL;
 	struct xfrm_mgr *km;
 
 	read_lock(&xfrm_km_lock);
 	list_for_each_entry(km, &xfrm_km_list, list) {
-		err = km->acquire(x, t, pol, XFRM_POLICY_OUT);
-		if (!err)
-			break;
+		acqret = km->acquire(x, t, pol, XFRM_POLICY_OUT);
+		if (!acqret)
+			err = acqret;
 	}
 	read_unlock(&xfrm_km_lock);
 	return err;
--- a/net/xfrm/xfrm_user.c	2005/03/26 17:02:39	1.1
+++ b/net/xfrm/xfrm_user.c	2005/03/26 17:22:06
@@ -1053,7 +1053,7 @@
 	return -1;
 }
 
-static int xfrm_send_state_notify(struct xfrm_state *x, int hard)
+static int xfrm_send_state_notify(struct xfrm_state *x, int event, int cb_id)
 {
 	struct sk_buff *skb;
 
@@ -1061,7 +1061,10 @@
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_expire(skb, x, hard) < 0)
+	if (event != XFRM_SA_EXPIRED)
+		return 0;
+
+	if (build_expire(skb, x, cb_id) < 0)
 		BUG();
 
 	NETLINK_CB(skb).dst_groups = XFRMGRP_EXPIRE;
--- a/net/key/af_key.c	2005-03-19 01:35:06.000000000 -0500
+++ b/net/key/af_key.c	2005-03-26 12:20:19.000000000 -0500
@@ -2317,12 +2317,20 @@
 	}
 }
 
-static int pfkey_send_notify(struct xfrm_state *x, int hard)
+static int pfkey_send_notify(struct xfrm_state *x, int event, int cb_id)
 {
 	struct sk_buff *out_skb;
 	struct sadb_msg *out_hdr;
+	int hard = cb_id;
 	int hsc = (hard ? 2 : 1);
 
+	/* 
+	 * migrate pf_key later - for now only support is for
+	 * expire events 
+	*/
+	if (event != XFRM_SA_EXPIRED)
+		return 0; 
+
 	out_skb = pfkey_xfrm_state2msg(x, 0, hsc);
 	if (IS_ERR(out_skb))
 		return PTR_ERR(out_skb);

--=-xsC9sMkxzwA3vZ2+ptU5--
