From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 2/2] igb: Record host memory receive overflow in net_stats
Date: Thu, 07 May 2009 15:38:32 +0200
Message-ID: <1241703512.18487.27.camel@localhost.localdomain>
References: <1241703346.18487.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:37860 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760001AbZEGNic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 09:38:32 -0400
In-Reply-To: <1241703346.18487.22.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The RNBC (Receive No Buffers Count) register for the 82576, indicate
that frames were received when there were no available buffers in host
memory to store those frames (receive descriptor head and tail
pointers were equal).  The packet is still received by the NIC if
there is space in the FIFO on the NIC.

I have shown that this situation can arise when the kernel is too
busy else where.

As the the RNBC value is not necessary a packet drop, I choose to
store the RNBC value in net_stats.rx_fifo_errors, as its potentically
not a true drop.

Saving the stats in dev->net_stats makes it visible via
/proc/net/dev as "fifo", and thus viewable to ifconfig
as "overruns" and 'netstat -i' as "RX-OVR".

The Receive No Buffers Count (RNBC) can already be queried by
ethtool -S as "rx_no_buffer_count".

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 06b01fc..539b9f8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3496,6 +3496,7 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	u16 phy_tmp;
 	u32 rqdpc_tmp;
+	u64 rqdpc_total = 0;
 	int i;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
@@ -3598,7 +3599,15 @@ void igb_update_stats(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0xFFF;
 		adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+		rqdpc_total += adapter->rx_ring[i].rx_stats.drops;
 	}
+	adapter->net_stats.rx_fifo_errors = rqdpc_total;
+
+	/* Note RNBC (Receive No Buffers Count) is an not an exact
+	 * drop count as the hardware FIFO might save the day.  Thats
+	 * one of the reason for saving it in rx_fifo_errors, as its
+	 * potentically not a true drop. */
+	adapter->net_stats.rx_fifo_errors += adapter->stats.rnbc;
 
 	/* RLEC on some newer hardware can be incorrect so build
 	* our own version based on RUC and ROC */


