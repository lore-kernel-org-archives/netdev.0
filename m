From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 2/2] add devlink tool
Date: Tue, 22 Mar 2016 10:02:21 +0100
Message-ID: <1458637341-3434-2-git-send-email-jiri@resnulli.us>
References: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, yishaih@mellanox.com, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	eugenia@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	brouer@redhat.com, ivecera@redhat.com, rami.rosen@intel.com,
	hannes@stressinduktion.org, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34118 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393AbcCVJC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 05:02:26 -0400
Received: by mail-wm0-f68.google.com with SMTP id p65so28288793wmp.1
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 02:02:25 -0700 (PDT)
In-Reply-To: <1458637341-3434-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add new tool called devlink which is userspace counterpart of devlink
Netlink socket.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
v1->v2:
    - fix some checkpatch issues
---
 Makefile                   |   2 +-
 devlink/Makefile           |  20 +
 devlink/devlink.c          | 987 +++++++++++++++++++++++++++++++++++++++++++++
 devlink/mnlg.c             | 274 +++++++++++++
 devlink/mnlg.h             |  27 ++
 include/linux/devlink.h    |  72 ++++
 man/man8/devlink-dev.8     |  58 +++
 man/man8/devlink-monitor.8 |  36 ++
 man/man8/devlink-port.8    | 126 ++++++
 man/man8/devlink.8         |  83 ++++
 10 files changed, 1684 insertions(+), 1 deletion(-)
 create mode 100644 devlink/Makefile
 create mode 100644 devlink/devlink.c
 create mode 100644 devlink/mnlg.c
 create mode 100644 devlink/mnlg.h
 create mode 100644 include/linux/devlink.h
 create mode 100644 man/man8/devlink-dev.8
 create mode 100644 man/man8/devlink-monitor.8
 create mode 100644 man/man8/devlink-port.8
 create mode 100644 man/man8/devlink.8

