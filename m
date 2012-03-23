From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2] sh: sh_eth: Add support SH7734
Date: Fri, 23 Mar 2012 13:55:33 +0900
Message-ID: <1332478533-17382-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48436 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab2CWEwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 00:52:47 -0400
Received: by pbcun15 with SMTP id un15so2199160pbc.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 21:52:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add define of SH7734 register and sh_eth_reset_hw_crc function.

V2: Do not split line of #if defined.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/Kconfig  |    9 +++++----
 drivers/net/ethernet/renesas/sh_eth.c |   22 +++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   10 ++++++++--
 3 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
index 9755b49..077528b 100644
--- a/drivers/net/ethernet/renesas/Kconfig
+++ b/drivers/net/ethernet/renesas/Kconfig
@@ -5,9 +5,10 @@
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
-		(CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
-		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7619 || \
-		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7757)
+		(CPU_SUBTYPE_SH7619 || \
+		 CPU_SUBTYPE_SH7710 || CPU_SUBTYPE_SH7712 || \
+		 CPU_SUBTYPE_SH7724 || CPU_SUBTYPE_SH7734 || \
+		 CPU_SUBTYPE_SH7763 || CPU_SUBTYPE_SH7757)
 	select CRC32
 	select NET_CORE
 	select MII
@@ -16,4 +17,4 @@ config SH_ETH
 	---help---
 	  Renesas SuperH Ethernet device driver.
 	  This driver supporting CPUs are:
-		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
+		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763 and SH7757.
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 87b6501..63fc224 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,8 +1,8 @@
 /*
  *  SuperH Ethernet device driver
  *
- *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
- *  Copyright (C) 2008-2009 Renesas Solutions Corp.
+ *  Copyright (C) 2006-2011 Nobuhiro Iwamatsu
+ *  Copyright (C) 2008-2011 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
  *  under the terms and conditions of the GNU General Public License,
@@ -40,6 +40,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/sh_eth.h>
+#include <linux/clk.h>
 
 #include "sh_eth.h"
 
@@ -97,6 +98,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.tpauser	= 1,
 	.hw_swap	= 1,
 	.rpadir		= 1,
+	.hw_crc		= 0,
 	.rpadir_value	= 0x00020000, /* NET_IP_ALIGN assumed to be 2 */
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
@@ -147,6 +149,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.hw_swap	= 1,
 	.no_ade		= 1,
 	.rpadir		= 1,
+	.hw_crc		= 0,
 	.rpadir_value   = 2 << 16,
 };
 
@@ -269,6 +272,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.rpadir_value   = 2 << 16,
 	.no_trimd	= 1,
 	.no_ade		= 1,
+	.hw_crc		= 0,
 };
 
 static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
@@ -279,8 +283,9 @@ static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
 		return &sh_eth_my_cpu_data;
 }
 
-#elif defined(CONFIG_CPU_SUBTYPE_SH7763)
+#elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
 #define SH_ETH_HAS_TSU	1
+static void sh_eth_reset_hw_crc(struct net_device *ndev);
 static void sh_eth_chip_reset(struct net_device *ndev)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
@@ -314,6 +319,9 @@ static void sh_eth_reset(struct net_device *ndev)
 	sh_eth_write(ndev, 0x0, RDFAR);
 	sh_eth_write(ndev, 0x0, RDFXR);
 	sh_eth_write(ndev, 0x0, RDFFR);
+
+	/* Reset HW CRC register */
+	sh_eth_reset_hw_crc(ndev);
 }
 
 static void sh_eth_set_duplex(struct net_device *ndev)
@@ -370,8 +378,15 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.no_trimd	= 1,
 	.no_ade		= 1,
 	.tsu		= 1,
+	.hw_crc		= 1,
 };
 
+static void sh_eth_reset_hw_crc(struct net_device *ndev)
+{
+	if (sh_eth_my_cpu_data.hw_crc)
+		sh_eth_write(ndev, 0x0, CSMR);
+}
+
 #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
 #define SH_ETH_RESET_DEFAULT	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
@@ -381,6 +396,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.mpr		= 1,
 	.tpauser	= 1,
 	.hw_swap	= 1,
+	.hw_crc		= 0,
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
 #define SH_ETH_RESET_DEFAULT	1
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index cdbd844..da384d2 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -1,7 +1,7 @@
 /*
  *  SuperH Ethernet device driver
  *
- *  Copyright (C) 2006-2008 Nobuhiro Iwamatsu
+ *  Copyright (C) 2006-2008, 2011 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2011 Renesas Solutions Corp.
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -59,6 +59,8 @@ enum {
 	TRIMD,
 	RBWAR,
 	TBRAR,
+	CSMR,
+	RMII_MII,
 
 	/* Ether registers */
 	ECMR,
@@ -170,6 +172,8 @@ static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[RMCR]	= 0x0458,
 	[RPADIR]	= 0x0460,
 	[FCFTR]	= 0x0468,
+	[CSMR] = 0x04E4,
+	[RMII_MII] =  0x0790,
 
 	[ECMR]	= 0x0500,
 	[ECSR]	= 0x0510,
@@ -375,7 +379,8 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 /*
  * Register's bits
  */
-#ifdef CONFIG_CPU_SUBTYPE_SH7763
+#if defined(CONFIG_CPU_SUBTYPE_SH7734) ||\
+	defined(CONFIG_CPU_SUBTYPE_SH7763)
 /* EDSR */
 enum EDSR_BIT {
 	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
@@ -745,6 +750,7 @@ struct sh_eth_cpu_data {
 	unsigned rpadir:1;		/* E-DMAC have RPADIR */
 	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
+	unsigned hw_crc:1;		/* E-DMAC have CSMR */
 };
 
 struct sh_eth_private {
-- 
1.7.9.1
