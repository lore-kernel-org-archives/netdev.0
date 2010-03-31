From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 1/2] phylib: Support phy module autoloading
Date: Wed, 31 Mar 2010 02:18:54 +0100
Message-ID: <1269998334.18090.278.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60193 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab0CaBS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 21:18:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't use the normal hotplug mechanism because it doesn't work. It will
load the module some time after the device appears, but that's not good
enough for us -- we need the driver loaded _immediately_ because otherwise
the NIC driver may just abort and then the phy 'device' goes away.

Instead, we just issue a request_module() directly in phy_device_create().

The device aliases take the form 'phy:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
with a binary representation of the phy_id. This means that the "don't
care" bits of driver's phy_id_mask can be question marks which modprobe
will interpret correctly as wildcards.

So a driver with { .phy_id = 0x02345600, .phy_id_mask = 0x0fffff00 }
will have an alias of phy:????00100011010001010110???????? and will be
loaded whenever any matching phy is created by phy_device_create().

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/net/phy/phy_device.c    |   13 +++++++++++++
 include/linux/mod_devicetable.h |   20 ++++++++++++++++++++
 include/linux/phy.h             |    1 +
 scripts/mod/file2alias.c        |   25 +++++++++++++++++++++++++
 4 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index db17945..b35ec7e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -149,6 +149,8 @@ EXPORT_SYMBOL(phy_scan_fixups);
 struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 {
 	struct phy_device *dev;
+	char modid[37];
+
 	/* We allocate the device, and initialize the
 	 * default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
@@ -179,6 +181,17 @@ struct phy_device* phy_device_create(struct mii_bus *bus, int addr, int phy_id)
 	mutex_init(&dev->lock);
 	INIT_DELAYED_WORK(&dev->state_queue, phy_state_machine);
 
+#ifdef CONFIG_MODULES
+	/* Request the appropriate module unconditionally. A hotplug
+	   event would have done so anyway. But normal hotplug won't
+	   work for MDIO -- because it relies on the device staying
+	   around for long enough for the driver to get loaded. With
+	   MDIO, the NIC driver will get bored and give up as soon
+	   as it finds that there's no driver _already_ loaded. */
+	sprintf(modid, "phy:" PHYID_FMT, PHYID_ARGS(phy_id));
+	request_module(modid);
+#endif
+
 	return dev;
 }
 EXPORT_SYMBOL(phy_device_create);
diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
index f58e9d8..0c3e300 100644
--- a/include/linux/mod_devicetable.h
+++ b/include/linux/mod_devicetable.h
@@ -474,4 +474,24 @@ struct platform_device_id {
 			__attribute__((aligned(sizeof(kernel_ulong_t))));
 };
 
+#define PHY_MODULE_PREFIX	"phy:"
+
+#define PHYID_FMT "%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d"
+#define PHYID_ARGS(_id) \
+	(_id)>>31, ((_id)>>30) & 1, ((_id)>>29) & 1, ((_id)>>28) & 1,	\
+	((_id)>>27) & 1, ((_id)>>26) & 1, ((_id)>>25) & 1, ((_id)>>24) & 1, \
+	((_id)>>23) & 1, ((_id)>>22) & 1, ((_id)>>21) & 1, ((_id)>>20) & 1, \
+	((_id)>>19) & 1, ((_id)>>18) & 1, ((_id)>>17) & 1, ((_id)>>16) & 1, \
+	((_id)>>15) & 1, ((_id)>>14) & 1, ((_id)>>13) & 1, ((_id)>>12) & 1, \
+	((_id)>>11) & 1, ((_id)>>10) & 1, ((_id)>>9) & 1, ((_id)>>8) & 1, \
+	((_id)>>7) & 1, ((_id)>>6) & 1, ((_id)>>5) & 1, ((_id)>>4) & 1, \
+	((_id)>>3) & 1, ((_id)>>2) & 1, ((_id)>>1) & 1, (_id) & 1
+
+
+
+struct phy_device_id {
+	uint32_t phy_id;
+	uint32_t phy_id_mask;
+};
+
 #endif /* LINUX_MOD_DEVICETABLE_H */
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 14d7fdf..f269f1b 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -24,6 +24,7 @@
 #include <linux/mii.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
+#include <linux/mod_devicetable.h>
 
 #include <asm/atomic.h>
 
diff --git a/scripts/mod/file2alias.c b/scripts/mod/file2alias.c
index 220213e..b412185 100644
--- a/scripts/mod/file2alias.c
+++ b/scripts/mod/file2alias.c
@@ -796,6 +796,27 @@ static int do_platform_entry(const char *filename,
 	return 1;
 }
 
+static int do_phy_entry(const char *filename,
+			struct phy_device_id *id, char *alias)
+{
+	char str[33];
+	int i;
+
+	str[32] = 0;
+
+	for (i = 0; i < 32; i++) {
+		if (!((id->phy_id_mask >> (31-i)) & 1))
+			str[i] = '?';
+		else if ((id->phy_id >> (31-i)) & 1)
+			str[i] = '1';
+		else
+			str[i] = '0';
+	}
+
+	sprintf(alias, PHY_MODULE_PREFIX "%s", str);
+	return 1;
+}
+
 /* Ignore any prefix, eg. some architectures prepend _ */
 static inline int sym_is(const char *symbol, const char *name)
 {
@@ -943,6 +964,10 @@ void handle_moddevtable(struct module *mod, struct elf_info *info,
 		do_table(symval, sym->st_size,
 			 sizeof(struct platform_device_id), "platform",
 			 do_platform_entry, mod);
+	else if (sym_is(symname, "__mod_phy_device_table"))
+		do_table(symval, sym->st_size,
+			 sizeof(struct phy_device_id), "phy",
+			 do_phy_entry, mod);
 	free(zeros);
 }
 
-- 
1.6.6.1

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

