From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 2/4 net-next] tools: add Generic Netlink switch
 configuration tool
Date: Tue, 22 Oct 2013 11:23:47 -0700
Message-ID: <1382466229-15123-3-git-send-email-f.fainelli@gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, nbd@openwrt.org,
	blogic@openwrt.org, jogo@openwrt.org, gary@mlbassoc.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2515 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454Ab3JVSYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 14:24:11 -0400
In-Reply-To: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the user-space configuration tool for the Generic Netlink switch
configuration API. This tool is currently linking with libnl-1 and uses
pkg-config to discover the netlink library to use.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: John Crispin <blogic@openwrt.org>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 MAINTAINERS               |   1 +
 tools/Makefile            |  10 +-
 tools/swconfig/.gitignore |   2 +
 tools/swconfig/Makefile   |  15 +
 tools/swconfig/cli.c      | 328 +++++++++++++++++++
 tools/swconfig/swlib.c    | 786 ++++++++++++++++++++++++++++++++++++++++++++++
 tools/swconfig/swlib.h    | 244 ++++++++++++++
 7 files changed, 1385 insertions(+), 1 deletion(-)
 create mode 100644 tools/swconfig/.gitignore
 create mode 100644 tools/swconfig/Makefile
 create mode 100644 tools/swconfig/cli.c
 create mode 100644 tools/swconfig/swlib.c
 create mode 100644 tools/swconfig/swlib.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 3a54262..bdd5b0f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8126,6 +8126,7 @@ F:	drivers/net/ethernet/phy/swconfig*.c
 F:	include/uapi/linux/switch.h
 F:	include/linux/switch.h
 F:	Documentation/networking/swconfig.txt
+F:	tools/swconfig/
 
 SYNOPSYS ARC ARCHITECTURE
 M:	Vineet Gupta <vgupta@synopsys.com>
diff --git a/tools/Makefile b/tools/Makefile
index 41067f3..2dbb2695 100644
--- a/tools/Makefile
+++ b/tools/Makefile
@@ -15,6 +15,7 @@ help:
 	@echo '  net        - misc networking tools'
 	@echo '  vm         - misc vm tools'
 	@echo '  x86_energy_perf_policy - Intel energy policy tool'
+	@echo '  swconfig   - netlink switch configuration tool'
 	@echo ''
 	@echo 'You can do:'
 	@echo ' $$ make -C tools/ <tool>_install'
@@ -50,6 +51,9 @@ selftests: FORCE
 turbostat x86_energy_perf_policy: FORCE
 	$(call descend,power/x86/$@)
 
+swconfig: FORCE
+	$(call descend,swconfig)
+
 cpupower_install:
 	$(call descend,power/$(@:_install=),install)
 
@@ -84,8 +88,12 @@ selftests_clean:
 turbostat_clean x86_energy_perf_policy_clean:
 	$(call descend,power/x86/$(@:_clean=),clean)
 
+swconfig_clean:
+	$(call descend,swconfig,clean)
+
 clean: cgroup_clean cpupower_clean firewire_clean lguest_clean perf_clean \
 		selftests_clean turbostat_clean usb_clean virtio_clean \
-		vm_clean net_clean x86_energy_perf_policy_clean
+		vm_clean net_clean x86_energy_perf_policy_clean \
+		swconfig_clean
 
 .PHONY: FORCE
