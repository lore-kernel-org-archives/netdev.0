From: =?ISO-8859-15?Q?S=E9guier_R=E9gis?= <rseguier@e-teleport.net>
Subject: via-velocity driver vlan_filtering and promisc
Date: Wed, 08 Oct 2008 20:35:42 +0200
Message-ID: <48ECFD7E.1060801@e-teleport.net>
References: <20080830082353.7ca74f45@extreme> <20080831162558.GA17469@electric-eye.fr.zoreil.com> <48BBD75A.50607@trash.net>
Reply-To: technique@e-teleport.net
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010001000804070705040502"
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.e-teleport.net ([213.190.83.68]:41634 "EHLO
	mail.imsnet.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755095AbYJHTJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 15:09:20 -0400
In-Reply-To: <48BBD75A.50607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010001000804070705040502
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 8bit

Hi,

Disabling vlan filters doen't work in promiscous mode.

This patch normaly correct this.

"The non-tagged interface is filtered out as soon as a tagged
    (!= 0) interface is created. Its traffic appears again when an
    zero-tagged interface is created."
in commit d4f73c8e459d355e10051174d859ffd0ef5764c0 is no more true with this patch, just setting promisc mode is needed.


The patch change how setting MCFG_RTGOPT, no more in 
velocity_init_cam_filter() but in velocity_set_multi(), 
velocity_vlan_rx_kill_vid() and velocity_vlan_rx_add_vid()
This patch also autorise to create vlan with id 0.

-- 
Régis

--------------010001000804070705040502
Content-Type: text/plain;
 name="vlan-filtering"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan-filtering"

--- ../linux-2.6.26/drivers/net/via-velocity.c	2008-10-08 17:08:42.000000000 +0000
+++ drivers/net/via-velocity.c	2008-10-08 19:37:10.000000000 +0000
@@ -605,9 +605,8 @@ static void __devinit velocity_get_optio
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem * regs = vptr->mac_regs;
-
 	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
-	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
+	WORD_REG_BITS_ON(MCFG_PQEN, &regs->MCFG);
 	WORD_REG_BITS_ON(MCFG_VIDFR, &regs->MCFG);
 
 	/* Disable all CAMs */
@@ -619,11 +618,7 @@ static void velocity_init_cam_filter(str
 	/* Enable VCAMs */
 	if (vptr->vlgrp) {
 		unsigned int vid, i = 0;
-
-		if (!vlan_group_get_device(vptr->vlgrp, 0))
-			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
-
-		for (vid = 1; (vid < VLAN_VID_MASK); vid++) {
+		for (vid = 0; (vid < VLAN_VID_MASK); vid++) {
 			if (vlan_group_get_device(vptr->vlgrp, vid)) {
 				mac_set_vlan_cam(regs, i, (u8 *) &vid);
 				vptr->vCAMmask[i / 8] |= 0x1 << (i % 8);
@@ -646,19 +641,25 @@ static void velocity_vlan_rx_register(st
 static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
+	struct mac_regs __iomem * regs = vptr->mac_regs;
 
         spin_lock_irq(&vptr->lock);
 	velocity_init_cam_filter(vptr);
+	if (vptr->vCAMmask[0] && !(dev->flags & IFF_PROMISC))
+                WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG); /* enable vlan filtering */
         spin_unlock_irq(&vptr->lock);
 }
 
 static void velocity_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
+	struct mac_regs __iomem * regs = vptr->mac_regs;
 
         spin_lock_irq(&vptr->lock);
 	vlan_group_set_device(vptr->vlgrp, vid, NULL);
 	velocity_init_cam_filter(vptr);
+	if (!vptr->vCAMmask[0])
+		WORD_REG_BITS_OFF(MCFG_RTGOPT, &regs->MCFG); /* disable vlan filtering */
         spin_unlock_irq(&vptr->lock);
 }
 
@@ -2278,11 +2279,14 @@ static void velocity_set_multi(struct ne
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB | RCR_PROM);
+		WORD_REG_BITS_OFF(MCFG_RTGOPT, &regs->MCFG); /* disable vlan filtering */
 	} else if ((dev->mc_count > vptr->multicast_limit)
 		   || (dev->flags & IFF_ALLMULTI)) {
 		writel(0xffffffff, &regs->MARCAM[0]);
 		writel(0xffffffff, &regs->MARCAM[4]);
 		rx_mode = (RCR_AM | RCR_AB);
+		if (vptr->vCAMmask[0])
+			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG); /* enable vlan filtering */
 	} else {
 		int offset = MCAM_SIZE - vptr->multicast_limit;
 		mac_get_cam_mask(regs, vptr->mCAMmask);
@@ -2294,6 +2298,9 @@ static void velocity_set_multi(struct ne
 
 		mac_set_cam_mask(regs, vptr->mCAMmask);
 		rx_mode = (RCR_AM | RCR_AB);
+		
+		if (vptr->vCAMmask[0])
+			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG); /* enable vlan filtering */
 	}
 	if (dev->mtu > 1500)
 		rx_mode |= RCR_AL;

--------------010001000804070705040502--
