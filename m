From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [RFC][PATCH]: e1000e: If ASPM L0s needs to be disabled, do it
 prior to enabling device
Date: Tue, 22 Mar 2011 13:16:42 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A900183167B00@orsmsx509.amr.corp.intel.com>
References: <20110322194437.3043.97757.sendpatchset@nchumbalkar.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Naga Chumbalkar <nagananda.chumbalkar@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2291 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab1CVUQp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 16:16:45 -0400
In-Reply-To: <20110322194437.3043.97757.sendpatchset@nchumbalkar.americas.hpqcorp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Naga Chumbalkar [mailto:nagananda.chumbalkar@hp.com]
>Sent: Tuesday, March 22, 2011 12:49 PM
>To: davem@davemloft.net
>Cc: netdev@vger.kernel.org; Naga Chumbalkar; Allan, Bruce W
>Subject: [RFC][PATCH]: e1000e: If ASPM L0s needs to be disabled, do it prior to
>enabling device
>
>If ASPM L0s needs to be disabled due to HW errata, do it prior to
>"enabling" the device. This way if the kernel ever defaults its
>aspm_policy to POLICY_POWERSAVE, then the e1000e driver will get a
>chance to disable ASPM on the misbehaving device *prior* to calling
>pci_enable_device_mem(). This will be useful in situations
>where the BIOS indicates ASPM support on the server by clearing the
>ACPI FADT "ASPM Controls" bit.
>
>Note:
>The kernel (2.6.38) currently uses the BIOS "default" as its aspm_policy.
>However, Linux distros can diverge from that and set the default to "powersave".
>
>Signed-off-by: Naga Chumbalkar <nagananda.chumbalkar@hp.com>
>Cc: Bruce Allan <bruce.w.allan@intel.com>
>
>---
> drivers/net/e1000e/82571.c  |   10 +++++-----
> drivers/net/e1000e/e1000.h  |    1 +
> drivers/net/e1000e/netdev.c |   25 +++++++++++++++++++++----
> 3 files changed, 27 insertions(+), 9 deletions(-)
>
>diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
>index 89a6903..5fddc94 100644
>--- a/drivers/net/e1000e/82571.c
>+++ b/drivers/net/e1000e/82571.c
>@@ -431,9 +431,6 @@ static s32 e1000_get_variants_82571(struct e1000_adapter
>*adapter)
> 	case e1000_82573:
> 	case e1000_82574:
> 	case e1000_82583:
>-		/* Disable ASPM L0s due to hardware errata */
>-		e1000e_disable_aspm(adapter->pdev, PCIE_LINK_STATE_L0S);
>-
> 		if (pdev->device == E1000_DEV_ID_82573L) {
> 			adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
> 			adapter->max_hw_frame_size = DEFAULT_JUMBO;
>@@ -2066,7 +2063,8 @@ struct e1000_info e1000_82573_info = {
> 				  | FLAG_HAS_SMART_POWER_DOWN
> 				  | FLAG_HAS_AMT
> 				  | FLAG_HAS_SWSM_ON_LOAD,
>-	.flags2			= FLAG2_DISABLE_ASPM_L1,
>+	.flags2			= FLAG2_DISABLE_ASPM_L1
>+				  | FLAG2_DISABLE_ASPM_L0S,
> 	.pba			= 20,
> 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
> 	.get_variants		= e1000_get_variants_82571,
>@@ -2086,7 +2084,8 @@ struct e1000_info e1000_82574_info = {
> 				  | FLAG_HAS_SMART_POWER_DOWN
> 				  | FLAG_HAS_AMT
> 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
>-	.flags2			  = FLAG2_CHECK_PHY_HANG,
>+	.flags2			  = FLAG2_CHECK_PHY_HANG
>+				  | FLAG2_DISABLE_ASPM_L0S,
> 	.pba			= 32,
> 	.max_hw_frame_size	= DEFAULT_JUMBO,
> 	.get_variants		= e1000_get_variants_82571,
>@@ -2104,6 +2103,7 @@ struct e1000_info e1000_82583_info = {
> 				  | FLAG_HAS_SMART_POWER_DOWN
> 				  | FLAG_HAS_AMT
> 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
>+	.flags2			= FLAG2_DISABLE_ASPM_L0S,
> 	.pba			= 32,
> 	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
> 	.get_variants		= e1000_get_variants_82571,
>diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
>index 00bf595..ff224a7 100644
>--- a/drivers/net/e1000e/e1000.h
>+++ b/drivers/net/e1000e/e1000.h
>@@ -458,6 +458,7 @@ struct e1000_info {
> #define FLAG2_DMA_BURST                   (1 << 6)
> #define FLAG2_DISABLE_AIM                 (1 << 8)
> #define FLAG2_CHECK_PHY_HANG              (1 << 9)
>+#define FLAG2_DISABLE_ASPM_L0S            (1 << 10)
>
> #define E1000_RX_DESC_PS(R, i)	    \
> 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
>diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
>index a39d4a4..f60deec 100644
>--- a/drivers/net/e1000e/netdev.c
>+++ b/drivers/net/e1000e/netdev.c
>@@ -5393,13 +5393,19 @@ static int __e1000_resume(struct pci_dev *pdev)
> 	struct net_device *netdev = pci_get_drvdata(pdev);
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	struct e1000_hw *hw = &adapter->hw;
>+	static int aspm_disable_flag;
> 	u32 err;
>
>+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L0S)
>+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
>+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
>+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
>+	if (aspm_disable_flag)
>+		e1000e_disable_aspm(pdev, aspm_disable_flag);
>+
> 	pci_set_power_state(pdev, PCI_D0);
> 	pci_restore_state(pdev);
> 	pci_save_state(pdev);
>-	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
>-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
>
> 	e1000e_set_interrupt_capability(adapter);
> 	if (netif_running(netdev)) {
>@@ -5643,11 +5649,17 @@ static pci_ers_result_t e1000_io_slot_reset(struct
>pci_dev *pdev)
> 	struct net_device *netdev = pci_get_drvdata(pdev);
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
> 	struct e1000_hw *hw = &adapter->hw;
>+	static int aspm_disable_flag;
> 	int err;
> 	pci_ers_result_t result;
>
>+	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L0S)
>+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
> 	if (adapter->flags2 & FLAG2_DISABLE_ASPM_L1)
>-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
>+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
>+	if (aspm_disable_flag)
>+		e1000e_disable_aspm(pdev, aspm_disable_flag);
>+
> 	err = pci_enable_device_mem(pdev);
> 	if (err) {
> 		dev_err(&pdev->dev,
>@@ -5789,12 +5801,17 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
> 	resource_size_t flash_start, flash_len;
>
> 	static int cards_found;
>+	static int aspm_disable_flag;
> 	int i, err, pci_using_dac;
> 	u16 eeprom_data = 0;
> 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
>
>+	if (ei->flags2 & FLAG2_DISABLE_ASPM_L0S)
>+		aspm_disable_flag = PCIE_LINK_STATE_L0S;
> 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L1)
>-		e1000e_disable_aspm(pdev, PCIE_LINK_STATE_L1);
>+		aspm_disable_flag |= PCIE_LINK_STATE_L1;
>+	if (aspm_disable_flag)
>+		e1000e_disable_aspm(pdev, aspm_disable_flag);
>
> 	err = pci_enable_device_mem(pdev);
> 	if (err)
>--
>1.7.1.2

Yeah, I was thinking this very thing was needed after seeing the patchset
from Naga yesterday on linux-pci/lkml, but was beaten to it ;-)

Jeff Kirsher, when you pull this into your tree for Intel validation, you
can add my ACK to it.

Thanks Naga,
Bruce.
