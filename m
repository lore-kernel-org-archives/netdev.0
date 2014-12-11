From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 19:49:20 +0000
Message-ID: <20141211194920.GR11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:52308 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758899AbaLKTt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:49:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
all fragments with dma_map_single().  This fails when the driver is
used in an environment with highmem.

With this patch in place in 3.18:

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d44560d1d268..14d1fc9ff485 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -882,7 +882,9 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 		void *addr;
  
 		this_frag = &skb_shinfo(skb)->frags[frag];
+		BUG_ON(PageHighMem(this_frag->page.p));
 		addr = page_address(this_frag->page.p) + this_frag->page_offset;
+		BUG_ON(!addr);
 		tx_index = txq->tx_curr_desc++;
 		if (txq->tx_curr_desc == txq->tx_ring_size)
 			txq->tx_curr_desc = 0;

I regularly hit the first BUG_ON().  Without the BUG_ON(), the machine
either freezes or oopses in the DMA API functions due to them being
passed an invalid struct page *.

So, I'm unclear whether this is a driver bug, or whether it's a core
netdev bug: should netdev be passing skbuffs with highmem pages
attached when the driver has NETIF_F_HIGHDMA clear, or is Ezequiel's
patch removing the ability to map highmem pages from this driver
incorrect?

Here's the ethtool -k eth0 output for this driver:

Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: off [fixed]
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: off [fixed]
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: off [fixed]
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: off [fixed]
tx-vlan-offload: off [fixed]
ntuple-filters: off [fixed]
receive-hashing: off [fixed]
highdma: off [fixed]
rx-vlan-filter: off [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: off
loopback: off [fixed]
rx-fcs: off [fixed]
rx-all: off [fixed]
tx-vlan-stag-hw-insert: off [fixed]
rx-vlan-stag-hw-parse: off [fixed]
rx-vlan-stag-filter: off [fixed]
l2-fwd-offload: off [fixed]
busy-poll: off [fixed]

Thanks.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
