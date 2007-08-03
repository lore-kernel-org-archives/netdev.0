From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH] lro: myri10ge example how to use LRO
Date: Fri, 03 Aug 2007 13:19:36 -0400
Message-ID: <46B363A8.4010407@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050000080608080106020207"
Cc: raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com,
	jeff@garzik.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1880 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763294AbXHCRUI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Aug 2007 13:20:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050000080608080106020207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

To follow up on Jan-Bernd Themann's LRO patch earlier today,
this patch shows how the generic LRO interface can be used for
page based drivers.

Again, many thanks to Jan-Bernd Themann for leading this effort.

Drew

Singed off by: Andrew Gallatin <gallatin@myri.com>

--------------050000080608080106020207
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="myri10ge_lro.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="myri10ge_lro.diff"

diff -urNp a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
--- a/drivers/net/myri10ge/myri10ge.c	2007-07-24 15:57:12.000000000 -0400
+++ b/drivers/net/myri10ge/myri10ge.c	2007-08-03 13:07:48.000000000 -0400
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
@@ -1019,6 +1033,15 @@ myri10ge_rx_done(struct myri10ge_priv *m
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
@@ -1137,6 +1160,9 @@ static inline void myri10ge_clean_rx_don
 	mgp->stats.rx_packets += rx_packets;
 	mgp->stats.rx_bytes += rx_bytes;
 
+	if (myri10ge_lro)
+		lro_flush_all(&rx_done->lro_mgr);
+
 	/* restock receive rings if needed */
 	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
 		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
@@ -1378,7 +1404,8 @@ static const char myri10ge_gstrings_stat
 	"dropped_pause", "dropped_bad_phy", "dropped_bad_crc32",
 	"dropped_unicast_filtered", "dropped_multicast_filtered",
 	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
-	"dropped_no_big_buffer"
+	"dropped_no_big_buffer", "LRO aggregated", "LRO flushed",
+	"LRO avg aggr", "LRO no_desc"
 };
 
 #define MYRI10GE_NET_STATS_LEN      21
@@ -1444,6 +1471,14 @@ myri10ge_get_ethtool_stats(struct net_de
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_overrun);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_small_buffer);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_big_buffer);
+	data[i++] = mgp->rx_done.lro_mgr.stats.aggregated;
+	data[i++] = mgp->rx_done.lro_mgr.stats.flushed;
+	if (mgp->rx_done.lro_mgr.stats.flushed)
+		data[i++] = mgp->rx_done.lro_mgr.stats.aggregated /
+		    mgp->rx_done.lro_mgr.stats.flushed;
+	else
+		data[i++] = 0;
+	data[i++] = mgp->rx_done.lro_mgr.stats.no_desc;
 }
 
 static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
@@ -1717,10 +1752,69 @@ static void myri10ge_free_irq(struct myr
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
@@ -1852,6 +1946,18 @@ static int myri10ge_open(struct net_devi
 	mgp->link_state = htonl(~0U);
 	mgp->rdma_tags_available = 15;
 
+	lro_mgr = &mgp->rx_done.lro_mgr;
+	lro_mgr->dev = dev;
+	lro_mgr->features = LRO_F_NAPI;
+	lro_mgr->ip_summed = CHECKSUM_COMPLETE;
+	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	lro_mgr->max_desc = MYRI10GE_MAX_LRO_DESCRIPTORS;
+	lro_mgr->lro_arr = mgp->rx_done.lro_desc;
+	lro_mgr->get_frag_header = myri10ge_get_frag_header;
+	lro_mgr->max_aggr = myri10ge_lro_max_pkts;
+	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+
 	netif_poll_enable(mgp->dev);	/* must happen prior to any irq */
 
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_UP, &cmd, 0);

--------------050000080608080106020207--
