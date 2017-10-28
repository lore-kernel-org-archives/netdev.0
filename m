From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 1/3] netlink: Allow ext_ack to carry non-error messages
Date: Fri, 27 Oct 2017 17:37:12 -0700
Message-ID: <1509151034-28278-2-git-send-email-dsahern@gmail.com>
References: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com, johannes.berg@intel.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:55719 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751380AbdJ1AhX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:37:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id 17so6029514pfn.12
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:37:23 -0700 (PDT)
In-Reply-To: <1509151034-28278-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NLMSGERR API already carries data (eg, a cookie) on the success path.
Allow a message string to be returned as well.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/netlink/af_netlink.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 767c84e10e20..26ded4239611 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2313,17 +2313,16 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	 * requests to cap the error message, and get extra error data if
 	 * requested.
 	 */
+	if (nlk_has_extack && extack && extack->_msg)
+		tlvlen += nla_total_size(strlen(extack->_msg) + 1);
+
 	if (err) {
 		if (!(nlk->flags & NETLINK_F_CAP_ACK))
 			payload += nlmsg_len(nlh);
 		else
 			flags |= NLM_F_CAPPED;
-		if (nlk_has_extack && extack) {
-			if (extack->_msg)
-				tlvlen += nla_total_size(strlen(extack->_msg) + 1);
-			if (extack->bad_attr)
-				tlvlen += nla_total_size(sizeof(u32));
-		}
+		if (nlk_has_extack && extack && extack->bad_attr)
+			tlvlen += nla_total_size(sizeof(u32));
 	} else {
 		flags |= NLM_F_CAPPED;
 
@@ -2348,10 +2347,11 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err,
 	memcpy(&errmsg->msg, nlh, payload > sizeof(*errmsg) ? nlh->nlmsg_len : sizeof(*nlh));
 
 	if (nlk_has_extack && extack) {
+		if (extack->_msg) {
+			WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
+					       extack->_msg));
+		}
 		if (err) {
-			if (extack->_msg)
-				WARN_ON(nla_put_string(skb, NLMSGERR_ATTR_MSG,
-						       extack->_msg));
 			if (extack->bad_attr &&
 			    !WARN_ON((u8 *)extack->bad_attr < in_skb->data ||
 				     (u8 *)extack->bad_attr >= in_skb->data +
-- 
2.1.4
