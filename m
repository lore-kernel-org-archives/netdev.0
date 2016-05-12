From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net-next] gtp: put back reference to netns when not required anymore
Date: Thu, 12 May 2016 17:16:31 +0200
Message-ID: <1463066191-20748-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42591 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbcELPQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 11:16:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C52FA13C0DE
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 17:16:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B4E982687C2
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 17:16:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id B7C172687C2
	for <netdev@vger.kernel.org>; Thu, 12 May 2016 17:16:39 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a netns leak.

Fixes: 93edb8c7f94f ("gtp: reload GTPv1 header after pskb_may_pull()")
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 drivers/net/gtp.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index f7caf1e..4e976a0 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1028,8 +1028,11 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL)
+	if (dev == NULL) {
+		put_net(net);
 		return -ENODEV;
+	}
+	put_net(net);
 
 	return ipv4_pdp_add(dev, info);
 }
@@ -1051,8 +1054,11 @@ static int gtp_genl_del_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL)
+	if (dev == NULL) {
+		put_net(net);
 		return -ENODEV;
+	}
+	put_net(net);
 
 	gtp = netdev_priv(dev);
 
@@ -1163,8 +1169,11 @@ static int gtp_genl_get_pdp(struct sk_buff *skb, struct genl_info *info)
 
 	/* Check if there's an existing gtpX device to configure */
 	dev = gtp_find_dev(net, nla_get_u32(info->attrs[GTPA_LINK]));
-	if (dev == NULL)
+	if (dev == NULL) {
+		put_net(net);
 		return -ENODEV;
+	}
+	put_net(net);
 
 	gtp = netdev_priv(dev);
 
-- 
2.1.4
