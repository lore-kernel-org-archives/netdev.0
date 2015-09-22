From: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Subject: [PATCH 4/9] phy: add proper phy struct device refcounting
Date: Tue, 22 Sep 2015 17:18:18 +0100
Message-ID: <E1ZeQGo-0006Xf-7Y@rmk-PC.arm.linux.org.uk>
References: <20150922161710.GA21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Robert Richter <rric-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Soren Brinkmann" <soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	Sunil Goutham <sgoutham-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150922161710.GA21084-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Content-Disposition: inline
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Take a refcount on the phy struct device when the phy device is attached
to a network device, and drop it after it's detached.  This ensures that
a refcount is held on the phy device while the device is being used by
a network device, thereby preventing the phy_device from being
unexpectedly kfree()'d by phy_device_release().

Signed-off-by: Russell King <rmk+kernel-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
---
 drivers/net/phy/phy_device.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 03adf328f49b..97a4f52addac 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -578,6 +578,7 @@ EXPORT_SYMBOL(phy_init_hw);
  *     generic driver is used.  The phy_device is given a ptr to
  *     the attaching device, and given a callback for link status
  *     change.  The phy_device is returned to the attaching driver.
+ *     This function takes a reference on the phy device.
  */
 int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		      u32 flags, phy_interface_t interface)
@@ -591,6 +592,8 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 		return -EIO;
 	}
 
+	get_device(d);
+
 	/* Assume that if there is no driver, that it doesn't
 	 * exist, and we should use the genphy driver.
 	 */
@@ -636,6 +639,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	return err;
 
 error:
+	put_device(d);
 	module_put(bus->owner);
 	return err;
 }
@@ -679,6 +683,9 @@ EXPORT_SYMBOL(phy_attach);
 /**
  * phy_detach - detach a PHY device from its network device
  * @phydev: target phy_device struct
+ *
+ * This detaches the phy device from its network device and the phy
+ * driver, and drops the reference count taken in phy_attach_direct().
  */
 void phy_detach(struct phy_device *phydev)
 {
@@ -701,8 +708,13 @@ void phy_detach(struct phy_device *phydev)
 		}
 	}
 
+	/*
+	 * The phydev might go away on the put_device() below, so avoid
+	 * a use-after-free bug by reading the underlying bus first.
+	 */
 	bus = phydev->bus;
 
+	put_device(&phydev->dev);
 	module_put(bus->owner);
 }
 EXPORT_SYMBOL(phy_detach);
-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
