From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [PATCH] e1000: do not allow watchdog to reenable
 transmits on shutdown (v2)
Date: Fri, 7 Mar 2014 17:59:26 -0300
Message-ID: <20140307205926.GA5041@amt.cnet>
References: <20140307020420.GA10797@amt.cnet>
	<1394162671.2214.36.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladimir Davydov <VDavydov@parallels.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1394162671.2214.36.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


There is a race on the shutdown path of the e1000 driver
that allows the card to DMA into free'd memory.

The symptoms are similar to those described at
commit d5bc77a223b0e9b9dfb002048d2b34a79e7d0b48,
"e1000: don't enable dma receives until after dma address has been
setup", where memory corruption is visible due to E1000_RXD_STAT_DD
being written to the DMA transfer descriptor.

Fix by not allowing the watchdog and tx fifo stall detector
to re-enable E1000_TCTL_EN.

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 10a0f22..bb5dc1a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -321,7 +321,8 @@ struct e1000_adapter {
 enum e1000_state_t {
 	__E1000_TESTING,
 	__E1000_RESETTING,
-	__E1000_DOWN
+	__E1000_DOWN,
+	__E1000_NOTX = 4,
 };
 
 #undef pr_fmt
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 46e6544..a39484f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -414,6 +414,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	e1000_configure(adapter);
 
 	clear_bit(__E1000_DOWN, &adapter->flags);
+	clear_bit(__E1000_NOTX, &adapter->flags);
 
 	napi_enable(&adapter->napi);
 
@@ -524,6 +525,11 @@ void e1000_down(struct e1000_adapter *adapter)
 
 	netif_tx_disable(netdev);
 
+	/* do not allow watchdog to reenable transmits between
+	 * clearing E1000_TCTL_EN below and setting E1000_DOWN
+	 */
+	set_bit(__E1000_NOTX, &adapter->flags);
+
 	/* disable transmits in the hardware */
 	tctl = er32(TCTL);
 	tctl &= ~E1000_TCTL_EN;
@@ -2339,6 +2345,9 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
 
+	if (test_bit(__E1000_NOTX, &adapter->flags))
+		return;
+
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
 		   (er32(TDFT) == er32(TDFH)) &&
@@ -2412,6 +2421,9 @@ static void e1000_watchdog(struct work_struct *work)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
 
+	if (test_bit(__E1000_NOTX, &adapter->flags))
+		return;
+
 	link = e1000_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link)
 		goto link_up;

------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
