From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Wed, 25 Jul 2007 13:17:54 -0400
Message-ID: <46A785C2.9090708@myri.com>
References: <200707201741.45079.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020803090500000001090709"
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1846 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754525AbXGYRzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 13:55:13 -0400
In-Reply-To: <200707201741.45079.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020803090500000001090709
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I've ported myri10ge to use the new LRO interface.  I have attached a
preliminary patch to myri10ge.  I'm very pleased to note that the
performance is on-par with my own LRO used by our out-of-tree driver.
(except when using mixed MTUS, see performance data below).

As I expected, actually porting our driver to use the LRO interface
gave me a far better understanding of the interface, and allowed for
better feedback.  I have attached a patch to the LRO code which
addresses some of the issues I mention below.

Please find below a performance summary, as well as my comments
on the LRO code, and patches to myri10ge and inet_lro. Both patches
are Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>


Cheers,

Drew

===================
Performance:
===================

Here is a performance summary taken on my very low-end 2.0GHz AMD
Athlon(tm) 64 X2 Dual Core Processor 3800+ running 2.6.23-rc1 and
receiving a netperf TCP_SENDFILE test from an identical sender (which
was running 2.6.22 and our 1.3.1 "out of tree" driver).  The netserver
process was bound to a different core than the interrupt handler.  The
data reported is from the median of 5 60 second netperf tests.  The
following settings were in /etc/sysctl.conf on both machines:

net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.netdev_max_backlog = 2500
net.ipv4.tcp_timestamps = 0


RX Performance for Sender MTU=1500, Receiver MTU=1500 expressed as
"x Gb/s, y %CPU receiver utilization":

rxbuf(1) 1.3.1(2)  inet_lro   no LRO
-----	 -------   -------    --------
4K pg	 8.9 78%   8.8 77%	3.7 89%
8K pg	 9.2 77%   9.1 77%	3.7 89%
16Kpg	 9.4 73%   9.4 73%	3.8 89%
32Kpg	 9.4 72%   9.4 72%	3.9 89%
skb	 N/A N/A   5.5 90%	4.1 92%

RX Performance for Sender MTU=1500, Receiver MTU=9000 expressed as
"x Gb/s, y %CPU receiver utilization":

rxbuf(1) 1.3.1(2)  inet_lro   no LRO
-----	 -------   -------    --------
4K pg	 8.9 78%   7.3 79%	3.7 89%
8K pg	 9.2 77%   7.6 79%	3.7 89%
16Kpg	 9.4 73%   8.0 78%	3.8 89%
32Kpg	 9.4 72%   8.2 79%	3.9 89%
skb	 N/A N/A   4.9 92%	4.1 92%

RX Performance for Sender MTU=9000, Receiver MTU=9000 expressed as
"x Gb/s, y %CPU receiver utilization":

rxbuf(1) 1.3.1(2)  inet_lro   no LRO
-----	 -------   -------    --------
4K pg	 9.9 63%   9.6 66%	8.3 71%
8K pg	 9.9 60%   9.9 63%	8.4 72%
16Kpg	 9.9 55%   9.9 55%	8.7 70%
32Kpg	 9.9 53%   9.9 53%	8.9 67%
skb	 N/A N/A   9.9 68%	8.7 72%

(1) "xK pg" means the driver was configured to adjust the receive page
size using MYRI10GE_ALLOC_ORDER.  "skb" means an internal variant
of our driver which receives into skbs rather than pages was used.

(2) "1.3.1" is our latest out of tree driver which uses the myri10ge
specific frags-based LRO code previously submitted and rejected.

===================
Code review / comments:
===================

1) Checksum information for CHECKSUM_COMPLETE drivers.

Our NIC passes partial checksums to our driver.  In the current code,
it seems impossible for page based CHECKSUM_COMPLETE drivers to behave
correctly in the case of "rejected" frames.  Eg, there is no way
to pass the partial checksum to the LRO module so that it gets
set in the skb header and passed up the stack.

Further, there seems to be no (easy) way to use CHECKSUM_COMPLETE
on an aggregated packet at LRO flush time.  By the time a packet
is aggregated, the partial checksum from the first segment is
out of date.

I think it would make sense to require that a CHECKSUM_COMPLETE style
driver verify the checksum in its get_frag_header / get_skb_header
callback.  This allows the LRO code to unconditionally set
CHECKSUM_UNNECESSARY.

The attached a patch modifies the code to do this.


2) Non-accelerated VLAN tags

