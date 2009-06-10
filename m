From: Martin Fuzzey <mfuzzey@gmail.com>
Subject: [RFC PATCH] Ethtool style in kernel network driver configuration.
Date: Wed, 10 Jun 2009 19:34:43 +0200
Message-ID: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nico@cam.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f210.google.com ([209.85.219.210]:39659 "EHLO
	mail-ew0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786AbZFJReu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 13:34:50 -0400
Received: by ewy6 with SMTP id 6so1201823ewy.37
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2009 10:34:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow network drivers to be configured by the kernel
in the same way as the userspace "ethtool" program as suggested
by Nicolas Pitre in a recent mailing list discussion.

Two methods are possible, selected by KConfig:

1) Kernel parameter (net_ethconfig.ethtool)
which accepts (most of) the same arguments as "ethtool -s"

	net_ethconfig.ethtool="eth0 speed 10 duplex full"

The wol, sopass and msglvl parameters are not (yet?) supported.

2) Programatic configuration via a new function
neteth_configure_interface() (typically from board specific setup code):

#include <linux/net-ethconfig.h>
static struct neteth_if_config force_10mbps = {
	.etool_cmd = {
		.speed = SPEED_10,
		.duplex = DUPLEX_FULL,
	},
	.set_flags = NETCONF_SET_SPEED | NETCONF_SET_DUPLEX,
};
...
neteth_configure_interface("eth0", &force_10mbps);

The programatic method may be required in certain embedded situations
(for example when different hardware revisions require different
configurations and the hardware revision can be detected by software).

Signed-off-by: Martin Fuzzey <mfuzzey@gmail.com>

---

I'm not really happy with the placement of this as it's not core,
but it's not a driver either so any better ideas?

Also not sure if I need to hold a lock while manipulating the device
from the notifier callback.

 Documentation/kernel-parameters.txt |    4 
 include/linux/net-ethconfig.h       |   30 ++
 net/Kconfig                         |   36 ++
 net/core/Makefile                   |    2 
 net/core/net-ethconfig.c            |  545 +++++++++++++++++++++++++++++++++++
 5 files changed, 616 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/net-ethconfig.h
 create mode 100644 net/core/net-ethconfig.c

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 600cdd7..6151f36 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1422,6 +1422,10 @@ and is between 256 and 4096 characters. It is defined in the file
 			This usage is only documented in each driver source
 			file if at all.
 
+	net_ethconfig.ethtool=	[NET] ethtool style network configuration
+			Accepts most of options of ethtool -s
+			Example net_ethconfig.ethtool="eth0 speed 10 duplex full"
+
 	nf_conntrack.acct=
 			[NETFILTER] Enable connection tracking flow accounting
 			0 to disable accounting
