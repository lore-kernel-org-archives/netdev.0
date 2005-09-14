From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.13] IPv4/IPv6: USO Scatter-gather approac
Date: Tue, 13 Sep 2005 23:55:01 -0700
Message-ID: <200509140655.j8E6t1jx003507@localhost.localdomain>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com,
        ananda.raju@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached below is kernel patch with UPD large send offload which address the 
sendfile() syscall also. This patch uses scatter-gather support of skb to 
generate large UDP datagram. 

Below is a "how-to" on changes required in network drivers to use the USO 
interface.


UDP Large Send Offload (USO) Interface:
--------------------------------------
USO is a feature wherein the Linux kernel network stack will offload the IP 
fragmentation functionality of large UDP datagram to hardware. This will reduce
the overhead of stack in fragmenting the large UDP datagram to MTU sized packets

1) Drivers indicate their capability of USO using
dev->features |= NETIF_F_USO | NETIF_F_HW_CSUM | NETIF_F_SG

NETIF_F_HW_CSUM is required for USO over ipv6.

2) USO packet will be submitted for transmission using driver xmit routine. 
USO packet will have a non-zero value for

"skb_shinfo(skb)->uso_size"

skb_shinfo(skb)->uso_size will indicate the length of data part in each IP 
fragment going out of the adapter after IP fragmentation by hardware.

skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[]
contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW 
indicating that hardware has to do checksum calculation. Hardware should 
compute the UDP checksum of complete datagram and also ip header checksum of 
each fragmented IP packet.

For IPV6 the USO provides the fragment identification-id in 
skb_shinfo(skb)->ip6_frag_id. The adapter should use this ID for generating
IPv6 fragments.

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -uNr linux-2.6.13/include/linux/ethtool.h linux-2.6.13_uso/include/linux/ethtool.h
--- linux-2.6.13/include/linux/ethtool.h	2005-09-07 06:36:15.000000000 -0700
+++ linux-2.6.13_uso/include/linux/ethtool.h	2005-09-07 06:32:29.000000000 -0700
@@ -261,6 +261,8 @@
 int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
+u32 ethtool_op_get_uso(struct net_device *dev);
+int ethtool_op_set_uso(struct net_device *dev, u32 data);
 
 /**
  * &ethtool_ops - Alter and report network device settings
@@ -290,6 +292,8 @@
  * set_sg: Turn scatter-gather on or off
  * get_tso: Report whether TCP segmentation offload is enabled
  * set_tso: Turn TCP segmentation offload on or off
+ * get_uso: Report whether UDP large send offload is enabled
+ * set_uso: Turn UDP large send offload on or off
  * self_test: Run specified self-tests
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
@@ -354,6 +358,8 @@
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
+	u32     (*get_uso)(struct net_device *);
+	int     (*set_uso)(struct net_device *, u32);
 };
 
 /* CMDs currently supported */
@@ -389,6 +395,8 @@
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_GUSO           0x00000020 /* Get USO enable (ethtool_value) */
+#define ETHTOOL_SUSO           0x00000021 /* Set USO enable (ethtool_value) */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff -uNr linux-2.6.13/include/linux/netdevice.h linux-2.6.13_uso/include/linux/netdevice.h
--- linux-2.6.13/include/linux/netdevice.h	2005-09-07 04:20:51.000000000 -0700
+++ linux-2.6.13_uso/include/linux/netdevice.h	2005-09-07 04:22:51.000000000 -0700
@@ -408,6 +408,7 @@
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_USO             8192    /* Can offload UDP Large Send*/
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
diff -uNr linux-2.6.13/include/linux/skbuff.h linux-2.6.13_uso/include/linux/skbuff.h
--- linux-2.6.13/include/linux/skbuff.h	2005-09-07 04:20:56.000000000 -0700
+++ linux-2.6.13_uso/include/linux/skbuff.h	2005-09-07 04:22:58.000000000 -0700
@@ -137,6 +137,8 @@
 	unsigned int	nr_frags;
 	unsigned short	tso_size;
 	unsigned short	tso_segs;
