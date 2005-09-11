From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH 12/12] Introduct stuct nr_private
Date: Sun, 11 Sep 2005 23:19:37 +0100
Message-ID: <20050911221937.GA9343@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET/ROM's virtual interfaces don't have a proper private data structure
yet.  Create struct nr_private and put the statistics there.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/netrom.h   |    5 +++++
 net/netrom/af_netrom.c |    3 +--
 net/netrom/nr_dev.c    |   11 ++++++-----
 3 files changed, 12 insertions(+), 7 deletions(-)

Index: net-2.6.git/include/net/netrom.h
===================================================================
--- net-2.6.git.orig/include/net/netrom.h
+++ net-2.6.git/include/net/netrom.h
@@ -6,6 +6,7 @@
 
 #ifndef _NETROM_H
 #define _NETROM_H 
+
 #include <linux/netrom.h>
 #include <linux/list.h>
 #include <net/sock.h>
@@ -58,6 +59,10 @@ enum {
 #define NR_MAX_WINDOW_SIZE		127			/* Maximum Window Allowable - 127 */
 #define	NR_MAX_PACKET_SIZE		236			/* Maximum Packet Length - 236 */
 
+struct nr_private {
+	struct net_device_stats	stats;
+};
+
 struct nr_sock {
 	struct sock		sock;
 	ax25_address		user_addr, source_addr, dest_addr;
Index: net-2.6.git/net/netrom/af_netrom.c
===================================================================
--- net-2.6.git.orig/net/netrom/af_netrom.c
+++ net-2.6.git/net/netrom/af_netrom.c
@@ -1392,8 +1392,7 @@ static int __init nr_proto_init(void)
 		struct net_device *dev;
 
 		sprintf(name, "nr%d", i);
-		dev = alloc_netdev(sizeof(struct net_device_stats), name,
-					  nr_setup);
+		dev = alloc_netdev(sizeof(struct nr_private), name, nr_setup);
 		if (!dev) {
 			printk(KERN_ERR "NET/ROM: nr_proto_init - unable to allocate device structure\n");
 			goto fail;
Index: net-2.6.git/net/netrom/nr_dev.c
===================================================================
--- net-2.6.git.orig/net/netrom/nr_dev.c
+++ net-2.6.git/net/netrom/nr_dev.c
@@ -153,10 +153,9 @@ static int nr_close(struct net_device *d
 
 static int nr_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = netdev_priv(dev);
-	unsigned int len;
-
-	len = skb->len;
+	struct nr_private *nr = netdev_priv(dev);
+	struct net_device_stats *stats = &nr->stats;
+	unsigned int len = skb->len;
 
 	if (!nr_route_frame(skb, NULL)) {
 		kfree_skb(skb);
@@ -172,7 +171,9 @@ static int nr_xmit(struct sk_buff *skb, 
 
 static struct net_device_stats *nr_get_stats(struct net_device *dev)
 {
-	return netdev_priv(dev);
+	struct nr_private *nr = netdev_priv(dev);
+
+	return &nr->stats;
 }
 
 void nr_setup(struct net_device *dev)