diff --git a/include/linux/net-ethconfig.h b/include/linux/net-ethconfig.h
new file mode 100644
index 0000000..1b50361
--- /dev/null
+++ b/include/linux/net-ethconfig.h
@@ -0,0 +1,30 @@
+/*
+ * net-config.h: Defines for programatic interface for board setup code
+ *
+ * Copyright (C) 2009 Martin Fuzzey <mfuzzey@gmail.com>
+ */
+
+#ifndef _LINUX_NET_CONFIG_H
+#define _LINUX_NET_CONFIG_H
+
+#include <linux/ethtool.h>
+
+#define NETCONF_SET_ADVERTISING		(1 << 0)
+#define NETCONF_SET_SPEED		(1 << 1)
+#define NETCONF_SET_DUPLEX		(1 << 2)
+#define NETCONF_SET_PORT		(1 << 3)
+#define NETCONF_SET_PHY_ADDR		(1 << 4)
+#define NETCONF_SET_TRANCEIVER		(1 << 5)
+#define NETCONF_SET_AUTONEG		(1 << 6)
+
+struct neteth_if_config {
+	struct ethtool_cmd etool_cmd;
+	unsigned int set_flags;
+};
+
+int neteth_configure_interface(
+		const char *name,
+		struct neteth_if_config *if_config);
+
+#endif
+
diff --git a/net/Kconfig b/net/Kconfig
index ce77db4..e1e8744 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -188,6 +188,42 @@ source "net/phonet/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 
+menuconfig NET_ETHCONFIG
+	bool "Kernel configuration of network device parameters"
+	---help---
+	  This option allows the "ethtool" interface to be used from within
+	  the kernel or via the kernel command line. It provides support
+	  for setting such things as links speed and duplex.
+
+	  This facility is intended for embedded systems which may need to
+	  force specific settings at boot time but where the complexity of
+	  using ethtool from userspace is undesirable.
+
+if NET_ETHCONFIG
+config NET_ETHCONFIG_CMDLINE
+	bool "Enable network device configuration via kernel command line"
+	depends on NET_ETHCONFIG
+	help
+	  Saying Y here will enable the kernel parameter net_ethconfig.ethtool
+	  This parameter takes a comma seperated list of network configurations
+	  in the same format as accepted by the -s option to userspace ethtool
+	  program.
+
+config NET_ETHCONFIG_PROG
+	bool "Enable programatic network device configuration"
+	depends on NET_ETHCONFIG
+	help
+	  You can say Y here to allow board specific code to programaticaly
+	  configure the network interfaces.
+
+config NET_ETHCONFIG_DEBUG
+	bool "Enable configuration debugging"
+	depends on NET_ETHCONFIG
+	help
+	  You can say Y here to generate detailed messages regarding the network
+	  device configuration.
+endif
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/core/Makefile b/net/core/Makefile
index 796f46e..fc2b3d0 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -19,4 +19,4 @@ obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
-
+obj-$(CONFIG_NET_ETHCONFIG) += net-ethconfig.o
diff --git a/net/core/net-ethconfig.c b/net/core/net-ethconfig.c
new file mode 100644
index 0000000..f059fc2
--- /dev/null
+++ b/net/core/net-ethconfig.c
@@ -0,0 +1,545 @@
+/****************************************************************
+ * In kernel ethtool configuration for network devices.
+ *
+ * Copyright (c) 2009 by Martin Fuzzey <mfuzzey@gmail.com>
+
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ ****************************************************************/
+
+/*
+This module allows network drivers to be configured by the kernel
+in the same way as the userspace "ethtool" program.
+
+Two methods are possible, selected by configuration:
+
+1) Kernel parameter (net_ethconfig.ethtool)
+which accepts (most of) the same arguments as "ethtool -s"
+Eg: net_ethconfig.ethtool="eth0 speed 10 duplex full"
+
+The wol, sopass and msglvl parameters are not (yet?) supported.
+
+2) Programatic configuration via neteth_configure_interface() (typically
+from board specific setup code):
+
+#include <linux/net-ethconfig.h>
+static struct neteth_if_config force_10mbps = {
+	.etool_cmd = {
+		.speed = SPEED_10,
+		.duplex = DUPLEX_FULL,
+	},
+	.set_flags = NETCONF_SET_SPEED | NETCONF_SET_DUPLEX,
+};
+...
+neteth_configure_interface("eth0", &force_10mbps);
+*/
+
+
+#ifdef CONFIG_NET_ETHCONFIG_DEBUG
+#define DEBUG 1
+#endif
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+#include <linux/net-ethconfig.h>
+
+static char module_name[] = "net-ethconfig";
+
+MODULE_AUTHOR("Martin Fuzzey <mfuzzey@gmail.com>");
+MODULE_DESCRIPTION("Ethtool based network configuration");
+MODULE_LICENSE("GPL");
+
+#define ADVERTISED_SPEEDS (ADVERTISED_10baseT_Half |\
+				ADVERTISED_10baseT_Full |\
+				ADVERTISED_100baseT_Half |\
+				ADVERTISED_100baseT_Full |\
+				ADVERTISED_1000baseT_Half |\
+				ADVERTISED_1000baseT_Full|\
+				ADVERTISED_2500baseX_Full |\
+				ADVERTISED_10000baseT_Full)
+
+struct if_config {
+	char name[IFNAMSIZ];
+	unsigned int set_flags;
+	struct ethtool_cmd cmd;
+};
+
+static unsigned int config_count;
+static struct if_config if_config[2];
+static DEFINE_SPINLOCK(if_config_lock);
+
+#ifdef CONFIG_NET_ETHCONFIG_CMDLINE
+
+struct param_def {
+	const char *name;
+	int (*parse)(const char *, struct if_config *);
+};
+
+struct choice {
+	const char *name;
+	int value;
+};
+
+
+static struct choice *find_choice(
+		const char *val, struct choice *choices, int count)
+{
+	int i;
+	struct choice *choice;
+
+	for (i = 0, choice = choices; i < count; i++, choice++) {
+		if (!strcmp(val, choice->name))
+			return choice;
+	}
+	return NULL;
+}
+
+static struct choice speed_choices[] = {
+	{"10", SPEED_10},
+	{"100", SPEED_100},
+	{"1000", SPEED_1000},
+	{"2500", SPEED_2500},
+	{"10000", SPEED_10000}
+};
+
+static int parse_speed(const char *val, struct if_config *config)
+{
+	struct choice *choice = find_choice(val,
+		speed_choices, ARRAY_SIZE(speed_choices));
+
+	if (choice == NULL)
+		return -EINVAL;
+
+	ethtool_cmd_speed_set(&config->cmd, (u32)choice->value);
+	config->set_flags |= NETCONF_SET_SPEED;
+	return 0;
+}
+
+static struct choice duplex_choices[] = {
+	{"half", DUPLEX_HALF},
+	{"full", DUPLEX_FULL}
+};
+
+static int parse_duplex(const char *val, struct if_config *config)
+{
+	struct choice *choice = find_choice(val,
+		duplex_choices, ARRAY_SIZE(duplex_choices));
+
+	if (choice == NULL)
+		return -EINVAL;
+
+	config->cmd.duplex = (u8)choice->value;
+	config->set_flags |= NETCONF_SET_DUPLEX;
+	return 0;
+}
+
+static struct choice port_choices[] = {
+	{"tp", PORT_TP},
+	{"aui", PORT_AUI},
+	{"bnc", PORT_BNC},
+	{"mii", PORT_MII},
+	{"fibre", PORT_FIBRE},
+};
+
+static int parse_port(const char *val, struct if_config *config)
+{
+	struct choice *choice = find_choice(val,
+		port_choices, ARRAY_SIZE(port_choices));
+
+	if (choice == NULL)
+		return -EINVAL;
+
+	config->cmd.port = (u8)choice->value;
+	config->set_flags |= NETCONF_SET_PORT;
+	return 0;
+}
+
+static struct choice autoneg_choices[] = {
+	{"on", AUTONEG_ENABLE},
+	{"off", AUTONEG_DISABLE}
+};
+
+static int parse_autoneg(const char *val, struct if_config *config)
+{
+	struct choice *choice = find_choice(val,
+		autoneg_choices, ARRAY_SIZE(autoneg_choices));
+
+	if (choice == NULL)
+		return -EINVAL;
+
+	config->cmd.autoneg = (u8)choice->value;
+	config->set_flags |= NETCONF_SET_AUTONEG;
+	return 0;
+}
+
+static int parse_advertise(const char *val, struct if_config *config)
+{
+	unsigned long advertising;
+
+	if (strict_strtoul(val, 16, &advertising))
+		return -EINVAL;
+
+	config->cmd.advertising = advertising;
+	config->set_flags |= NETCONF_SET_ADVERTISING;
+	return 0;
+}
+
+static int parse_phyad(const char *val, struct if_config *config)
+{
+	unsigned long phyad;
+
+	if (strict_strtoul(val, 0, &phyad))
+		return -EINVAL;
+
+	config->cmd.phy_address = (u8)phyad;
+	config->set_flags |= NETCONF_SET_PHY_ADDR;
+	return 0;
+}
+
+static struct choice xcvr_choices[] = {
+	{"internal", XCVR_INTERNAL},
+	{"external", XCVR_EXTERNAL}
+};
+
+static int parse_xcvr(const char *val, struct if_config *config)
+{
+	struct choice *choice = find_choice(val,
+		xcvr_choices, ARRAY_SIZE(xcvr_choices));
+
+	if (choice == NULL)
+		return -EINVAL;
+
+	config->cmd.transceiver = (u8)choice->value;
+	config->set_flags |= NETCONF_SET_TRANCEIVER;
+	return 0;
+}
+
+
+static struct param_def param_defs[] = {
+	{ .name = "speed", .parse = parse_speed },
+	{ .name = "duplex", .parse = parse_duplex },
+	{ .name = "port", .parse = parse_port },
+	{ .name = "autoneg", .parse = parse_autoneg },
+	{ .name = "advertise", .parse = parse_advertise },
+	{ .name = "phyad", .parse = parse_phyad },
+	{ .name = "xcvr", .parse = parse_xcvr }
+};
+
+enum parser_state {
+	INTERFACE,
+	KEY,
+	VALUE
+};
+
+static int param_set_ethtoolcmd(const char *val, struct kernel_param *kp)
+{
+	enum parser_state state = INTERFACE;
+	struct if_config *config = kp->arg;
+	char buf[64];
+	char *cur = buf, *word;
+	struct param_def *param = NULL;
+	int i, rc = 0;
+
+	strlcpy(buf, val, sizeof(buf)); /* don't mangle original */
+
+	do {
+		word = strsep(&cur, " ");
+		if (!word || *word == 0)
+			continue;
+
+		switch (state) {
+		case INTERFACE:
+			pr_debug("%s: cmdline config found for %s\n",
+				module_name, word);
+			strlcpy(config->name, word, sizeof(config->name));
+			state = KEY;
+			break;
+
+		case KEY:
+			param = param_defs;
+			for (i = 0; i < ARRAY_SIZE(param_defs); i++, param++)
+				if (!strcmp(word, param->name)) {
+					state = VALUE;
+					break;
+				}
+			if (state == KEY) {
+				pr_err("%s: Invalid key %s\n",
+					module_name, word);
+				return -EINVAL;
+			}
+			break;
+
+		case VALUE:
+			rc = param->parse(word, config);
+			if (rc < 0) {
+				pr_err("%s: Invalid value %s for %s\n",
+					module_name, word, param->name);
+				return rc;
+			}
+			state = KEY;
+			break;
+		}
+	} while (word);
+
+	if (state != KEY) {
+		pr_err("%s: %s too short\n", module_name, val);
+		rc = -EINVAL;
+	}
+	return rc;
+}
+
+static int param_get_ethtoolcmd(char *buffer, struct kernel_param *kp)
+{
+	return 0; /* no sysfs export so this should never be called */
+}
+
+module_param_array_named(ethtool, if_config, ethtoolcmd, &config_count, 0);
+
+#endif  /* CONFIG_NET_ETHCONFIG_CMDLINE */
+
+
+static struct if_config *find_config(const char *name)
+{
+	int i;
+	struct if_config *config = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&if_config_lock, flags);
+	for (i = 0; i < config_count; i++) {
+		if (!strcmp(name,  if_config[i].name)) {
+			config = &if_config[i];
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&if_config_lock, flags);
+	return config;
+}
+
+static void copy_set_fields(
+		struct ethtool_cmd *src,
+		struct ethtool_cmd *dest,
+		unsigned int set_flags)
+{
+	if (set_flags & NETCONF_SET_ADVERTISING)
+		dest->advertising = src->advertising;
+
+	if (set_flags & NETCONF_SET_SPEED) {
+		dest->speed = src->speed;
+		dest->speed_hi = src->speed_hi;
+	}
+
+	if (set_flags & NETCONF_SET_DUPLEX)
+		dest->duplex = src->duplex;
+
+	if (set_flags & NETCONF_SET_PORT)
+		dest->port = src->port;
+
+	if (set_flags & NETCONF_SET_PHY_ADDR)
+		dest->phy_address = src->phy_address;
+
+	if (set_flags & NETCONF_SET_TRANCEIVER)
+		dest->transceiver = src->transceiver;
+
+	if (set_flags & NETCONF_SET_AUTONEG)
+		dest->autoneg = src->autoneg;
+}
+
+static void dump_config(const char *header, struct ethtool_cmd *config)
+{
+	pr_debug("%s: %s "
+		"speed=%d duplex=%d "
+		"advertise=0x%08X supported=0x%08X "
+		"autoneg=%d\n",
+		module_name,
+		header,
+		config->speed, config->duplex,
+		config->advertising, config->supported,
+		config->autoneg);
+}
+
+
+#ifdef CONFIG_NET_ETHCONFIG_PROG
+
+int neteth_configure_interface(const char *name,
+		struct neteth_if_config *prog_config)
+{
+	struct if_config *config = NULL;
+	unsigned long flags;
+	int rc = 0;
+
+	pr_debug("%s: programatic configuration for %s\n",
+		module_name, name);
+
+	config = find_config(name);
+	spin_lock_irqsave(&if_config_lock, flags);
+
+	if (!config) {
+		if (config_count >= ARRAY_SIZE(if_config)) {
+			pr_err("%s: no free slots\n", module_name);
+			rc = -ENOSPC;
+			goto out;
+		}
+		config = &if_config[config_count++];
+		config->set_flags = 0;
+		strlcpy(config->name, name, sizeof(config->name));
+	}
+
+	config->set_flags |= prog_config->set_flags;
+	copy_set_fields(&prog_config->etool_cmd, &config->cmd,
+		prog_config->set_flags);
+
+out:
+	spin_unlock_irqrestore(&if_config_lock, flags);
+	return rc;
+}
+EXPORT_SYMBOL(neteth_configure_interface);
+
+#endif /* CONFIG_NET_ETHCONFIG_PROG */
+
+
+static u32 calc_advertising(u32 speed, u8 duplex)
+{
+	u32 advertising = 0;
+
+	switch (speed) {
+	case SPEED_10:
+		advertising = (duplex == DUPLEX_FULL) ?
+			ADVERTISED_10baseT_Full : ADVERTISED_10baseT_Half;
+		break;
+
+	case SPEED_100:
+		advertising = (duplex == DUPLEX_FULL) ?
+			ADVERTISED_100baseT_Full : ADVERTISED_100baseT_Half;
+		break;
+
+	case SPEED_1000:
+		advertising = (duplex == DUPLEX_FULL) ?
+			ADVERTISED_1000baseT_Full : ADVERTISED_1000baseT_Half;
+		break;
+
+	case SPEED_2500:
+		advertising = ADVERTISED_2500baseX_Full;
+		break;
+
+	case SPEED_10000:
+		advertising = ADVERTISED_10000baseT_Full;
+		break;
+	}
+	return advertising;
+}
+
+
+static int netconfig_netdev_event(struct notifier_block *this,
+		unsigned long event,
+		void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct ethtool_cmd etool_cmd;
+	struct if_config *config;
+	int rc;
+
+	if (event != NETDEV_UP)
+		goto done;
+
+	pr_debug("%s: dev=%s\n", module_name, dev->name);
+
+	config = find_config(dev->name);
+	if (!config)
+		goto done;
+
+	if (!dev->ethtool_ops ||
+			!dev->ethtool_ops->get_settings ||
+			!dev->ethtool_ops->set_settings) {
+		pr_warning(
+			"%s: %s has no ethtool support - not configuring\n",
+			module_name, dev->name);
+		goto done;
+	}
+
+	rc = dev->ethtool_ops->get_settings(dev, &etool_cmd);
+	if (rc) {
+		pr_err("%s: unable to obtain current configuration for %s "
+			"(%d)\n", module_name, dev->name, rc);
+		goto done;
+	}
+
+	dump_config("current", &etool_cmd);
+
+	if (config->set_flags & NETCONF_SET_ADVERTISING) {
+		if (config->cmd.advertising)
+			etool_cmd.advertising = config->cmd.advertising;
+		else
+			etool_cmd.advertising =
+				etool_cmd.supported & ADVERTISED_SPEEDS;
+	} else {
+		if ((config->set_flags & NETCONF_SET_SPEED) &&
+				(config->set_flags & NETCONF_SET_DUPLEX)) {
+			u32 advertising = calc_advertising(
+				ethtool_cmd_speed(&config->cmd),
+				config->cmd.duplex);
+
+			if (advertising) {
+				advertising |= (etool_cmd.advertising &
+					~ADVERTISED_SPEEDS);
+				etool_cmd.advertising = advertising;
+			}
+		}
+	}
+
+	copy_set_fields(&etool_cmd, &config->cmd,
+		config->set_flags & ~NETCONF_SET_ADVERTISING);
+
+	dump_config("new", &etool_cmd);
+
+	if (dev->ethtool_ops->begin) {
+		rc = dev->ethtool_ops->begin(dev);
+		if (rc) {
+			pr_err("%s: ethtool begin failed for %s (%d)\n",
+				module_name, dev->name, rc);
+			goto done;
+		}
+	}
+
+	rc = dev->ethtool_ops->set_settings(dev, &etool_cmd);
+	if (rc)
+		pr_err("%s: ethtool set failed for %s (%d)\n",
+			module_name, dev->name, rc);
+	else
+		pr_info("%s: configured %s\n", module_name, dev->name);
+
+	if (dev->ethtool_ops->complete)
+		dev->ethtool_ops->complete(dev);
+
+done:
+	return NOTIFY_DONE;
+}
+
+
+static struct notifier_block netconfig_netdev_notifier = {
+	.notifier_call  = netconfig_netdev_event,
+};
+
+static int __init netconfig_init(void)
+{
+	int err;
+
+	err = register_netdevice_notifier(&netconfig_netdev_notifier);
+	if (err)
+		goto fail;
+
+	pr_info("%s: %d configs\n", module_name, config_count);
+	return 0;
+
+fail:
+	return err;
+
+}
+
+module_init(netconfig_init);

