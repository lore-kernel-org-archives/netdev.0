From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 3/7] phy: add proper phy struct device refcounting
Date: Fri, 18 Sep 2015 10:55:06 +0100
Message-ID: <E1ZcsNm-0001FK-JN@rmk-PC.arm.linux.org.uk>
References: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: devicetree@vger.kernel.org, Frank Rowand <frowand.list@gmail.com>,
	Grant Likely <grant.likely@linaro.org>,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, Li Yang <leoli@freescale.com>,
	Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org,
	Robert Richter <rric@kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	"Soren Brinkmann" <soren.brinkmann@xilinx.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150918094625.GB21084@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Take a refcount on the phy struct device when the phy device is attached
to a network device, and drop it after it's detached.  This ensures that
a refcount is held on the phy device while the device is being used by
a network device, thereby preventing the phy_device from being
unexpectedly kfree()'d by phy_device_release().

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
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