Our firmware currently does not do vlan tag insertion
and removal.  This causes a problem in __lro_proc_segment()
where the tcp and ip headers are setup to point into the
newly created skb.  A frame containing an unstripped vlan
tag will cause the headers to be garbage.

The attached patch modifies __lro_proc_segment() to offset
those pointers by VLAN_HLEN when required.

3) Padded frames.

I may be missing something, but I don't see where you
either strip padding from frames or reject padded frames.
(see the pskb_trim_rcsum() in net/ipv4/ip_input.c:ip_rcv()

I did not add such a feature as I was confused about the intended
use of len/true_size.

Also, trimming is a pain when dealing with pure frags (without a
containing skb).  We have code in our out-of-kernel driver to deal
with it which you are welcome to use.


4) LRO_MIN_PG_HLEN (== 80)

This confuses me.  Can you please explain what you're trying to do?
Because of this, I kept getting crashes in the skb_pull() done by
eth_type_trans() because I was passing segments which were 60 bytes
and the skb->data_len of the skb constructed by lro_gen_skb() was -20.
I added my own code to bump the length to a magic 80 bytes, and the
panics disappeared.  This may cause data corruption because of
#3 above!

5) NAPI/non-NAPI

The LRO code assumes the underlying driver uses NAPI, and calls
netif_receive_skb() rather than netif_rx().  Perhaps there should be a
field in the lro_mgr struct to specify napi / non-napi.

6) The checks for when to stop aggregating and flush in
    __lro_proc_{segment|skb} need some improvement.

The skb variant currently uses a pure count (max_aggr).  In order to
keep the resulting aggregated frame below 64KB, the underlying driver
computes max_aggr as 0xffff / MTU.  This reduces the effectiveness of
LRO on mixed MTU networks.  Eg, this causes packets coming from a
source with a 1500b MTU to be aggregated after 7 frames when using a
9000b MTU on the receiver, rather than after 43 frames.  As you can
see from the differences in inet_lro's performance in the table
above, this is a real problem.

I believe that a hybrid byte / max_aggr model should be used.  The
__lro_proc_segment takes this approach.  Note that there is a subtle
bug in that the maximum aggregated bytes should not be be 0xffff.
Rather, one must leave room for the next frame to arrive by setting
the max aggregated bytes to 0xffff - dev->mtu.  This is masked
by the driver computing max_aggr as above.






--------------020803090500000001090709
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="inet_lro.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet_lro.diff"

--- linux-2.6.23-rc1.orig/include/linux/inet_lro.h	2007-07-25 12:48:48.000000000 -0400
+++ linux-2.6.23-rc1/include/linux/inet_lro.h	2007-07-24 15:07:28.000000000 -0400
@@ -132,7 +132,7 @@ void lro_vlan_hwaccel_receive_skb(struct
 
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv);
+		       int len, int true_size, void *priv, __wsum sum);
 
 void lro_vlan_hwaccel_receive_frags(struct net_lro_mgr *lro_mgr,
 				    struct skb_frag_struct *frags,
@@ -140,7 +140,8 @@ void lro_vlan_hwaccel_receive_frags(stru
 				    int true_size,
 				    struct vlan_group *vgrp,
 				    u16 vlan_tag,
-				    void *priv);
+				    void *priv,
+				    __wsum sum);
 
 /*
  * Forward all aggregated SKBs held by lro_mgr to network stack
--- linux-2.6.23-rc1.orig/net/ipv4/inet_lro.c	2007-07-25 12:48:48.000000000 -0400
+++ linux-2.6.23-rc1/net/ipv4/inet_lro.c	2007-07-25 10:23:31.000000000 -0400
@@ -341,6 +341,10 @@ int __lro_proc_skb(struct net_lro_mgr *l
 	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
 		goto out;
 
+	/* checksum has been verified by get_frag_header() */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->csum = 0;
+
 	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
 	if (!lro_desc)
 		goto out;