+	unsigned short  uso_size;
+	unsigned int    ip6_frag_id;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 };
@@ -327,6 +329,11 @@
 extern void	      skb_under_panic(struct sk_buff *skb, int len,
 				      void *here);
 
+extern int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
+			int getfrag(void *from, char *to, int offset,
+			int len,int odd, struct sk_buff *skb),
+			void *from, int length);
+
 struct skb_seq_state
 {
 	__u32		lower_offset;
diff -uNr linux-2.6.13/net/core/dev.c linux-2.6.13_uso/net/core/dev.c
--- linux-2.6.13/net/core/dev.c	2005-09-07 06:36:25.000000000 -0700
+++ linux-2.6.13_uso/net/core/dev.c	2005-09-07 06:32:02.000000000 -0700
@@ -2706,6 +2706,25 @@
 		       dev->name);
 		dev->features &= ~NETIF_F_TSO;
 	}
+	/* TSO requires that SG is present as well. */
+	if ((dev->features & NETIF_F_TSO) &&
+	    !(dev->features & NETIF_F_SG)) {
+		printk("%s: Dropping NETIF_F_TSO since no SG feature.\n",
+		       dev->name);
+		dev->features &= ~NETIF_F_TSO;
+	}
+	if (dev->features & NETIF_F_USO) {
+		if (!(dev->features & NETIF_F_HW_CSUM)) {
+			printk("%s: Dropping NETIF_F_USO since no ", dev->name);
+			printk("NETIF_F_HW_CSUM feature.\n");
+			dev->features &= ~NETIF_F_USO;
+		}
+		if (!(dev->features & NETIF_F_SG)) {
+			printk("%s: Dropping NETIF_F_USO since no ", dev->name);
+			printk("NETIF_F_SG feature.\n");
+			dev->features &= ~NETIF_F_USO;
+		}
+	}
 
 	/*
 	 *	nil rebuild_header routine,
diff -uNr linux-2.6.13/net/core/ethtool.c linux-2.6.13_uso/net/core/ethtool.c
--- linux-2.6.13/net/core/ethtool.c	2005-09-07 06:36:34.000000000 -0700
+++ linux-2.6.13_uso/net/core/ethtool.c	2005-09-07 06:32:15.000000000 -0700
@@ -81,6 +81,20 @@
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
+	return 0;
+}
+
 /* Handlers for each ethtool command */
 
 static int ethtool_get_settings(struct net_device *dev, void __user *useraddr)
@@ -469,6 +483,9 @@
 		err = dev->ethtool_ops->set_tso(dev, 0);
 		if (err)
 			return err;
+		err = dev->ethtool_ops->set_uso(dev, 0);
+		if (err)
+			return err;
 	}
 
 	return dev->ethtool_ops->set_sg(dev, data);
@@ -557,6 +574,32 @@
 	return dev->ethtool_ops->set_tso(dev, edata.data);
 }
 
+static int ethtool_get_uso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GTSO };
+
+	if (!dev->ethtool_ops->get_uso)
+		return -EOPNOTSUPP;
+	edata.data = dev->ethtool_ops->get_uso(dev);
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		 return -EFAULT;
+	return 0;
+}
+static int ethtool_set_uso(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata;
+
+	if (!dev->ethtool_ops->set_uso)
+		return -EOPNOTSUPP;
+	if (copy_from_user(&edata, useraddr, sizeof(edata)))
+		return -EFAULT;
+	if (edata.data && !(dev->features & NETIF_F_SG))
+		return -EINVAL;
+	if (edata.data && !(dev->features & NETIF_F_HW_CSUM))
+		return -EINVAL;
+	return dev->ethtool_ops->set_uso(dev, edata.data);
+}
+
 static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 {
 	struct ethtool_test test;
@@ -806,6 +849,12 @@
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
@@ -833,3 +882,5 @@
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
 EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
+EXPORT_SYMBOL(ethtool_op_set_uso);
+EXPORT_SYMBOL(ethtool_op_get_uso);
diff -uNr linux-2.6.13/net/core/skbuff.c linux-2.6.13_uso/net/core/skbuff.c
--- linux-2.6.13/net/core/skbuff.c	2005-09-07 04:21:30.000000000 -0700
+++ linux-2.6.13_uso/net/core/skbuff.c	2005-09-07 06:38:57.000000000 -0700
@@ -159,6 +159,8 @@
 	skb_shinfo(skb)->tso_size = 0;
 	skb_shinfo(skb)->tso_segs = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->uso_size = 0;
+	skb_shinfo(skb)->ip6_frag_id = 0;
 out:
 	return skb;
 nodata:
@@ -1654,6 +1656,64 @@
 	return textsearch_find(config, state);
 }
 
