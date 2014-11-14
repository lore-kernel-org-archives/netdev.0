From: "Martin K. Petersen" <martin.petersen@oracle.com>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 15:20:09 -0500
Message-ID: <yq1mw7tv8jq.fsf@sermon.lab.mkp.net>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
	<54666106.9000609@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>,
	netdev@vger.kernel.org, linux.nics@intel.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:43726 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbaKNUUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:20:18 -0500
In-Reply-To: <54666106.9000609@cogentembedded.com> (Sergei Shtylyov's message
	of "Fri, 14 Nov 2014 23:07:34 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Sergei" == Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

>> +#ifdef CONFIG_OF
>> + ixgbe_of_mac_addr(adapter);
>> +#endif

Sergei>    Eww... why not define the following above instead:

Sergei> #else
Sergei> static inline void ixgbe_of_mac_addr(struct ixgbe_adapter
Sergei> *adapter) {}
Sergei> #endif

I don't care much either way. But we might as well do this, then, and
shave off an ifdef...

commit 01e25f145972563ee87ebf85b7cb02a4ff8fce3b
Author: Martin K. Petersen <martin.petersen@oracle.com>
Date:   Wed Nov 12 20:47:42 2014 -0500

    ixgbe: Look up MAC address in Open Firmware
    
    Attempt to look up the MAC address in Open Firmware on systems that
    support it. If the "local-mac-address" property is not valid resort to
    using the IDPROM value.
    
    Signed-off-by: Martin K. Petersen <martin.petersen@oracle.com>

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d2df4e3d1032..0e45a43172eb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -50,6 +50,11 @@
 #include <linux/prefetch.h>
 #include <scsi/fc/fc_fcoe.h>
 
+#ifdef CONFIG_OF
+#include <asm/idprom.h>
+#include <asm/prom.h>
+#endif
+
 #include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb_82599.h"
@@ -7960,6 +7965,31 @@ int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
 }
 
 /**
+ * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
+ * @adapter: Pointer to adapter struct
+ */
+static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
+{
+#ifdef CONFIG_OF
+	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	const unsigned char *addr;
+	int len;
+
+	addr = of_get_property(dp, "local-mac-address", &len);
+	if (addr && len == 6) {
+		e_dev_info("Using OpenPROM MAC address\n");
+		memcpy(hw->mac.perm_addr, addr, 6);
+	}
+
+	if (!is_valid_ether_addr(hw->mac.perm_addr)) {
+		e_dev_info("Using IDPROM MAC address\n");
+		memcpy(hw->mac.perm_addr, idprom->id_ethaddr, 6);
+	}
+#endif
+}
+
+/**
  * ixgbe_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in ixgbe_pci_tbl
@@ -8223,6 +8253,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	ixgbe_of_mac_addr(adapter);
+
 	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
