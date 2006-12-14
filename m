From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 6/7] Fix unchecked rose_add_loopback_node uses
Date: Thu, 14 Dec 2006 23:42:12 +0100
Message-ID: <11661361354109-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:47091 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791AbWLNXOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:14:43 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/rose/rose_dev.c |   22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

Index: linux-net/net/rose/rose_dev.c
===================================================================
--- linux-net.orig/net/rose/rose_dev.c
+++ linux-net/net/rose/rose_dev.c
@@ -93,20 +93,34 @@ static int rose_rebuild_header(struct sk
 static int rose_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
+	int err;
 
-	rose_del_loopback_node((rose_address *)dev->dev_addr);
+	if (!memcpy(dev->dev_addr, sa->sa_data, dev->addr_len))
+		return 0;
 
-	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+	if (dev->flags & IFF_UP) {
+		err = rose_add_loopback_node((rose_address *)dev->dev_addr);
+		if (err)
+			return err;
+
+		rose_del_loopback_node((rose_address *)dev->dev_addr);
+	}
 
-	rose_add_loopback_node((rose_address *)dev->dev_addr);
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 
 	return 0;
 }
 
 static int rose_open(struct net_device *dev)
 {
+	int err;
+
+	err = rose_add_loopback_node((rose_address *)dev->dev_addr);
+	if (err)
+		return err;
+
 	netif_start_queue(dev);
-	rose_add_loopback_node((rose_address *)dev->dev_addr);
+
 	return 0;
 }
 