+/*
+ * skb_append_datato_frags - append the user data to a skb,
+ * sk - sock  structure which contains skbs for transmission
+ * getfrag - The function to be called to get the data from the user.
+ * from - pointer to user message iov
+ * length -  length of the iov message
+ *
+ * This procedure will allocate a skb enough to hold protocol headers and
+ * append the user data in the fragment part of the skb and add the skb to
+ * socket write queue
+ */
+int skb_append_datato_frags(struct sock *sk, struct sk_buff *skb,
+			int getfrag(void *from, char *to, int offset, 
+				    int len,int odd, struct sk_buff *skb),
+			void *from, int length)
+{
+	int frg_cnt = 0;
+	skb_frag_t *frag = NULL;
+	struct page *page = NULL;
+	int copy, left;
+	int offset = 0;
+	do {
+		frg_cnt = skb_shinfo(skb)->nr_frags;
+		if (frg_cnt >= MAX_SKB_FRAGS) {
+			kfree_skb(skb);
+			return -EFAULT;
+		}
+		page = alloc_pages(sk->sk_allocation, 0);
+		if (page == NULL) {
+			kfree_skb(skb);
+			return -ENOMEM;
+		}
+		sk->sk_sndmsg_page = page;
+		sk->sk_sndmsg_off = 0;
+		skb_fill_page_desc(skb, frg_cnt, page, 0, 0);
+		frg_cnt = skb_shinfo(skb)->nr_frags;
+		atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+		skb->truesize += PAGE_SIZE;
+		frag = &skb_shinfo(skb)->frags[frg_cnt - 1];
+		left = PAGE_SIZE - frag->page_offset;
+		copy = (length > left)? left : length;
+		if (getfrag(from, page_address(frag->page) +
+			    frag->page_offset+frag->size,
+			    offset, copy, 0, skb) < 0) {
+			kfree_skb(skb);
+			return -EFAULT;
+		}
+		sk->sk_sndmsg_off += copy;
+		frag->size += copy;
+		skb->len += copy;
+		skb->data_len += copy;
+		offset += copy;
+		length -= copy;
+		page = NULL;
+	} while (length > 0);
+	return 0;
+}
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
@@ -1696,3 +1756,4 @@
 EXPORT_SYMBOL(skb_seq_read);
 EXPORT_SYMBOL(skb_abort_seq_read);
 EXPORT_SYMBOL(skb_find_text);
