From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.12-rc4] IPv4/IPv6: USO v2, fragment list approach
Date: Thu,  2 Jun 2005 17:43:51 -0700 (PDT)
Message-ID: <20050603004351.41BFB7B990@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached below is version 2 of kernel patch for UDP Large send offload 
feature. This patch uses the "fragment list" approach.
It also incorporates David Miller's comments on the first version.

Also, below is a "how-to" on changes required in network drivers to use
the USO interface.

UDP Large Send Offload (USO) Interface:
--------------------------------------- 

USO is a feature wherein the Linux kernel network stack will offload the 
IP fragmentation functionality of large UDP datagram to hardware. This will 
reduce the overhead of stack in fragmenting the large UDP datagram to MTU 
sized packets. 

1) Drivers indicate their capability of USO using

dev->features |= NETIF_F_USO | NETIF_F_HW_CSUM | NETIF_F_FRAGLIST

NETIF_F_HW_CSUM is required for USO over IPv6.

2) USO packet will be submitted for transmission using driver xmit 
routine. USO packet will have a non zero value for 

"skb_shinfo(skb)->uso_size"

skb_shinfo(skb)->uso_size indicates the length of data part in each IP
fragment going out of the adapter after IP fragmentation by hardware.

skb->data and skb_shinfo(skb)->frag_list will contain complete large 
UDP datagram.
The driver is required to traverse each skb in skb_shinfo(skb)->frag_list 
to get complete UDP packet. The skb->ip_summed will be set to CHECKSUM_HW
indicating that hardware has to perform checksum calculation. Hardware should 
compute the UDP checksum of complete UDP datagram and also ip header checksum 
of each fragmented IP packet.

For IPV6 the USO provides the fragment identification id in
skb_shinfo(skb)->ip6_frag_id. The adapter should use this ID for generating 
IPv6 fragments.

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -uNr linux-2.6.12-rc4.org/include/linux/ethtool.h linux-2.6.12-rc4/include/linux/ethtool.h
--- linux-2.6.12-rc4.org/include/linux/ethtool.h	2005-06-02 16:55:51.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/ethtool.h	2005-06-02 16:56:46.000000000 +0545
@@ -260,6 +260,8 @@
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
+u32 ethtool_op_get_uso(struct net_device *dev);
+int ethtool_op_set_uso(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -289,6 +291,8 @@
  * set_sg: Turn scatter-gather on or off
  * get_tso: Report whether TCP segmentation offload is enabled
  * set_tso: Turn TCP segmentation offload on or off
+ * get_uso: Report whether UDP large send offload is enabled
+ * set_uso: Turn UDP large send offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -353,6 +357,8 @@
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
+	u32	(*get_uso)(struct net_device *);
+	int	(*set_uso)(struct net_device *, u32);
 };
 
 /* CMDs currently supported */
@@ -388,6 +394,8 @@
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_GUSO		0x00000020 /* Get USO enable (ethtool_value) */
+#define ETHTOOL_SUSO		0x00000021 /* Set USO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -uNr linux-2.6.12-rc4.org/include/linux/netdevice.h linux-2.6.12-rc4/include/linux/netdevice.h
--- linux-2.6.12-rc4.org/include/linux/netdevice.h	2005-05-27 23:22:46.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/netdevice.h	2005-05-31 10:02:02.000000000 +0545
@@ -414,6 +414,7 @@
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_USO		8192    /* Can offload UDP Large Send*/
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
diff -uNr linux-2.6.12-rc4.org/include/linux/skbuff.h linux-2.6.12-rc4/include/linux/skbuff.h
--- linux-2.6.12-rc4.org/include/linux/skbuff.h	2005-05-27 23:22:46.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/skbuff.h	2005-06-02 20:27:43.000000000 +0545
@@ -136,6 +136,8 @@
 	unsigned int	nr_frags;
 	unsigned short	tso_size;
 	unsigned short	tso_segs;
