From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Wed, 06 May 2009 22:59:55 +0200
Message-ID: <1241643595.2234.9.camel@localhost.localdomain>
References: <20090505.115819.84151021.davem@davemloft.net>
	 <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	 <9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
	 <20090505.143529.148721206.davem@davemloft.net>
	 <1241595993.5172.4.camel@localhost.localdomain>
	 <Pine.WNT.4.64.0905060048570.22956@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1241615351.5172.60.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hawk@diku.dk" <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:56039 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756112AbZEFU74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:59:56 -0400
In-Reply-To: <1241615351.5172.60.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-06 at 15:09 +0200, Jesper Dangaard Brouer wrote:
> > In the SRRCTL registers, there is a DROP_EN bit, bit 31.  If this 
> > bit is set to 1b for the queue in question, then the packet will be 
> > dropped when there are no buffers in the packet buffer.  This does
> not 
> > mean the FIFO is full or has been overrun, it just means there's no
> more
> > descriptors available in the Rx ring for that queue.  In this case,
> RNBC 
> > is incremented, MPC is not.
> 
> My experience is that if DROP_EN bit is *set*. Then I cannot find the
> drop count anywhere... not in RNBC and not in MPC ... and I can still
> see the drops with my netfilter module mp2t.
> 
> ethtool -S eth21 | egrep 'rx_no_buffer_count|rx_miss'
>      rx_no_buffer_count: 0
>      rx_missed_errors: 0
> 
> I'm guessing that the drop counters are now in the per queue RQDPC
> register (Receive Queue Drop Packet Count), but reading that is not
> implemented in the driver. 

Just did a quick implemenation in the driver, see draft patch below (not
ready for inclusion yet!).

An my guess was correct, the drops count is stored per queue in RQDPC.
The only really anoying thing is that this counter is only 12 bit, thus
overruns can occur quickly.  (This reminds me of my drop count
implemenation for Sun niu driver.  This counter has less bits that the 
Sun counter, but at least it automatically clears on reads)

I'll post some more clean patches tomorrow...

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


Quick implemenation of register:
Receive Queue Drop Packet Count - RQDPC (0xC030 + 0x40*n [n=0...15]; RC).
---

 drivers/net/igb/e1000_regs.h  |    2 ++
 drivers/net/igb/igb.h         |    1 +
 drivers/net/igb/igb_ethtool.c |    4 ++++
 drivers/net/igb/igb_main.c    |    6 ++++++
 4 files changed, 13 insertions(+), 0 deletions(-)


diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 0bd7728..85683e2 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -165,6 +165,8 @@ enum {
 				    : (0x0C018 + ((_n) * 0x40)))
 #define E1000_RXDCTL(_n)  ((_n) < 4 ? (0x02828 + ((_n) * 0x100)) \
 				    : (0x0C028 + ((_n) * 0x40)))
+#define E1000_RQDPC(_n)   ((_n) < 4 ? (0x02830 + ((_n) * 0x100)) \
+				    : (0x0C030 + ((_n) * 0x40)))
 #define E1000_TDBAL(_n)   ((_n) < 4 ? (0x03800 + ((_n) * 0x100)) \
 				    : (0x0E000 + ((_n) * 0x40)))
 #define E1000_TDBAH(_n)   ((_n) < 4 ? (0x03804 + ((_n) * 0x100)) \
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 4e8464b..4a16ac0 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -140,6 +140,7 @@ struct igb_buffer {
 struct igb_queue_stats {
 	u64 packets;
 	u64 bytes;
+	u64 drops;
 };
 
 struct igb_ring {
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 27eae49..b0d3100 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1998,12 +1998,16 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "tx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_queue_%u_drops", i);
+			p += ETH_GSTRING_LEN;
 		}
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			sprintf(p, "rx_queue_%u_packets", i);
 			p += ETH_GSTRING_LEN;
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
+			sprintf(p, "rx_queue_%u_drops", i);
+			p += ETH_GSTRING_LEN;
 		}
 /*		BUG_ON(p - data != IGB_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 183235d..20190bb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3494,6 +3494,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_tmp;
+	int i;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -3583,6 +3584,11 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->net_stats.multicast = adapter->stats.mprc;
 	adapter->net_stats.collisions = adapter->stats.colc;
 
+	/* Read out drops stats per RX queue */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		adapter->rx_ring[i].rx_stats.drops += rd32(E1000_RQDPC(i));
+	}
+
 	/* Rx Errors */
 
 	/* RLEC on some newer hardware can be incorrect so build


