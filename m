From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] netlink: send exterr cookie on success
Date: Fri,  7 Apr 2017 21:44:02 +0200
Message-ID: <20170407194402.4181-1-johannes@sipsolutions.net>
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This is for Jamal, it allows the subsystem to return an arbitrary
cookie to identify a new object/operation, perhaps to delete or
cancel it later.

This is actually something we use a lot in wifi too, though I'm
not sure how we could do the backport necessary for that (since
we sadly need to ship to all kinds of old kernels)

Also contains the missing (err) check I pointed out - I'll squash
this patch into the first of the exterr after I test it.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/netlink.h      |  2 ++
 include/uapi/linux/netlink.h |  4 ++++
 net/netlink/af_netlink.c     | 28 +++++++++++++++++++---------
 3 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 662f343dc68b..76a0b0a22349 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -67,6 +67,8 @@ struct netlink_ext_err {
 	u32 ext_code;
 	u32 msg_offset;
 	u16 attr;
+	const u8 *cookie;
+	u8 cookie_len;
 };
 
 extern void netlink_kernel_release(struct sock *sk);
diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index 0ef970e6f9f5..72a398e0f332 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -119,6 +119,9 @@ struct nlmsgerr {
  * @NLMSGERR_ATTR_CODE: extended per-subsystem error code (u32)
  * @NLMSGERR_ATTR_ATTR: top-level attribute that caused the error
  *	(or is missing, u16)
+ * @NLMSGERR_ATTR_COOKIE: arbitrary subsystem specific cookie to
+ *	be used - in the success case - to identify a created
+ *	object or operation or similar (binary)
  */
 enum nlmsgerr_attrs {
 	NLMSGERR_ATTR_UNUSED,
@@ -126,6 +129,7 @@ enum nlmsgerr_attrs {
 	NLMSGERR_ATTR_OFFS,
 	NLMSGERR_ATTR_CODE,
 	NLMSGERR_ATTR_ATTR,
+	NLMSGERR_ATTR_COOKIE,
 };
 
 #define NETLINK_ADD_MEMBERSHIP		1
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 532d906af3be..6b256e540bc1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2277,6 +2277,9 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 			if (exterr && exterr->attr)
 				payload += nla_total_size(sizeof(u16));
 		}
+	} else if (nlk->flags & NETLINK_F_EXT_ACK) {
+		if (exterr && exterr->cookie_len)
+			payload += nla_total_size(exterr->cookie_len);
 	}
 
 	skb = nlmsg_new(payload, GFP_KERNEL);
@@ -2301,15 +2304,22 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
 
 	if (nlk->flags & NETLINK_F_EXT_ACK) {
-		if (exterr && exterr->msg)
-			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
-					       exterr->msg));
-		if (exterr && exterr->msg_offset)
-			WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
-					    exterr->msg_offset));
-		if (exterr && exterr->attr)
-			WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
-					    exterr->attr));
+		if (err) {
+			if (exterr && exterr->msg)
+				WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
+						       exterr->msg));
+			if (exterr && exterr->msg_offset)
+				WARN_ON(nla_put_u32(skb, NLMSGERR_ATTR_OFFS,
+						    exterr->msg_offset));
+			if (exterr && exterr->attr)
+				WARN_ON(nla_put_u16(skb, NLMSGERR_ATTR_ATTR,
+						    exterr->attr));
+		} else {
+			if (exterr && exterr->attr)
+				WARN_ON(nla_put(skb, NLMSGERR_ATTR_COOKIE,
+						exterr->cookie_len,
+						exterr->cookie));
+		}
 	}
 
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
-- 
2.11.0
