From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 6/6] S2IO: Restoring the mac address in s2io_reset
Date: Sat, 24 Feb 2007 02:04:24 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10702240203260.3434-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, sreenivasa.honnur@neterion.com,
	ramkrishna.vepa@neterion.com, santosh.rastapur@neterion.com,
	alicia.pena@neterion.com, sriram.rapuru@neterion.com
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:45824 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933401AbXBXHEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 02:04:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Restore in s2io_reset, the mac address assigned during s2io_open.
  Earlier, it was getting overwritten to the factory default (read from the
  eeprom) and subsequently dropping received frames.

- Fixed the typo in calling rtnl_unlock in s2io_set_link function.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch5/drivers/net/s2io.c patch6/drivers/net/s2io.c
--- patch5/drivers/net/s2io.c	2007-02-21 15:23:00.000000000 +0530
+++ patch6/drivers/net/s2io.c	2007-02-21 17:02:48.000000000 +0530
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.16.1"
+#define DRV_VERSION "2.0.17.1"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -3394,6 +3394,9 @@ new_way:
 		writeq(val64, &bar0->pcc_err_reg);
 	}
 
+	/* restore the previously assigned mac address */
+	s2io_set_mac_addr(sp->dev, (u8 *)&sp->def_mac_addr[0].mac_addr);
+
 	sp->device_enabled_once = FALSE;
 }
 
@@ -4512,6 +4515,7 @@ static int s2io_set_mac_addr(struct net_
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	register u64 val64, mac_addr = 0;
 	int i;
+	u64 old_mac_addr = 0;
 
 	/*
 	 * Set the new MAC address as the new unicast filter and reflect this
@@ -4521,6 +4525,22 @@ static int s2io_set_mac_addr(struct net_
 	for (i = 0; i < ETH_ALEN; i++) {
 		mac_addr <<= 8;
 		mac_addr |= addr[i];
+		old_mac_addr <<= 8;
+		old_mac_addr |= sp->def_mac_addr[0].mac_addr[i];
+	}
+
+	if(0 == mac_addr)
+		return SUCCESS;
+
+	/* Update the internal structure with this new mac address */
+	if(mac_addr != old_mac_addr) {
+		memset(sp->def_mac_addr[0].mac_addr, 0, sizeof(ETH_ALEN));
+		sp->def_mac_addr[0].mac_addr[5] = (u8) (mac_addr);
+		sp->def_mac_addr[0].mac_addr[4] = (u8) (mac_addr >> 8);
+		sp->def_mac_addr[0].mac_addr[3] = (u8) (mac_addr >> 16);
+		sp->def_mac_addr[0].mac_addr[2] = (u8) (mac_addr >> 24);
+		sp->def_mac_addr[0].mac_addr[1] = (u8) (mac_addr >> 32);
+		sp->def_mac_addr[0].mac_addr[0] = (u8) (mac_addr >> 40);
 	}
 
 	writeq(RMAC_ADDR_DATA0_MEM_ADDR(mac_addr),
@@ -6022,7 +6042,7 @@ static void s2io_set_link(struct work_st
 	clear_bit(0, &(nic->link_state));
 
 out_unlock:
-	rtnl_lock();
+	rtnl_unlock();
 }
 
 static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
@@ -7182,8 +7202,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	mac_down = (u32) tmp64;
 	mac_up = (u32) (tmp64 >> 32);
 
-	memset(sp->def_mac_addr[0].mac_addr, 0, sizeof(ETH_ALEN));
-
 	sp->def_mac_addr[0].mac_addr[3] = (u8) (mac_up);
 	sp->def_mac_addr[0].mac_addr[2] = (u8) (mac_up >> 8);
 	sp->def_mac_addr[0].mac_addr[1] = (u8) (mac_up >> 16);

