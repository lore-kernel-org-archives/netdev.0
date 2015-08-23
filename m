From: Christophe Ricard <christophe.ricard@gmail.com>
Subject: [RFC] netlink: netlink_ack send a capped message in case of error
Date: Mon, 24 Aug 2015 00:06:17 +0200
Message-ID: <1440367577-15786-2-git-send-email-christophe-h.ricard@st.com>
References: <1440367577-15786-1-git-send-email-christophe-h.ricard@st.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Christophe Ricard <christophe-h.ricard@st.com>
To: pablo@netfilter.org, jbenc@redhat.com, sameo@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37875 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbbHWWGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 18:06:24 -0400
Received: by widdq5 with SMTP id dq5so56467401wid.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 15:06:23 -0700 (PDT)
In-Reply-To: <1440367577-15786-1-git-send-email-christophe-h.ricard@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ACK in case of error contains a full copy of the originating
message. This can cause lost ACKs with large netlink messages, especially
after commit c05cdb1b864f ("netlink: allow large data transfers from
user-space").

Send back a capped message instead.

Signed-off-by: Christophe Ricard <christophe-h.ricard@st.com>
---
 net/netlink/af_netlink.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 67d2104..9df862c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -85,6 +85,9 @@ struct listeners {
 #define NETLINK_F_RECV_NO_ENOBUFS	0x8
 #define NETLINK_F_LISTEN_ALL_NSID	0x10
 
+/* Arbitrary value for a small message less than PAGE_SIZE */
+#define NETLINK_ERR_MESSAGE_CAP	128
+
 static inline int netlink_is_kernel(struct sock *sk)
 {
 	return nlk_sk(sk)->flags & NETLINK_F_KERNEL_SOCKET;
@@ -2873,10 +2876,15 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 	struct nlmsghdr *rep;
 	struct nlmsgerr *errmsg;
 	size_t payload = sizeof(*errmsg);
+	size_t size = 0;
 
-	/* error messages get the original request appened */
-	if (err)
-		payload += nlmsg_len(nlh);
+	/* error messages get a cap request appened */
+	if (err) {
+		payload += nlmsg_len(nlh) > NETLINK_ERR_MESSAGE_CAP ?
+			   NETLINK_ERR_MESSAGE_CAP : nlmsg_len(nlh);
+		size = nlmsg_len(nlh) > NETLINK_ERR_MESSAGE_CAP ?
+		      (NETLINK_ERR_MESSAGE_CAP + NLMSG_HDRLEN) : nlh->nlmsg_len;
+	}
 
 	skb = netlink_alloc_skb(in_skb->sk, nlmsg_total_size(payload),
 				NETLINK_CB(in_skb).portid, GFP_KERNEL);
@@ -2898,7 +2906,8 @@ void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err)
 			  NLMSG_ERROR, payload, 0);
 	errmsg = nlmsg_data(rep);
 	errmsg->error = err;
-	memcpy(&errmsg->msg, nlh, err ? nlh->nlmsg_len : sizeof(*nlh));
+
+	memcpy(&errmsg->msg, nlh, err ? size : sizeof(*nlh));
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).portid, MSG_DONTWAIT);
 }
 EXPORT_SYMBOL(netlink_ack);
-- 
2.1.4
