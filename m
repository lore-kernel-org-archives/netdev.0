From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.12-rc4] IPv4/IPv6: USO v2, Scatter-gather approach
Date: Thu,  2 Jun 2005 17:41:06 -0700 (PDT)
Message-ID: <20050603004106.BAB6A7B990@linux.site>
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
feature. This patch uses the "Scatter-Gather" approach.
It also incorporates David Miller's comments on the first version.

Also, below is a "how-to" on changes required in network drivers to use
the USO interface.

UDP Large Send Offload (USO) Interface:
--------------------------------------

USO is a feature wherein the Linux kernel network stack will offload the 
IP fragmentation functionality of large UDP datagram to hardware. This 
will reduce the overhead of stack in fragmenting the large UDP datagram 
to MTU sized packets.


1) Drivers indicate their capability of USO using
dev->features |= NETIF_F_USO | NETIF_F_HW_CSUM | NETIF_F_SG

NETIF_F_HW_CSUM is required for USO over ipv6.

2) USO packet will be submitted for transmission using driver xmit 
routine. USO packet will have a non-zero value for

"skb_shinfo(skb)->uso_size"

skb_shinfo(skb)->uso_size will indicate the length of data part in each IP
fragment going out of the adapter after IP fragmentation by hardware.

skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[] 
contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW
indicating that hardware has to do checksum calculation. Hardware should
compute the UDP checksum of complete datagram and also ip header checksum 
of each fragmented IP packet.

For IPV6 the USO provides the fragment identification-id in
skb_shinfo(skb)->ip6_frag_id. The adapter should use this ID for generating 
IPv6 fragments.

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -uNr linux-2.6.12-rc4.org/include/linux/ethtool.h linux-2.6.12-rc4/include/linux/ethtool.h
--- linux-2.6.12-rc4.org/include/linux/ethtool.h	2005-06-01 19:56:58.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/ethtool.h	2005-06-01 19:51:47.000000000 +0545
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
--- linux-2.6.12-rc4.org/include/linux/netdevice.h	2005-05-25 17:18:11.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/netdevice.h	2005-06-01 14:33:12.000000000 +0545
@@ -414,6 +414,7 @@
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_USO		8192    /* Can offload UDP Large Send*/
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
diff -uNr linux-2.6.12-rc4.org/include/linux/skbuff.h linux-2.6.12-rc4/include/linux/skbuff.h
--- linux-2.6.12-rc4.org/include/linux/skbuff.h	2005-05-25 17:18:20.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/skbuff.h	2005-06-01 15:18:44.000000000 +0545
@@ -135,6 +135,8 @@
 	atomic_t	dataref;
 	unsigned int	nr_frags;
 	unsigned short	tso_size;
+	unsigned short  uso_size;
+	unsigned int	ip6_frag_id;
 	unsigned short	tso_segs;
 	struct sk_buff	*frag_list;
 	skb_frag_t	frags[MAX_SKB_FRAGS];
diff -uNr linux-2.6.12-rc4.org/include/net/sock.h linux-2.6.12-rc4/include/net/sock.h
--- linux-2.6.12-rc4.org/include/net/sock.h	2005-05-25 17:18:44.000000000 +0545
+++ linux-2.6.12-rc4/include/net/sock.h	2005-05-25 20:28:14.000000000 +0545
@@ -1296,5 +1296,11 @@
 	return -ENODEV;
 }
 #endif
+struct sk_buff *sock_append_data(struct sock *sk,
+		int getfrag(void *from, char *to, int offset, int len,
+		int odd, struct sk_buff *skb),
+		void *from, int length, int transhdrlen,
+		int hh_len, int fragheaderlen,
+		unsigned int flags,int *err);
 
 #endif	/* _SOCK_H */
diff -uNr linux-2.6.12-rc4.org/net/core/dev.c linux-2.6.12-rc4/net/core/dev.c
--- linux-2.6.12-rc4.org/net/core/dev.c	2005-06-01 14:35:01.000000000 +0545
+++ linux-2.6.12-rc4/net/core/dev.c	2005-06-01 19:46:03.000000000 +0545
@@ -2793,6 +2793,18 @@
 		       dev->name);
 		dev->features &= ~NETIF_F_TSO;
 	}
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
diff -uNr linux-2.6.12-rc4.org/net/core/ethtool.c linux-2.6.12-rc4/net/core/ethtool.c
--- linux-2.6.12-rc4.org/net/core/ethtool.c	2005-06-01 19:48:31.000000000 +0545
+++ linux-2.6.12-rc4/net/core/ethtool.c	2005-06-01 23:02:39.000000000 +0545
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
@@ -460,6 +475,9 @@
 		err = dev->ethtool_ops->set_tso(dev, 0);
 		if (err)
 			return err;
