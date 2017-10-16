From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] netlink: fix netlink_ack() extack race
Date: Mon, 16 Oct 2017 17:09:53 +0200
Message-ID: <20171016150953.17612-1-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.63.242]:46262 "EHLO
        sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752824AbdJPPJ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

It seems that it's possible to toggle NETLINK_F_EXT_ACK
through setsockopt() while another thread/CPU is building
a message inside netlink_ack(), which could then trigger
the WARN_ON()s I added since if it goes from being turned
off to being turned on between allocating and filling the
message, the skb could end up being too small.

Avoid this whole situation by storing the value of this
flag in a separate variable and using that throughout the
function instead.

Fixes: 2d4bc93368f5 ("netlink: extended ACK reporting")
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/netlink/af_netlink.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 336d9c6dcad9..767c84e10e20 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2307,6 +2307,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	size_t tlvlen = 0;
 	struct netlink_sock *nlk = nlk_sk(NETLINK_CB(in_skb).sk);
 	unsigned int flags = 0;
+	bool nlk_has_extack = nlk->flags & NETLINK_F_EXT_ACK;
 
 	/* Error messages get the original request appened, unless the user
 	 * requests to cap the error message, and get extra error data if
@@ -2317,7 +2318,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 			payload += nlmsg_len(nlh);
 		else
 			flags |= NLM_F_CAPPED;
-		if (nlk->flags & NETLINK_F_EXT_ACK && extack) {
+		if (nlk_has_extack && extack) {
 			if (extack->_msg)
 				tlvlen += nla_total_size(strlen(extack->_msg) + 1);
 			if (extack->bad_attr)
@@ -2326,8 +2327,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	} else {
 		flags |= NLM_F_CAPPED;
 
-		if (nlk->flags & NETLINK_F_EXT_ACK &&
-		    extack && extack->cookie_len)
+		if (nlk_has_extack && extack && extack->cookie_len)
 			tlvlen += nla_total_size(extack->cookie_len);
 	}
 
@@ -2347,7 +2347,7 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	errmsg->error = err;
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
 
-	if (nlk->flags & NETLINK_F_EXT_ACK && extack) {
+	if (nlk_has_extack && extack) {
 		if (err) {
 			if (extack->_msg)
 				WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
-- 
2.14.2