diff --git a/Makefile b/Makefile
index 67176be..0190aa0 100644
--- a/Makefile
+++ b/Makefile
@@ -41,7 +41,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc bridge misc netem genl tipc man
+SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
diff --git a/devlink/Makefile b/devlink/Makefile
new file mode 100644
index 0000000..3fdaa69
--- /dev/null
+++ b/devlink/Makefile
@@ -0,0 +1,20 @@
+include ../Config
+ifeq ($(HAVE_MNL),y)
+
+DEVLINKOBJ = devlink.o mnlg.o
+TARGETS=devlink
+
+CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
+LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
+
+endif
+
+all: $(TARGETS) $(LIBS)
+
+devlink: $(DEVLINKOBJ)
+
+install: all
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(DEVLINKOBJ) $(TARGETS)
diff --git a/devlink/devlink.c b/devlink/devlink.c
new file mode 100644
index 0000000..6bda925
--- /dev/null
+++ b/devlink/devlink.c
@@ -0,0 +1,987 @@
+/*
+ * devlink.c	Devlink tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri@mellanox.com>
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <stdbool.h>
+#include <unistd.h>
+#include <getopt.h>
+#include <limits.h>
+#include <errno.h>
+#include <linux/genetlink.h>
+#include <linux/devlink.h>
+#include <libmnl/libmnl.h>
+
+#include "SNAPSHOT.h"
+#include "list.h"
+#include "mnlg.h"
+
+#define pr_err(args...) fprintf(stderr, ##args)
+#define pr_out(args...) fprintf(stdout, ##args)
+
+static int _mnlg_socket_recv_run(struct mnlg_socket *nlg,
+				 mnl_cb_t data_cb, void *data)
+{
+	int err;
+
+	err = mnlg_socket_recv_run(nlg, data_cb, data);
+	if (err < 0) {
+		pr_err("devlink answers: %s\n", strerror(errno));
+		return -errno;
+	}
+	return 0;
+}
+
+static int _mnlg_socket_sndrcv(struct mnlg_socket *nlg,
+			       const struct nlmsghdr *nlh,
+			       mnl_cb_t data_cb, void *data)
+{
+	int err;
+
+	err = mnlg_socket_send(nlg, nlh);
+	if (err < 0) {
+		pr_err("Failed to call mnlg_socket_send\n");
+		return -errno;
+	}
+	return _mnlg_socket_recv_run(nlg, data_cb, data);
+}
+
+static int _mnlg_socket_group_add(struct mnlg_socket *nlg,
+				  const char *group_name)
+{
+	int err;
+
+	err = mnlg_socket_group_add(nlg, group_name);
+	if (err < 0) {
+		pr_err("Failed to call mnlg_socket_group_add\n");
+		return -errno;
+	}
+	return 0;
+}
+
+struct ifname_map {
+	struct list_head list;
+	char *bus_name;
+	char *dev_name;
+	uint32_t port_index;
+	char *ifname;
+};
+
+static struct ifname_map *ifname_map_alloc(const char *bus_name,
+					   const char *dev_name,
+					   uint32_t port_index,
+					   const char *ifname)
+{
+	struct ifname_map *ifname_map;
+
+	ifname_map = calloc(1, sizeof(*ifname_map));
+	if (!ifname_map)
+		return NULL;
+	ifname_map->bus_name = strdup(bus_name);
+	ifname_map->dev_name = strdup(dev_name);
+	ifname_map->port_index = port_index;
+	ifname_map->ifname = strdup(ifname);
+	if (!ifname_map->bus_name || !ifname_map->dev_name ||
+	    !ifname_map->ifname) {
+		free(ifname_map->ifname);
+		free(ifname_map->dev_name);
+		free(ifname_map->bus_name);
+		free(ifname_map);
+		return NULL;
+	}
+	return ifname_map;
+}
+
+static void ifname_map_free(struct ifname_map *ifname_map)
+{
+	free(ifname_map->ifname);
+	free(ifname_map->dev_name);
+	free(ifname_map->bus_name);
+	free(ifname_map);
+}
+
+struct dl {
+	struct mnlg_socket *nlg;
+	struct list_head ifname_map_list;
+	int argc;
+	char **argv;
+};
+
+static int dl_argc(struct dl *dl)
+{
+	return dl->argc;
+}
+
+static char *dl_argv(struct dl *dl)
+{
+	if (dl_argc(dl) == 0)
+		return NULL;
+	return *dl->argv;
+}
+
+static void dl_arg_inc(struct dl *dl)
+{
+	if (dl_argc(dl) == 0)
+		return;
+	dl->argc--;
+	dl->argv++;
+}
+
+static char *dl_argv_next(struct dl *dl)
+{
+	char *ret;
+
+	if (dl_argc(dl) == 0)
+		return NULL;
+
+	ret = *dl->argv;
+	dl_arg_inc(dl);
+	return ret;
+}
+
+static char *dl_argv_index(struct dl *dl, unsigned int index)
+{
+	if (index >= dl_argc(dl))
+		return NULL;
+	return dl->argv[index];
+}
+
+static int strcmpx(const char *str1, const char *str2)
+{
+	if (strlen(str1) > strlen(str2))
+		return -1;
+	return strncmp(str1, str2, strlen(str1));
+}
+
+static bool dl_argv_match(struct dl *dl, const char *pattern)
+{
+	if (dl_argc(dl) == 0)
+		return false;
+	return strcmpx(dl_argv(dl), pattern) == 0;
+}
+
+static bool dl_no_arg(struct dl *dl)
+{
+	return dl_argc(dl) == 0;
+}
+
+static int attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type;
+
+	type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, DEVLINK_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+
+	if (type == DEVLINK_ATTR_BUS_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DEV_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_DESIRED_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_NETDEV_IFINDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_NETDEV_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_PORT_IBDEV_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
+		return MNL_CB_ERROR;
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+static int ifname_map_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	struct dl *dl = data;
+	struct ifname_map *ifname_map;
+	const char *bus_name;
+	const char *dev_name;
+	uint32_t port_ifindex;
+	const char *port_ifname;
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX])
+		return MNL_CB_ERROR;
+
+	if (!tb[DEVLINK_ATTR_PORT_NETDEV_NAME])
+		return MNL_CB_OK;
+
+	bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
+	dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
+	port_ifindex = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+	port_ifname = mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_NETDEV_NAME]);
+	ifname_map = ifname_map_alloc(bus_name, dev_name,
+				      port_ifindex, port_ifname);
+	if (!ifname_map)
+		return MNL_CB_ERROR;
+	list_add(&ifname_map->list, &dl->ifname_map_list);
+
+	return MNL_CB_OK;
+}
+
+static void ifname_map_fini(struct dl *dl)
+{
+	struct ifname_map *ifname_map, *tmp;
+
+	list_for_each_entry_safe(ifname_map, tmp,
+				 &dl->ifname_map_list, list) {
+		list_del(&ifname_map->list);
+		ifname_map_free(ifname_map);
+	}
+}
+
+static int ifname_map_init(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	INIT_LIST_HEAD(&dl->ifname_map_list);
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_PORT_GET,
+			       NLM_F_REQUEST | NLM_F_ACK | NLM_F_DUMP);
+
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, ifname_map_cb, dl);
+	if (err) {
+		ifname_map_fini(dl);
+		return err;
+	}
+	return 0;
+}
+
+static int ifname_map_lookup(struct dl *dl, const char *ifname,
+			     char **p_bus_name, char **p_dev_name,
+			     uint32_t *p_port_index)
+{
+	struct ifname_map *ifname_map;
+
+	list_for_each_entry(ifname_map, &dl->ifname_map_list, list) {
+		if (strcmp(ifname, ifname_map->ifname) == 0) {
+			*p_bus_name = ifname_map->bus_name;
+			*p_dev_name = ifname_map->dev_name;
+			*p_port_index = ifname_map->port_index;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
+static unsigned int strslashcount(char *str)
+{
+	unsigned int count = 0;
+	char *pos = str;
+
+	while ((pos = strchr(pos, '/'))) {
+		count++;
+		pos++;
+	}
+	return count;
+}
+
+static int strslashrsplit(char *str, char **before, char **after)
+{
+	char *slash;
+
+	slash = strrchr(str, '/');
+	if (!slash)
+		return -EINVAL;
+	*slash = '\0';
+	*before = str;
+	*after = slash + 1;
+	return 0;
+}
+
+static int strtouint32_t(const char *str, uint32_t *p_val)
+{
+	char *endptr;
+	unsigned long int val;
+
+	val = strtoul(str, &endptr, 10);
+	if (endptr == str || *endptr != '\0')
+		return -EINVAL;
+	if (val > UINT_MAX)
+		return -ERANGE;
+	*p_val = val;
+	return 0;
+}
+
+static int dl_argv_put_handle(struct nlmsghdr *nlh, struct dl *dl)
+{
+	char *str = dl_argv_next(dl);
+	char *bus_name = bus_name;
+	char *dev_name = dev_name;
+
+	if (!str) {
+		pr_err("Devlink identification (\"bus_name/dev_name\") expected\n");
+		return -EINVAL;
+	}
+	if (strslashcount(str) != 1) {
+		pr_err("Wrong devlink identification string format.\n");
+		pr_err("Expected \"bus_name/dev_name\".\n");
+		return -EINVAL;
+	}
+
+	strslashrsplit(str, &bus_name, &dev_name);
+	mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, bus_name);
+	mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, dev_name);
+	return 0;
+}
+
+static int dl_argv_put_handle_port(struct nlmsghdr *nlh, struct dl *dl)
+{
+	char *str = dl_argv_next(dl);
+	unsigned int slash_count;
+	char *bus_name = bus_name;
+	char *dev_name = dev_name;
+	uint32_t port_index = port_index;
+	int err;
+
+	if (!str) {
+		pr_err("Port identification (\"bus_name/dev_name/port_index\" or \"netdev ifname\") expected.\n");
+		return -EINVAL;
+	}
+	slash_count = strslashcount(str);
+	if (slash_count != 2 && slash_count != 0) {
+		pr_err("Wrong port identification string format.\n");
+		pr_err("Expected \"bus_name/dev_name/port_index\" or \"netdev_ifname\".\n");
+		return -EINVAL;
+	}
+
+	if (slash_count == 2) {
+		char *handlestr = handlestr;
+		char *portstr = portstr;
+
+		err = strslashrsplit(str, &handlestr, &portstr);
+		err = strtouint32_t(portstr, &port_index);
+		if (err) {
+			pr_err("Port index \"%s\" is not a number or not within range\n",
+			       portstr);
+			return err;
+		}
+		strslashrsplit(handlestr, &bus_name, &dev_name);
+	} else if (slash_count == 0) {
+		err = ifname_map_lookup(dl, str, &bus_name, &dev_name,
+					&port_index);
+		if (err) {
+			pr_err("Netdevice \"%s\" not found\n", str);
+			return err;
+		}
+	}
+	mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, bus_name);
+	mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, dev_name);
+	mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_INDEX, port_index);
+	return 0;
+}
+
+static int dl_argv_uint32_t(struct dl *dl, uint32_t *p_val)
+{
+	char *str = dl_argv_next(dl);
+	int err;
+
+	if (!str) {
+		pr_err("Unsigned number argument expected\n");
+		return -EINVAL;
+	}
+
+	err = strtouint32_t(str, p_val);
+	if (err) {
+		pr_err("\"%s\" is not a number or not within range\n", str);
+		return err;
+	}
+	return 0;
+}
+
+static int dl_argv_str(struct dl *dl, const char **p_str)
+{
+	const char *str = dl_argv_next(dl);
+
+	if (!str) {
+		pr_err("String parameter expected\n");
+		return -EINVAL;
+	}
+	*p_str = str;
+	return 0;
+}
+
+static int port_type_get(const char *typestr, enum devlink_port_type *p_type)
+{
+	if (strcmp(typestr, "auto") == 0) {
+		*p_type = DEVLINK_PORT_TYPE_AUTO;
+	} else if (strcmp(typestr, "eth") == 0) {
+		*p_type = DEVLINK_PORT_TYPE_ETH;
+	} else if (strcmp(typestr, "ib") == 0) {
+		*p_type = DEVLINK_PORT_TYPE_IB;
+	} else {
+		pr_err("Unknown port type \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+#define BIT(nr)                 (1UL << (nr))
+#define DL_OPT_HANDLE		BIT(0)
+#define DL_OPT_HANDLEP		BIT(1)
+#define DL_OPT_PORT_TYPE	BIT(2)
+#define DL_OPT_PORT_COUNT	BIT(3)
+
+static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
+			     uint32_t o_required, uint32_t o_optional)
+{
+	uint32_t o_all = o_required | o_optional;
+	uint32_t o_found = 0;
+	int err;
+
+	if (o_required & DL_OPT_HANDLE) {
+		err = dl_argv_put_handle(nlh, dl);
+		if (err)
+			return err;
+	} else if (o_required & DL_OPT_HANDLEP) {
+		err = dl_argv_put_handle_port(nlh, dl);
+		if (err)
+			return err;
+	}
+
+	while (dl_argc(dl)) {
+		if (dl_argv_match(dl, "type") &&
+		    (o_all & DL_OPT_PORT_TYPE)) {
+			enum devlink_port_type port_type;
+			const char *typestr;
+
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = port_type_get(typestr, &port_type);
+			if (err)
+				return err;
+			mnl_attr_put_u16(nlh, DEVLINK_ATTR_PORT_TYPE,
+					 port_type);
+			o_found |= DL_OPT_PORT_TYPE;
+		} else if (dl_argv_match(dl, "count") &&
+			   (o_all & DL_OPT_PORT_COUNT)) {
+			uint32_t count;
+
+			dl_arg_inc(dl);
+			err = dl_argv_uint32_t(dl, &count);
+			if (err)
+				return err;
+			mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_SPLIT_COUNT,
+					 count);
+			o_found |= DL_OPT_PORT_COUNT;
+		} else {
+			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
+			return -EINVAL;
+		}
+	}
+
+	if ((o_required & DL_OPT_PORT_TYPE) && !(o_found & DL_OPT_PORT_TYPE)) {
+		pr_err("Port type option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_PORT_COUNT) &&
+	    !(o_found & DL_OPT_PORT_COUNT)) {
+		pr_err("Port split count option expected.\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void cmd_dev_help(void)
+{
+	pr_out("Usage: devlink dev show [ DEV ]\n");
+}
+
+static void pr_out_handle(struct nlattr **tb)
+{
+	pr_out("%s/%s", mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
+			mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]));
+}
+
+static void pr_out_dev(struct nlattr **tb)
+{
+	pr_out_handle(tb);
+	pr_out("\n");
+}
+
+static int cmd_dev_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME])
+		return MNL_CB_ERROR;
+	pr_out_dev(tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_dev_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, 0);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dev_show_cb, NULL);
+}
+
+static int cmd_dev(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_dev_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_dev_show(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void cmd_port_help(void)
+{
+	pr_out("Usage: devlink port show [ DEV/PORT_INDEX ]\n");
+	pr_out("       dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]\n");
+	pr_out("       dl port split DEV/PORT_INDEX count COUNT\n");
+	pr_out("       dl port unsplit DEV/PORT_INDEX\n");
+}
+
+static const char *port_type_name(uint32_t type)
+{
+	switch (type) {
+	case DEVLINK_PORT_TYPE_NOTSET: return "notset";
+	case DEVLINK_PORT_TYPE_AUTO: return "auto";
+	case DEVLINK_PORT_TYPE_ETH: return "eth";
+	case DEVLINK_PORT_TYPE_IB: return "ib";
+	default: return "<unknown type>";
+	}
+}
+
+static void pr_out_port(struct nlattr **tb)
+{
+	struct nlattr *pt_attr = tb[DEVLINK_ATTR_PORT_TYPE];
+	struct nlattr *dpt_attr = tb[DEVLINK_ATTR_PORT_DESIRED_TYPE];
+
+	pr_out_handle(tb);
+	pr_out("/%d:", mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+	if (pt_attr) {
+		uint16_t port_type = mnl_attr_get_u16(pt_attr);
+
+		pr_out(" type %s", port_type_name(port_type));
+		if (dpt_attr) {
+			uint16_t des_port_type = mnl_attr_get_u16(dpt_attr);
+
+			if (port_type != des_port_type)
+				pr_out("(%s)", port_type_name(des_port_type));
+		}
+	}
+	if (tb[DEVLINK_ATTR_PORT_NETDEV_NAME])
+		pr_out(" netdev %s",
+		       mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_NETDEV_NAME]));
+	if (tb[DEVLINK_ATTR_PORT_IBDEV_NAME])
+		pr_out(" ibdev %s",
+		       mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_IBDEV_NAME]));
+	if (tb[DEVLINK_ATTR_PORT_SPLIT_GROUP])
+		pr_out(" split_group %u",
+		       mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_SPLIT_GROUP]));
+	pr_out("\n");
+}
+
+static int cmd_port_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX])
+		return MNL_CB_ERROR;
+	pr_out_port(tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_port_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_PORT_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP, 0);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_port_show_cb, NULL);
+}
+
+static int cmd_port_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_PORT_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP | DL_OPT_PORT_TYPE, 0);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_port_split(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_PORT_SPLIT,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP | DL_OPT_PORT_COUNT, 0);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_port_unsplit(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_PORT_UNSPLIT,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP, 0);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_port(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_port_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") ||  dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_port_show(dl);
+	} else if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_port_set(dl);
+	} else if (dl_argv_match(dl, "split")) {
+		dl_arg_inc(dl);
+		return cmd_port_split(dl);
+	} else if (dl_argv_match(dl, "unsplit")) {
+		dl_arg_inc(dl);
+		return cmd_port_unsplit(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static const char *cmd_name(uint8_t cmd)
+{
+	switch (cmd) {
+	case DEVLINK_CMD_UNSPEC: return "unspec";
+	case DEVLINK_CMD_GET: return "get";
+	case DEVLINK_CMD_SET: return "set";
+	case DEVLINK_CMD_NEW: return "new";
+	case DEVLINK_CMD_DEL: return "del";
+	case DEVLINK_CMD_PORT_GET: return "get";
+	case DEVLINK_CMD_PORT_SET: return "set";
+	case DEVLINK_CMD_PORT_NEW: return "net";
+	case DEVLINK_CMD_PORT_DEL: return "del";
+	default: return "<unknown cmd>";
+	}
+}
+
+static const char *cmd_obj(uint8_t cmd)
+{
+	switch (cmd) {
+	case DEVLINK_CMD_UNSPEC: return "unspec";
+	case DEVLINK_CMD_GET:
+	case DEVLINK_CMD_SET:
+	case DEVLINK_CMD_NEW:
+	case DEVLINK_CMD_DEL:
+		return "dev";
+	case DEVLINK_CMD_PORT_GET:
+	case DEVLINK_CMD_PORT_SET:
+	case DEVLINK_CMD_PORT_NEW:
+	case DEVLINK_CMD_PORT_DEL:
+		return "port";
+	default: return "<unknown obj>";
+	}
+}
+
+static void pr_out_mon_header(uint8_t cmd)
+{
+	pr_out("[%s,%s] ", cmd_obj(cmd), cmd_name(cmd));
+}
+
+static bool cmd_filter_check(struct dl *dl, uint8_t cmd)
+{
+	const char *obj = cmd_obj(cmd);
+	unsigned int index = 0;
+	const char *cur_obj;
+
+	if (dl_no_arg(dl))
+		return true;
+	while ((cur_obj = dl_argv_index(dl, index++))) {
+		if (strcmp(cur_obj, obj) == 0 || strcmp(cur_obj, "all") == 0)
+			return true;
+	}
+	return false;
+}
+
+static int cmd_mon_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dl *dl = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	uint8_t cmd = genl->cmd;
+
+	if (!cmd_filter_check(dl, cmd))
+		return MNL_CB_OK;
+
+	switch (cmd) {
+	case DEVLINK_CMD_GET: /* fall through */
+	case DEVLINK_CMD_SET: /* fall through */
+	case DEVLINK_CMD_NEW: /* fall through */
+	case DEVLINK_CMD_DEL:
+		mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+		if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME])
+			return MNL_CB_ERROR;
+		pr_out_mon_header(genl->cmd);
+		pr_out_dev(tb);
+		break;
+	case DEVLINK_CMD_PORT_GET: /* fall through */
+	case DEVLINK_CMD_PORT_SET: /* fall through */
+	case DEVLINK_CMD_PORT_NEW: /* fall through */
+	case DEVLINK_CMD_PORT_DEL:
+		mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+		if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+		    !tb[DEVLINK_ATTR_PORT_INDEX])
+			return MNL_CB_ERROR;
+		pr_out_mon_header(genl->cmd);
+		pr_out_port(tb);
+		break;
+	}
+	return MNL_CB_OK;
+}
+
+static int cmd_mon_show(struct dl *dl)
+{
+	int err;
+	unsigned int index = 0;
+	const char *cur_obj;
+
+	while ((cur_obj = dl_argv_index(dl, index++))) {
+		if (strcmp(cur_obj, "all") != 0 &&
+		    strcmp(cur_obj, "dev") != 0 &&
+		    strcmp(cur_obj, "port") != 0) {
+			pr_err("Unknown object \"%s\"\n", cur_obj);
+			return -EINVAL;
+		}
+	}
+	err = _mnlg_socket_group_add(dl->nlg, DEVLINK_GENL_MCGRP_CONFIG_NAME);
+	if (err)
+		return err;
+	err = _mnlg_socket_recv_run(dl->nlg, cmd_mon_show_cb, dl);
+	if (err)
+		return err;
+	return 0;
+}
+
+static void cmd_mon_help(void)
+{
+	pr_out("Usage: devlink monitor [ all | OBJECT-LIST ]\n"
+	       "where  OBJECT-LIST := { dev | port }\n");
+}
+
+static int cmd_mon(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_mon_help();
+		return 0;
+	} else if (dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_mon_show(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void help(void)
+{
+	pr_out("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
+	       "where  OBJECT := { dev | port | monitor }\n"
+	       "       OPTIONS := { -V[ersion] }\n");
+}
+
+static int dl_cmd(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		help();
+		return 0;
+	} else if (dl_argv_match(dl, "dev")) {
+		dl_arg_inc(dl);
+		return cmd_dev(dl);
+	} else if (dl_argv_match(dl, "port")) {
+		dl_arg_inc(dl);
+		return cmd_port(dl);
+	} else if (dl_argv_match(dl, "monitor")) {
+		dl_arg_inc(dl);
+		return cmd_mon(dl);
+	}
+	pr_err("Object \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static int dl_init(struct dl *dl, int argc, char **argv)
+{
+	int err;
+
+	dl->argc = argc;
+	dl->argv = argv;
+
+	dl->nlg = mnlg_socket_open(DEVLINK_GENL_NAME, DEVLINK_GENL_VERSION);
+	if (!dl->nlg) {
+		pr_err("Failed to connect to devlink Netlink\n");
+		return -errno;
+	}
+
+	err = ifname_map_init(dl);
+	if (err) {
+		pr_err("Failed to create index map\n");
+		goto err_ifname_map_create;
+	}
+	return 0;
+
+err_ifname_map_create:
+	mnlg_socket_close(dl->nlg);
+	return err;
+}
+
+static void dl_fini(struct dl *dl)
+{
+	ifname_map_fini(dl);
+	mnlg_socket_close(dl->nlg);
+}
+
+static struct dl *dl_alloc(void)
+{
+	struct dl *dl;
+
+	dl = calloc(1, sizeof(*dl));
+	if (!dl)
+		return NULL;
+	return dl;
+}
+
+static void dl_free(struct dl *dl)
+{
+	free(dl);
+}
+
+int main(int argc, char **argv)
+{
+	static const struct option long_options[] = {
+		{ "Version",		no_argument,		NULL, 'V' },
+		{ NULL, 0, NULL, 0 }
+	};
+	struct dl *dl;
+	int opt;
+	int err;
+	int ret;
+
+	while ((opt = getopt_long(argc, argv, "V",
+				  long_options, NULL)) >= 0) {
+
+		switch (opt) {
+		case 'V':
+			printf("devlink utility, iproute2-ss%s\n", SNAPSHOT);
+			return EXIT_SUCCESS;
+		default:
+			pr_err("Unknown option.\n");
+			help();
+			return EXIT_FAILURE;
+		}
+	}
+
+	argc -= optind;
+	argv += optind;
+
+	dl = dl_alloc();
+	if (!dl) {
+		pr_err("Failed to allocate memory for devlink\n");
+		return EXIT_FAILURE;
+	}
+
+	err = dl_init(dl, argc, argv);
+	if (err) {
+		ret = EXIT_FAILURE;
+		goto dl_free;
+	}
+
+	err = dl_cmd(dl);
+	if (err) {
+		ret = EXIT_FAILURE;
+		goto dl_fini;
+	}
+
+	ret = EXIT_SUCCESS;
+
+dl_fini:
+	dl_fini(dl);
+dl_free:
+	dl_free(dl);
+
+	return ret;
+}
+
diff --git a/devlink/mnlg.c b/devlink/mnlg.c
new file mode 100644
index 0000000..9e27de2
--- /dev/null
+++ b/devlink/mnlg.c
@@ -0,0 +1,274 @@
+/*
+ *   mnlg.c	Generic Netlink helpers for libmnl
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri@mellanox.com>
+ */
+
+#include <stdlib.h>
+#include <stdbool.h>
+#include <string.h>
+#include <errno.h>
+#include <unistd.h>
+#include <time.h>
+#include <libmnl/libmnl.h>
+#include <linux/genetlink.h>
+
+#include "mnlg.h"
+
+struct mnlg_socket {
+	struct mnl_socket *nl;
+	char *buf;
+	uint32_t id;
+	uint8_t version;
+	unsigned int seq;
+	unsigned int portid;
+};
+
+static struct nlmsghdr *__mnlg_msg_prepare(struct mnlg_socket *nlg, uint8_t cmd,
+					   uint16_t flags, uint32_t id,
+					   uint8_t version)
+{
+	struct nlmsghdr *nlh;
+	struct genlmsghdr *genl;
+
+	nlh = mnl_nlmsg_put_header(nlg->buf);
+	nlh->nlmsg_type	= id;
+	nlh->nlmsg_flags = flags;
+	nlg->seq = time(NULL);
+	nlh->nlmsg_seq = nlg->seq;
+
+	genl = mnl_nlmsg_put_extra_header(nlh, sizeof(struct genlmsghdr));
+	genl->cmd = cmd;
+	genl->version = version;
+
+	return nlh;
+}
+
+struct nlmsghdr *mnlg_msg_prepare(struct mnlg_socket *nlg, uint8_t cmd,
+				  uint16_t flags)
+{
+	return __mnlg_msg_prepare(nlg, cmd, flags, nlg->id, nlg->version);
+}
+
+int mnlg_socket_send(struct mnlg_socket *nlg, const struct nlmsghdr *nlh)
+{
+	return mnl_socket_sendto(nlg->nl, nlh, nlh->nlmsg_len);
+}
+
+int mnlg_socket_recv_run(struct mnlg_socket *nlg, mnl_cb_t data_cb, void *data)
+{
+	int err;
+
+	do {
+		err = mnl_socket_recvfrom(nlg->nl, nlg->buf,
+					  MNL_SOCKET_BUFFER_SIZE);
+		if (err <= 0)
+			break;
+		err = mnl_cb_run(nlg->buf, err, nlg->seq, nlg->portid,
+				 data_cb, data);
+	} while (err > 0);
+
+	return err;
+}
+
+struct group_info {
+	bool found;
+	uint32_t id;
+	const char *name;
+};
+
+static int parse_mc_grps_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, CTRL_ATTR_MCAST_GRP_MAX) < 0)
+		return MNL_CB_OK;
+
+	switch (type) {
+	case CTRL_ATTR_MCAST_GRP_ID:
+		if (mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+			return MNL_CB_ERROR;
+		break;
+	case CTRL_ATTR_MCAST_GRP_NAME:
+		if (mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
+			return MNL_CB_ERROR;
+		break;
+	}
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+static void parse_genl_mc_grps(struct nlattr *nested,
+			       struct group_info *group_info)
+{
+	struct nlattr *pos;
+	const char *name;
+
+	mnl_attr_for_each_nested(pos, nested) {
+		struct nlattr *tb[CTRL_ATTR_MCAST_GRP_MAX + 1] = {};
+
+		mnl_attr_parse_nested(pos, parse_mc_grps_cb, tb);
+		if (!tb[CTRL_ATTR_MCAST_GRP_NAME] ||
+		    !tb[CTRL_ATTR_MCAST_GRP_ID])
+			continue;
+
+		name = mnl_attr_get_str(tb[CTRL_ATTR_MCAST_GRP_NAME]);
+		if (strcmp(name, group_info->name) != 0)
+			continue;
+
+		group_info->id = mnl_attr_get_u32(tb[CTRL_ATTR_MCAST_GRP_ID]);
+		group_info->found = true;
+	}
+}
+
+static int get_group_id_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, CTRL_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+
+	if (type == CTRL_ATTR_MCAST_GROUPS &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+static int get_group_id_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct group_info *group_info = data;
+	struct nlattr *tb[CTRL_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), get_group_id_attr_cb, tb);
+	if (!tb[CTRL_ATTR_MCAST_GROUPS])
+		return MNL_CB_ERROR;
+	parse_genl_mc_grps(tb[CTRL_ATTR_MCAST_GROUPS], group_info);
+	return MNL_CB_OK;
+}
+
+int mnlg_socket_group_add(struct mnlg_socket *nlg, const char *group_name)
+{
+	struct nlmsghdr *nlh;
+	struct group_info group_info;
+	int err;
+
+	nlh = __mnlg_msg_prepare(nlg, CTRL_CMD_GETFAMILY,
+				 NLM_F_REQUEST | NLM_F_ACK, GENL_ID_CTRL, 1);
+	mnl_attr_put_u32(nlh, CTRL_ATTR_FAMILY_ID, nlg->id);
+
+	err = mnlg_socket_send(nlg, nlh);
+	if (err < 0)
+		return err;
+
+	group_info.found = false;
+	group_info.name = group_name;
+	err = mnlg_socket_recv_run(nlg, get_group_id_cb, &group_info);
+	if (err < 0)
+		return err;
+
+	if (!group_info.found) {
+		errno = ENOENT;
+		return -1;
+	}
+
+	err = mnl_socket_setsockopt(nlg->nl, NETLINK_ADD_MEMBERSHIP,
+				    &group_info.id, sizeof(group_info.id));
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int get_family_id_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_type_valid(attr, CTRL_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+
+	if (type == CTRL_ATTR_FAMILY_ID &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+static int get_family_id_cb(const struct nlmsghdr *nlh, void *data)
+{
+	uint32_t *p_id = data;
+	struct nlattr *tb[CTRL_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), get_family_id_attr_cb, tb);
+	if (!tb[CTRL_ATTR_FAMILY_ID])
+		return MNL_CB_ERROR;
+	*p_id = mnl_attr_get_u16(tb[CTRL_ATTR_FAMILY_ID]);
+	return MNL_CB_OK;
+}
+
+struct mnlg_socket *mnlg_socket_open(const char *family_name, uint8_t version)
+{
+	struct mnlg_socket *nlg;
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlg = malloc(sizeof(*nlg));
+	if (!nlg)
+		return NULL;
+
+	nlg->buf = malloc(MNL_SOCKET_BUFFER_SIZE);
+	if (!nlg->buf)
+		goto err_buf_alloc;
+
+	nlg->nl = mnl_socket_open(NETLINK_GENERIC);
+	if (!nlg->nl)
+		goto err_mnl_socket_open;
+
+	err = mnl_socket_bind(nlg->nl, 0, MNL_SOCKET_AUTOPID);
+	if (err < 0)
+		goto err_mnl_socket_bind;
+
+	nlg->portid = mnl_socket_get_portid(nlg->nl);
+
+	nlh = __mnlg_msg_prepare(nlg, CTRL_CMD_GETFAMILY,
+				 NLM_F_REQUEST | NLM_F_ACK, GENL_ID_CTRL, 1);
+	mnl_attr_put_strz(nlh, CTRL_ATTR_FAMILY_NAME, family_name);
+
+	err = mnlg_socket_send(nlg, nlh);
+	if (err < 0)
+		goto err_mnlg_socket_send;
+
+	err = mnlg_socket_recv_run(nlg, get_family_id_cb, &nlg->id);
+	if (err < 0)
+		goto err_mnlg_socket_recv_run;
+
+	nlg->version = version;
+	return nlg;
+
+err_mnlg_socket_recv_run:
+err_mnlg_socket_send:
+err_mnl_socket_bind:
+	mnl_socket_close(nlg->nl);
+err_mnl_socket_open:
+	free(nlg->buf);
+err_buf_alloc:
+	free(nlg);
+	return NULL;
+}
+
+void mnlg_socket_close(struct mnlg_socket *nlg)
+{
+	mnl_socket_close(nlg->nl);
+	free(nlg->buf);
+	free(nlg);
+}
diff --git a/devlink/mnlg.h b/devlink/mnlg.h
new file mode 100644
index 0000000..4d1babf
--- /dev/null
+++ b/devlink/mnlg.h
@@ -0,0 +1,27 @@
+/*
+ *   mnlg.h	Generic Netlink helpers for libmnl
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Jiri Pirko <jiri@mellanox.com>
+ */
+
+#ifndef _MNLG_H_
+#define _MNLG_H_
+
+#include <libmnl/libmnl.h>
+
+struct mnlg_socket;
+
+struct nlmsghdr *mnlg_msg_prepare(struct mnlg_socket *nlg, uint8_t cmd,
+				  uint16_t flags);
+int mnlg_socket_send(struct mnlg_socket *nlg, const struct nlmsghdr *nlh);
+int mnlg_socket_recv_run(struct mnlg_socket *nlg, mnl_cb_t data_cb, void *data);
+int mnlg_socket_group_add(struct mnlg_socket *nlg, const char *group_name);
+struct mnlg_socket *mnlg_socket_open(const char *family_name, uint8_t version);
+void mnlg_socket_close(struct mnlg_socket *nlg);
+
+#endif /* _MNLG_H_ */
diff --git a/include/linux/devlink.h b/include/linux/devlink.h
new file mode 100644
index 0000000..c9fee57
--- /dev/null
+++ b/include/linux/devlink.h
@@ -0,0 +1,72 @@
+/*
+ * include/uapi/linux/devlink.h - Network physical device Netlink interface
+ * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_DEVLINK_H_
+#define _UAPI_LINUX_DEVLINK_H_
+
+#define DEVLINK_GENL_NAME "devlink"
+#define DEVLINK_GENL_VERSION 0x1
+#define DEVLINK_GENL_MCGRP_CONFIG_NAME "config"
+
+enum devlink_command {
+	/* don't change the order or add anything between, this is ABI! */
+	DEVLINK_CMD_UNSPEC,
+
+	DEVLINK_CMD_GET,		/* can dump */
+	DEVLINK_CMD_SET,
+	DEVLINK_CMD_NEW,
+	DEVLINK_CMD_DEL,
+
+	DEVLINK_CMD_PORT_GET,		/* can dump */
+	DEVLINK_CMD_PORT_SET,
+	DEVLINK_CMD_PORT_NEW,
+	DEVLINK_CMD_PORT_DEL,
+
+	DEVLINK_CMD_PORT_SPLIT,
+	DEVLINK_CMD_PORT_UNSPLIT,
+
+	/* add new commands above here */
+
+	__DEVLINK_CMD_MAX,
+	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
+};
+
+enum devlink_port_type {
+	DEVLINK_PORT_TYPE_NOTSET,
+	DEVLINK_PORT_TYPE_AUTO,
+	DEVLINK_PORT_TYPE_ETH,
+	DEVLINK_PORT_TYPE_IB,
+};
+
+enum devlink_attr {
+	/* don't change the order or add anything between, this is ABI! */
+	DEVLINK_ATTR_UNSPEC,
+
+	/* bus name + dev name together are a handle for devlink entity */
+	DEVLINK_ATTR_BUS_NAME,			/* string */
+	DEVLINK_ATTR_DEV_NAME,			/* string */
+
+	DEVLINK_ATTR_PORT_INDEX,		/* u32 */
+	DEVLINK_ATTR_PORT_TYPE,			/* u16 */
+	DEVLINK_ATTR_PORT_DESIRED_TYPE,		/* u16 */
+	DEVLINK_ATTR_PORT_NETDEV_IFINDEX,	/* u32 */
+	DEVLINK_ATTR_PORT_NETDEV_NAME,		/* string */
+	DEVLINK_ATTR_PORT_IBDEV_NAME,		/* string */
+	DEVLINK_ATTR_PORT_SPLIT_COUNT,		/* u32 */
+	DEVLINK_ATTR_PORT_SPLIT_GROUP,		/* u32 */
+
+	/* add new attributes above here, update the policy in devlink.c */
+
+	__DEVLINK_ATTR_MAX,
+	DEVLINK_ATTR_MAX = __DEVLINK_ATTR_MAX - 1
+};
+
+#endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
new file mode 100644
index 0000000..7878d89
--- /dev/null
+++ b/man/man8/devlink-dev.8
@@ -0,0 +1,58 @@
+.TH DEVLINK\-DEV 8 "14 Mar 2016" "iproute2" "Linux"
+.SH NAME
+devlink-dev \- devlink device configuration
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B devlink
+.RI "[ " OPTIONS " ]"
+.B dev
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+
+.ti -8
+.B devlink dev show
+.RI "[ " DEV " ]"
+
+.ti -8
+.B devlink dev help
+
+.SH "DESCRIPTION"
+.SS devlink dev show - display devlink device attributes
+
+.PP
+.I "DEV"
+- specifies the devlink device to show.
+If this argument is omitted all devices are listed.
+
+.in +4
+Format is:
+.in +2
+BUS_NAME/BUS_ADDRESS
+
+.SH "EXAMPLES"
+.PP
+devlink dev show
+.RS 4
+Shows the state of all devlink devices on the system.
+.RE
+.PP
+devlink dev show pci/0000:01:00.0
+.RS 4
+Shows the state of specified devlink device.
+
+.SH SEE ALSO
+.BR devlink (8),
+.BR devlink-port (8),
+.BR devlink-monitor (8),
+.br
+
+.SH AUTHOR
+Jiri Pirko <jiri@mellanox.com>
diff --git a/man/man8/devlink-monitor.8 b/man/man8/devlink-monitor.8
new file mode 100644
index 0000000..98134c3
--- /dev/null
+++ b/man/man8/devlink-monitor.8
@@ -0,0 +1,36 @@
+.TH DEVLINK\-MONITOR 8 "14 Mar 2016" "iproute2" "Linux"
+.SH "NAME"
+devlink-monitor \- state monitoring
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.BR "devlink monitor" " [ " all " |"
+.IR OBJECT-LIST " ]"
+.sp
+
+.SH DESCRIPTION
+The
+.B devlink
+utility can monitor the state of devlink devices and ports
+continuously. This option has a slightly different format. Namely, the
+.B monitor
+command is the first in the command line and then the object list.
+
+.I OBJECT-LIST
+is the list of object types that we want to monitor.
+It may contain
+.BR dev ", " port ".
+
+.B devlink
+opens Devlink Netlink socket, listens on it and dumps state changes.
+
+.SH SEE ALSO
+.BR devlink (8),
+.BR devlink-dev (8),
+.BR devlink-port (8),
+.br
+
+.SH AUTHOR
+Jiri Pirko <jiri@mellanox.com>
diff --git a/man/man8/devlink-port.8 b/man/man8/devlink-port.8
new file mode 100644
index 0000000..e6ae686
--- /dev/null
+++ b/man/man8/devlink-port.8
@@ -0,0 +1,126 @@
+.TH DEVLINK\-PORT 8 "14 Mar 2016" "iproute2" "Linux"
+.SH NAME
+devlink-port \- devlink port configuration
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B devlink
+.RI "[ " OPTIONS " ]"
+.B port
+.RI  " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+
+.ti -8
+.BR "devlink port set "
+.IR DEV/PORT_INDEX
+.RI "[ "
+.BR type " { " eth " | " ib " | " auto " }"
+.RI "]"
+
+.ti -8
+.BR "devlink port split "
+.IR DEV/PORT_INDEX
+.BR count
+.IR COUNT
+
+.ti -8
+.BR "devlink port unsplit "
+.IR DEV/PORT_INDEX
+
+.ti -8
+.B devlink port show
+.RI "[ " DEV/PORT_INDEX " ]"
+
+.ti -8
+.B devlink port help
+
+.SH "DESCRIPTION"
+.SS devlink port set - change devlink port attributes
+
+.PP
+.B "DEV/PORT_INDEX"
+- specifies the devlink port to operate on.
+
+.in +4
+Format is:
+.in +2
+BUS_NAME/BUS_ADDRESS/PORT_INDEX
+
+.TP
+.BR type " { " eth " | " ib " | " auto " } "
+set port type
+
+.I eth
+- Ethernet
+
+.I ib
+- Infiniband
+
+.I auto
+- autoselect
+
+.SS devlink port split - split devlink port into more
+
+.PP
+.B "DEV/PORT_INDEX"
+- specifies the devlink port to operate on.
+
+.TP
+.BI count " COUNT"
+number of ports to split to.
+
+.SS devlink port unsplit - unsplit previously split devlink port
+Could be performed on any split port of the same split group.
+
+.PP
+.B "DEV/PORT_INDEX"
+- specifies the devlink port to operate on.
+
+.SS devlink port show - display devlink port attributes
+
+.PP
+.I "DEV/PORT_INDEX"
+- specifies the devlink port to show.
+If this argument is omitted all ports are listed.
+
+.SH "EXAMPLES"
+.PP
+devlink port show
+.RS 4
+Shows the state of all devlink ports on the system.
+.RE
+.PP
+devlink port show pci/0000:01:00.0/1
+.RS 4
+Shows the state of specified devlink port.
+.RE
+.PP
+devlink port set pci/0000:01:00.0/1 type eth
+.RS 4
+Set type of specified devlink port to Ethernet.
+.RE
+.PP
+devlink port split pci/0000:01:00.0/1 count 4
+.RS 4
+Split the specified devlink port into four ports.
+.RE
+.PP
+devlink port unsplit pci/0000:01:00.0/1
+.RS 4
+Unplit the specified previously split devlink port.
+
+.SH SEE ALSO
+.BR devlink (8),
+.BR devlink-dev (8),
+.BR devlink-monitor (8),
+.br
+
+.SH AUTHOR
+Jiri Pirko <jiri@mellanox.com>
diff --git a/man/man8/devlink.8 b/man/man8/devlink.8
new file mode 100644
index 0000000..f608ccc
--- /dev/null
+++ b/man/man8/devlink.8
@@ -0,0 +1,83 @@
+.TH DEVLINK 8 "14 Mar 2016" "iproute2" "Linux"
+.SH NAME
+devlink \- Devlink tool
+.SH SYNOPSIS
+.sp
+.ad l
+.in +8
+.ti -8
+.B devlink
+.RI "[ " OPTIONS " ] " OBJECT " { " COMMAND " | "
+.BR help " }"
+.sp
+
+.ti -8
+.IR OBJECT " := { "
+.BR dev " | " port " | " monitor " }"
+.sp
+
+.ti -8
+.IR OPTIONS " := { "
+\fB\-V\fR[\fIersion\fR] |
+
+.SH OPTIONS
+
+.TP
+.BR "\-V" , " -Version"
+Print the version of the
+.B devlink
+utility and exit.
+
+.SS
+.I OBJECT
+
+.TP
+.B dev
+- devlink device.
+
+.TP
+.B port
+- devlink port.
+
+.TP
+.B monitor
+- watch for netlink messages.
+
+.SS
+.I COMMAND
+
+Specifies the action to perform on the object.
+The set of possible actions depends on the object type.
+As a rule, it is possible to
+.B show
+(or
+.B list
+) objects, but some objects do not allow all of these operations
+or have some additional commands. The
+.B help
+command is available for all objects. It prints
+out a list of available commands and argument syntax conventions.
+.sp
+If no command is given, some default command is assumed.
+Usually it is
+.B list
+or, if the objects of this class cannot be listed,
+.BR "help" .
+
+.SH EXIT STATUS
+Exit status is 0 if command was successful or a positive integer upon failure.
+
+.SH SEE ALSO
+.BR devlink-dev (8),
+.BR devlink-port (8),
+.BR devlink-monitor (8),
+.br
+
+.SH REPORTING BUGS
+Report any bugs to the Network Developers mailing list
+.B <netdev@vger.kernel.org>
+where the development and maintenance is primarily done.
+You do not have to be subscribed to the list to send a message there.
+
+.SH AUTHOR
+Jiri Pirko <jiri@mellanox.com>
-- 
2.5.5
