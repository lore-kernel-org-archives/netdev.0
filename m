From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: memory leak due to forget to release rx queues
Date: Tue, 23 Mar 2010 14:05:39 +0800
Message-ID: <4BA85A33.6050004@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: xiaosuo <xiaosuo@gmail.com>, Tom Herbert <therbert@google.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:35475 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415Ab0CWGMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:12:05 -0400
Received: by gwaa18 with SMTP id a18so1352067gwa.19
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 23:12:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

memory leak due to forget to release rx queues.

rx queues is allocated in alloc_netdev_mq(), but they aren't released in
free_netdev(), and the field rps_map is also miss.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 8 ++++++++
1 file changed, 8 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index c0e2608..51b86e0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5746,6 +5746,14 @@ void free_netdev(struct net_device *dev)
 
 	release_net(dev_net(dev));
 
+	if (dev->num_rx_queues) {
+		int i;
+
+		for (i = 0; i < dev->num_rx_queues; i++)
+			kfree(dev->_rx[i].rps_map);
+		kfree(dev->_rx);
+	}
+
 	kfree(dev->_tx);
 
 	/* Flush device addresses */