diff --git a/tools/swconfig/.gitignore b/tools/swconfig/.gitignore
new file mode 100644
index 0000000..b23b79b
--- /dev/null
+++ b/tools/swconfig/.gitignore
@@ -0,0 +1,2 @@
+/swconfig
+/*.o
diff --git a/tools/swconfig/Makefile b/tools/swconfig/Makefile
new file mode 100644
index 0000000..96158678
--- /dev/null
+++ b/tools/swconfig/Makefile
@@ -0,0 +1,15 @@
+ifndef CFLAGS
+CFLAGS = -O2 -g -D_GNU_SOURCE $(shell pkg-config --cflags libnl-1)
+endif
+LIBS=$(shell pkg-config --libs libnl-1)
+
+all: swconfig
+
+%.o: %.c
+	$(CC) $(CFLAGS) -c -o $@ $^
+
+swconfig: cli.o swlib.o
+	$(CC) $(LDFLAGS) -o $@ $^ $(LIBS)
+
+clean:
+	-rm *.o swconfig
diff --git a/tools/swconfig/cli.c b/tools/swconfig/cli.c
new file mode 100644
index 0000000..9752c95
--- /dev/null
+++ b/tools/swconfig/cli.c
@@ -0,0 +1,328 @@
+/*
+ * swconfig.c: Switch configuration utility
+ *
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
+ * Copyright (C) 2010 Martin Mares <mj@ucw.cz>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundatio.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <stdbool.h>
+#include <inttypes.h>
+#include <errno.h>
+#include <stdint.h>
+#include <getopt.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include <linux/types.h>
+#include <linux/netlink.h>
+#include <linux/genetlink.h>
+#include <netlink/netlink.h>
+#include <netlink/genl/genl.h>
+#include <netlink/genl/ctrl.h>
+#include "../../include/uapi/linux/swconfig.h"
+#include "swlib.h"
+
+enum {
+	CMD_NONE,
+	CMD_GET,
+	CMD_SET,
+	CMD_LOAD,
+	CMD_HELP,
+	CMD_SHOW,
+	CMD_PORTMAP,
+};
+
+static void
+print_attrs(const struct switch_attr *attr)
+{
+	int i = 0;
+	while (attr) {
+		const char *type;
+		switch(attr->type) {
+			case SWITCH_TYPE_INT:
+				type = "int";
+				break;
+			case SWITCH_TYPE_STRING:
+				type = "string";
+				break;
+			case SWITCH_TYPE_PORTS:
+				type = "ports";
+				break;
+			case SWITCH_TYPE_NOVAL:
+				type = "none";
+				break;
+			default:
+				type = "unknown";
+				break;
+		}
+		printf("\tAttribute %d (%s): %s (%s)\n", ++i, type, attr->name, attr->description);
+		attr = attr->next;
+	}
+}
+
+static void
+list_attributes(struct switch_dev *dev)
+{
+	printf("%s: %s(%s), ports: %d (cpu @ %d), vlans: %d\n", dev->dev_name, dev->alias, dev->name, dev->ports, dev->cpu_port, dev->vlans);
+	printf("     --switch\n");
+	print_attrs(dev->ops);
+	printf("     --vlan\n");
+	print_attrs(dev->vlan_ops);
+	printf("     --port\n");
+	print_attrs(dev->port_ops);
+}
+
+static void
+print_attr_val(const struct switch_attr *attr, const struct switch_val *val)
+{
+	int i;
+
+	switch (attr->type) {
+	case SWITCH_TYPE_INT:
+		printf("%d", val->value.i);
+		break;
+	case SWITCH_TYPE_STRING:
+		printf("%s", val->value.s);
+		break;
+	case SWITCH_TYPE_PORTS:
+		for(i = 0; i < val->len; i++) {
+			printf("%d%s ",
+				val->value.ports[i].id,
+				(val->value.ports[i].flags &
+				 SWLIB_PORT_FLAG_TAGGED) ? "t" : "");
+		}
+		break;
+	default:
+		printf("?unknown-type?");
+	}
+}
+
+static void
+show_attrs(struct switch_dev *dev, struct switch_attr *attr, struct switch_val *val)
+{
+	while (attr) {
+		if (attr->type != SWITCH_TYPE_NOVAL) {
+			printf("\t%s: ", attr->name);
+			if (swlib_get_attr(dev, attr, val) < 0)
+				printf("???");
+			else
+				print_attr_val(attr, val);
+			putchar('\n');
+		}
+		attr = attr->next;
+	}
+}
+
+static void
+show_global(struct switch_dev *dev)
+{
+	struct switch_val val;
+
+	printf("Global attributes:\n");
+	show_attrs(dev, dev->ops, &val);
+}
+
+static void
+show_port(struct switch_dev *dev, int port)
+{
+	struct switch_val val;
+
+	printf("Port %d:\n", port);
+	val.port_vlan = port;
+	show_attrs(dev, dev->port_ops, &val);
+}
+
+static void
+show_vlan(struct switch_dev *dev, int vlan, bool all)
+{
+	struct switch_val val;
+	struct switch_attr *attr;
+
+	val.port_vlan = vlan;
+
+	if (all) {
+		attr = swlib_lookup_attr(dev, SWLIB_ATTR_GROUP_VLAN, "ports");
+		if (swlib_get_attr(dev, attr, &val) < 0)
+			return;
+
+		if (!val.len)
+			return;
+	}
+
+	printf("VLAN %d:\n", vlan);
+	show_attrs(dev, dev->vlan_ops, &val);
+}
+
+static void
+print_usage(void)
+{
+	printf("swconfig list\n");
+	printf("swconfig dev <dev> [port <port>|vlan <vlan>] (help|set <key> <value>|get <key>|load <config>|show)\n");
+	exit(1);
+}
+
+int main(int argc, char **argv)
+{
+	int retval = 0;
+	struct switch_dev *dev;
+	struct switch_attr *a;
+	struct switch_val val;
+	int err;
+	int i;
+
+	int cmd = CMD_NONE;
+	char *cdev = NULL;
+	int cport = -1;
+	int cvlan = -1;
+	char *ckey = NULL;
+	char *cvalue = NULL;
+	char *csegment = NULL;
+
+	if((argc == 2) && !strcmp(argv[1], "list")) {
+		swlib_list();
+		return 0;
+	}
+
+	if(argc < 4)
+		print_usage();
+
+	if(strcmp(argv[1], "dev"))
+		print_usage();
+
+	cdev = argv[2];
+
+	for(i = 3; i < argc; i++)
+	{
+		char *arg = argv[i];
+		if (cmd != CMD_NONE) {
+			print_usage();
+		} else if (!strcmp(arg, "port") && i+1 < argc) {
+			cport = atoi(argv[++i]);
+		} else if (!strcmp(arg, "vlan") && i+1 < argc) {
+			cvlan = atoi(argv[++i]);
+		} else if (!strcmp(arg, "help")) {
+			cmd = CMD_HELP;
+		} else if (!strcmp(arg, "set") && i+1 < argc) {
+			cmd = CMD_SET;
+			ckey = argv[++i];
+			if (i+1 < argc)
+				cvalue = argv[++i];
+		} else if (!strcmp(arg, "get") && i+1 < argc) {
+			cmd = CMD_GET;
+			ckey = argv[++i];
+		} else if (!strcmp(arg, "load") && i+1 < argc) {
+			if ((cport >= 0) || (cvlan >= 0))
+				print_usage();
+			cmd = CMD_LOAD;
+			ckey = argv[++i];
+		} else if (!strcmp(arg, "portmap")) {
+			if (i + 1 < argc)
+				csegment = argv[++i];
+			cmd = CMD_PORTMAP;
+		} else if (!strcmp(arg, "show")) {
+			cmd = CMD_SHOW;
+		} else {
+			print_usage();
+		}
+	}
+
+	if (cmd == CMD_NONE)
+		print_usage();
+	if (cport > -1 && cvlan > -1)
+		print_usage();
+
+	dev = swlib_connect(cdev);
+	if (!dev) {
+		fprintf(stderr, "Failed to connect to the switch\n");
+		return 1;
+	}
+
+	swlib_scan(dev);
+
+	if (cmd == CMD_GET || cmd == CMD_SET) {
+		if(cport > -1)
+			a = swlib_lookup_attr(dev, SWLIB_ATTR_GROUP_PORT, ckey);
+		else if(cvlan > -1)
+			a = swlib_lookup_attr(dev, SWLIB_ATTR_GROUP_VLAN, ckey);
+		else
+			a = swlib_lookup_attr(dev, SWLIB_ATTR_GROUP_GLOBAL, ckey);
+
+		if(!a)
+		{
+			fprintf(stderr, "Unknown attribute \"%s\"\n", ckey);
+			goto out;
+		}
+	}
+
+	switch(cmd)
+	{
+	case CMD_SET:
+		if ((a->type != SWITCH_TYPE_NOVAL) &&
+				(cvalue == NULL))
+			print_usage();
+
+		if(cvlan > -1)
+			cport = cvlan;
+
+		if(swlib_set_attr_string(dev, a, cport, cvalue) < 0)
+		{
+			fprintf(stderr, "failed\n");
+			retval = -1;
+			goto out;
+		}
+		break;
+	case CMD_GET:
+		if(cvlan > -1)
+			val.port_vlan = cvlan;
+		if(cport > -1)
+			val.port_vlan = cport;
+		if(swlib_get_attr(dev, a, &val) < 0)
+		{
+			fprintf(stderr, "failed\n");
+			retval = -1;
+			goto out;
+		}
+		print_attr_val(a, &val);
+		putchar('\n');
+		break;
+	case CMD_LOAD:
+		fprintf(stderr, "load command not supported\n");
+		break;
+	case CMD_HELP:
+		list_attributes(dev);
+		break;
+	case CMD_PORTMAP:
+		swlib_print_portmap(dev, csegment);
+		break;
+	case CMD_SHOW:
+		if (cport >= 0 || cvlan >= 0) {
+			if (cport >= 0)
+				show_port(dev, cport);
+			else
+				show_vlan(dev, cvlan, false);
+		} else {
+			show_global(dev);
+			for (i=0; i < dev->ports; i++)
+				show_port(dev, i);
+			for (i=0; i < dev->vlans; i++)
+				show_vlan(dev, i, true);
+		}
+		break;
+	}
+
+out:
+	swlib_free_all(dev);
+	return 0;
+}
diff --git a/tools/swconfig/swlib.c b/tools/swconfig/swlib.c
new file mode 100644
index 0000000..9259f77
--- /dev/null
+++ b/tools/swconfig/swlib.c
@@ -0,0 +1,786 @@
+/*
+ * swlib.c: Switch configuration API (user space part)
+ *
+ * Copyright (C) 2008 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public License
+ * version 2.1 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <inttypes.h>
+#include <errno.h>
+#include <stdint.h>
+#include <getopt.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include "../../include/uapi/linux/swconfig.h"
+#include "swlib.h"
+#include <netlink/netlink.h>
+#include <netlink/genl/genl.h>
+#include <netlink/genl/family.h>
+
+//#define DEBUG 1
+#ifdef DEBUG
+#define DPRINTF(fmt, ...) fprintf(stderr, "%s(%d): " fmt, __func__, __LINE__, ##__VA_ARGS__)
+#else
+#define DPRINTF(fmt, ...) do {} while (0)
+#endif
+
+static struct nl_handle *handle;
+static struct nl_cache *cache;
+static struct genl_family *family;
+static struct nlattr *tb[SWITCH_ATTR_MAX + 1];
+static int refcount = 0;
+
+static struct nla_policy port_policy[SWITCH_ATTR_MAX] = {
+	[SWITCH_PORT_ID] = { .type = NLA_U32 },
+	[SWITCH_PORT_FLAG_TAGGED] = { .type = NLA_FLAG },
+};
+
+static struct nla_policy portmap_policy[SWITCH_PORTMAP_MAX] = {
+	[SWITCH_PORTMAP_SEGMENT] = { .type = NLA_STRING },
+	[SWITCH_PORTMAP_VIRT] = { .type = NLA_U32 },
+};
+
+static inline void *
+swlib_alloc(size_t size)
+{
+	void *ptr;
+
+	ptr = malloc(size);
+	if (!ptr)
+		goto done;
+	memset(ptr, 0, size);
+
+done:
+	return ptr;
+}
+
+static int
+wait_handler(struct nl_msg *msg, void *arg)
+{
+	int *finished = arg;
+
+	*finished = 1;
+	return NL_STOP;
+}
+
+/* helper function for performing netlink requests */
+static int
+swlib_call(int cmd, int (*call)(struct nl_msg *, void *),
+		int (*data)(struct nl_msg *, void *), void *arg)
+{
+	struct nl_msg *msg;
+	struct nl_cb *cb = NULL;
+	int finished;
+	int flags = 0;
+	int err;
+
+	msg = nlmsg_alloc();
+	if (!msg) {
+		fprintf(stderr, "Out of memory!\n");
+		exit(1);
+	}
+
+	if (!data)
+		flags |= NLM_F_DUMP;
+
+	genlmsg_put(msg, NL_AUTO_PID, NL_AUTO_SEQ, genl_family_get_id(family), 0, flags, cmd, 0);
+	if (data) {
+		if (data(msg, arg) < 0)
+			goto nla_put_failure;
+	}
+
+	cb = nl_cb_alloc(NL_CB_CUSTOM);
+	if (!cb) {
+		fprintf(stderr, "nl_cb_alloc failed.\n");
+		exit(1);
+	}
+
+	err = nl_send_auto_complete(handle, msg);
+	if (err < 0) {
+		fprintf(stderr, "nl_send_auto_complete failed: %d\n", err);
+		goto out;
+	}
+
+	finished = 0;
+
+	if (call)
+		nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, call, arg);
+
+	if (data)
+		nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, wait_handler, &finished);
+	else
+		nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, wait_handler, &finished);
+
+	err = nl_recvmsgs(handle, cb);
+	if (err < 0) {
+		goto out;
+	}
+
+	if (!finished)
+		err = nl_wait_for_ack(handle);
+
+out:
+	if (cb)
+		nl_cb_put(cb);
+nla_put_failure:
+	nlmsg_free(msg);
+	return err;
+}
+
+static int
+send_attr(struct nl_msg *msg, void *arg)
+{
+	struct switch_val *val = arg;
+	struct switch_attr *attr = val->attr;
+
+	NLA_PUT_U32(msg, SWITCH_ATTR_ID, attr->dev->id);
+	NLA_PUT_U32(msg, SWITCH_ATTR_OP_ID, attr->id);
+	switch(attr->atype) {
+	case SWLIB_ATTR_GROUP_PORT:
+		NLA_PUT_U32(msg, SWITCH_ATTR_OP_PORT, val->port_vlan);
+		break;
+	case SWLIB_ATTR_GROUP_VLAN:
+		NLA_PUT_U32(msg, SWITCH_ATTR_OP_VLAN, val->port_vlan);
+		break;
+	default:
+		break;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int
+store_port_val(struct nl_msg *msg, struct nlattr *nla, struct switch_val *val)
+{
+	struct nlattr *p;
+	int ports = val->attr->dev->ports;
+	int err = 0;
+	int remaining;
+
+	if (!val->value.ports)
+		val->value.ports = malloc(sizeof(struct switch_port) * ports);
+
+	nla_for_each_nested(p, nla, remaining) {
+		struct nlattr *tb[SWITCH_PORT_ATTR_MAX+1];
+		struct switch_port *port;
+
+		if (val->len >= ports)
+			break;
+
+		err = nla_parse_nested(tb, SWITCH_PORT_ATTR_MAX, p, port_policy);
+		if (err < 0)
+			goto out;
+
+		if (!tb[SWITCH_PORT_ID])
+			continue;
+
+		port = &val->value.ports[val->len];
+		port->id = nla_get_u32(tb[SWITCH_PORT_ID]);
+		port->flags = 0;
+		if (tb[SWITCH_PORT_FLAG_TAGGED])
+			port->flags |= SWLIB_PORT_FLAG_TAGGED;
+
+		val->len++;
+	}
+
+out:
+	return err;
+}
+
+static int
+store_val(struct nl_msg *msg, void *arg)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct switch_val *val = arg;
+	struct switch_attr *attr = val->attr;
+
+	if (!val)
+		goto error;
+
+	if (nla_parse(tb, SWITCH_ATTR_MAX - 1, genlmsg_attrdata(gnlh, 0),
+			genlmsg_attrlen(gnlh, 0), NULL) < 0) {
+		goto error;
+	}
+
+	if (tb[SWITCH_ATTR_OP_VALUE_INT])
+		val->value.i = nla_get_u32(tb[SWITCH_ATTR_OP_VALUE_INT]);
+	else if (tb[SWITCH_ATTR_OP_VALUE_STR])
+		val->value.s = strdup(nla_get_string(tb[SWITCH_ATTR_OP_VALUE_STR]));
+	else if (tb[SWITCH_ATTR_OP_VALUE_PORTS])
+		val->err = store_port_val(msg, tb[SWITCH_ATTR_OP_VALUE_PORTS], val);
+
+	val->err = 0;
+	return 0;
+
+error:
+	return NL_SKIP;
+}
+
+int
+swlib_get_attr(struct switch_dev *dev, struct switch_attr *attr, struct switch_val *val)
+{
+	int cmd;
+	int err;
+
+	switch(attr->atype) {
+	case SWLIB_ATTR_GROUP_GLOBAL:
+		cmd = SWITCH_CMD_GET_GLOBAL;
+		break;
+	case SWLIB_ATTR_GROUP_PORT:
+		cmd = SWITCH_CMD_GET_PORT;
+		break;
+	case SWLIB_ATTR_GROUP_VLAN:
+		cmd = SWITCH_CMD_GET_VLAN;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	memset(&val->value, 0, sizeof(val->value));
+	val->len = 0;
+	val->attr = attr;
+	val->err = -EINVAL;
+	err = swlib_call(cmd, store_val, send_attr, val);
+	if (!err)
+		err = val->err;
+
+	return err;
+}
+
+static int
+send_attr_ports(struct nl_msg *msg, struct switch_val *val)
+{
+	struct nlattr *n;
+	int i;
+
+	/* TODO implement multipart? */
+	if (val->len == 0)
+		goto done;
+	n = nla_nest_start(msg, SWITCH_ATTR_OP_VALUE_PORTS);
+	if (!n)
+		goto nla_put_failure;
+	for (i = 0; i < val->len; i++) {
+		struct switch_port *port = &val->value.ports[i];
+		struct nlattr *np;
+
+		np = nla_nest_start(msg, SWITCH_ATTR_PORT);
+		if (!np)
+			goto nla_put_failure;
+
+		NLA_PUT_U32(msg, SWITCH_PORT_ID, port->id);
+		if (port->flags & SWLIB_PORT_FLAG_TAGGED)
+			NLA_PUT_FLAG(msg, SWITCH_PORT_FLAG_TAGGED);
+
+		nla_nest_end(msg, np);
+	}
+	nla_nest_end(msg, n);
+done:
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int
+send_attr_val(struct nl_msg *msg, void *arg)
+{
+	struct switch_val *val = arg;
+	struct switch_attr *attr = val->attr;
+
+	if (send_attr(msg, arg))
+		goto nla_put_failure;
+
+	switch(attr->type) {
+	case SWITCH_TYPE_NOVAL:
+		break;
+	case SWITCH_TYPE_INT:
+		NLA_PUT_U32(msg, SWITCH_ATTR_OP_VALUE_INT, val->value.i);
+		break;
+	case SWITCH_TYPE_STRING:
+		if (!val->value.s)
+			goto nla_put_failure;
+		NLA_PUT_STRING(msg, SWITCH_ATTR_OP_VALUE_STR, val->value.s);
+		break;
+	case SWITCH_TYPE_PORTS:
+		if (send_attr_ports(msg, val) < 0)
+			goto nla_put_failure;
+		break;
+	default:
+		goto nla_put_failure;
+	}
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+int
+swlib_set_attr(struct switch_dev *dev, struct switch_attr *attr, struct switch_val *val)
+{
+	int cmd;
+
+	switch(attr->atype) {
+	case SWLIB_ATTR_GROUP_GLOBAL:
+		cmd = SWITCH_CMD_SET_GLOBAL;
+		break;
+	case SWLIB_ATTR_GROUP_PORT:
+		cmd = SWITCH_CMD_SET_PORT;
+		break;
+	case SWLIB_ATTR_GROUP_VLAN:
+		cmd = SWITCH_CMD_SET_VLAN;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	val->attr = attr;
+	return swlib_call(cmd, NULL, send_attr_val, val);
+}
+
+int swlib_set_attr_string(struct switch_dev *dev, struct switch_attr *a, int port_vlan, const char *str)
+{
+	struct switch_port *ports;
+	struct switch_val val;
+	char *ptr;
+
+	memset(&val, 0, sizeof(val));
+	val.port_vlan = port_vlan;
+	switch(a->type) {
+	case SWITCH_TYPE_INT:
+		val.value.i = atoi(str);
+		break;
+	case SWITCH_TYPE_STRING:
+		val.value.s = str;
+		break;
+	case SWITCH_TYPE_PORTS:
+		ports = alloca(sizeof(struct switch_port) * dev->ports);
+		memset(ports, 0, sizeof(struct switch_port) * dev->ports);
+		val.len = 0;
+		ptr = (char *)str;
+		while(ptr && *ptr)
+		{
+			while(*ptr && isspace(*ptr))
+				ptr++;
+
+			if (!*ptr)
+				break;
+
+			if (!isdigit(*ptr))
+				return -1;
+
+			if (val.len >= dev->ports)
+				return -1;
+
+			ports[val.len].flags = 0;
+			ports[val.len].id = strtoul(ptr, &ptr, 10);
+			while(*ptr && !isspace(*ptr)) {
+				if (*ptr == 't')
+					ports[val.len].flags |= SWLIB_PORT_FLAG_TAGGED;
+				else
+					return -1;
+
+				ptr++;
+			}
+			if (*ptr)
+				ptr++;
+			val.len++;
+		}
+		val.value.ports = ports;
+		break;
+	case SWITCH_TYPE_NOVAL:
+		if (str && !strcmp(str, "0"))
+			return 0;
+
+		break;
+	default:
+		return -1;
+	}
+	return swlib_set_attr(dev, a, &val);
+}
+
+
+struct attrlist_arg {
+	int id;
+	int atype;
+	struct switch_dev *dev;
+	struct switch_attr *prev;
+	struct switch_attr **head;
+};
+
+static int
+add_id(struct nl_msg *msg, void *arg)
+{
+	struct attrlist_arg *l = arg;
+
+	NLA_PUT_U32(msg, SWITCH_ATTR_ID, l->id);
+
+	return 0;
+nla_put_failure:
+	return -1;
+}
+
+static int
+add_attr(struct nl_msg *msg, void *ptr)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct attrlist_arg *arg = ptr;
+	struct switch_attr *new;
+
+	if (nla_parse(tb, SWITCH_ATTR_MAX - 1, genlmsg_attrdata(gnlh, 0),
+			genlmsg_attrlen(gnlh, 0), NULL) < 0)
+		goto done;
+
+	new = swlib_alloc(sizeof(struct switch_attr));
+	if (!new)
+		goto done;
+
+	new->dev = arg->dev;
+	new->atype = arg->atype;
+	if (arg->prev) {
+		arg->prev->next = new;
+	} else {
+		arg->prev = *arg->head;
+	}
+	*arg->head = new;
+	arg->head = &new->next;
+
+	if (tb[SWITCH_ATTR_OP_ID])
+		new->id = nla_get_u32(tb[SWITCH_ATTR_OP_ID]);
+	if (tb[SWITCH_ATTR_OP_TYPE])
+		new->type = nla_get_u32(tb[SWITCH_ATTR_OP_TYPE]);
+	if (tb[SWITCH_ATTR_OP_NAME])
+		new->name = strdup(nla_get_string(tb[SWITCH_ATTR_OP_NAME]));
+	if (tb[SWITCH_ATTR_OP_DESCRIPTION])
+		new->description = strdup(nla_get_string(tb[SWITCH_ATTR_OP_DESCRIPTION]));
+
+done:
+	return NL_SKIP;
+}
+
+int
+swlib_scan(struct switch_dev *dev)
+{
+	struct attrlist_arg arg;
+
+	if (dev->ops || dev->port_ops || dev->vlan_ops)
+		return 0;
+
+	arg.atype = SWLIB_ATTR_GROUP_GLOBAL;
+	arg.dev = dev;
+	arg.id = dev->id;
+	arg.prev = NULL;
+	arg.head = &dev->ops;
+	swlib_call(SWITCH_CMD_LIST_GLOBAL, add_attr, add_id, &arg);
+
+	arg.atype = SWLIB_ATTR_GROUP_PORT;
+	arg.prev = NULL;
+	arg.head = &dev->port_ops;
+	swlib_call(SWITCH_CMD_LIST_PORT, add_attr, add_id, &arg);
+
+	arg.atype = SWLIB_ATTR_GROUP_VLAN;
+	arg.prev = NULL;
+	arg.head = &dev->vlan_ops;
+	swlib_call(SWITCH_CMD_LIST_VLAN, add_attr, add_id, &arg);
+
+	return 0;
+}
+
+struct switch_attr *swlib_lookup_attr(struct switch_dev *dev,
+		enum swlib_attr_group atype, const char *name)
+{
+	struct switch_attr *head;
+
+	if (!name || !dev)
+		return NULL;
+
+	switch(atype) {
+	case SWLIB_ATTR_GROUP_GLOBAL:
+		head = dev->ops;
+		break;
+	case SWLIB_ATTR_GROUP_PORT:
+		head = dev->port_ops;
+		break;
+	case SWLIB_ATTR_GROUP_VLAN:
+		head = dev->vlan_ops;
+		break;
+	}
+	while(head) {
+		if (!strcmp(name, head->name))
+			return head;
+		head = head->next;
+	}
+
+	return NULL;
+}
+
+static void
+swlib_priv_free(void)
+{
+	if (cache)
+		nl_cache_free(cache);
+	if (handle)
+		nl_handle_destroy(handle);
+	handle = NULL;
+	cache = NULL;
+}
+
+static int
+swlib_priv_init(void)
+{
+	int ret;
+
+	handle = nl_handle_alloc();
+	if (!handle) {
+		DPRINTF("Failed to create handle\n");
+		goto err;
+	}
+
+	if (genl_connect(handle)) {
+		DPRINTF("Failed to connect to generic netlink\n");
+		goto err;
+	}
+
+	cache = genl_ctrl_alloc_cache(handle);
+	if (!cache) {
+		DPRINTF("Failed to allocate netlink cache\n");
+		goto err;
+	}
+
+	family = genl_ctrl_search_by_name(cache, "switch");
+	if (!family) {
+		DPRINTF("Switch API not present\n");
+		goto err;
+	}
+	return 0;
+
+err:
+	swlib_priv_free();
+	return -EINVAL;
+}
+
+struct swlib_scan_arg {
+	const char *name;
+	struct switch_dev *head;
+	struct switch_dev *ptr;
+};
+
+static int
+add_port_map(struct switch_dev *dev, struct nlattr *nla)
+{
+	struct nlattr *p;
+	int err = 0, idx = 0;
+	int remaining;
+
+	dev->maps = malloc(sizeof(struct switch_portmap) * dev->ports);
+	if (!dev->maps)
+		return -1;
+	memset(dev->maps, 0, sizeof(struct switch_portmap) * dev->ports);
+
+	nla_for_each_nested(p, nla, remaining) {
+		struct nlattr *tb[SWITCH_PORTMAP_MAX+1];
+
+		if (idx >= dev->ports)
+			continue;
+
+		err = nla_parse_nested(tb, SWITCH_PORTMAP_MAX, p, portmap_policy);
+		if (err < 0)
+			continue;
+
+
+		if (tb[SWITCH_PORTMAP_SEGMENT] && tb[SWITCH_PORTMAP_VIRT]) {
+			dev->maps[idx].segment = strdup(nla_get_string(tb[SWITCH_PORTMAP_SEGMENT]));
+			dev->maps[idx].virt = nla_get_u32(tb[SWITCH_PORTMAP_VIRT]);
+		}
+		idx++;
+	}
+
+out:
+	return err;
+}
+
+
+static int
+add_switch(struct nl_msg *msg, void *arg)
+{
+	struct swlib_scan_arg *sa = arg;
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct switch_dev *dev;
+	const char *name;
+	const char *alias;
+
+	if (nla_parse(tb, SWITCH_ATTR_MAX, genlmsg_attrdata(gnlh, 0), genlmsg_attrlen(gnlh, 0), NULL) < 0)
+		goto done;
+
+	if (!tb[SWITCH_ATTR_DEV_NAME])
+		goto done;
+
+	name = nla_get_string(tb[SWITCH_ATTR_DEV_NAME]);
+	alias = nla_get_string(tb[SWITCH_ATTR_ALIAS]);
+
+	if (sa->name && (strcmp(name, sa->name) != 0) && (strcmp(alias, sa->name) != 0))
+		goto done;
+
+	dev = swlib_alloc(sizeof(struct switch_dev));
+	if (!dev)
+		goto done;
+
+	strncpy(dev->dev_name, name, IFNAMSIZ - 1);
+	dev->alias = strdup(alias);
+	if (tb[SWITCH_ATTR_ID])
+		dev->id = nla_get_u32(tb[SWITCH_ATTR_ID]);
+	if (tb[SWITCH_ATTR_NAME])
+		dev->name = strdup(nla_get_string(tb[SWITCH_ATTR_NAME]));
+	if (tb[SWITCH_ATTR_PORTS])
+		dev->ports = nla_get_u32(tb[SWITCH_ATTR_PORTS]);
+	if (tb[SWITCH_ATTR_VLANS])
+		dev->vlans = nla_get_u32(tb[SWITCH_ATTR_VLANS]);
+	if (tb[SWITCH_ATTR_CPU_PORT])
+		dev->cpu_port = nla_get_u32(tb[SWITCH_ATTR_CPU_PORT]);
+	if (tb[SWITCH_ATTR_PORTMAP])
+		add_port_map(dev, tb[SWITCH_ATTR_PORTMAP]);
+
+	if (!sa->head) {
+		sa->head = dev;
+		sa->ptr = dev;
+	} else {
+		sa->ptr->next = dev;
+		sa->ptr = dev;
+	}
+
+	refcount++;
+done:
+	return NL_SKIP;
+}
+
+static int
+list_switch(struct nl_msg *msg, void *arg)
+{
+	struct swlib_scan_arg *sa = arg;
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct switch_dev *dev;
+	const char *name;
+	const char *alias;
+
+	if (nla_parse(tb, SWITCH_ATTR_MAX, genlmsg_attrdata(gnlh, 0), genlmsg_attrlen(gnlh, 0), NULL) < 0)
+		goto done;
+
+	if (!tb[SWITCH_ATTR_DEV_NAME] || !tb[SWITCH_ATTR_NAME])
+		goto done;
+
+	printf("Found: %s - %s\n", nla_get_string(tb[SWITCH_ATTR_DEV_NAME]),
+		nla_get_string(tb[SWITCH_ATTR_ALIAS]));
+
+done:
+	return NL_SKIP;
+}
+
+void
+swlib_list(void)
+{
+	if (swlib_priv_init() < 0)
+		return;
+	swlib_call(SWITCH_CMD_GET_SWITCH, list_switch, NULL, NULL);
+	swlib_priv_free();
+}
+
+void
+swlib_print_portmap(struct switch_dev *dev, char *segment)
+{
+	int i;
+
+	if (segment) {
+		if (!strcmp(segment, "cpu")) {
+			printf("%d ", dev->cpu_port);
+		} else if (!strcmp(segment, "disabled")) {
+			for (i = 0; i < dev->ports; i++)
+				if (!dev->maps[i].segment)
+					printf("%d ", i);
+		} else for (i = 0; i < dev->ports; i++) {
+			if (dev->maps[i].segment && !strcmp(dev->maps[i].segment, segment))
+				printf("%d ", i);
+		}
+	} else {
+		printf("%s - %s\n", dev->dev_name, dev->name);
+		for (i = 0; i < dev->ports; i++)
+			if (i == dev->cpu_port)
+				printf("port%d:\tcpu\n", i);
+			else if (dev->maps[i].segment)
+				printf("port%d:\t%s.%d\n", i, dev->maps[i].segment, dev->maps[i].virt);
+			else
+				printf("port%d:\tdisabled\n", i);
+	}
+}
+
+struct switch_dev *
+swlib_connect(const char *name)
+{
+	struct swlib_scan_arg arg;
+	int err;
+
+	if (!refcount) {
+		if (swlib_priv_init() < 0)
+			return NULL;
+	};
+
+	arg.head = NULL;
+	arg.ptr = NULL;
+	arg.name = name;
+	swlib_call(SWITCH_CMD_GET_SWITCH, add_switch, NULL, &arg);
+
+	if (!refcount)
+		swlib_priv_free();
+
+	return arg.head;
+}
+
+static void
+swlib_free_attributes(struct switch_attr **head)
+{
+	struct switch_attr *a = *head;
+	struct switch_attr *next;
+
+	while (a) {
+		next = a->next;
+		free(a);
+		a = next;
+	}
+	*head = NULL;
+}
+
+void
+swlib_free(struct switch_dev *dev)
+{
+	swlib_free_attributes(&dev->ops);
+	swlib_free_attributes(&dev->port_ops);
+	swlib_free_attributes(&dev->vlan_ops);
+	free(dev);
+
+	if (--refcount == 0)
+		swlib_priv_free();
+}
+
+void
+swlib_free_all(struct switch_dev *dev)
+{
+	struct switch_dev *p;
+
+	while (dev) {
+		p = dev->next;
+		swlib_free(dev);
+		dev = p;
+	}
+}
diff --git a/tools/swconfig/swlib.h b/tools/swconfig/swlib.h
new file mode 100644
index 0000000..dba68b2
--- /dev/null
+++ b/tools/swconfig/swlib.h
@@ -0,0 +1,244 @@
+/*
+ * swlib.h: Switch configuration API (user space part)
+ *
+ * Copyright (C) 2008-2009 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public License
+ * version 2.1 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+
+Usage of the library functions:
+
+  The main datastructure for a switch is the struct switch_device
+  To get started, you first need to use switch_connect() to probe
+  for switches and allocate an instance of this struct.
+
+  There are two possible usage modes:
+    dev = switch_connect("eth0");
+      - this call will look for a switch registered for the linux device
+  	  "eth0" and only allocate a switch_device for this particular switch.
+
+    dev = switch_connect(NULL)
+      - this will return one switch_device struct for each available
+  	  switch. The switch_device structs are chained with by ->next pointer
+
+  Then to query a switch for all available attributes, use:
+    swlib_scan(dev);
+
+  All allocated datastructures for the switch_device struct can be freed with
+    swlib_free(dev);
+  or
+    swlib_free_all(dev);
+
+  The latter traverses a whole chain of switch_device structs and frees them all
+
+  Switch attributes (struct switch_attr) are divided into three groups:
+    dev->ops:
+      - global settings
+    dev->port_ops:
+      - per-port settings
+    dev->vlan_ops:
+      - per-vlan settings
+
+  switch_lookup_attr() is a small helper function to locate attributes
+  by name.
+
+  switch_set_attr() and switch_get_attr() can alter or request the values
+  of attributes.
+
+Usage of the switch_attr struct:
+
+  ->atype: attribute group, one of:
+    - SWLIB_ATTR_GROUP_GLOBAL
+    - SWLIB_ATTR_GROUP_VLAN
+    - SWLIB_ATTR_GROUP_PORT
+
+  ->id: identifier for the attribute
+
+  ->type: data type, one of:
+    - SWITCH_TYPE_INT
+    - SWITCH_TYPE_STRING
+    - SWITCH_TYPE_PORT
+
+  ->name: short name of the attribute
+  ->description: longer description
+  ->next: pointer to the next attribute of the current group
+
+
+Usage of the switch_val struct:
+
+  When setting attributes, following members of the struct switch_val need
+  to be set up:
+
+    ->len (for attr->type == SWITCH_TYPE_PORT)
+    ->port_vlan:
+      - port number (for attr->atype == SWLIB_ATTR_GROUP_PORT), or:
+      - vlan number (for attr->atype == SWLIB_ATTR_GROUP_VLAN)
+    ->value.i (for attr->type == SWITCH_TYPE_INT)
+    ->value.s (for attr->type == SWITCH_TYPE_STRING)
+      - owned by the caller, not stored in the library internally
+    ->value.ports (for attr->type == SWITCH_TYPE_PORT)
+      - must point to an array of at lest val->len * sizeof(struct switch_port)
+
+  When getting string attributes, val->value.s must be freed by the caller
+  When getting port list attributes, an internal static buffer is used,
+  which changes from call to call.
+
+ */
+
+#ifndef __SWLIB_H
+#define __SWLIB_H
+
+enum swlib_attr_group {
+	SWLIB_ATTR_GROUP_GLOBAL,
+	SWLIB_ATTR_GROUP_VLAN,
+	SWLIB_ATTR_GROUP_PORT,
+};
+
+enum swlib_port_flags {
+	SWLIB_PORT_FLAG_TAGGED = (1 << 0),
+};
+
+
+struct switch_dev;
+struct switch_attr;
+struct switch_port;
+struct switch_port_map;
+struct switch_val;
+
+struct switch_dev {
+	int id;
+	char dev_name[IFNAMSIZ];
+	const char *name;
+	const char *alias;
+	int ports;
+	int vlans;
+	int cpu_port;
+	struct switch_attr *ops;
+	struct switch_attr *port_ops;
+	struct switch_attr *vlan_ops;
+	struct switch_portmap *maps;
+	struct switch_dev *next;
+	void *priv;
+};
+
+struct switch_val {
+	struct switch_attr *attr;
+	int len;
+	int err;
+	int port_vlan;
+	union {
+		const char *s;
+		int i;
+		struct switch_port *ports;
+	} value;
+};
+
+struct switch_attr {
+	struct switch_dev *dev;
+	int atype;
+	int id;
+	int type;
+	const char *name;
+	const char *description;
+	struct switch_attr *next;
+};
+
+struct switch_port {
+	unsigned int id;
+	unsigned int flags;
+};
+
+struct switch_portmap {
+	unsigned int virt;
+	const char *segment;
+};
+
+/**
+ * swlib_list: list all switches
+ */
+void swlib_list(void);
+
+/**
+ * swlib_print_portmap: get portmap
+ * @dev: switch device struct
+ */
+void swlib_print_portmap(struct switch_dev *dev, char *segment);
+
+/**
+ * swlib_connect: connect to the switch through netlink
+ * @name: name of the ethernet interface,
+ *
+ * if name is NULL, it connect and builds a chain of all switches
+ */
+struct switch_dev *swlib_connect(const char *name);
+
+/**
+ * swlib_free: free all dynamically allocated data for the switch connection
+ * @dev: switch device struct
+ *
+ * all members of a switch device chain (generated by swlib_connect(NULL))
+ * must be freed individually
+ */
+void swlib_free(struct switch_dev *dev);
+
+/**
+ * swlib_free_all: run swlib_free on all devices in the chain
+ * @dev: switch device struct
+ */
+void swlib_free_all(struct switch_dev *dev);
+
+/**
+ * swlib_scan: probe the switch driver for available commands/attributes
+ * @dev: switch device struct
+ */
+int swlib_scan(struct switch_dev *dev);
+
+/**
+ * swlib_lookup_attr: look up a switch attribute
+ * @dev: switch device struct
+ * @type: global, port or vlan
+ * @name: name of the attribute
+ */
+struct switch_attr *swlib_lookup_attr(struct switch_dev *dev,
+		enum swlib_attr_group atype, const char *name);
+
+/**
+ * swlib_set_attr: set the value for an attribute
+ * @dev: switch device struct
+ * @attr: switch attribute struct
+ * @val: attribute value pointer
+ * returns 0 on success
+ */
+int swlib_set_attr(struct switch_dev *dev, struct switch_attr *attr,
+		struct switch_val *val);
+
+/**
+ * swlib_set_attr_string: set the value for an attribute with type conversion
+ * @dev: switch device struct
+ * @attr: switch attribute struct
+ * @port_vlan: port or vlan (if applicable)
+ * @str: string value
+ * returns 0 on success
+ */
+int swlib_set_attr_string(struct switch_dev *dev, struct switch_attr *attr,
+		int port_vlan, const char *str);
+
+/**
+ * swlib_get_attr: get the value for an attribute
+ * @dev: switch device struct
+ * @attr: switch attribute struct
+ * @val: attribute value pointer
+ * returns 0 on success
+ * for string attributes, the result string must be freed by the caller
+ */
+int swlib_get_attr(struct switch_dev *dev, struct switch_attr *attr,
+		struct switch_val *val);
+
+#endif
-- 
1.8.3.2
