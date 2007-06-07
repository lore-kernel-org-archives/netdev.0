From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 2/4] NetXen: Fix ping issue after reboot on Blades with 3.4.19 firmware
Date: Thu, 7 Jun 2007 04:33:02 -0700
Message-ID: <200706071133.l57BX2G6007563@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, mithlesh@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:17718 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753465AbXFGLdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 07:33:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix initialization and subsequent ping issue on 3.4.19 firmware
This patch fixes the ping problem seen X/PBlades after the adapter's 
firmware was moved to 3.4.19. After configured interface up, ping 
failed. 
NetXen adapter couldn't accept ARP broadcast packet. Manual addition of
MAC address in the ARP table, made ping work.
NetXen adapter should finish initilization after system boot. But looks
NetXen adapter didn't initilization correctly after system boot up.
So have to re-load the firmware again in probe routine.
Also re-initilization netxen_config_0 and netxen_config_1 registers.

Signed-off by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off by: Mithlesh Thukral <mithlesh@netxen.com>
---

 drivers/net/netxen/netxen_nic_main.c |    7 +++++++
 drivers/net/netxen/netxen_nic_niu.c  |    8 ++------
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index c61181f..6167b58 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -542,6 +542,13 @@ #endif
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
+
+	       /* leave the hw in the same state as reboot */
+	       writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
+	       netxen_pinit_from_rom(adapter, 0);
+	       udelay(500);
+	       netxen_load_firmware(adapter);
+	       netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
 
 	/*
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index cef90a7..75102d3 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -454,16 +454,12 @@ int netxen_niu_gbe_init_port(struct netx
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
-	u32 reg;
 	u32 portnum = physical_port[adapter->portnum];
 
 	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_0+(0x10000*portnum), 0x5);
-	netxen_nic_hw_read_wx(adapter,
-		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), &reg, 4);
-	reg = (reg & ~0x2000UL);
+		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), 0x1447);
 	netxen_crb_writelit_adapter(adapter,
-		NETXEN_NIU_XGE_CONFIG_1+(0x10000*portnum), reg);
+		NETXEN_NIU_XGE_CONFIG_0+(0x10000*portnum), 0x5);
 
 	return 0;
 }
