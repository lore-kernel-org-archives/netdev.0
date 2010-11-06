From: Guillaume Chazarain <guichaz@gmail.com>
Subject: [PATCH 2/2] net: Detect and ignore netif_stop_queue() calls before register_netdev()
Date: Sat,  6 Nov 2010 17:39:32 +0100
Message-ID: <1289061572-5029-2-git-send-email-guichaz@gmail.com>
References: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
Cc: Guillaume Chazarain <guichaz@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55355 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897Ab0KFQjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 12:39:55 -0400
Received: by wwb39 with SMTP id 39so2454387wwb.1
        for <netdev@vger.kernel.org>; Sat, 06 Nov 2010 09:39:54 -0700 (PDT)
In-Reply-To: <1289061572-5029-1-git-send-email-guichaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After e6484930d7c73d324bccda7d43d131088da697b9: net: allocate tx queues in register_netdevice
These calls make net drivers oops at load time, so let's avoid people
git-bisect'ing known problems.

Signed-off-by: Guillaume Chazarain <guichaz@gmail.com>
---
 include/linux/netdevice.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 072652d..d8fd2c2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1554,6 +1554,11 @@ static inline void netif_tx_wake_all_queues(struct net_device *dev)
 
 static inline void netif_tx_stop_queue(struct netdev_queue *dev_queue)
 {
+	if (WARN_ON(!dev_queue)) {
+		printk(KERN_INFO "netif_stop_queue() cannot be called before "
+		       "register_netdev()");
+		return;
+	}
 	set_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
 }
 
-- 
1.7.1