+EXPORT_SYMBOL(skb_append_datato_frags);
diff -uNr linux-2.6.13/net/ipv4/ip_output.c linux-2.6.13_uso/net/ipv4/ip_output.c
--- linux-2.6.13/net/ipv4/ip_output.c	2005-09-07 04:21:46.000000000 -0700
+++ linux-2.6.13_uso/net/ipv4/ip_output.c	2005-09-13 07:12:05.000000000 -0700
@@ -280,7 +280,8 @@
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) &&
+		!(skb_shinfo(skb)->uso_size || skb_shinfo(skb)->tso_size))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -781,6 +782,46 @@
 		csummode = CHECKSUM_HW;
 
 	inet->cork.length += length;
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
+			(rt->u.dst.dev->features & NETIF_F_USO)) {
+		/* There is support for UDP large send offload by network
+		 * device, so create one single skb packet containing complete
+		 * udp datagram
+		 */
+		if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
+			skb = sock_alloc_send_skb(sk,
+				hh_len + fragheaderlen + transhdrlen + 20,
+				(flags & MSG_DONTWAIT), &err);
+			if (skb == NULL) 
+				goto error;
+			/* reserve space for Hardware header */
+			skb_reserve(skb, hh_len);
+			/* create space for UDP/IP header */
+			skb_put(skb,fragheaderlen + transhdrlen);
+			/* initialize network header pointer */
+			skb->nh.raw = skb->data;
+			/* initialize protocol header pointer */
+			skb->h.raw = skb->data + fragheaderlen;
+			skb->ip_summed = CHECKSUM_HW;
+			skb->csum = 0;
+			sk->sk_sndmsg_off = 0;
+		}
+		err = skb_append_datato_frags(sk,skb, getfrag, from,
+				       (length - transhdrlen));
+		if (!err) {
+			/* specify the length of each IP datagram fragment*/
+			skb_shinfo(skb)->uso_size = (mtu - fragheaderlen);
+			__skb_queue_tail(&sk->sk_write_queue, skb);
+			return 0;
+		} else {
+			/* There is not enough support do UPD LSO,
+			 * so follow normal path
+			 */
+			kfree_skb(skb);
+			goto error;
+		}
+	}
+
 
 	/* So, what's going on in the loop below?
 	 *
@@ -1012,14 +1053,23 @@
 		return -EINVAL;
 
 	inet->cork.length += size;
+	if ((sk->sk_protocol == IPPROTO_UDP) &&
+	    (rt->u.dst.dev->features & NETIF_F_USO))
+		skb_shinfo(skb)->uso_size = (mtu - fragheaderlen);
+
 
 	while (size > 0) {
 		int i;
 
-		/* Check if the remaining data fits into current packet. */
-		len = mtu - skb->len;
-		if (len < size)
-			len = maxfraglen - skb->len;
+		if (skb_shinfo(skb)->uso_size) {
+			len = size;
+		} else {
+
+			/* Check if the remaining data fits into current packet. */
+			len = mtu - skb->len;
+			if (len < size)
+				len = maxfraglen - skb->len;
+		}
 		if (len <= 0) {
 			struct sk_buff *skb_prev;
 			char *data;
diff -uNr linux-2.6.13/net/ipv6/ip6_output.c linux-2.6.13_uso/net/ipv6/ip6_output.c
--- linux-2.6.13/net/ipv6/ip6_output.c	2005-09-07 04:21:57.000000000 -0700
+++ linux-2.6.13_uso/net/ipv6/ip6_output.c	2005-09-13 07:11:10.000000000 -0700
@@ -147,7 +147,8 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->uso_size) ||
+				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -893,6 +894,50 @@
 	 */
 
 	inet->cork.length += length;
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
+	    (rt->u.dst.dev->features & NETIF_F_USO)) {
+		/* There is support for UDP large send offload by network
+		 * device, so create one single skb packet containing complete
+		 * udp datagram
+		 */
+		if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
+			skb = sock_alloc_send_skb(sk,
+				hh_len + fragheaderlen + transhdrlen + 20,
+				(flags & MSG_DONTWAIT), &err);
+			if (skb == NULL)
+				goto error;
+			/* reserve space for Hardware header */
+			skb_reserve(skb, hh_len);
+			/* create space for UDP/IP header */
+			skb_put(skb,fragheaderlen + transhdrlen);
+			/* initialize network header pointer */
+			skb->nh.raw = skb->data;
+			/* initialize protocol header pointer */
+			skb->h.raw = skb->data + fragheaderlen;
+			skb->ip_summed = CHECKSUM_HW;
+			skb->csum = 0;
+			sk->sk_sndmsg_off = 0;
+		}
+		err = skb_append_datato_frags(sk,skb, getfrag, from,
+					      (length - transhdrlen));
+		if (!err) {
+			struct frag_hdr fhdr;
+
+			/* specify the length of each IP datagram fragment*/
+			skb_shinfo(skb)->uso_size = (mtu - fragheaderlen) - 
+							sizeof(struct frag_hdr);
+			ipv6_select_ident(skb, &fhdr);
+			skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
+			__skb_queue_tail(&sk->sk_write_queue, skb);
+			return 0;
+		} else {
+			/* There is not enough support do UPD LSO,
+			 * so follow normal path
+			 */
+			kfree_skb(skb);
+			goto error;
+		}
+	}
 
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		goto alloc_new_skb;