@@ -437,7 +441,8 @@ struct sk_buff *__lro_proc_segment(struc
 				   struct skb_frag_struct *frags,
 				   int len, int true_size,
 				   struct vlan_group *vgrp,
-				   u16 vlan_tag, void *priv)
+				   u16 vlan_tag, void *priv,
+				   __wsum sum)
 {
 	struct net_lro_desc *lro_desc;
         struct iphdr *iph;
@@ -446,6 +451,7 @@ struct sk_buff *__lro_proc_segment(struc
 	void *mac_hdr;
 	u64 flags;
 	int hdr_len = 0;
+	int vlan_hdr_len;
 
 	if (!lro_mgr->get_frag_header
 	    || lro_mgr->get_frag_header(frags, (void *)&mac_hdr, (void *)&iph,
@@ -473,8 +479,17 @@ struct sk_buff *__lro_proc_segment(struc
 		if (!skb)
 			goto out;
 
-		iph = (void *)(skb->data);
-		tcph = (void *)((u8 *)skb->data + IP_HDR_LEN(iph));
+		/* checksum has been verified by get_frag_header() */
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->csum = 0;
+
+		if (skb->protocol == htons(ETH_P_8021Q))
+			vlan_hdr_len = VLAN_HLEN;
+		else
+			vlan_hdr_len = 0;
+
+		iph = (void *)(skb->data + vlan_hdr_len);
+		tcph = (void *)((u8 *)skb->data + vlan_hdr_len + IP_HDR_LEN(iph));
 
 		lro_init_desc(lro_desc, skb, iph, tcph, 0, NULL);
 		return 0;
@@ -501,17 +516,20 @@ out1:  /* Original packet has to be post
 	skb = lro_gen_skb(lro_mgr, frags,
 			  len, true_size, mac_hdr,
 			  max(hdr_len, LRO_MIN_PG_HLEN));
+	skb->ip_summed = lro_mgr->ip_summed;
+	skb->csum = sum;
 out:
 	return skb;
 }
 
 void lro_receive_frags(struct net_lro_mgr *lro_mgr,
 		       struct skb_frag_struct *frags,
-		       int len, int true_size, void *priv)
+		       int len, int true_size, void *priv, __wsum sum)
 {
 	struct sk_buff *skb;
 
-	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, NULL, 0, priv);
+	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, NULL, 0,
+				 priv, sum);
 	if(skb)
 		netif_receive_skb(skb);
 }
@@ -524,12 +542,13 @@ void lro_vlan_hwaccel_receive_frags(stru
 				    int true_size,
 				    struct vlan_group *vgrp,
 				    u16 vlan_tag,
-				    void *priv)
+				    void *priv,
+				    __wsum sum)
 {
 	struct sk_buff *skb;
 
 	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, vgrp,
-				 vlan_tag, priv);
+				 vlan_tag, priv, sum);
 	if(skb)
 		vlan_hwaccel_receive_skb(skb, vgrp, vlan_tag);
 }

--------------020803090500000001090709
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="myri10ge_lro.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myri10ge_lro.diff"

diff -urNp a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c	2007-07-24 15:57:12.000000000 -0400
+++ b/drivers/net/myri10ge/myri10ge.c	2007-07-25 13:10:54.000000000 -0400
@@ -48,6 +48,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
+#include <linux/inet_lro.h>
 #include <linux/ip.h>
 #include <linux/inet.h>
 #include <linux/in.h>
@@ -62,6 +63,8 @@
 #include <linux/io.h>
 #include <linux/log2.h>
 #include <net/checksum.h>
+#include <net/ip.h>
+#include <net/tcp.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
 #include <asm/processor.h>
@@ -89,6 +92,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 
 #define MYRI10GE_EEPROM_STRINGS_SIZE 256
 #define MYRI10GE_MAX_SEND_DESC_TSO ((65536 / 2048) * 2)
+#define MYRI10GE_MAX_LRO_DESCRIPTORS 8
 
 #define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
 #define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
@@ -151,6 +155,8 @@ struct myri10ge_rx_done {
 	dma_addr_t bus;
 	int cnt;
 	int idx;
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[MYRI10GE_MAX_LRO_DESCRIPTORS];
 };
 
 struct myri10ge_priv {
@@ -276,6 +282,14 @@ static int myri10ge_debug = -1;	/* defau
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
+static int myri10ge_lro = 1;
+module_param(myri10ge_lro, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload\n");
+
+static int myri10ge_lro_max_pkts = MYRI10GE_LRO_MAX_PKTS;
+module_param(myri10ge_lro_max_pkts, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_lro, "Number of LRO packets to be aggregated\n");
+
 static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
@@ -1001,6 +1015,8 @@ myri10ge_rx_done(struct myri10ge_priv *m
 	struct net_device *dev = mgp->dev;
 	u8 *va;
 
+	if (len < 80)
+		len = 80;	/* XXX LRO hack XXX */
 	len += MXGEFW_PAD;
 	idx = rx->cnt & rx->mask;
 	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
@@ -1019,6 +1035,15 @@ myri10ge_rx_done(struct myri10ge_priv *m
 		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
+	if (mgp->csum_flag && myri10ge_lro) {
+		rx_frags[0].page_offset += MXGEFW_PAD;
+		rx_frags[0].size -= MXGEFW_PAD;
+		len -= MXGEFW_PAD;
+		lro_receive_frags(&mgp->rx_done.lro_mgr, rx_frags,
+				  len, len, (void *)(unsigned long)csum, csum);
+		return 1;
+	}
+
 	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
 
 	/* allocate an skb to attach the page(s) to. */
@@ -1137,6 +1162,9 @@ static inline void myri10ge_clean_rx_don
 	mgp->stats.rx_packets += rx_packets;
 	mgp->stats.rx_bytes += rx_bytes;
 
+	if (myri10ge_lro)
+		lro_flush_all(&rx_done->lro_mgr);
+
 	/* restock receive rings if needed */
 	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
@@ -1717,10 +1745,69 @@ static void myri10ge_free_irq(struct myr
 		pci_disable_msi(pdev);
 }
 
+static int
+myri10ge_get_frag_header(struct skb_frag_struct *frag, void **mac_hdr,
+			 void **ip_hdr, void **tcpudp_hdr,
+			 u64 * hdr_flags, void *priv)
+{
+	struct ethhdr *eh;
+	struct vlan_ethhdr *veh;
+	struct iphdr *iph;
+	u8 *va = page_address(frag->page) + frag->page_offset;
+	unsigned long ll_hlen;
+	__wsum csum = (__wsum) (unsigned long)priv;
+
+	/* find the mac header, aborting if not IPv4 */
+
+	eh = (struct ethhdr *)va;
+	*mac_hdr = eh;
+	ll_hlen = ETH_HLEN;
+	if (eh->h_proto != htons(ETH_P_IP)) {
+		if (eh->h_proto == htons(ETH_P_8021Q)) {
+			veh = (struct vlan_ethhdr *)va;
+			if (veh->h_vlan_encapsulated_proto != htons(ETH_P_IP))
+				return -1;
+
+			ll_hlen += VLAN_HLEN;
+
+			/*
+			 *  HW checksum starts ETH_HLEN bytes into
+			 *  frame, so we must subtract off the VLAN
+			 *  header's checksum before csum can be used
+			 */
+			csum = csum_sub(csum, csum_partial(va + ETH_HLEN,
+							   VLAN_HLEN, 0));
+		} else {
+			return -1;
+		}
+	}
+	*hdr_flags = LRO_IPV4;
+
+	iph = (struct iphdr *)(va + ll_hlen);
+	*ip_hdr = iph;
+	if (iph->protocol != IPPROTO_TCP)
+		return -1;
+	*hdr_flags |= LRO_TCP;
+	*tcpudp_hdr = (u8 *) (*ip_hdr) + (iph->ihl << 2);
+
+	/* verify the IP checksum */
+	if (unlikely(ip_fast_csum((u8 *) iph, iph->ihl)))
+		return -1;
+
+	/* verify the  checksum */
+	if (unlikely(csum_tcpudp_magic(iph->saddr, iph->daddr,
+				       ntohs(iph->tot_len) - (iph->ihl << 2),
+				       IPPROTO_TCP, csum)))
+		return -1;
+
+	return 0;
+}
+
 static int myri10ge_open(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp;
 	struct myri10ge_cmd cmd;
+	struct net_lro_mgr *lro_mgr;
 	int status, big_pow2;
 
 	mgp = netdev_priv(dev);
@@ -1852,6 +1939,18 @@ static int myri10ge_open(struct net_devi
 	mgp->link_state = htonl(~0U);
 	mgp->rdma_tags_available = 15;
 
+	lro_mgr = &mgp->rx_done.lro_mgr;
+	lro_mgr->dev = dev;
+	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
+	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
+	lro_mgr->lro_arr = mgp->rx_done.lro_desc;
+	lro_mgr->get_frag_header = myri10ge_get_frag_header;
+	lro_mgr->max_aggr = 0xffff / dev->mtu;
+	if (lro_mgr->max_aggr > myri10ge_lro_max_pkts)
+		lro_mgr->max_aggr = myri10ge_lro_max_pkts;
+	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+
 	netif_poll_enable(mgp->dev);	/* must happen prior to any irq */
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);

--------------020803090500000001090709--
