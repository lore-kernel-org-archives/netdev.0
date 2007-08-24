From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] via-velocity: more cleanup
Date: Fri, 24 Aug 2007 14:40:45 -0700
Message-ID: <20070824144045.087d41ff@freepuppy.rosehill.hemminger.net>
References: <20070824135649.509e1fe7@freepuppy.rosehill.hemminger.net>
	<20070824211547.GW21089@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60469 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754874AbXHXVlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:41:08 -0400
In-Reply-To: <20070824211547.GW21089@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Per Al's suggestion, get rid of the stupid stuff:
Remove cam_type switch,
And deinline things that aren't important for speed.
And make big macro and inline.
And remove some dead/unused code.
And use const char * for chip name.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/via-velocity.c	2007-08-24 13:49:17.000000000 -0700
+++ b/drivers/net/via-velocity.c	2007-08-24 14:39:14.000000000 -0700
@@ -85,6 +85,163 @@
 static int velocity_nics = 0;
 static int msglevel = MSG_LEVEL_INFO;
 
+/**
+ *	mac_get_cam_mask	-	Read a CAM mask
+ *	@regs: register block for this velocity
+ *	@mask: buffer to store mask
+ *
+ *	Fetch the mask bits of the selected CAM and store them into the
+ *	provided mask buffer.
+ */
+
+static void mac_get_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* read mask */
+	for (i = 0; i < 8; i++)
+		*mask++ = readb(&(regs->MARCAM[i]));
+
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+}
+
+
+/**
+ *	mac_set_cam_mask	-	Set a CAM mask
+ *	@regs: register block for this velocity
+ *	@mask: CAM mask to load
+ *
+ *	Store a new mask into a CAM
+ */
+
+static void mac_set_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(CAMADDR_CAMEN, &regs->CAMADDR);
+
+	for (i = 0; i < 8; i++) {
+		writeb(*mask++, &(regs->MARCAM[i]));
+	}
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+static void mac_set_vlan_cam_mask(struct mac_regs __iomem * regs, u8 * mask)
+{
+	int i;
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL, &regs->CAMADDR);
+
+	for (i = 0; i < 8; i++) {
+		writeb(*mask++, &(regs->MARCAM[i]));
+	}
+	/* disable CAMEN */
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+/**
+ *	mac_set_cam	-	set CAM data
+ *	@regs: register block of this velocity
+ *	@idx: Cam index
+ *	@addr: 2 or 6 bytes of CAM data
+ *
+ *	Load an address or vlan tag into a CAM
+ */
+
+static void mac_set_cam(struct mac_regs __iomem * regs, int idx, const u8 *addr)
+{
+	int i;
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	idx &= (64 - 1);
+
+	writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
+
+	for (i = 0; i < 6; i++) {
+		writeb(*addr++, &(regs->MARCAM[i]));
+	}
+	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
+
+	udelay(10);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+static void mac_set_vlan_cam(struct mac_regs __iomem * regs, int idx,
+			     const u8 *addr)
+{
+
+	/* Select CAM mask */
+	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+
+	idx &= (64 - 1);
+
+	writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
+	writew(*((u16 *) addr), &regs->MARCAM[0]);
+
+	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
+
+	udelay(10);
+
+	writeb(0, &regs->CAMADDR);
+
+	/* Select mar */
+	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+}
+
+
+/**
+ *	mac_wol_reset	-	reset WOL after exiting low power
+ *	@regs: register block of this velocity
+ *
+ *	Called after we drop out of wake on lan mode in order to
+ *	reset the Wake on lan features. This function doesn't restore
+ *	the rest of the logic from the result of sleep/wakeup
+ */
+
+static void mac_wol_reset(struct mac_regs __iomem * regs)
+{
+
+	/* Turn off SWPTAG right after leaving power mode */
+	BYTE_REG_BITS_OFF(STICKHW_SWPTAG, &regs->STICKHW);
+	/* clear sticky bits */
+	BYTE_REG_BITS_OFF((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
+
+	BYTE_REG_BITS_OFF(CHIPGCR_FCGMII, &regs->CHIPGCR);
+	BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
+	/* disable force PME-enable */
+	writeb(WOLCFG_PMEOVR, &regs->WOLCFGClr);
+	/* disable power-event config bit */
+	writew(0xFFFF, &regs->WOLCRClr);
+	/* clear power status */
+	writew(0xFFFF, &regs->WOLSRClr);
+}
 
 static int velocity_mii_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static const struct ethtool_ops velocity_ethtool_ops;
@@ -309,7 +466,7 @@ MODULE_DEVICE_TABLE(pci, velocity_id_tab
  *	a pointer a static string valid while the driver is loaded.
  */
 
-static char __devinit *get_chip_name(enum chip_type chip_id)
+static const char __devinit *get_chip_name(enum chip_type chip_id)
 {
 	int i;
 	for (i = 0; chip_info_table[i].name != NULL; i++)
@@ -458,8 +615,8 @@ static void velocity_init_cam_filter(str
 	/* Disable all CAMs */
 	memset(vptr->vCAMmask, 0, sizeof(u8) * 8);
 	memset(vptr->mCAMmask, 0, sizeof(u8) * 8);
-	mac_set_cam_mask(regs, vptr->vCAMmask, VELOCITY_VLAN_ID_CAM);
-	mac_set_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
+	mac_set_cam_mask(regs, vptr->mCAMmask);
 
 	/* Enable first VCAM */
 	if (vptr->vlgrp) {
@@ -471,17 +628,16 @@ static void velocity_init_cam_filter(str
 				if (vid != 0)
 					WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
 
-				mac_set_cam(regs, 0, (u8 *) &vid,
-					    VELOCITY_VLAN_ID_CAM);
+				mac_set_vlan_cam(regs, 0, (u8 *) &vid);
 			}
 		}
 		vptr->vCAMmask[0] |= 1;
-		mac_set_cam_mask(regs, vptr->vCAMmask, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 	} else {
 		u16 temp = 0;
-		mac_set_cam(regs, 0, (u8 *) &temp, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam(regs, 0, (u8 *) &temp);
 		temp = 1;
-		mac_set_cam_mask(regs, (u8 *) &temp, VELOCITY_VLAN_ID_CAM);
+		mac_set_vlan_cam_mask(regs, (u8 *) &temp);
 	}
 }
 
@@ -2136,14 +2292,14 @@ static void velocity_set_multi(struct ne
 		rx_mode = (RCR_AM | RCR_AB);
 	} else {
 		int offset = MCAM_SIZE - vptr->multicast_limit;
-		mac_get_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+		mac_get_cam_mask(regs, vptr->mCAMmask);
 
 		for (i = 0, mclist = dev->mc_list; mclist && i < dev->mc_count; i++, mclist = mclist->next) {
-			mac_set_cam(regs, i + offset, mclist->dmi_addr, VELOCITY_MULTICAST_CAM);
+			mac_set_cam(regs, i + offset, mclist->dmi_addr);
 			vptr->mCAMmask[(offset + i) / 8] |= 1 << ((offset + i) & 7);
 		}
 
-		mac_set_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
+		mac_set_cam_mask(regs, vptr->mCAMmask);
 		rx_mode = (RCR_AM | RCR_AB);
 	}
 	if (dev->mtu > 1500)
--- a/drivers/net/via-velocity.h	2007-08-24 13:49:17.000000000 -0700
+++ b/drivers/net/via-velocity.h	2007-08-24 14:29:09.000000000 -0700
@@ -1173,7 +1173,7 @@ enum chip_type {
 
 struct velocity_info_tbl {
 	enum chip_type chip_id;
-	char *name;
+	const char *name;
 	int txqueue;
 	u32 flags;
 };
@@ -1194,14 +1194,6 @@ struct velocity_info_tbl {
 #define mac_disable_int(regs)       	writel(CR0_GINTMSK1,&((regs)->CR0Clr))
 #define mac_enable_int(regs)    	writel(CR0_GINTMSK1,&((regs)->CR0Set))
 
-#define mac_hw_mibs_read(regs, MIBs) {\
-	int i;\
-	BYTE_REG_BITS_ON(MIBCR_MPTRINI,&((regs)->MIBCR));\
-	for (i=0;i<HW_MIB_SIZE;i++) {\
-		(MIBs)[i]=readl(&((regs)->MIBData));\
-	}\
-}
-
 #define mac_set_dma_length(regs, n) {\
 	BYTE_REG_BITS_SET((n),0x07,&((regs)->DCFG));\
 }
@@ -1226,195 +1218,17 @@ struct velocity_info_tbl {
 	writew(TRDCSR_WAK<<(n*4),&((regs)->TDCSRSet));\
 }
 
-#define mac_eeprom_reload(regs) {\
-	int i=0;\
-	BYTE_REG_BITS_ON(EECSR_RELOAD,&((regs)->EECSR));\
-	do {\
-		udelay(10);\
-		if (i++>0x1000) {\
-			break;\
-		}\
-	}while (BYTE_REG_BITS_IS_ON(EECSR_RELOAD,&((regs)->EECSR)));\
-}
-
-enum velocity_cam_type {
-	VELOCITY_VLAN_ID_CAM = 0,
-	VELOCITY_MULTICAST_CAM
-};
-
-/**
- *	mac_get_cam_mask	-	Read a CAM mask
- *	@regs: register block for this velocity
- *	@mask: buffer to store mask
- *	@cam_type: CAM to fetch
- *
- *	Fetch the mask bits of the selected CAM and store them into the
- *	provided mask buffer.
- */
-
-static inline void mac_get_cam_mask(struct mac_regs __iomem * regs, u8 * mask, enum velocity_cam_type cam_type)
-{
-	int i;
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_VCAMSL, &regs->CAMADDR);
-	else
-		writeb(0, &regs->CAMADDR);
-
-	/* read mask */
-	for (i = 0; i < 8; i++)
-		*mask++ = readb(&(regs->MARCAM[i]));
-
-	/* disable CAMEN */
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-}
-
-/**
- *	mac_set_cam_mask	-	Set a CAM mask
- *	@regs: register block for this velocity
- *	@mask: CAM mask to load
- *	@cam_type: CAM to store
- *
- *	Store a new mask into a CAM
- */
-
-static inline void mac_set_cam_mask(struct mac_regs __iomem * regs, u8 * mask, enum velocity_cam_type cam_type)
-{
-	int i;
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_MASK, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN, &regs->CAMADDR);
-
-	for (i = 0; i < 8; i++) {
-		writeb(*mask++, &(regs->MARCAM[i]));
-	}
-	/* disable CAMEN */
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-}
-
-/**
- *	mac_set_cam	-	set CAM data
- *	@regs: register block of this velocity
- *	@idx: Cam index
- *	@addr: 2 or 6 bytes of CAM data
- *	@cam_type: CAM to load
- *
- *	Load an address or vlan tag into a CAM
- */
-
-static inline void mac_set_cam(struct mac_regs __iomem * regs, int idx, u8 *addr, enum velocity_cam_type cam_type)
-{
-	int i;
-
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	idx &= (64 - 1);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writew(*((u16 *) addr), &regs->MARCAM[0]);
-	else {
-		for (i = 0; i < 6; i++) {
-			writeb(*addr++, &(regs->MARCAM[i]));
-		}
-	}
-	BYTE_REG_BITS_ON(CAMCR_CAMWR, &regs->CAMCR);
-
-	udelay(10);
-
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-}
-
-/**
- *	mac_get_cam	-	fetch CAM data
- *	@regs: register block of this velocity
- *	@idx: Cam index
- *	@addr: buffer to hold up to 6 bytes of CAM data
- *	@cam_type: CAM to load
- *
- *	Load an address or vlan tag from a CAM into the buffer provided by
- *	the caller. VLAN tags are 2 bytes the address cam entries are 6.
- */
+static inline void mac_eeprom_reload(struct mac_regs __iomem * regs) {
+	int i=0;
 
-static inline void mac_get_cam(struct mac_regs __iomem * regs, int idx, u8 *addr, enum velocity_cam_type cam_type)
-{
-	int i;
-
-	/* Select CAM mask */
-	BYTE_REG_BITS_SET(CAMCR_PS_CAM_DATA, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
-
-	idx &= (64 - 1);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		writeb(CAMADDR_CAMEN | CAMADDR_VCAMSL | idx, &regs->CAMADDR);
-	else
-		writeb(CAMADDR_CAMEN | idx, &regs->CAMADDR);
-
-	BYTE_REG_BITS_ON(CAMCR_CAMRD, &regs->CAMCR);
-
-	udelay(10);
-
-	if (cam_type == VELOCITY_VLAN_ID_CAM)
-		*((u16 *) addr) = readw(&(regs->MARCAM[0]));
-	else
-		for (i = 0; i < 6; i++, addr++)
-			*((u8 *) addr) = readb(&(regs->MARCAM[i]));
-
-	writeb(0, &regs->CAMADDR);
-
-	/* Select mar */
-	BYTE_REG_BITS_SET(CAMCR_PS_MAR, CAMCR_PS1 | CAMCR_PS0, &regs->CAMCR);
+	BYTE_REG_BITS_ON(EECSR_RELOAD,&(regs->EECSR));
+	do {
+		udelay(10);
+		if (i++>0x1000)
+			break;
+	} while (BYTE_REG_BITS_IS_ON(EECSR_RELOAD,&(regs->EECSR)));
 }
 
-/**
- *	mac_wol_reset	-	reset WOL after exiting low power
- *	@regs: register block of this velocity
- *
- *	Called after we drop out of wake on lan mode in order to
- *	reset the Wake on lan features. This function doesn't restore
- *	the rest of the logic from the result of sleep/wakeup
- */
-
-static inline void mac_wol_reset(struct mac_regs __iomem * regs)
-{
-
-	/* Turn off SWPTAG right after leaving power mode */
-	BYTE_REG_BITS_OFF(STICKHW_SWPTAG, &regs->STICKHW);
-	/* clear sticky bits */
-	BYTE_REG_BITS_OFF((STICKHW_DS1 | STICKHW_DS0), &regs->STICKHW);
-
-	BYTE_REG_BITS_OFF(CHIPGCR_FCGMII, &regs->CHIPGCR);
-	BYTE_REG_BITS_OFF(CHIPGCR_FCMODE, &regs->CHIPGCR);
-	/* disable force PME-enable */
-	writeb(WOLCFG_PMEOVR, &regs->WOLCFGClr);
-	/* disable power-event config bit */
-	writew(0xFFFF, &regs->WOLCRClr);
-	/* clear power status */
-	writew(0xFFFF, &regs->WOLSRClr);
-}
-
-
 /*
  * Header for WOL definitions. Used to compute hashes
  */