+	unsigned short	uso_size;
+	unsigned int	ip6_frag_id;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
diff -uNr linux-2.6.12-rc4.org/net/core/dev.c linux-2.6.12-rc4/net/core/dev.c
--- linux-2.6.12-rc4.org/net/core/dev.c	2005-05-28 01:49:18.000000000 +0545
+++ linux-2.6.12-rc4/net/core/dev.c	2005-05-31 22:57:22.000000000 +0545
@@ -2793,6 +2793,18 @@
 		       dev->name);
 		dev->features &= ~NETIF_F_TSO;
 	}
+	if (dev->features & NETIF_F_USO) {
+		if(!(dev->features & NETIF_F_FRAGLIST)) {
+			printk("%s: Dropping NETIF_F_USO since no ", dev->name);
+			printk("NETIF_F_FRAGLIST feature.\n");
+			dev->features &= ~NETIF_F_USO;
+		}
+		if(!(dev->features & NETIF_F_HW_CSUM)) {
+			printk("%s: Dropping NETIF_F_USO since no ", dev->name);
+			printk("NETIF_F_HW_CSUM feature.\n");
+			dev->features &= ~NETIF_F_USO;
+		}
+	}
 
 	/*
 	 *	nil rebuild_header routine,
diff -uNr linux-2.6.12-rc4.org/net/core/ethtool.c linux-2.6.12-rc4/net/core/ethtool.c
--- linux-2.6.12-rc4.org/net/core/ethtool.c	2005-06-02 16:55:32.000000000 +0545
+++ linux-2.6.12-rc4/net/core/ethtool.c	2005-06-02 21:53:16.000000000 +0545
@@ -72,6 +72,21 @@
 	return 0;
 }
 
+u32 ethtool_op_get_uso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_USO) != 0;
+}
+
+int ethtool_op_set_uso(struct net_device *dev, u32 data)
+{
+	if (data)
+		dev->features |= NETIF_F_USO;
+	else
+		dev->features &= ~NETIF_F_USO;
+
+	return 0;
+}
+
 /* Handlers for each ethtool command */
 
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
@@ -548,6 +563,39 @@
 	return dev->ethtool_ops->set_tso(dev, edata.data);
 }
 
+static int ethtool_get_uso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTSO };
+
+	if (!dev->ethtool_ops->get_uso)
+		return -EOPNOTSUPP;
+
+	edata.data = dev->ethtool_ops->get_uso(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_uso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_uso)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+
+	if (edata.data && !(dev->features & NETIF_F_FRAGLIST))
+		return -EINVAL;
+
+	if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
+		return -EINVAL;
+
+	return dev->ethtool_ops->set_uso(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -795,6 +843,12 @@
 	case ETHTOOL_GSTATS:
 		rc = ethtool_get_stats(dev, useraddr);
 		break;
+	case ETHTOOL_GUSO:
+		rc = ethtool_get_uso(dev, useraddr);
+		break;
+	case ETHTOOL_SUSO:
+		rc = ethtool_set_uso(dev, useraddr);
+		break;
 	default:
 		rc =  -EOPNOTSUPP;
 	}
@@ -817,3 +871,6 @@
 EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
+EXPORT_SYMBOL(ethtool_op_set_uso);
+EXPORT_SYMBOL(ethtool_op_get_uso);
+
diff -uNr linux-2.6.12-rc4.org/net/core/skbuff.c linux-2.6.12-rc4/net/core/skbuff.c
--- linux-2.6.12-rc4.org/net/core/skbuff.c	2005-05-27 23:22:46.000000000 +0545
+++ linux-2.6.12-rc4/net/core/skbuff.c	2005-06-02 20:27:27.000000000 +0545
@@ -159,6 +159,8 @@
 	skb_shinfo(skb)->tso_size = 0;
 	skb_shinfo(skb)->tso_segs = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->ip6_frag_id = 0;
