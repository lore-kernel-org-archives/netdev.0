From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH v6 iproute2 2/8] rdma: Add basic infrastructure for RDMA tool
Date: Sun, 20 Aug 2017 12:58:22 +0300
Message-ID: <20170820095828.13812-3-leon@kernel.org>
References: <20170820095828.13812-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49108 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751142AbdHTJ6f (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 05:58:35 -0400
In-Reply-To: <20170820095828.13812-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

RDMA devices are cross-functional devices from one side,
but very tailored for the specific markets from another.

Such diversity caused to spread of RDMA related configuration
across various tools, e.g. devlink, ip, ethtool, ib specific and
vendor specific solutions.

This patch adds ability to fill device and port information
by reading RDMA netlink.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 Makefile                    |   2 +-
 include/rdma/rdma_netlink.h | 307 ++++++++++++++++++++++++++++++++++++++++++++
 rdma/.gitignore             |   1 +
 rdma/Makefile               |  22 ++++
 rdma/rdma.c                 | 116 +++++++++++++++++
 rdma/rdma.h                 |  71 ++++++++++
 rdma/utils.c                | 217 +++++++++++++++++++++++++++++++
 7 files changed, 735 insertions(+), 1 deletion(-)
 create mode 100644 include/rdma/rdma_netlink.h
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c

diff --git a/Makefile b/Makefile
index 1f88f7f5..dbb4a4af 100644
--- a/Makefile
+++ b/Makefile
@@ -49,7 +49,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v
 
-SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
+SUBDIRS=lib ip tc bridge misc netem genl tipc devlink rdma man
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
diff --git a/include/rdma/rdma_netlink.h b/include/rdma/rdma_netlink.h
new file mode 100644
index 00000000..861440a8
--- /dev/null
+++ b/include/rdma/rdma_netlink.h
@@ -0,0 +1,307 @@
+#ifndef _UAPI_RDMA_NETLINK_H
+#define _UAPI_RDMA_NETLINK_H
+
+#include <linux/types.h>
+
+enum {
+	RDMA_NL_RDMA_CM = 1,
+	RDMA_NL_IWCM,
+	RDMA_NL_RSVD,
+	RDMA_NL_LS,	/* RDMA Local Services */
+	RDMA_NL_NLDEV,	/* RDMA device interface */
+	RDMA_NL_NUM_CLIENTS
+};
+
+enum {
+	RDMA_NL_GROUP_CM = 1,
+	RDMA_NL_GROUP_IWPM,
+	RDMA_NL_GROUP_LS,
+	RDMA_NL_NUM_GROUPS
+};
+
+#define RDMA_NL_GET_CLIENT(type) ((type & (((1 << 6) - 1) << 10)) >> 10)
+#define RDMA_NL_GET_OP(type) (type & ((1 << 10) - 1))
+#define RDMA_NL_GET_TYPE(client, op) ((client << 10) + op)
+
+enum {
+	RDMA_NL_RDMA_CM_ID_STATS = 0,
+	RDMA_NL_RDMA_CM_NUM_OPS
+};
+
+enum {
+	RDMA_NL_RDMA_CM_ATTR_SRC_ADDR = 1,
+	RDMA_NL_RDMA_CM_ATTR_DST_ADDR,
+	RDMA_NL_RDMA_CM_NUM_ATTR,
+};
+
+/* iwarp port mapper op-codes */
+enum {
+	RDMA_NL_IWPM_REG_PID = 0,
+	RDMA_NL_IWPM_ADD_MAPPING,
+	RDMA_NL_IWPM_QUERY_MAPPING,
+	RDMA_NL_IWPM_REMOVE_MAPPING,
+	RDMA_NL_IWPM_REMOTE_INFO,
+	RDMA_NL_IWPM_HANDLE_ERR,
+	RDMA_NL_IWPM_MAPINFO,
+	RDMA_NL_IWPM_MAPINFO_NUM,
+	RDMA_NL_IWPM_NUM_OPS
+};
+
+struct rdma_cm_id_stats {
+	__u32	qp_num;
+	__u32	bound_dev_if;
+	__u32	port_space;
+	__s32	pid;
+	__u8	cm_state;
+	__u8	node_type;
+	__u8	port_num;
+	__u8	qp_type;
+};
+
+enum {
+	IWPM_NLA_REG_PID_UNSPEC = 0,
+	IWPM_NLA_REG_PID_SEQ,
+	IWPM_NLA_REG_IF_NAME,
+	IWPM_NLA_REG_IBDEV_NAME,
+	IWPM_NLA_REG_ULIB_NAME,
+	IWPM_NLA_REG_PID_MAX
+};
+
+enum {
+	IWPM_NLA_RREG_PID_UNSPEC = 0,
+	IWPM_NLA_RREG_PID_SEQ,
+	IWPM_NLA_RREG_IBDEV_NAME,
+	IWPM_NLA_RREG_ULIB_NAME,
+	IWPM_NLA_RREG_ULIB_VER,
+	IWPM_NLA_RREG_PID_ERR,
+	IWPM_NLA_RREG_PID_MAX
+
+};
+
+enum {
+	IWPM_NLA_MANAGE_MAPPING_UNSPEC = 0,
+	IWPM_NLA_MANAGE_MAPPING_SEQ,
+	IWPM_NLA_MANAGE_ADDR,
+	IWPM_NLA_MANAGE_MAPPED_LOC_ADDR,
+	IWPM_NLA_RMANAGE_MAPPING_ERR,
+	IWPM_NLA_RMANAGE_MAPPING_MAX
+};
+
+#define IWPM_NLA_MANAGE_MAPPING_MAX 3
+#define IWPM_NLA_QUERY_MAPPING_MAX  4
+#define IWPM_NLA_MAPINFO_SEND_MAX   3
+
+enum {
+	IWPM_NLA_QUERY_MAPPING_UNSPEC = 0,
+	IWPM_NLA_QUERY_MAPPING_SEQ,
+	IWPM_NLA_QUERY_LOCAL_ADDR,
+	IWPM_NLA_QUERY_REMOTE_ADDR,
+	IWPM_NLA_RQUERY_MAPPED_LOC_ADDR,
+	IWPM_NLA_RQUERY_MAPPED_REM_ADDR,
+	IWPM_NLA_RQUERY_MAPPING_ERR,
+	IWPM_NLA_RQUERY_MAPPING_MAX
+};
+
+enum {
+	IWPM_NLA_MAPINFO_REQ_UNSPEC = 0,
+	IWPM_NLA_MAPINFO_ULIB_NAME,
+	IWPM_NLA_MAPINFO_ULIB_VER,
+	IWPM_NLA_MAPINFO_REQ_MAX
+};
+
+enum {
+	IWPM_NLA_MAPINFO_UNSPEC = 0,
+	IWPM_NLA_MAPINFO_LOCAL_ADDR,
+	IWPM_NLA_MAPINFO_MAPPED_ADDR,
+	IWPM_NLA_MAPINFO_MAX
+};
+
+enum {
+	IWPM_NLA_MAPINFO_NUM_UNSPEC = 0,
+	IWPM_NLA_MAPINFO_SEQ,
+	IWPM_NLA_MAPINFO_SEND_NUM,
+	IWPM_NLA_MAPINFO_ACK_NUM,
+	IWPM_NLA_MAPINFO_NUM_MAX
+};
+
+enum {
+	IWPM_NLA_ERR_UNSPEC = 0,
+	IWPM_NLA_ERR_SEQ,
+	IWPM_NLA_ERR_CODE,
+	IWPM_NLA_ERR_MAX
+};
+
+/*
+ * Local service operations:
+ *   RESOLVE - The client requests the local service to resolve a path.
+ *   SET_TIMEOUT - The local service requests the client to set the timeout.
+ *   IP_RESOLVE - The client requests the local service to resolve an IP to GID.
+ */
+enum {
+	RDMA_NL_LS_OP_RESOLVE = 0,
+	RDMA_NL_LS_OP_SET_TIMEOUT,
+	RDMA_NL_LS_OP_IP_RESOLVE,
+	RDMA_NL_LS_NUM_OPS
+};
+
+/* Local service netlink message flags */
+#define RDMA_NL_LS_F_ERR	0x0100	/* Failed response */
+
+/*
+ * Local service resolve operation family header.
+ * The layout for the resolve operation:
+ *    nlmsg header
+ *    family header
+ *    attributes
+ */
+
+/*
+ * Local service path use:
+ * Specify how the path(s) will be used.
+ *   ALL - For connected CM operation (6 pathrecords)
+ *   UNIDIRECTIONAL - For unidirectional UD (1 pathrecord)
+ *   GMP - For miscellaneous GMP like operation (at least 1 reversible
+ *         pathrecord)
+ */
+enum {
+	LS_RESOLVE_PATH_USE_ALL = 0,
+	LS_RESOLVE_PATH_USE_UNIDIRECTIONAL,
+	LS_RESOLVE_PATH_USE_GMP,
+	LS_RESOLVE_PATH_USE_MAX
+};
+
+#define LS_DEVICE_NAME_MAX 64
+
+struct rdma_ls_resolve_header {
+	__u8 device_name[LS_DEVICE_NAME_MAX];
+	__u8 port_num;
+	__u8 path_use;
+};
+
+struct rdma_ls_ip_resolve_header {
+	__u32 ifindex;
+};
+
+/* Local service attribute type */
+#define RDMA_NLA_F_MANDATORY	(1 << 13)
+#define RDMA_NLA_TYPE_MASK	(~(NLA_F_NESTED | NLA_F_NET_BYTEORDER | \
+				  RDMA_NLA_F_MANDATORY))
+
+/*
+ * Local service attributes:
+ *   Attr Name       Size                       Byte order
+ *   -----------------------------------------------------
+ *   PATH_RECORD     struct ib_path_rec_data
+ *   TIMEOUT         u32                        cpu
+ *   SERVICE_ID      u64                        cpu
+ *   DGID            u8[16]                     BE
+ *   SGID            u8[16]                     BE
+ *   TCLASS          u8
+ *   PKEY            u16                        cpu
+ *   QOS_CLASS       u16                        cpu
+ *   IPV4            u32                        BE
+ *   IPV6            u8[16]                     BE
+ */
+enum {
+	LS_NLA_TYPE_UNSPEC = 0,
+	LS_NLA_TYPE_PATH_RECORD,
+	LS_NLA_TYPE_TIMEOUT,
+	LS_NLA_TYPE_SERVICE_ID,
+	LS_NLA_TYPE_DGID,
+	LS_NLA_TYPE_SGID,
+	LS_NLA_TYPE_TCLASS,
+	LS_NLA_TYPE_PKEY,
+	LS_NLA_TYPE_QOS_CLASS,
+	LS_NLA_TYPE_IPV4,
+	LS_NLA_TYPE_IPV6,
+	LS_NLA_TYPE_MAX
+};
+
+/* Local service DGID/SGID attribute: big endian */
+struct rdma_nla_ls_gid {
+	__u8		gid[16];
+};
+
+enum rdma_nldev_command {
+	RDMA_NLDEV_CMD_UNSPEC,
+
+	RDMA_NLDEV_CMD_GET, /* can dump */
+	RDMA_NLDEV_CMD_SET,
+	RDMA_NLDEV_CMD_NEW,
+	RDMA_NLDEV_CMD_DEL,
+
+	RDMA_NLDEV_CMD_PORT_GET, /* can dump */
+	RDMA_NLDEV_CMD_PORT_SET,
+	RDMA_NLDEV_CMD_PORT_NEW,
+	RDMA_NLDEV_CMD_PORT_DEL,
+
+	RDMA_NLDEV_NUM_OPS
+};
+
+enum rdma_nldev_attr {
+	/* don't change the order or add anything between, this is ABI! */
+	RDMA_NLDEV_ATTR_UNSPEC,
+
+	/* Identifier for ib_device */
+	RDMA_NLDEV_ATTR_DEV_INDEX,		/* u32 */
+
+	RDMA_NLDEV_ATTR_DEV_NAME,		/* string */
+	/*
+	 * Device index together with port index are identifiers
+	 * for port/link properties.
+	 *
+	 * For RDMA_NLDEV_CMD_GET commamnd, port index will return number
+	 * of available ports in ib_device, while for port specific operations,
+	 * it will be real port index as it appears in sysfs. Port index follows
+	 * sysfs notation and starts from 1 for the first port.
+	 */
+	RDMA_NLDEV_ATTR_PORT_INDEX,		/* u32 */
+
+	/*
+	 * Device and port capabilities
+	 */
+	RDMA_NLDEV_ATTR_CAP_FLAGS,		/* u64 */
+
+	/*
+	 * FW version
+	 */
+	RDMA_NLDEV_ATTR_FW_VERSION,		/* string */
+
+	/*
+	 * Node GUID (in host byte order) associated with the RDMA device.
+	 */
+	RDMA_NLDEV_ATTR_NODE_GUID,			/* u64 */
+
+	/*
+	 * System image GUID (in host byte order) associated with
+	 * this RDMA device and other devices which are part of a
+	 * single system.
+	 */
+	RDMA_NLDEV_ATTR_SYS_IMAGE_GUID,		/* u64 */
+
+	/*
+	 * Subnet prefix (in host byte order)
+	 */
+	RDMA_NLDEV_ATTR_SUBNET_PREFIX,		/* u64 */
+
+	/*
+	 * Local Identifier (LID),
+	 * According to IB specification, It is 16-bit address assigned
+	 * by the Subnet Manager. Extended to be 32-bit for OmniPath users.
+	 */
+	RDMA_NLDEV_ATTR_LID,			/* u32 */
+	RDMA_NLDEV_ATTR_SM_LID,			/* u32 */
+
+	/*
+	 * LID mask control (LMC)
+	 */
+	RDMA_NLDEV_ATTR_LMC,			/* u8 */
+
+	RDMA_NLDEV_ATTR_PORT_STATE,		/* u8 */
+	RDMA_NLDEV_ATTR_PORT_PHYS_STATE,	/* u8 */
+
+	RDMA_NLDEV_ATTR_DEV_NODE_TYPE,		/* u8 */
+
+	RDMA_NLDEV_ATTR_MAX
+};
+#endif /* _UAPI_RDMA_NETLINK_H */
diff --git a/rdma/.gitignore b/rdma/.gitignore
new file mode 100644
index 00000000..51fb172b
--- /dev/null
+++ b/rdma/.gitignore
@@ -0,0 +1 @@
+rdma
diff --git a/rdma/Makefile b/rdma/Makefile
new file mode 100644
index 00000000..64da2142
--- /dev/null
+++ b/rdma/Makefile
@@ -0,0 +1,22 @@
+include ../Config
+
+ifeq ($(HAVE_MNL),y)
+
+RDMA_OBJ = rdma.o utils.o
+
+TARGETS=rdma
+CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
+LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
+
+endif
+
+all:	$(TARGETS) $(LIBS)
+
+rdma:	$(RDMA_OBJ) $(LIBS)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
+
+install: all
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(RDMA_OBJ) $(TARGETS)
diff --git a/rdma/rdma.c b/rdma/rdma.c
new file mode 100644
index 00000000..d850e396
--- /dev/null
+++ b/rdma/rdma.c
@@ -0,0 +1,116 @@
+/*
+ * rdma.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+#include "SNAPSHOT.h"
+
+static void help(char *name)
+{
+	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
+	       "where  OBJECT := { help }\n"
+	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
+}
+
+static int cmd_help(struct rd *rd)
+{
+	help(rd->filename);
+	return 0;
+}
+
+static int rd_cmd(struct rd *rd)
+{
+	const struct rd_cmd cmds[] = {
+		{ NULL,		cmd_help },
+		{ "help",	cmd_help },
+		{ 0 }
+	};
+
+	return rd_exec_cmd(rd, cmds, "object");
+}
+
+static int rd_init(struct rd *rd, int argc, char **argv, char *filename)
+{
+	uint32_t seq;
+	int ret;
+
+	rd->filename = filename;
+	rd->argc = argc;
+	rd->argv = argv;
+	INIT_LIST_HEAD(&rd->dev_map_list);
+	rd->buff = malloc(MNL_SOCKET_BUFFER_SIZE);
+	if (!rd->buff)
+		return -ENOMEM;
+
+	rd_prepare_msg(rd, RDMA_NLDEV_CMD_GET,
+		       &seq, (NLM_F_REQUEST | NLM_F_ACK | NLM_F_DUMP));
+	ret = rd_send_msg(rd);
+	if (ret)
+		return ret;
+
+	return rd_recv_msg(rd, rd_dev_init_cb, rd, seq);
+}
+
+static void rd_free(struct rd *rd)
+{
+	free(rd->buff);
+	rd_free_devmap(rd);
+}
+
+int main(int argc, char **argv)
+{
+	static const struct option long_options[] = {
+		{ "version",		no_argument,		NULL, 'V' },
+		{ "help",		no_argument,		NULL, 'h' },
+		{ "details",		no_argument,		NULL, 'd' },
+		{ NULL, 0, NULL, 0 }
+	};
+	bool show_details = false;
+	char *filename;
+	struct rd rd;
+	int opt;
+	int err;
+
+	filename = basename(argv[0]);
+
+	while ((opt = getopt_long(argc, argv, "Vhd",
+				  long_options, NULL)) >= 0) {
+		switch (opt) {
+		case 'V':
+			printf("%s utility, iproute2-ss%s\n",
+			       filename, SNAPSHOT);
+			return EXIT_SUCCESS;
+		case 'd':
+			show_details = true;
+			break;
+		case 'h':
+			help(filename);
+			return EXIT_SUCCESS;
+		default:
+			pr_err("Unknown option.\n");
+			help(filename);
+			return EXIT_FAILURE;
+		}
+	}
+
+	argc -= optind;
+	argv += optind;
+
+	err = rd_init(&rd, argc, argv, filename);
+	if (err)
+		goto out;
+
+	rd.show_details = show_details;
+	err = rd_cmd(&rd);
+out:
+	/* Always cleanup */
+	rd_free(&rd);
+	return err ? EXIT_FAILURE : EXIT_SUCCESS;
+}
diff --git a/rdma/rdma.h b/rdma/rdma.h
new file mode 100644
index 00000000..2f655118
--- /dev/null
+++ b/rdma/rdma.h
@@ -0,0 +1,71 @@
+/*
+ * rdma.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+#ifndef _RDMA_TOOL_H_
+#define _RDMA_TOOL_H_
+
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <getopt.h>
+#include <libmnl/libmnl.h>
+#include <rdma/rdma_netlink.h>
+#include <time.h>
+
+#include "list.h"
+
+#define pr_err(args...) fprintf(stderr, ##args)
+#define pr_out(args...) fprintf(stdout, ##args)
+
+struct dev_map {
+	struct list_head list;
+	char *dev_name;
+	uint32_t num_ports;
+	uint32_t idx;
+};
+
+struct rd {
+	int argc;
+	char **argv;
+	char *filename;
+	bool show_details;
+	struct list_head dev_map_list;
+	struct mnl_socket *nl;
+	struct nlmsghdr *nlh;
+	char *buff;
+};
+
+struct rd_cmd {
+	const char *cmd;
+	int (*func)(struct rd *rd);
+};
+
+/*
+ * Parser interface
+ */
+bool rd_no_arg(struct rd *rd);
+void rd_arg_inc(struct rd *rd);
+
+int rd_exec_cmd(struct rd *rd, const struct rd_cmd *c, const char *str);
+
+/*
+ * Device manipulation
+ */
+void rd_free_devmap(struct rd *rd);
+
+/*
+ * Netlink
+ */
+int rd_send_msg(struct rd *rd);
+int rd_recv_msg(struct rd *rd, mnl_cb_t callback, void *data, uint32_t seq);
+void rd_prepare_msg(struct rd *rd, uint32_t cmd, uint32_t *seq, uint16_t flags);
+int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data);
+int rd_attr_cb(const struct nlattr *attr, void *data);
+#endif /* _RDMA_TOOL_H_ */
diff --git a/rdma/utils.c b/rdma/utils.c
new file mode 100644
index 00000000..9bd7418f
--- /dev/null
+++ b/rdma/utils.c
@@ -0,0 +1,217 @@
+/*
+ * utils.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+static int rd_argc(struct rd *rd)
+{
+	return rd->argc;
+}
+
+static char *rd_argv(struct rd *rd)
+{
+	if (!rd_argc(rd))
+		return NULL;
+	return *rd->argv;
+}
+
+static int strcmpx(const char *str1, const char *str2)
+{
+	if (strlen(str1) > strlen(str2))
+		return -1;
+	return strncmp(str1, str2, strlen(str1));
+}
+
+static bool rd_argv_match(struct rd *rd, const char *pattern)
+{
+	if (!rd_argc(rd))
+		return false;
+	return strcmpx(rd_argv(rd), pattern) == 0;
+}
+
+void rd_arg_inc(struct rd *rd)
+{
+	if (!rd_argc(rd))
+		return;
+	rd->argc--;
+	rd->argv++;
+}
+
+bool rd_no_arg(struct rd *rd)
+{
+	return rd_argc(rd) == 0;
+}
+
+static struct dev_map *dev_map_alloc(const char *dev_name)
+{
+	struct dev_map *dev_map;
+
+	dev_map = calloc(1, sizeof(*dev_map));
+	if (!dev_map)
+		return NULL;
+	dev_map->dev_name = strdup(dev_name);
+
+	return dev_map;
+}
+
+static void dev_map_free(struct dev_map *dev_map)
+{
+	if (!dev_map)
+		return;
+
+	free(dev_map->dev_name);
+	free(dev_map);
+}
+
+static void dev_map_cleanup(struct rd *rd)
+{
+	struct dev_map *dev_map, *tmp;
+
+	list_for_each_entry_safe(dev_map, tmp,
+				 &rd->dev_map_list, list) {
+		list_del(&dev_map->list);
+		dev_map_free(dev_map);
+	}
+}
+
+static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
+	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
+	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
+};
+
+int rd_attr_cb(const struct nlattr *attr, void *data)
+{
+	const struct nlattr **tb = data;
+	int type;
+
+	if (mnl_attr_type_valid(attr, RDMA_NLDEV_ATTR_MAX) < 0)
+		return MNL_CB_ERROR;
+
+	type = mnl_attr_get_type(attr);
+
+	if (mnl_attr_validate(attr, nldev_policy[type]) < 0)
+		return MNL_CB_ERROR;
+
+	tb[type] = attr;
+	return MNL_CB_OK;
+}
+
+int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
+	struct dev_map *dev_map;
+	struct rd *rd = data;
+	const char *dev_name;
+
+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
+	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME] || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
+		return MNL_CB_ERROR;
+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
+		pr_err("This tool doesn't support switches yet\n");
+		return MNL_CB_ERROR;
+	}
+
+	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
+
+	dev_map = dev_map_alloc(dev_name);
+	if (!dev_map)
+		/* The main function will cleanup the allocations */
+		return MNL_CB_ERROR;
+	list_add_tail(&dev_map->list, &rd->dev_map_list);
+
+	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
+	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	return MNL_CB_OK;
+}
+
+void rd_free_devmap(struct rd *rd)
+{
+	if (!rd)
+		return;
+	dev_map_cleanup(rd);
+}
+
+int rd_exec_cmd(struct rd *rd, const struct rd_cmd *cmds, const char *str)
+{
+	const struct rd_cmd *c;
+
+	/* First argument in objs table is default variant */
+	if (rd_no_arg(rd))
+		return cmds->func(rd);
+
+	for (c = cmds + 1; c->cmd; ++c) {
+		if (rd_argv_match(rd, c->cmd)) {
+			/* Move to next argument */
+			rd_arg_inc(rd);
+			return c->func(rd);
+		}
+	}
+
+	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
+	return 0;
+}
+
+void rd_prepare_msg(struct rd *rd, uint32_t cmd, uint32_t *seq, uint16_t flags)
+{
+	*seq = time(NULL);
+
+	rd->nlh = mnl_nlmsg_put_header(rd->buff);
+	rd->nlh->nlmsg_type = RDMA_NL_GET_TYPE(RDMA_NL_NLDEV, cmd);
+	rd->nlh->nlmsg_seq = *seq;
+	rd->nlh->nlmsg_flags = flags;
+}
+
+int rd_send_msg(struct rd *rd)
+{
+	int ret;
+
+	rd->nl = mnl_socket_open(NETLINK_RDMA);
+	if (!rd->nl) {
+		pr_err("Failed to open NETLINK_RDMA socket\n");
+		return -ENODEV;
+	}
+
+	ret = mnl_socket_bind(rd->nl, 0, MNL_SOCKET_AUTOPID);
+	if (ret < 0) {
+		pr_err("Failed to bind socket with err %d\n", ret);
+		goto err;
+	}
+
+	ret = mnl_socket_sendto(rd->nl, rd->nlh, rd->nlh->nlmsg_len);
+	if (ret < 0) {
+		pr_err("Failed to send to socket with err %d\n", ret);
+		goto err;
+	}
+	return 0;
+
+err:
+	mnl_socket_close(rd->nl);
+	return ret;
+}
+
+int rd_recv_msg(struct rd *rd, mnl_cb_t callback, void *data, unsigned int seq)
+{
+	int ret;
+	unsigned int portid;
+	char buf[MNL_SOCKET_BUFFER_SIZE];
+
+	portid = mnl_socket_get_portid(rd->nl);
+	do {
+		ret = mnl_socket_recvfrom(rd->nl, buf, sizeof(buf));
+		if (ret <= 0)
+			break;
+
+		ret = mnl_cb_run(buf, ret, seq, portid, callback, data);
+	} while (ret > 0);
+
+	mnl_socket_close(rd->nl);
+	return ret;
+}
-- 
2.14.1
