From: ravinandan.arakali@neterion.com
Subject: [PATCH 2.6.12-rc4] IPv4/IPv6: UDP Large Send Offload feature
Date: Thu, 26 May 2005 16:20:06 -0700 (PDT)
Message-ID: <20050526232006.60E6365005@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, ananda.raju@neterion.com,
        rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Attached below is a kernel patch to provide UDP LSO(Large Send Offload) 
feature.
This is the UDP counterpart of TSO. Basically, an oversized packet
(less than or equal to 65535) is handed to the NIC. The adapter then
produces IP fragments in conformance with RFC791(IPv4) or RFC2460(IPv6).

Very much like TCP TSO, UDP LSO provides significant reduction in CPU 
utilization, especially with 1500 MTU frames. For 10GbE traffic,
these extra CPU cycles translate into significant throughput increase 
on most server platforms.

Reasonable amount of testing has been done on the patch using Neterion's
10G Xframe-II adapter to ensure code stability.

Please review the patch.

Also, below is a "how-to" on changes required in network drivers to use
the UDP LSO interface.


UDP Large Send Offload (ULSO) Interface:
----------------------------------------

ULSO is a feature wherein the Linux kernel network stack will offload 
the IP fragmentation functionality of large UDP datagram to hardware. This
will reduce the overhead of stack in fragmenting the large UDP datagram to
MTU sized packets.

1) Drivers indicate their capability of ULSO using
dev->features |= NETIF_F_UDP_LSO | NETIF_F_HW_CSUM

NETIF_F_HW_CSUM is required for ULSO over ipv6.

2) ULSO packet will be submitted for transmission using driver xmit 
routine. ULSO packet will have a non zero value for

"skb_shinfo(skb)->ulso_size"

skb_shinfo(skb)->ulso_size will indicate the length of data in each IP
fragment going out of the adapter after IP fragmentation by hardware.

skb->data will contain MAC/IP/UDP header and skb_shinfo(skb)->frags[] 
contains the data payload. The skb->ip_summed will be set to CHECKSUM_HW
indicating that hardware has to perform checksum calculation. Hardware 
should compute the UDP checksum of complete UDP datagram and also the IP 
header checksum of each fragmented IP packet.

For IPV6 the ULSO provides the fragment identification id in
skb_shinfo(skb)->ip6_id. The adapter should use this ID for generating IPv6
fragments.

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -uNr linux-2.6.12-rc4.org/include/linux/netdevice.h linux-2.6.12-rc4/include/linux/netdevice.h
--- linux-2.6.12-rc4.org/include/linux/netdevice.h	2005-05-25 17:18:11.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/netdevice.h	2005-05-25 20:28:25.000000000 +0545
@@ -414,6 +414,7 @@
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_UDP_LSO		8192    /* Can offload UDP Large Send*/
 
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
diff -uNr linux-2.6.12-rc4.org/include/linux/skbuff.h linux-2.6.12-rc4/include/linux/skbuff.h
--- linux-2.6.12-rc4.org/include/linux/skbuff.h	2005-05-25 17:18:20.000000000 +0545
+++ linux-2.6.12-rc4/include/linux/skbuff.h	2005-05-26 17:04:50.000000000 +0545
@@ -135,6 +135,8 @@
 	atomic_t	dataref;
 	unsigned int	nr_frags;
 	unsigned short	tso_size;
+	unsigned short  ulso_size;
+	unsigned int	ip6_id;
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
diff -uNr linux-2.6.12-rc4.org/net/core/skbuff.c linux-2.6.12-rc4/net/core/skbuff.c
--- linux-2.6.12-rc4.org/net/core/skbuff.c	2005-05-25 20:25:35.000000000 +0545
+++ linux-2.6.12-rc4/net/core/skbuff.c	2005-05-25 20:46:04.000000000 +0545
@@ -159,6 +159,8 @@
 	skb_shinfo(skb)->tso_size = 0;
 	skb_shinfo(skb)->tso_segs = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->ulso_size = 0;
+	skb_shinfo(skb)->ip6_id = 0;
 out:
 	return skb;
 nodata:
diff -uNr linux-2.6.12-rc4.org/net/core/sock.c linux-2.6.12-rc4/net/core/sock.c
--- linux-2.6.12-rc4.org/net/core/sock.c	2005-05-25 20:25:47.000000000 +0545
+++ linux-2.6.12-rc4/net/core/sock.c	2005-05-26 17:19:39.000000000 +0545
@@ -1401,6 +1401,107 @@
 
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
+	if (!((sk->sk_route_caps & NETIF_F_SG) && 
+		 (sk->sk_route_caps & (NETIF_F_IP_CSUM | NETIF_F_HW_CSUM)))) {
+		*err = -EOPNOTSUPP;
+		return NULL;
+	}
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
+++ linux-2.6.12-rc4/net/ipv4/ip_output.c	2005-05-25 20:27:20.000000000 +0545
@@ -291,7 +291,8 @@
 {
 	IP_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 
-	if (skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->tso_size)
+	if (skb->len > dst_mtu(skb->dst) && 
+		!(skb_shinfo(skb)->ulso_size || skb_shinfo(skb)->tso_size))
 		return ip_fragment(skb, ip_finish_output);
 	else
 		return ip_finish_output(skb);
@@ -789,6 +790,29 @@
 
 	inet->cork.length += length;
 
+	sk->sk_route_caps |= rt->u.dst.dev->features;
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) && 
+		(sk->sk_route_caps & NETIF_F_UDP_LSO)) { 
+		/* There is support for UDP large send offload by network 
+		 * device, so create one single skb packet containing complete
+		 * udp datagram
+		 */
+		skb = sock_append_data(sk, getfrag, from, 
+				(length - transhdrlen), transhdrlen, 
+				hh_len, fragheaderlen, flags, &err);
+		if (skb != NULL) {
+			 /* specify the length of each IP datagram fragment*/
+			skb_shinfo(skb)->ulso_size = (mtu - fragheaderlen);
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
+++ linux-2.6.12-rc4/net/ipv6/ip6_output.c	2005-05-26 17:05:06.000000000 +0545
@@ -147,7 +147,8 @@
 
 int ip6_output(struct sk_buff *skb)
 {
-	if (skb->len > dst_mtu(skb->dst) || dst_allfrag(skb->dst))
+	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->ulso_size) || 
+			dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
 		return ip6_output2(skb);
@@ -898,6 +899,35 @@
 	 */
 
 	inet->cork.length += length;
+	sk->sk_route_caps |= rt->u.dst.dev->features;
+	if (((length > mtu) && (sk->sk_protocol == IPPROTO_UDP)) &&
+		((sk->sk_route_caps & (NETIF_F_UDP_LSO | NETIF_F_HW_CSUM)) ==
+			(NETIF_F_UDP_LSO | NETIF_F_HW_CSUM))) {
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
+			skb_shinfo(skb)->ulso_size = (mtu - fragheaderlen -
+						      sizeof(struct frag_hdr));
+			ipv6_select_ident(skb, &fhdr);
+			skb_shinfo(skb)->ip6_id = fhdr.identification;
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