+	skb_shinfo(skb)->uso_size = 0;
 out:
 	return skb;
 nodata:
diff -uNr linux-2.6.12-rc4.org/net/ipv4/ip_output.c linux-2.6.12-rc4/net/ipv4/ip_output.c
--- linux-2.6.12-rc4.org/net/ipv4/ip_output.c	2005-05-27 23:22:46.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv4/ip_output.c	2005-05-31 15:55:39.000000000 +0545
@@ -291,7 +291,8 @@
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) &&
+	    !(skb_shinfo(skb)->tso_size || skb_shinfo(skb)->uso_size))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -768,7 +769,6 @@
 		mtu = inet->cork.fragsize;
 	}
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
-
 	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
@@ -864,6 +864,12 @@
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			if ((!offset) && (length > mtu) &&
+			    (sk->sk_protocol == IPPROTO_UDP) &&
+			    (rt->u.dst.dev->features & NETIF_F_USO)) {
+				skb_shinfo(skb)->uso_size = mtu - fragheaderlen;
+				skb->ip_summed = CHECKSUM_HW;
+			}
 
 			/*
 			 *	Find where to start putting bytes.
diff -uNr linux-2.6.12-rc4.org/net/ipv4/udp.c linux-2.6.12-rc4/net/ipv4/udp.c
--- linux-2.6.12-rc4.org/net/ipv4/udp.c	2005-05-27 23:23:55.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv4/udp.c	2005-05-31 21:14:44.000000000 +0545
@@ -424,9 +424,10 @@
 		goto send;
 	}
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+	if ((skb_queue_len(&sk->sk_write_queue) == 1) ||
+		(skb_shinfo(skb)->uso_size)) {
 		/*
-		 * Only one fragment on the socket.
+		 * Only one fragment on the socket or it is udp lso skb.
 		 */
 		if (skb->ip_summed == CHECKSUM_HW) {
 			skb->csum = offsetof(struct udphdr, check);
diff -uNr linux-2.6.12-rc4.org/net/ipv6/ip6_output.c linux-2.6.12-rc4/net/ipv6/ip6_output.c
--- linux-2.6.12-rc4.org/net/ipv6/ip6_output.c	2005-05-27 23:22:46.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv6/ip6_output.c	2005-06-02 20:27:55.000000000 +0545
@@ -147,7 +147,8 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst)) &&
+				!skb_shinfo(skb)->uso_size)
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -977,6 +978,19 @@
 			skb->csum = 0;
 			/* reserve for fragmentation */
 			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
+			if ((!offset) && (length > mtu) &&
+			    (sk->sk_protocol == IPPROTO_UDP) &&
+				(rt->u.dst.dev->features  & NETIF_F_USO)) {
+				struct frag_hdr fhdr;
+
+				skb_shinfo(skb)->uso_size =
+					(mtu - fragheaderlen -
+					 sizeof(struct frag_hdr));
+				skb->ip_summed = CHECKSUM_HW;
+				ipv6_select_ident(skb, &fhdr);
+				skb_shinfo(skb)->ip6_frag_id =
+						fhdr.identification;
+			}
 
 			/*
 			 *	Find where to start putting bytes
diff -uNr linux-2.6.12-rc4.org/net/ipv6/udp.c linux-2.6.12-rc4/net/ipv6/udp.c
--- linux-2.6.12-rc4.org/net/ipv6/udp.c	2005-05-27 23:24:12.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv6/udp.c	2005-05-31 17:32:31.000000000 +0545
@@ -590,7 +590,8 @@
 		goto send;
 	}
 
-	if (skb_queue_len(&sk->sk_write_queue) == 1) {
+	if ((skb_queue_len(&sk->sk_write_queue) == 1) ||
+		(skb_shinfo(skb)->uso_size)) {
 		skb->csum = csum_partial((char *)uh,
 				sizeof(struct udphdr), skb->csum);
 		uh->check = csum_ipv6_magic(&fl->fl6_src,