+		err = dev->ethtool_ops->set_uso(dev, 0);
+		if (err)
+			return err;
 	}
 
 	return dev->ethtool_ops->set_sg(dev, data);
@@ -548,6 +566,39 @@
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
+	if (edata.data && !(dev->features & NETIF_F_SG))
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
@@ -795,6 +846,12 @@
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
@@ -817,3 +874,6 @@
 EXPORT_SYMBOL(ethtool_op_set_sg);
 EXPORT_SYMBOL(ethtool_op_set_tso);
 EXPORT_SYMBOL(ethtool_op_set_tx_csum);
+EXPORT_SYMBOL(ethtool_op_set_uso);
+EXPORT_SYMBOL(ethtool_op_get_uso);
+
diff -uNr linux-2.6.12-rc4.org/net/core/skbuff.c linux-2.6.12-rc4/net/core/skbuff.c
--- linux-2.6.12-rc4.org/net/core/skbuff.c	2005-05-25 20:25:35.000000000 +0545
+++ linux-2.6.12-rc4/net/core/skbuff.c	2005-06-01 14:34:27.000000000 +0545
@@ -159,6 +159,8 @@
 	skb_shinfo(skb)->tso_size = 0;
 	skb_shinfo(skb)->tso_segs = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->uso_size = 0;
+	skb_shinfo(skb)->ip6_frag_id = 0;
 out:
 	return skb;
 nodata:
diff -uNr linux-2.6.12-rc4.org/net/core/sock.c linux-2.6.12-rc4/net/core/sock.c
--- linux-2.6.12-rc4.org/net/core/sock.c	2005-05-25 20:25:47.000000000 +0545
+++ linux-2.6.12-rc4/net/core/sock.c	2005-06-01 19:40:03.000000000 +0545
@@ -1401,6 +1401,102 @@
 
 EXPORT_SYMBOL(proto_unregister);
 
