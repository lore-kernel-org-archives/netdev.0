From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 18 Feb 2011 12:20:16 +1100
Message-ID: <20110218122016.bc3d6470.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/e1000e/netdev.c between commit
713b3c9e4c1a6da6b45da6474ed554ed0a48de69 ("e1000e: flush all writebacks
before unload") from the net-current tree and commit
67fd4fcb78a7ced369a6bd8a131ec8c65ebd2bbb ("e1000e: convert to stats64")
from the net tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/e1000e/netdev.c
index 3fa110d,7cedfeb..0000000
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@@ -3344,21 -3335,8 +3341,23 @@@ int e1000e_up(struct e1000_adapter *ada
  	return 0;
  }
  
 +static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
 +{
 +	struct e1000_hw *hw = &adapter->hw;
 +
 +	if (!(adapter->flags2 & FLAG2_DMA_BURST))
 +		return;
 +
 +	/* flush pending descriptor writebacks to memory */
 +	ew32(TIDV, adapter->tx_int_delay | E1000_TIDV_FPD);
 +	ew32(RDTR, adapter->rx_int_delay | E1000_RDTR_FPD);
 +
 +	/* execute the writes immediately */
 +	e1e_flush();
 +}
 +
+ static void e1000e_update_stats(struct e1000_adapter *adapter);
+ 
  void e1000e_down(struct e1000_adapter *adapter)
  {
  	struct net_device *netdev = adapter->netdev;
@@@ -4179,11 -4154,7 +4186,10 @@@ static void e1000_watchdog_task(struct 
  	struct e1000_ring *tx_ring = adapter->tx_ring;
  	struct e1000_hw *hw = &adapter->hw;
  	u32 link, tctl;
- 	int tx_pending = 0;
  
 +	if (test_bit(__E1000_DOWN, &adapter->state))
 +		return;
 +
  	link = e1000e_has_link(adapter);
  	if ((netif_carrier_ok(netdev)) && link) {
  		/* Cancel scheduled suspend requests. */
