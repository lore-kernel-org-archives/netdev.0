From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 3/5] netlink: allow sending extended ACK with cookie on success
Date: Sat,  8 Apr 2017 19:48:58 +0200
Message-ID: <20170408174900.12820-4-johannes@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408174900.12820-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Now that we have extended error reporting and a new message format
for netlink ACK messages, also extend this to be able to return
arbitrary cookie data on success.

This will allow, for example, nl80211 to not send an extra message
for cookies identifying newly created objects, but return those
directly in the ACK message.

The cookie data size is currently limited to 32 bytes (since Jamal
talked about using SHA1 for identifiers.)

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/netlink.h      |  3 +++
 include/uapi/linux/netlink.h |  4 ++++
 net/netlink/af_netlink.c     | 38 ++++++++++++++++++++++++--------------
 3 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 47562e940e9c..2133353b9a30 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -62,6 +62,9 @@ netlink_kernel_create(struct net *net, int unit, struct netlink_kernel_cfg *cfg)
 	return __netlink_kernel_create(net, unit, THIS_MODULE, cfg);
 }
 
+/* this can be increased when necessary - don't expose to userland */
+#define NETLINK_MAX_COOKIE_LEN	32
+
 /**
  * struct netlink_ext_ack - netlink extended ACK report struct
  * @_msg: message string to report - don't access directly, use
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index d1564557d645..7892095b1a16 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -118,12 +118,16 @@ struct nlmsgerr {
  * @NLMSGERR_ATTR_OFFS: error offset in the original message (u32)
  * @NLMSGERR_ATTR_ATTR: top-level attribute that caused the error
  *	(or is missing, u16)
+ * @NLMSGERR_ATTR_COOKIE: arbitrary subsystem specific cookie to
+ *	be used - in the success case - to identify a created
+ *	object or operation or similar (binary)
  */
 enum nlmsgerr_attrs {
 	NLMSGERR_ATTR_UNUSED,
 	NLMSGERR_ATTR_MSG,
 	NLMSGERR_ATTR_OFFS,
 	NLMSGERR_ATTR_ATTR,
+	NLMSGERR_ATTR_COOKIE,
 };
 
 #define NETLINK_ADD_MEMBERSHIP		1
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 02cffb0a3904..bc1c9e8dd7ef 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2312,6 +2312,9 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 			    (extack->missing_attr || extack->bad_attr))
 				acksize += nla_total_size(sizeof(u16));
 		}
+	} else if (nlk->flags & NETLINK_F_EXT_ACK) {
+		if (extack && extack->cookie_len)
+			acksize += nla_total_size(extack->cookie_len);
 	}
 
 	skb = nlmsg_new(acksize, GFP_KERNEL);
@@ -2337,20 +2340,27 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	       !(nlk->flags & NETLINK_F_CAP_ACK) ? nlh->nlmsg_len
 						 : sizeof(*nlh));
 
-	if (err && nlk->flags & NETLINK_F_EXT_ACK) {
-		if (extack && extack->_msg)
-			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
-					       extack->_msg));
-		if (extack && extack->bad_attr &&
-		    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
-			     (u8 *)extack->bad_attr >= in_skb->data +
-						       in_skb->len))
-			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
-					    (u8 *)extack->bad_attr -
-					    in_skb->data));
-		if (extack && extack->missing_attr)
-			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
-					    extack->missing_attr));
+	if (nlk->flags & NETLINK_F_EXT_ACK) {
+		if (err) {
+			if (extack && extack->_msg)
+				WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
+						       extack->_msg));
+			if (extack && extack->bad_attr &&
+			    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
+				     (u8 *)extack->bad_attr >= in_skb->data +
+							       in_skb->len))
+				WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
+						    (u8 *)extack->bad_attr -
+						    in_skb->data));
+			if (extack && extack->missing_attr)
+				WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
+						    extack->missing_attr));
+		} else {
+			if (extack && extack->cookie_len)
+				WARN_ON(nla_put(skb, NLMSGERR_ATTR_COOKIE,
+						extack->cookie_len,
+						extack->cookie));
+		}
 	}
 
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
-- 
2.11.0
