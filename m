From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Tue, 13 Nov 2007 18:26:01 +0100
Message-ID: <4739DE29.2030507@trash.net>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au>
	<20071113.033611.73195922.davem@davemloft.net>
	<20071113120328.GB1086@gondor.apana.org.au>
	<20071113.040624.43544149.davem@davemloft.net>
	<20071113121647.GA1330@gondor.apana.org.au>
	<4739961E.90708@trash.net> <4739D3A5.4020503@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090706080101090309040505"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, joonwpark81@gmail.com,
	David Miller <davem@davemloft.net>, cfriesen@nortel.com, w@1wt.eu
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4739D3A5.4020503@intel.com>
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

This is a multi-part message in MIME format.
--------------090706080101090309040505
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Kok, Auke wrote:
> Patrick McHardy wrote:
>
>> I already posted a patch for this, not sure what happened to it.
>> Auke, any news on merging the secondary unicast address support?
> 
> I dropped the ball on that one. Care to resend it and send me one for e1000e as well?

Patch for e1000 attached.

Does e1000e also work with PCI cards if I add the proper IDs?
Otherwise I could only send an untested patch.


--------------090706080101090309040505
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[E1000]: Secondary unicast address support

Add support for configuring secondary unicast addresses. Unicast
addresses take precendece over multicast addresses when filling
the exact address filters to avoid going to promiscous mode.
When more unicast addresses are present than filter slots,
unicast filtering is disabled and all slots can be used for
multicast addresses.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 5d2e80a9c326ca529d278da823c8e4a4da91f612
tree 97a8ac20070b101c250e79912636124167a6dd07
parent 325d22df7b19e0116aff3391d3a03f73d0634ded
author Patrick McHardy <kaber@trash.net> Tue, 13 Nov 2007 18:23:34 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 13 Nov 2007 18:23:34 +0100

 drivers/net/e1000/e1000_main.c |   47 ++++++++++++++++++++++++++--------------
 1 files changed, 31 insertions(+), 16 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 72deff0..5fd5f51 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -153,7 +153,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
                                 struct e1000_tx_ring *tx_ring);
 static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
                                 struct e1000_rx_ring *rx_ring);
-static void e1000_set_multi(struct net_device *netdev);
+static void e1000_set_rx_mode(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
@@ -514,7 +514,7 @@ static void e1000_configure(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
-	e1000_set_multi(netdev);
+	e1000_set_rx_mode(netdev);
 
 	e1000_restore_vlan(adapter);
 	e1000_init_manageability(adapter);
@@ -926,7 +926,7 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
 	netdev->get_stats = &e1000_get_stats;
-	netdev->set_multicast_list = &e1000_set_multi;
+	netdev->set_rx_mode = &e1000_set_rx_mode;
 	netdev->set_mac_address = &e1000_set_mac;
 	netdev->change_mtu = &e1000_change_mtu;
 	netdev->do_ioctl = &e1000_ioctl;
@@ -2409,21 +2409,22 @@ e1000_set_mac(struct net_device *netdev, void *p)
 }
 
 /**
- * e1000_set_multi - Multicast and Promiscuous mode set
+ * e1000_set_rx_mode - Secondary Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
+ * The set_rx_mode entry point is called whenever the unicast or multicast
+ * address lists or the network interface flags are updated. This routine is
+ * responsible for configuring the hardware for proper unicast, multicast,
  * promiscuous mode, and all-multi behavior.
  **/
 
 static void
-e1000_set_multi(struct net_device *netdev)
+e1000_set_rx_mode(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	struct dev_mc_list *mc_ptr;
+	struct dev_addr_list *uc_ptr;
+	struct dev_addr_list *mc_ptr;
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
@@ -2446,9 +2447,16 @@ e1000_set_multi(struct net_device *netdev)
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
 	} else if (netdev->flags & IFF_ALLMULTI) {
 		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
 	} else {
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		rctl &= ~E1000_RCTL_MPE;
+	}
+
+	uc_ptr = NULL;
+	if (netdev->uc_count > rar_entries - 1) {
+		rctl |= E1000_RCTL_UPE;
+	} else if (!(netdev->flags & IFF_PROMISC)) {
+		rctl &= ~E1000_RCTL_UPE;
+		uc_ptr = netdev->uc_list;
 	}
 
 	E1000_WRITE_REG(hw, RCTL, rctl);
@@ -2458,7 +2466,10 @@ e1000_set_multi(struct net_device *netdev)
 	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_enter_82542_rst(adapter);
 
-	/* load the first 14 multicast address into the exact filters 1-14
+	/* load the first 14 addresses into the exact filters 1-14. Unicast
+	 * addresses take precedence to avoid disabling unicast filtering
+	 * when possible.
+	 *
 	 * RAR 0 is used for the station MAC adddress
 	 * if there are not 14 addresses, go ahead and clear the filters
 	 * -- with 82571 controllers only 0-13 entries are filled here
@@ -2466,8 +2477,11 @@ e1000_set_multi(struct net_device *netdev)
 	mc_ptr = netdev->mc_list;
 
 	for (i = 1; i < rar_entries; i++) {
-		if (mc_ptr) {
-			e1000_rar_set(hw, mc_ptr->dmi_addr, i);
+		if (uc_ptr) {
+			e1000_rar_set(hw, uc_ptr->da_addr, i);
+			uc_ptr = uc_ptr->next;
+		} else if (mc_ptr) {
+			e1000_rar_set(hw, mc_ptr->da_addr, i);
 			mc_ptr = mc_ptr->next;
 		} else {
 			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
@@ -2476,6 +2490,7 @@ e1000_set_multi(struct net_device *netdev)
 			E1000_WRITE_FLUSH(hw);
 		}
 	}
+	WARN_ON(uc_ptr != NULL);
 
 	/* clear the old settings from the multicast hash table */
 
@@ -2487,7 +2502,7 @@ e1000_set_multi(struct net_device *netdev)
 	/* load any remaining addresses into the hash table */
 
 	for (; mc_ptr; mc_ptr = mc_ptr->next) {
-		hash_value = e1000_hash_mc_addr(hw, mc_ptr->dmi_addr);
+		hash_value = e1000_hash_mc_addr(hw, mc_ptr->da_addr);
 		e1000_mta_set(hw, hash_value);
 	}
 
@@ -5104,7 +5119,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (wufc) {
 		e1000_setup_rctl(adapter);
-		e1000_set_multi(netdev);
+		e1000_set_rx_mode(netdev);
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {

--------------090706080101090309040505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------090706080101090309040505
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--------------090706080101090309040505--