+/*
+ * sock_append_data - append the user data to a skb,
+ * sk - sock  structure which contains skbs for transmission
+ * getfrag - The function to be called to get the data from the user.
+ * from - pointer to user message iov
+ * length -  length of the iov message
+ * transhdrlen - transport header length
+ * hh_len - hardware header length
+ * fragheaderlen - length of the IP header
+ * flags - iov message flags
+ * err - Error code returned
+ * 
+ * This procedure will allocate a skb enough to hold protocol headers and 
+ * append the user data in the fragment part of the skb and add the skb to 
+ * socket write queue
+ */
+struct sk_buff *sock_append_data(struct sock *sk, 
+		int getfrag(void *from, char *to, int offset, int len,
+				int odd, struct sk_buff *skb),
+		void *from, int length, int transhdrlen, 
+		int hh_len, int fragheaderlen,
+           	unsigned int flags,int *err)
+{
+	struct sk_buff *skb;
+	int frg_cnt = 0;
+	skb_frag_t *frag = NULL;
+	struct page *page = NULL;
+	int copy, left;
+	int offset = 0;
+
+	if (skb_queue_len(&sk->sk_write_queue)) {
+		*err = -EOPNOTSUPP;
+		return NULL;
+	}
+
+	skb = sock_alloc_send_skb(sk,
+                        hh_len + fragheaderlen + transhdrlen + 20,
+                        (flags & MSG_DONTWAIT), err);
+	if (skb == NULL) {
+		*err = -ENOMEM;
+		return NULL;
+	}
+	/* reserve space for Hardware header */
+	skb_reserve(skb, hh_len); 
+	/* create space for UDP/IP header */
+	skb_put(skb,fragheaderlen + transhdrlen); 
+	/* initialize network header pointer */
+	skb->nh.raw = skb->data;
+	/* initialize protocol header pointer */
+	skb->h.raw = skb->data + fragheaderlen;
+	skb->ip_summed = CHECKSUM_HW;
+	skb->csum = 0;
+	do {
+		copy = length;
+		if (frg_cnt >= MAX_SKB_FRAGS) {
+			*err = -EFAULT;
+			kfree_skb(skb);
+			return NULL;
+		}
+		page = alloc_pages(sk->sk_allocation, 0);
+		if (page == NULL) {
+			*err = -ENOMEM;
+			kfree_skb(skb);
+			return NULL;
+		}
+		sk->sk_sndmsg_page = page;
+		sk->sk_sndmsg_off = 0;
+		skb_fill_page_desc(skb, frg_cnt, page, 0, 0);
+		skb->truesize += PAGE_SIZE;
+		atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+		frg_cnt = skb_shinfo(skb)->nr_frags;
+		frag = &skb_shinfo(skb)->frags[frg_cnt - 1];
+		left = PAGE_SIZE - frag->page_offset;
+		if (copy > left)
+			copy = left;
+		if (getfrag(from, page_address(frag->page)+
+					frag->page_offset+frag->size,
+					offset, copy, 0, skb) < 0) {
+			*err = -EFAULT;
+			kfree_skb(skb);
+			return NULL;
+		}
+		sk->sk_sndmsg_off += copy;
+		frag->size += copy;
+		skb->len += copy;
+		skb->data_len += copy;
+		offset += copy;
+		length -= copy;
+		page = NULL;
+	} while (length > 0);
+	__skb_queue_tail(&sk->sk_write_queue, skb);
+	*err = 0;
+	return skb;
+}
+EXPORT_SYMBOL(sock_append_data);
+
 #ifdef CONFIG_PROC_FS
 static inline struct proto *__proto_head(void)
 {
diff -uNr linux-2.6.12-rc4.org/net/ipv4/ip_output.c linux-2.6.12-rc4/net/ipv4/ip_output.c
--- linux-2.6.12-rc4.org/net/ipv4/ip_output.c	2005-05-25 20:26:07.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv4/ip_output.c	2005-06-02 22:04:59.000000000 +0545
@@ -291,7 +291,8 @@
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) && 
+		!(skb_shinfo(skb)->uso_size || skb_shinfo(skb)->tso_size))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -789,6 +790,28 @@
 
 	inet->cork.length += length;
 
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) && 
+		(rt->u.dst.dev->features & NETIF_F_USO)) { 
+		/* There is support for UDP large send offload by network 
+		 * device, so create one single skb packet containing complete
+		 * udp datagram
+		 */
+		skb = sock_append_data(sk, getfrag, from, 
+				(length - transhdrlen), transhdrlen, 
+				hh_len, fragheaderlen, flags, &err);
+		if (skb != NULL) {
+			 /* specify the length of each IP datagram fragment*/
+			skb_shinfo(skb)->uso_size = (mtu - fragheaderlen);
+			return 0;
+		} else if (err == -EOPNOTSUPP) {
+			/* There is not enough support do UPD LSO,
+			 * so follow normal path 
+			 */
+			err = 0;
+		} else
+			goto error;
+	}
+
 	/* So, what's going on in the loop below?
 	 *
 	 * We use calculated fragment length to generate chained skb,
diff -uNr linux-2.6.12-rc4.org/net/ipv6/ip6_output.c linux-2.6.12-rc4/net/ipv6/ip6_output.c
--- linux-2.6.12-rc4.org/net/ipv6/ip6_output.c	2005-05-25 20:26:17.000000000 +0545
+++ linux-2.6.12-rc4/net/ipv6/ip6_output.c	2005-06-02 22:05:24.000000000 +0545
@@ -147,7 +147,8 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->uso_size) || 
+			dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -898,6 +899,33 @@
 	 */
 
 	inet->cork.length += length;
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
+		(rt->u.dst.dev->features & NETIF_F_USO)) {
+
+		/* There is support for UDP large send offload by network 
+		 * device, so create one single skb packet containing complete
+		 * udp datagram
+		 */
+		skb = sock_append_data(sk, getfrag, from, 
+				(length - transhdrlen), transhdrlen, 
+				hh_len, fragheaderlen, flags, &err);
+		if (skb != NULL) { 
+			struct frag_hdr fhdr;
+
+			/* specify the length of each IP datagram fragment*/
+			skb_shinfo(skb)->uso_size = (mtu - fragheaderlen -
+						      sizeof(struct frag_hdr));
+			ipv6_select_ident(skb, &fhdr);
+			skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
+			return 0;
+		} else if (err == -EOPNOTSUPP){
+			/* There is not enough support for UDP LSO, 
+			 * so follow normal path 
+			 */
+			err = 0;
+		} else
+			goto error;
+	}
 
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL)
 		goto alloc_new_skb;
