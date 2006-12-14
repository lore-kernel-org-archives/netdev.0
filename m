From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 3/7] Fix unchecked ax25_listen_register uses
Date: Thu, 14 Dec 2006 23:42:09 +0100
Message-ID: <11661361342916-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix ax25_listen_register to return something that's a sane error code,
then all callers to use it.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/ax25/ax25_iface.c |    7 ++++---
 net/netrom/nr_dev.c   |   24 ++++++++++++++++++------
 net/rose/af_rose.c    |    3 ++-
 3 files changed, 24 insertions(+), 10 deletions(-)

Index: linux-net/net/ax25/ax25_iface.c
===================================================================
--- linux-net.orig/net/ax25/ax25_iface.c
+++ linux-net/net/ax25/ax25_iface.c
@@ -154,7 +154,7 @@ int ax25_listen_register(ax25_address *c
 		return 0;
 
 	if ((listen = kmalloc(sizeof(*listen), GFP_ATOMIC)) == NULL)
-		return 0;
+		return -ENOMEM;
 
 	listen->callsign = *callsign;
 	listen->dev      = dev;
@@ -164,7 +164,7 @@ int ax25_listen_register(ax25_address *c
 	listen_list  = listen;
 	spin_unlock_bh(&listen_lock);
 
-	return 1;
+	return 0;
 }
 
 EXPORT_SYMBOL(ax25_listen_register);
@@ -225,7 +225,8 @@ int ax25_listen_mine(ax25_address *calls
 
 	spin_lock_bh(&listen_lock);
 	for (listen = listen_list; listen != NULL; listen = listen->next)
-		if (ax25cmp(&listen->callsign, callsign) == 0 && (listen->dev == dev || listen->dev == NULL)) {
+		if (ax25cmp(&listen->callsign, callsign) == 0 &&
+		    (listen->dev == dev || listen->dev == NULL)) {
 			spin_unlock_bh(&listen_lock);
 			return 1;
 	}
Index: linux-net/net/netrom/nr_dev.c
===================================================================
--- linux-net.orig/net/netrom/nr_dev.c
+++ linux-net/net/netrom/nr_dev.c
@@ -128,25 +128,37 @@ static int nr_header(struct sk_buff *skb
 	return -37;
 }
 
-static int nr_set_mac_address(struct net_device *dev, void *addr)
+static int __must_check nr_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *sa = addr;
+	int err;
+
+	if (!memcmp(dev->dev_addr, sa->sa_data, dev->addr_len))
+		return 0;
+
+	if (dev->flags & IFF_UP) {
+		err = ax25_listen_register((ax25_address *)sa->sa_data, NULL);
+		if (err)
+			return err;
 
-	if (dev->flags & IFF_UP)
 		ax25_listen_release((ax25_address *)dev->dev_addr, NULL);
+	}
 
 	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
 
-	if (dev->flags & IFF_UP)
-		ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
-
 	return 0;
 }
 
 static int nr_open(struct net_device *dev)
 {
+	int err;
+
+	err = ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
+	if (err)
+		return err;
+
 	netif_start_queue(dev);
-	ax25_listen_register((ax25_address *)dev->dev_addr, NULL);
+
 	return 0;
 }
 
Index: linux-net/net/rose/af_rose.c
===================================================================
--- linux-net.orig/net/rose/af_rose.c
+++ linux-net/net/rose/af_rose.c
@@ -1314,7 +1314,8 @@ static int rose_ioctl(struct socket *soc
 		if (copy_from_user(&rose_callsign, argp, sizeof(ax25_address)))
 			return -EFAULT;
 		if (ax25cmp(&rose_callsign, &null_ax25_address) != 0)
-			ax25_listen_register(&rose_callsign, NULL);
+			return ax25_listen_register(&rose_callsign, NULL);
+
 		return 0;
 
 	case SIOCRSGL2CALL:
