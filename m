From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 01/37] i2c/of: Allow device node to be passed via
	i2c_board_info
Date: Thu, 11 Mar 2010 11:03:52 -0700
Message-ID: <20100311180352.4824.75457.stgit__24487.8881182105$1268332975$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34774 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933509Ab0CKSD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:03:59 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct device_node *of_node pointer is moving out of dev->archdata
and into the struct device proper.  of_i2c.c needs to set the of_node
pointer before the device is registered.  Since the i2c subsystem
doesn't allow 2 stage allocation and registration of i2c devices, the
of_node pointer needs to be passed via the i2c_board_info structure
so that it is set prior to registration.

This patch adds of_node to struct i2c_board_info (conditional on
CONFIG_OF), sets of_node in i2c_new_device(), and modifies of_i2c.c
to use the new parameter.  The calling of dev_archdata_set_node()
from of_i2c will be removed in a subsequent patch when of_node is
removed from archdata and all users are converted over.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/i2c/i2c-core.c |    3 +++
 drivers/of/of_i2c.c    |    3 ++-
 include/linux/i2c.h    |    4 ++++
 3 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/i2c/i2c-core.c b/drivers/i2c/i2c-core.c
index 3202a86..4099b2b 100644
--- a/drivers/i2c/i2c-core.c
+++ b/drivers/i2c/i2c-core.c
@@ -387,6 +387,9 @@ i2c_new_device(struct i2c_adapter *adap, struct i2c_board_info const *info)
 	client->dev.parent = &client->adapter->dev;
 	client->dev.bus = &i2c_bus_type;
 	client->dev.type = &i2c_client_type;
+#ifdef CONFIG_OF
+	client->dev.of_node = info->of_node;
+#endif
 
 	dev_set_name(&client->dev, "%d-%04x", i2c_adapter_id(adap),
 		     client->addr);
diff --git a/drivers/of/of_i2c.c b/drivers/of/of_i2c.c
index a3a708e..605bc42 100644
--- a/drivers/of/of_i2c.c
+++ b/drivers/of/of_i2c.c
@@ -42,7 +42,8 @@ void of_register_i2c_devices(struct i2c_adapter *adap,
 
 		info.addr = be32_to_cpup(addr);
 
-		dev_archdata_set_node(&dev_ad, node);
+		dev_archdata_set_node(&dev_ad, node); /* temporary */
+		info.of_node = node;
 		info.archdata = &dev_ad;
 
 		request_module("%s", info.type);
diff --git a/include/linux/i2c.h b/include/linux/i2c.h
index 0a5da63..4f37ff1 100644
--- a/include/linux/i2c.h
+++ b/include/linux/i2c.h
@@ -34,6 +34,7 @@
 #include <linux/device.h>	/* for struct device */
 #include <linux/sched.h>	/* for completion */
 #include <linux/mutex.h>
+#include <linux/of.h>		/* for struct device_node */
 
 extern struct bus_type i2c_bus_type;
 
@@ -251,6 +252,9 @@ struct i2c_board_info {
 	unsigned short	addr;
 	void		*platform_data;
 	struct dev_archdata	*archdata;
+#ifdef CONFIG_OF
+	struct device_node *of_node;
+#endif
 	int		irq;
 };
 

