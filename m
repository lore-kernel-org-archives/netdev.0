From: yuval.shaia@oracle.com
Subject: [PATCH] Add support for netconsole driver used on bridge device with,
 VIF attached
Date: Mon, 21 Jan 2013 18:34:31 +0200
Message-ID: <50FD6E17.1010309@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: ian.campbell@citrix.com, xen-devel@lists.xensource.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47716 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab3AUQe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:34:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When starting a VM which has virtual interface attached to the same 
bridge (i.e vif = [type=netfront,bridge=xenbr0'] in vm.cfg) which is 
used for netconsole the
following message appears (after about 60 seconds) and VM creation 
operation fails.
      Error: Device 0 (vif) could not be connected. Hotplug scripts not 
working.

Note:
When trying to do the opposite, i.e. first create VM and then run
netconsole we got the error #524 - vif2.0 doesn't support polling,
aborting.

The following patch (to latest kernel) fix this bug by adding 
implementation to ndo_poll_controller.

0001-Add-support-for-netconsole-driver-used-on-bridge-dev.patch
0 2001
From: Yuval <yuval.shaia@oracle.com>
Date: Tue, 8 Jan 2013 10:08:45 +0200
Subject: [PATCH] Add support for netconsole driver used on bridge device 
with
  VIF attached

Signed-off-by: Yuval <yuval.shaia@oracle.com>
---
  drivers/net/xen-netback/interface.c |    8 ++++++++
  1 file changed, 8 insertions(+)

diff --git a/drivers/net/xen-netback/interface.c 
b/drivers/net/xen-netback/interface.c
index 601ae2a..10751f5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -179,6 +179,13 @@ static u32 xenvif_fix_features(struct net_device 
*dev, u32 features)
      return features;
  }

+static void xenvif_poll_controller(struct net_device *dev)
+{
+    disable_irq(dev->irq);
+    xenvif_interrupt(dev->irq, dev);
+    enable_irq(dev->irq);
+}
+
  static const struct xenvif_stat {
      char name[ETH_GSTRING_LEN];
      u16 offset;
@@ -237,6 +244,7 @@ static const struct net_device_ops xenvif_netdev_ops = {
      .ndo_stop    = xenvif_close,
      .ndo_change_mtu    = xenvif_change_mtu,
      .ndo_fix_features = xenvif_fix_features,
+    .ndo_poll_controller = xenvif_poll_controller,
  };

  struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
-- 
1.7.9.5
