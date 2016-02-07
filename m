From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: factor out register bit twiddling code
Date: Sun, 07 Feb 2016 22:30:59 +0300
Message-ID: <16172313.gq61xOomR3@wasted.cogentembedded.com>
References: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <10945950.IO3b17qsSH@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The  driver has often repeated pattern of reading a register,  AND'ing and/or
OR'ing some bits  and writing  the  value back. Factor the pattern out into
sh_eth_modify() -- this saves  84 bytes of code with ARM gcc 4.7.3.

While at it, update Cogent Embedded's copyright.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |   53 +++++++++++++++-------------------
 1 file changed, 24 insertions(+), 29 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -3,7 +3,7 @@
  *  Copyright (C) 2014  Renesas Electronics Corporation
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2014 Renesas Solutions Corp.
- *  Copyright (C) 2013-2014 Cogent Embedded, Inc.
+ *  Copyright (C) 2013-2016 Cogent Embedded, Inc.
  *  Copyright (C) 2014 Codethink Limited
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -428,6 +428,13 @@ static u32 sh_eth_read(struct net_device
 	return ioread32(mdp->addr + offset);
 }
 
+static void sh_eth_modify(struct net_device *ndev, int enum_index, u32 mask,
+			  u32 value)
+{
+	sh_eth_write(ndev, (sh_eth_read(ndev, enum_index) & ~mask) | value,
+		     enum_index);
+}
+
 static bool sh_eth_is_gether(struct sh_eth_private *mdp)
 {
 	return mdp->reg_offset == sh_eth_offset_gigabit;
@@ -467,10 +474,7 @@ static void sh_eth_set_duplex(struct net
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
-	if (mdp->duplex) /* Full */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_DM, ECMR);
-	else		/* Half */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
+	sh_eth_modify(ndev, ECMR, ECMR_DM, mdp->duplex ? ECMR_DM : 0);
 }
 
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -583,10 +587,10 @@ static void sh_eth_set_rate_r8a777x(stru
 
 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_ELB, ECMR);
+		sh_eth_modify(ndev, ECMR, ECMR_ELB, 0);
 		break;
 	case 100:/* 100BASE */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_ELB, ECMR);
+		sh_eth_modify(ndev, ECMR, ECMR_ELB, ECMR_ELB);
 		break;
 	default:
 		break;
@@ -649,10 +653,10 @@ static void sh_eth_set_rate_sh7724(struc
 
 	switch (mdp->speed) {
 	case 10: /* 10BASE */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_RTM, ECMR);
+		sh_eth_modify(ndev, ECMR, ECMR_RTM, 0);
 		break;
 	case 100:/* 100BASE */
-		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) | ECMR_RTM, ECMR);
+		sh_eth_modify(ndev, ECMR, ECMR_RTM, ECMR_RTM);
 		break;
 	default:
 		break;
@@ -924,8 +928,7 @@ static int sh_eth_reset(struct net_devic
 
 	if (sh_eth_is_gether(mdp) || sh_eth_is_rz_fast_ether(mdp)) {
 		sh_eth_write(ndev, EDSR_ENALL, EDSR);
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_GETHER,
-			     EDMR);
+		sh_eth_modify(ndev, EDMR, EDMR_SRST_GETHER, EDMR_SRST_GETHER);
 
 		ret = sh_eth_check_reset(ndev);
 		if (ret)
@@ -949,11 +952,9 @@ static int sh_eth_reset(struct net_devic
 		if (mdp->cd->select_mii)
 			sh_eth_select_mii(ndev);
 	} else {
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) | EDMR_SRST_ETHER,
-			     EDMR);
+		sh_eth_modify(ndev, EDMR, EDMR_SRST_ETHER, EDMR_SRST_ETHER);
 		mdelay(3);
-		sh_eth_write(ndev, sh_eth_read(ndev, EDMR) & ~EDMR_SRST_ETHER,
-			     EDMR);
+		sh_eth_modify(ndev, EDMR, EDMR_SRST_ETHER, 0);
 	}
 
 	return ret;
@@ -1285,7 +1286,7 @@ static int sh_eth_dev_init(struct net_de
 	sh_eth_write(ndev, ndev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN,
 		     RFLR);
 
-	sh_eth_write(ndev, sh_eth_read(ndev, EESR), EESR);
+	sh_eth_modify(ndev, EESR, 0, 0);
 	if (start) {
 		mdp->irq_enabled = true;
 		sh_eth_write(ndev, mdp->cd->eesipr_value, EESIPR);
@@ -1532,15 +1533,13 @@ static int sh_eth_rx(struct net_device *
 static void sh_eth_rcv_snd_disable(struct net_device *ndev)
 {
 	/* disable tx and rx */
-	sh_eth_write(ndev, sh_eth_read(ndev, ECMR) &
-		~(ECMR_RE | ECMR_TE), ECMR);
+	sh_eth_modify(ndev, ECMR, ECMR_RE | ECMR_TE, 0);
 }
 
 static void sh_eth_rcv_snd_enable(struct net_device *ndev)
 {
 	/* enable tx and rx */
-	sh_eth_write(ndev, sh_eth_read(ndev, ECMR) |
-		(ECMR_RE | ECMR_TE), ECMR);
+	sh_eth_modify(ndev, ECMR, ECMR_RE | ECMR_TE, ECMR_RE | ECMR_TE);
 }
 
 /* error control function */
@@ -1569,13 +1568,11 @@ static void sh_eth_error(struct net_devi
 				sh_eth_rcv_snd_disable(ndev);
 			} else {
 				/* Link Up */
-				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) &
-						   ~DMAC_M_ECI, EESIPR);
+				sh_eth_modify(ndev, EESIPR, DMAC_M_ECI, 0);
 				/* clear int */
-				sh_eth_write(ndev, sh_eth_read(ndev, ECSR),
-					     ECSR);
-				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) |
-						   DMAC_M_ECI, EESIPR);
+				sh_eth_modify(ndev, ECSR, 0, 0);
+				sh_eth_modify(ndev, EESIPR, DMAC_M_ECI,
+					      DMAC_M_ECI);
 				/* enable tx and rx */
 				sh_eth_rcv_snd_enable(ndev);
 			}
@@ -1765,9 +1762,7 @@ static void sh_eth_adjust_link(struct ne
 				mdp->cd->set_rate(ndev);
 		}
 		if (!mdp->link) {
-			sh_eth_write(ndev,
-				     sh_eth_read(ndev, ECMR) & ~ECMR_TXF,
-				     ECMR);
+			sh_eth_modify(ndev, ECMR, ECMR_TXF, 0);
 			new_state = 1;
 			mdp->link = phydev->link;
 			if (mdp->cd->no_psr || mdp->no_ether_link)
