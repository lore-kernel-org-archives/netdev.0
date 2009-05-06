From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: [PATCH v2] igb: Record host memory receive overflow in net_stats
Date: Wed, 06 May 2009 10:56:38 +0200
Message-ID: <1241600198.5172.36.camel@localhost.localdomain>
References: <1241435206.8115.104.camel@localhost.localdomain>
	 <9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
	 <20090505.115819.84151021.davem@davemloft.net>
	 <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	 <273D38FBE7C6FE46A1689FCD014A0B8B49655903@azsmsx505.amr.corp.intel.com>
	 <1241597562.5172.25.camel@localhost.localdomain>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Ronciak, John" <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:53498 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbZEFI4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 04:56:39 -0400
In-Reply-To: <1241597562.5172.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The RNBC (Receive No Buffers Count) register for the 82576, indicate
that frames were received when there were no available buffers in host
memory to store those frames (receive descriptor head and tail
pointers were equal).  The packet is still received by the NIC if
there is space in the FIFO

I have shown that this situation can arise when the kernel is too
busy else where.

As the the RNBC value is not necessary a packet drop, I choose to
store the RNBC value in net_stats.rx_fifo_errors.

Saving the stats in dev->net_stats makes it visible via
/proc/net/dev as "fifo", and thus viewable to ifconfig
as "overruns" and 'netstat -i' as "RX-OVR".

The Receive No Buffers Count (RNBC) can already be queried by
ethtool -S as "rx_no_buffer_count".

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)


diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 183235d..3ee00a5 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3597,6 +3597,10 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->net_stats.rx_frame_errors = adapter->stats.algnerrc;
 	adapter->net_stats.rx_missed_errors = adapter->stats.mpc;
 
+	/* Note RNBC (Receive No Buffers Count) is an overflow
+	 * indication, thus not necessary a dropped packet. */
+	adapter->net_stats.rx_fifo_errors = adapter->stats.rnbc;
+
 	/* Tx Errors */
 	adapter->net_stats.tx_errors = adapter->stats.ecol +
 				       adapter->stats.latecol;

