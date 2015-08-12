From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [PATCH 1/2] Add a matching set of device_ functions for determining mac/phy
Date: Wed, 12 Aug 2015 17:06:26 -0500
Message-ID: <1439417187-21411-2-git-send-email-jeremy.linton@arm.com>
References: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
	rafael.j.wysocki@intel.com, grant.likely@linaro.org,
	Suravee.Suthikulpanit@amd.com, Catalin.Marinas@arm.com,
	Jeremy Linton <jeremy.linton@arm.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:60420 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751617AbbHLWGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 18:06:50 -0400
In-Reply-To: <1439417187-21411-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OF has some helper functions for parsing MAC and PHY settings.
In cases where the platform is providing this information rather
than the device itself, there needs to be similar functions for ACPI.

These functions are slightly modified versions of the ones in
of_net which can use information provided via DT or ACPI.

Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>
---
 drivers/base/property.c  | 73 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 include/linux/property.h |  4 +++
 2 files changed, 77 insertions(+)

diff --git a/drivers/base/property.c b/drivers/base/property.c
index f3f6d16..2e8cd14 100644
--- a/drivers/base/property.c
+++ b/drivers/base/property.c
@@ -16,6 +16,8 @@
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/property.h>
+#include <linux/etherdevice.h>
+#include <linux/phy.h>
=20
 /**
  * device_add_property_set - Add a collection of properties to a device ob=
ject.
@@ -533,3 +535,74 @@ bool device_dma_is_coherent(struct device *dev)
 =09return coherent;
 }
 EXPORT_SYMBOL_GPL(device_dma_is_coherent);
+
+/**
+ * device_get_phy_mode - Get phy mode for given device_node
+ * @dev:=09Pointer to the given device
+ *
+ * The function gets phy interface string from property 'phy-mode' or
+ * 'phy-connection-type', and return its index in phy_modes table, or errn=
o in
+ * error case.
+ */
+int device_get_phy_mode(struct device *dev)
+{
+=09const char *pm;
+=09int err, i;
+
+=09err =3D device_property_read_string(dev, "phy-mode", &pm);
+=09if (err < 0)
+=09=09err =3D device_property_read_string(dev,
+=09=09=09=09=09=09  "phy-connection-type", &pm);
+=09if (err < 0)
+=09=09return err;
+
+=09for (i =3D 0; i < PHY_INTERFACE_MODE_MAX; i++)
+=09=09if (!strcasecmp(pm, phy_modes(i)))
+=09=09=09return i;
+
+=09return -ENODEV;
+}
+EXPORT_SYMBOL_GPL(device_get_phy_mode);
+
+static void *device_get_mac_addr(struct device *dev,
+=09=09=09=09 const char *name, char *addr,
+=09=09=09=09 int alen)
+{
+=09int ret =3D device_property_read_u8_array(dev, name, addr, alen);
+
+=09if (ret =3D=3D 0 && is_valid_ether_addr(addr))
+=09=09return addr;
+=09return NULL;
+}
+
+/**
+ * Search the device tree for the best MAC address to use.  'mac-address' =
is
+ * checked first, because that is supposed to contain to "most recent" MAC
+ * address. If that isn't set, then 'local-mac-address' is checked next,
+ * because that is the default address.  If that isn't set, then the obsol=
ete
+ * 'address' is checked, just in case we're using an old device tree.
+ *
+ * Note that the 'address' property is supposed to contain a virtual addre=
ss of
+ * the register set, but some DTS files have redefined that property to be=
 the
+ * MAC address.
+ *
+ * All-zero MAC addresses are rejected, because those could be properties =
that
+ * exist in the device tree, but were not set by U-Boot.  For example, the
+ * DTS could define 'mac-address' and 'local-mac-address', with zero MAC
+ * addresses.  Some older U-Boots only initialized 'local-mac-address'.  I=
n
+ * this case, the real MAC is in 'local-mac-address', and 'mac-address' ex=
ists
+ * but is all zeros.
+*/
+void *device_get_mac_address(struct device *dev, char *addr, int alen)
+{
+=09addr =3D device_get_mac_addr(dev, "mac-address", addr, alen);
+=09if (addr)
+=09=09return addr;
+
+=09addr =3D device_get_mac_addr(dev, "local-mac-address", addr, alen);
+=09if (addr)
+=09=09return addr;
+
+=09return device_get_mac_addr(dev, "address", addr, alen);
+}
+EXPORT_SYMBOL(device_get_mac_address);
diff --git a/include/linux/property.h b/include/linux/property.h
index 76ebde9..a59c6ee 100644
--- a/include/linux/property.h
+++ b/include/linux/property.h
@@ -166,4 +166,8 @@ void device_add_property_set(struct device *dev, struct=
 property_set *pset);
=20
 bool device_dma_is_coherent(struct device *dev);
=20
+int device_get_phy_mode(struct device *dev);
+
+void *device_get_mac_address(struct device *dev, char *addr, int alen);
+
 #endif /* _LINUX_PROPERTY_H_ */
--=20
2.4.3
