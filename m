From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] 3c59x: fix regression from patch "Add ethtool WOL
	 support"
Date: Mon, 27 Sep 2010 12:37:49 +0100
Message-ID: <4CA09E2D0200007800019050@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <andrew@beldisplaytech.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch (commit 690a1f2002a3091bd18a501f46c9530f10481463) added a
new call site for acpi_set_WOL() without checking that the function is
actually suitable to be called via

 vortex_set_wol+0xcd/0xe0 [3c59x]
 dev_ethtool+0xa5a/0xb70
 dev_ioctl+0x2e0/0x4b0
 T.961+0x49/0x50
 sock_ioctl+0x47/0x290
 do_vfs_ioctl+0x7f/0x340
 sys_ioctl+0x80/0xa0
 system_call_fastpath+0x16/0x1b

i.e. outside of code paths run when the device is not yet enabled or
already disabled. In particular, putting the device into D3hot is a
pretty bad idea when it was already brought up.

Furthermore, all prior callers of the function made sure they're
actually dealing with a PCI device, while the newly added one didn't.

In the same spirit, the .get_wol handler shouldn't indicate support
for WOL for non-PCI devices.

Signed-off-by: Jan Beulich <jbeulich@novell.com>
Cc: Andrew O. Shadoura <andrew@beldisplaytech.com>

---
 drivers/net/3c59x.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux-2.6.36-rc5/drivers/net/3c59x.c
+++ 2.6.36-rc5-3c59x-WOL/drivers/net/3c59x.c
@@ -2942,6 +2942,9 @@ static void vortex_get_wol(struct net_de
 {
 	struct vortex_private *vp = netdev_priv(dev);
 
+	if (!VORTEX_PCI(vp))
+		return;
+
 	wol->supported = WAKE_MAGIC;
 
 	wol->wolopts = 0;
@@ -2952,6 +2955,10 @@ static void vortex_get_wol(struct net_de
 static int vortex_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct vortex_private *vp = netdev_priv(dev);
+
+	if (!VORTEX_PCI(vp))
+		return -EOPNOTSUPP;
+
 	if (wol->wolopts & ~WAKE_MAGIC)
 		return -EINVAL;
 
@@ -3201,6 +3208,9 @@ static void acpi_set_WOL(struct net_devi
 			return;
 		}
 
+		if (VORTEX_PCI(vp)->current_state < PCI_D3hot)
+			return;
+
 		/* Change the power state to D3; RxEnable doesn't take effect. */
 		pci_set_power_state(VORTEX_PCI(vp), PCI_D3hot);
 	}



