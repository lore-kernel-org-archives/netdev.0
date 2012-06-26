From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Subject: [PATCH 1/1] connector: use nlmsg_put() instead of NLMSG_PUT() macro.
Date: Tue, 26 Jun 2012 17:41:24 +0200
Message-ID: <1340725284-21698-1-git-send-email-javier.martinez@collabora.co.uk>
Cc: netdev@vger.kernel.org,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.135.160]:37303 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756880Ab2FZPtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 11:49:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NLMSG_PUT() macro contains a hidden goto which makes the code hard
to audit and very error prone.

While been there also use the inline function nlmsg_data() instead of the
NLMSG_DATA() macro to do explicit type checking.

Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
---
 drivers/connector/connector.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index a1f9364..a728d33 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -101,19 +101,19 @@ int cn_netlink_send(struct cn_msg *msg, u32 __group, gfp_t gfp_mask)
 	if (!skb)
 		return -ENOMEM;
 
-	nlh = NLMSG_PUT(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh));
+	nlh = nlmsg_put(skb, 0, msg->seq, NLMSG_DONE, size - sizeof(*nlh), 0);
+	if (!nlh) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
 
-	data = NLMSG_DATA(nlh);
+	data = nlmsg_data(nlh);
 
 	memcpy(data, msg, sizeof(*data) + msg->len);
 
 	NETLINK_CB(skb).dst_group = group;
 
 	return netlink_broadcast(dev->nls, skb, 0, group, gfp_mask);
-
-nlmsg_failure:
-	kfree_skb(skb);
-	return -EINVAL;
 }
 EXPORT_SYMBOL_GPL(cn_netlink_send);
 
-- 
1.7.7.6
