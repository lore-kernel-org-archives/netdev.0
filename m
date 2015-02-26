From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH net-next 2/5] sh_eth: WARN on access to a register not
 implemented in a particular chip
Date: Thu, 26 Feb 2015 20:34:14 +0000
Message-ID: <1424982854.4444.73.camel@xylophone.i.decadent.org.uk>
References: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:46809 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483AbbBZUeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 15:34:19 -0500
In-Reply-To: <1424982665.4444.70.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we may silently read/write a register at offset 0.  Change
this to WARN and then ignore the write or read-back all-ones.

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
 drivers/net/ethernet/renesas/sh_eth.c |   16 +++++++++++++++-
 drivers/net/ethernet/renesas/sh_eth.h |   14 ++++++++++++--
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4169f93b5c3c..e21f8ce609cd 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -52,7 +52,12 @@
 		NETIF_MSG_RX_ERR| \
 		NETIF_MSG_TX_ERR)
 
+#define SH_ETH_OFFSET_DEFAULTS			\
+	[0 ... SH_ETH_MAX_REGISTER_OFFSET - 1] = SH_ETH_OFFSET_INVALID
+
 static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
+	SH_ETH_OFFSET_DEFAULTS,
+
 	[EDSR]		= 0x0000,
 	[EDMR]		= 0x0400,
 	[EDTRR]		= 0x0408,
@@ -151,6 +156,8 @@ static const u16 sh_eth_offset_gigabit[SH_ETH_MAX_REGISTER_OFFSET] = {
 };
 
 static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
+	SH_ETH_OFFSET_DEFAULTS,
+
 	[EDSR]		= 0x0000,
 	[EDMR]		= 0x0400,
 	[EDTRR]		= 0x0408,
@@ -210,6 +217,8 @@ static const u16 sh_eth_offset_fast_rz[SH_ETH_MAX_REGISTER_OFFSET] = {
 };
 
 static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
+	SH_ETH_OFFSET_DEFAULTS,
+
 	[ECMR]		= 0x0300,
 	[RFLR]		= 0x0308,
 	[ECSR]		= 0x0310,
@@ -256,6 +265,8 @@ static const u16 sh_eth_offset_fast_rcar[SH_ETH_MAX_REGISTER_OFFSET] = {
 };
 
 static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
+	SH_ETH_OFFSET_DEFAULTS,
+
 	[ECMR]		= 0x0100,
 	[RFLR]		= 0x0108,
 	[ECSR]		= 0x0110,
@@ -308,6 +319,8 @@ static const u16 sh_eth_offset_fast_sh4[SH_ETH_MAX_REGISTER_OFFSET] = {
 };
 
 static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
+	SH_ETH_OFFSET_DEFAULTS,
+
 	[EDMR]		= 0x0000,
 	[EDTRR]		= 0x0004,
 	[EDRRR]		= 0x0008,
@@ -1541,7 +1554,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving if RDE is set */
-		if (intr_status & EESR_RDE && mdp->reg_offset[RDFAR] != 0) {
+		if (intr_status & EESR_RDE &&
+		    mdp->reg_offset[RDFAR] != SH_ETH_OFFSET_INVALID) {
 			u32 count = (sh_eth_read(ndev, RDFAR) -
 				     sh_eth_read(ndev, RDLAR)) >> 4;
 
diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 259d03f353e1..33a360c4fd10 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -543,19 +543,29 @@ static inline void sh_eth_soft_swap(char *src, int len)
 #endif
 }
 
+#define SH_ETH_OFFSET_INVALID	((u16) ~0)
+
 static inline void sh_eth_write(struct net_device *ndev, u32 data,
 				int enum_index)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u16 offset = mdp->reg_offset[enum_index];
+
+	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
+		return;
 
-	iowrite32(data, mdp->addr + mdp->reg_offset[enum_index]);
+	iowrite32(data, mdp->addr + offset);
 }
 
 static inline u32 sh_eth_read(struct net_device *ndev, int enum_index)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
+	u16 offset = mdp->reg_offset[enum_index];
+
+	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
+		return ~0U;
 
-	return ioread32(mdp->addr + mdp->reg_offset[enum_index]);
+	return ioread32(mdp->addr + offset);
 }
 
 static inline void *sh_eth_tsu_get_offset(struct sh_eth_private *mdp,
-- 
1.7.10.4
