From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/8] ixgbe: fix several counter register errata
Date: Fri, 01 Feb 2008 15:59:14 -0800
Message-ID: <20080201235914.31474.76845.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

Several counters behave differently on 82598 causing them to display
incorrect values. Adjust the accounting so the reported numbers
make sense and do not double count or represent the wrong item.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   53 +++++++++++++++++++++++-----------------
 1 files changed, 31 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ee5ee10..6e7d90e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2026,22 +2026,26 @@ static int ixgbe_close(struct net_device *netdev)
 void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u64 good_rx, missed_rx, bprc;
+	u64 total_mpc = 0;
+	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
-	good_rx = IXGBE_READ_REG(hw, IXGBE_GPRC);
-	missed_rx = IXGBE_READ_REG(hw, IXGBE_MPC(0));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(1));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(2));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(3));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(4));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(5));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(6));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(7));
-	adapter->stats.gprc += (good_rx - missed_rx);
-
-	adapter->stats.mpc[0] += missed_rx;
+	for (i = 0; i < 8; i++) {
+		/* for packet buffers not used, the register should read 0 */
+		mpc = IXGBE_READ_REG(hw, IXGBE_MPC(i));
+		missed_rx += mpc;
+		adapter->stats.mpc[i] += mpc;
+		total_mpc += adapter->stats.mpc[i];
+		adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+	}
+	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
+	/* work around hardware counting issue */
+	adapter->stats.gprc -= missed_rx;
+
+	/* 82598 hardware only has a 32 bit counter in the high register */
 	adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 	bprc = IXGBE_READ_REG(hw, IXGBE_BPRC);
 	adapter->stats.bprc += bprc;
 	adapter->stats.mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
@@ -2053,28 +2057,34 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->stats.prc511 += IXGBE_READ_REG(hw, IXGBE_PRC511);
 	adapter->stats.prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
 	adapter->stats.prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
-
 	adapter->stats.rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
 	adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
-	adapter->stats.lxontxc += IXGBE_READ_REG(hw, IXGBE_LXONTXC);
 	adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
-	adapter->stats.lxofftxc += IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	lxon = IXGBE_READ_REG(hw, IXGBE_LXONTXC);
+	adapter->stats.lxontxc += lxon;
+	lxoff = IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	adapter->stats.lxofftxc += lxoff;
 	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
 	adapter->stats.gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
-	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
-	adapter->stats.rnbc[0] += IXGBE_READ_REG(hw, IXGBE_RNBC(0));
+	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
+	/*
+	 * 82598 errata - tx of flow control packets is included in tx counters
+	 */
+	xon_off_tot = lxon + lxoff;
+	adapter->stats.gptc -= xon_off_tot;
+	adapter->stats.mptc -= xon_off_tot;
+	adapter->stats.gotc -= (xon_off_tot * (ETH_ZLEN + ETH_FCS_LEN));
 	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
 	adapter->stats.rfc += IXGBE_READ_REG(hw, IXGBE_RFC);
 	adapter->stats.rjc += IXGBE_READ_REG(hw, IXGBE_RJC);
-	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 	adapter->stats.tpr += IXGBE_READ_REG(hw, IXGBE_TPR);
 	adapter->stats.ptc64 += IXGBE_READ_REG(hw, IXGBE_PTC64);
+	adapter->stats.ptc64 -= xon_off_tot;
 	adapter->stats.ptc127 += IXGBE_READ_REG(hw, IXGBE_PTC127);
 	adapter->stats.ptc255 += IXGBE_READ_REG(hw, IXGBE_PTC255);
 	adapter->stats.ptc511 += IXGBE_READ_REG(hw, IXGBE_PTC511);
 	adapter->stats.ptc1023 += IXGBE_READ_REG(hw, IXGBE_PTC1023);
 	adapter->stats.ptc1522 += IXGBE_READ_REG(hw, IXGBE_PTC1522);
-	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
 	adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
 
 	/* Fill out the OS statistics structure */
@@ -2090,8 +2100,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->net_stats.rx_dropped = 0;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_missed_errors = adapter->stats.mpc[0];
-
+	adapter->net_stats.rx_missed_errors = total_mpc;
 }
 
 /**


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
