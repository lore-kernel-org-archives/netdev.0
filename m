From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH 1/6][NET][2.6] split arp_send into arp_create and arp_xmit
Date: Thu, 22 Jan 2004 17:59:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401221759.34877.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, bonding-devel@lists.sourceforge.net
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Enable intermediate network drivers like bonding to create an ARP
packet and modify it to their needs before sending it, while avoiding
code duplication. It does not affect any other place in the kernel
that uses arp_send.


diff -Nuarp a/include/net/arp.h b/include/net/arp.h
--- a/include/net/arp.h	Wed Jan 21 16:56:05 2004
+++ b/include/net/arp.h	Wed Jan 21 16:56:07 2004
@@ -5,6 +5,8 @@
 #include <linux/if_arp.h>
 #include <net/neighbour.h>
 
+#define HAVE_ARP_CREATE
+
 extern struct neigh_table arp_tbl;
 
 extern void	arp_init(void);
@@ -19,6 +21,12 @@ extern int	arp_bind_neighbour(struct dst
 extern int	arp_mc_map(u32 addr, u8 *haddr, struct net_device *dev, int dir);
 extern void	arp_ifdown(struct net_device *dev);
 
+extern struct sk_buff *arp_create(int type, int ptype, u32 dest_ip,
+				  struct net_device *dev, u32 src_ip,
+				  unsigned char *dest_hw, unsigned char *src_hw,
+				  unsigned char *target_hw);
+extern void arp_xmit(struct sk_buff *skb);
+
 extern struct neigh_ops arp_broken_ops;
 
 #endif	/* _ARP_H */
diff -Nuarp a/net/ipv4/arp.c b/net/ipv4/arp.c
--- a/net/ipv4/arp.c	Wed Jan 21 16:56:05 2004
+++ b/net/ipv4/arp.c	Wed Jan 21 16:56:07 2004
@@ -67,6 +67,10 @@
  *					now it is in net/core/neighbour.c.
  *		Krzysztof Halasa:	Added Frame Relay ARP support.
  *		Arnaldo C. Melo :	convert /proc/net/arp to seq_file
+ *		Shmulik Hen:		Split arp_send to arp_create and
+ *					arp_xmit so intermediate drivers like
+ *					bonding can change the skb before
+ *					sending (e.g. insert 8021q tag).
  */
 
 #include <linux/module.h>
@@ -487,34 +491,26 @@ static inline int arp_fwd_proxy(struct i
  */
 
 /*
- *	Create and send an arp packet. If (dest_hw == NULL), we create a broadcast
+ *	Create an arp packet. If (dest_hw == NULL), we create a broadcast
  *	message.
  */
-
-void arp_send(int type, int ptype, u32 dest_ip, 
-	      struct net_device *dev, u32 src_ip, 
-	      unsigned char *dest_hw, unsigned char *src_hw,
-	      unsigned char *target_hw)
+struct sk_buff *arp_create(int type, int ptype, u32 dest_ip,
+			   struct net_device *dev, u32 src_ip,
+			   unsigned char *dest_hw, unsigned char *src_hw,
+			   unsigned char *target_hw)
 {
 	struct sk_buff *skb;
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
 
 	/*
-	 *	No arp on this interface.
-	 */
-	
-	if (dev->flags&IFF_NOARP)
-		return;
-
-	/*
 	 *	Allocate a buffer
 	 */
 	
 	skb = alloc_skb(sizeof(struct arphdr)+ 2*(dev->addr_len+4)
 				+ LL_RESERVED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
-		return;
+		return NULL;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb->nh.raw = skb->data;
@@ -594,12 +590,46 @@ void arp_send(int type, int ptype, u32 d
 	arp_ptr+=dev->addr_len;
 	memcpy(arp_ptr, &dest_ip, 4);
 
-	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NF_ARP, NF_ARP_OUT, skb, NULL, dev, dev_queue_xmit);
-	return;
+	return skb;
 
 out:
 	kfree_skb(skb);
+	return NULL;
+}
+
+/*
+ *	Send an arp packet.
+ */
+void arp_xmit(struct sk_buff *skb)
+{
+	/* Send it off, maybe filter it using firewalling first.  */
+	NF_HOOK(NF_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
+}
+
+/*
+ *	Create and send an arp packet.
+ */
+void arp_send(int type, int ptype, u32 dest_ip, 
+	      struct net_device *dev, u32 src_ip, 
+	      unsigned char *dest_hw, unsigned char *src_hw,
+	      unsigned char *target_hw)
+{
+	struct sk_buff *skb;
+
+	/*
+	 *	No arp on this interface.
+	 */
+	
+	if (dev->flags&IFF_NOARP)
+		return;
+
+	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
+			 dest_hw, src_hw, target_hw);
+	if (skb == NULL) {
+		return;
+	}
+
+	arp_xmit(skb);
 }
 
 static void parp_redo(struct sk_buff *skb)
@@ -1437,6 +1467,8 @@ static int __init arp_proc_init(void)
 EXPORT_SYMBOL(arp_broken_ops);
 EXPORT_SYMBOL(arp_find);
 EXPORT_SYMBOL(arp_rcv);
+EXPORT_SYMBOL(arp_create);
+EXPORT_SYMBOL(arp_xmit);
 EXPORT_SYMBOL(arp_send);
 EXPORT_SYMBOL(arp_tbl);
 
