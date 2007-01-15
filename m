From: Harry Coin <hcoin@n4comm.com>
Subject: 3c59x.c patch to 2.6.18 fixing Wake on Lan (WOL)
Date: Mon, 15 Jan 2007 09:09:17 -0600
Message-ID: <4.3.2.7.2.20070115090100.01d91e90@www.n4comm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14g.g14.rapidsite.net ([128.121.64.166]:30421 "HELO
	mail14g.g14.rapidsite.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750816AbXAOPQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 10:16:06 -0500
Received: from mx56.mlpsca01.us.mxservers.net (199.236.120.6)
	by mail14g.g14.rapidsite.net (RS ver 1.0.95vs) with SMTP id 4-0668773764
	for <netdev@vger.kernel.org>; Mon, 15 Jan 2007 10:09:25 -0500 (EST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 3c59x.c in kernel 2.6.18 (and as I see later ones too) attempts
to enable PME from the D0 state. The PME config space on Dell Optiplexs
for this chip has a zero in the capabilities as it doesn't 'wake from d0'.

So the pci_wake call fails, its result is not tested, so no error is reported.

The routine changes the wake request from 0 to D3_hot.  This fix
causes wake on lan (WOL) to work properly on older Dell Optiplex models.

Harry Coin
Bettendorf, Iowa


--- drivers-orig/3c59x.c        2007-01-15 00:03:52.000000000 -0600
+++ drivers-fixed/3c59x.c       2007-01-15 00:46:37.000000000 -0600
@@ -3090,8 +3090,8 @@
  /* Set Wake-On-LAN mode and put the board into D3 (power-down) state. */
  static void acpi_set_WOL(struct net_device *dev)
  {
-       struct vortex_private *vp = netdev_priv(dev);
-       void __iomem *ioaddr = vp->ioaddr;
+  struct vortex_private *vp = netdev_priv(dev);
+  void __iomem *ioaddr = vp->ioaddr;

         if (vp->enable_wol) {
                 /* Power up on: 1==Downloaded Filter, 2==Magic Packets, 
4==Link Status. */
@@ -3101,7 +3101,7 @@
                 iowrite16(SetRxFilter|RxStation|RxMulticast|RxBroadcast, 
ioaddr + EL3_CMD);
                 iowrite16(RxEnable, ioaddr + EL3_CMD);

-               pci_enable_wake(VORTEX_PCI(vp), 0, 1);
+               pci_enable_wake(VORTEX_PCI(vp),PCI_D3hot,1);

                 /* Change the power state to D3; RxEnable doesn't take 
effect. */
                 pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);


