From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 2/4] connector: use nlmsg_len() to check message length
Date: Mon, 30 Sep 2013 22:03:07 +0200
Message-ID: <1380571389-15343-3-git-send-email-minipli@googlemail.com>
References: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:33191 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756402Ab3I3UD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 16:03:28 -0400
Received: by mail-bk0-f50.google.com with SMTP id mz11so2321175bkb.9
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 13:03:26 -0700 (PDT)
In-Reply-To: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code tests the length of the whole netlink message to be
at least as long to fit a cn_msg. This is wrong as nlmsg_len includes
the length of the netlink message header. Use nlmsg_len() instead to
fix this "off-by-NLMSG_HDRLEN" size check.

Cc: stable@vger.kernel.org  # v2.6.14+
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 drivers/connector/connector.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 6ecfa75..0daa11e 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -157,17 +157,18 @@ static int cn_call_callback(struct sk_buff *skb)
 static void cn_rx_skb(struct sk_buff *__skb)
 {
 	struct nlmsghdr *nlh;
-	int err;
 	struct sk_buff *skb;
+	int len, err;
 
 	skb = skb_get(__skb);
 
 	if (skb->len >= NLMSG_HDRLEN) {
 		nlh = nlmsg_hdr(skb);
+		len = nlmsg_len(nlh);
 
-		if (nlh->nlmsg_len < sizeof(struct cn_msg) ||
+		if (len < (int)sizeof(struct cn_msg) ||
 		    skb->len < nlh->nlmsg_len ||
-		    nlh->nlmsg_len > CONNECTOR_MAX_MSG_SIZE) {
+		    len > CONNECTOR_MAX_MSG_SIZE) {
 			kfree_skb(skb);
 			return;
 		}
-- 
1.7.10.4
