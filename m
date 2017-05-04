From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC iproute2 1/8] rdma: Add basic infrastructure for RDMA tool
Date: Thu,  4 May 2017 21:02:09 +0300
Message-ID: <20170504180216.7665-2-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504180216.7665-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

RDMA devices are cross-functional devices from one side,
but very tailored for the specific markets from another.

Such diversity caused to spread of RDMA related configuration
across various tools, e.g. devlink, ip, ethtool, ib specific and
vendor specific solutions.

This patch adds ability to fill device and port information
by reading sysfs entries (legacy).

All future configuration settings will be implemented in netlink format,
to be aligned with iproute2 package.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 Makefile        |   2 +-
 rdma/.gitignore |   1 +
 rdma/Makefile   |  15 +++
 rdma/rdma.c     |  96 +++++++++++++++++
 rdma/rdma.h     |  77 ++++++++++++++
 rdma/utils.c    | 313 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 503 insertions(+), 1 deletion(-)
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c

diff --git a/Makefile b/Makefile
index 18de7dcb..c255063b 100644
--- a/Makefile
+++ b/Makefile
@@ -52,7 +52,7 @@ WFLAGS += -Wmissing-declarations -Wold-style-definition -Wformat=2
 CFLAGS := $(WFLAGS) $(CCOPTS) -I../include $(DEFINES) $(CFLAGS)
 YACCFLAGS = -d -t -v

-SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
+SUBDIRS=lib ip tc bridge misc netem genl tipc devlink rdma man

 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
diff --git a/rdma/.gitignore b/rdma/.gitignore
new file mode 100644
index 00000000..51fb172b
--- /dev/null
+++ b/rdma/.gitignore
@@ -0,0 +1 @@
+rdma
diff --git a/rdma/Makefile b/rdma/Makefile
new file mode 100644
index 00000000..65248b31
--- /dev/null
+++ b/rdma/Makefile
@@ -0,0 +1,15 @@
+include ../Config
+
+RDMA_OBJ = rdma.o utils.o
+TARGETS=rdma
+
+all:	$(TARGETS) $(LIBS)
+
+rdma:	$(RDMA_OBJ)
+	$(QUIET_LINK)$(CC) $^ -o $@
+
+install: all
+	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
+
+clean:
+	rm -f $(RDMA_OBJ) $(TARGETS)
diff --git a/rdma/rdma.c b/rdma/rdma.c
new file mode 100644
index 00000000..bc7d1483
--- /dev/null
+++ b/rdma/rdma.c
@@ -0,0 +1,96 @@
+/*
+ * rdma.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+ */
+
+#include <limits.h>
+
+#include "rdma.h"
+#include "SNAPSHOT.h"
+
+static void help(char *name)
+{
+	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
+	       "where  OBJECT := { }\n"
+	       "       OPTIONS := { -V[ersion] }\n", name);
+}
+
+static int obj_help(struct rdma *rd)
+{
+	help(rd->filename);
+	return 0;
+}
+
+static int rd_cmd(struct rdma *rd)
+{
+	const struct rdma_obj objs[] = {
+		{ NULL,		obj_help },
+		{ "help",	obj_help },
+		{ 0 }
+	};
+
+	return rdma_exec_cmd(rd, objs, "object");
+}
+
+static int rd_init(struct rdma *rd, int argc, char **argv, char *filename)
+{
+	rd->filename = filename;
+	rd->argc = argc;
+	rd->argv = argv;
+	INIT_LIST_HEAD(&rd->dev_map_list);
+	return 0;
+}
+static void rd_free(struct rdma *rd)
+{
+	dev_map_cleanup(rd);
+}
+int main(int argc, char **argv)
+{
+	char *filename;
+	static const struct option long_options[] = {
+		{ "version",		no_argument,		NULL, 'V' },
+		{ "help",		no_argument,		NULL, 'h' },
+		{ NULL, 0, NULL, 0 }
+	};
+	struct rdma rd;
+	int opt;
+	int err;
+
+	filename = basename(argv[0]);
+
+	while ((opt = getopt_long(argc, argv, "Vh",
+				  long_options, NULL)) >= 0) {
+
+		switch (opt) {
+		case 'V':
+			printf("%s utility, iproute2-ss%s\n", filename, SNAPSHOT);
+			return EXIT_SUCCESS;
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
+	err = rd_cmd(&rd);
+	/* Always cleanup */
+	rd_free(&rd);
+
+out:	return (err) ? EXIT_FAILURE:EXIT_SUCCESS;
+}
diff --git a/rdma/rdma.h b/rdma/rdma.h
new file mode 100644
index 00000000..156bb74c
--- /dev/null
+++ b/rdma/rdma.h
@@ -0,0 +1,77 @@
+/*
+ * rdma.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+ */
+#ifndef _RDMA_TOOL_H_
+#define _RDMA_TOOL_H_
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <string.h>
+#include <errno.h>
+#include <getopt.h>
+#include <stdbool.h>
+
+#include "list.h"
+
+#define pr_err(args...) fprintf(stderr, ##args)
+#define pr_out(args...) fprintf(stdout, ##args)
+
+enum rt_protocols {
+	RT_PROTOCOL_IB,
+	RT_PROTOCOL_IWARP,
+	RT_PROTOCOL_ROCE_V1,
+	RT_PROTOCOL_ROCE_V2,
+	RT_PROTOCOL_OPA,
+	RT_NO_PROTOCOL
+};
+
+struct port_map {
+	struct list_head list;
+	char *ifname;
+	uint32_t idx;
+};
+
+struct dev_map {
+	struct list_head list;
+	char *dev_name;
+	uint32_t num_ports;
+	struct list_head port_map_list;
+	uint32_t idx;
+};
+
+struct rdma {
+	int argc;
+	char **argv;
+	char *filename;
+	struct list_head dev_map_list;
+};
+
+struct rdma_obj {
+	const char *cmd;
+	int (*func)(struct rdma *rd);
+};
+
+/*
+ * Parser interface
+ */
+bool rd_no_arg(struct rdma *rd);
+uint32_t get_port_from_argv(struct rdma *rd);
+
+int rdma_exec_cmd(struct rdma *rd, const struct rdma_obj *o, const char *str);
+int rdma_sysfs_read_ib(const char *name, int port, const char *field, char *res);
+
+/*
+ * Device manipulation
+ */
+int dev_map_init(struct rdma *rd);
+void dev_map_cleanup(struct rdma *rd);
+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index);
+#endif /* _RDMA_TOOL_H_ */
diff --git a/rdma/utils.c b/rdma/utils.c
new file mode 100644
index 00000000..568d7c0a
--- /dev/null
+++ b/rdma/utils.c
@@ -0,0 +1,313 @@
+/*
+ * utils.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+ */
+
+#include <sys/types.h>
+#include <dirent.h>
+
+#include "rdma.h"
+
+/*
+ * This macro will be moved to generic layer,
+ * after code will be accepted.
+ * it is placed here to avoid rebases with upstream code.
+ */
+#define MAX(a, b)	((a) > (b) ? (a) : (b))
+
+static int rd_argc(struct rdma *rd)
+{
+	return rd->argc;
+}
+
+static char *rd_argv(struct rdma *rd)
+{
+	if (!rd_argc(rd))
+		return NULL;
+	return *rd->argv;
+}
+
+static int strcmpx(const char *str1, const char *str2)
+{
+	if (strlen(str1) > strlen(str2))
+			return -1;
+	return strncmp(str1, str2, strlen(str1));
+}
+
+static bool rd_argv_match(struct rdma *rd, const char *pattern)
+{
+	if (!rd_argc(rd))
+		return false;
+	return strcmpx(rd_argv(rd), pattern) == 0;
+}
+
+static void rd_arg_inc(struct rdma *rd)
+{
+	if (!rd_argc(rd))
+		return;
+	rd->argc--;
+	rd->argv++;
+}
+
+bool rd_no_arg(struct rdma *rd)
+{
+	return rd_argc(rd) == 0;
+}
+
+#define SYSFS_INFINIBAND "/sys/class/infiniband"
+#define SYSFS_NET "/sys/class/net"
+static int sysfs_read(const char *prefix, const char *name, int port, const char *field, char *res)
+{
+	char fpath[64];
+	FILE *fentry;
+	int result;
+
+	if (port == 0)
+		snprintf(fpath, 64, "%s/%s/%s", prefix, name, field);
+	else
+		snprintf(fpath, 64, "%s/%s/ports/%d/%s", prefix, name, port, field);
+
+	fentry = fopen(fpath, "r");
+	if (!fentry)
+		return -ENOENT;
+
+	result = fread(res, 1, 4096, fentry);
+	/* Remove last "\n" */
+	res[result-1] = '\0';
+	fclose(fentry);
+	return 0;
+}
+
+int rdma_sysfs_read_ib(const char *name, int port, const char *field, char *res)
+{
+	return sysfs_read(SYSFS_INFINIBAND, name, port, field, res);
+}
+
+static int sysfs_read_net(const char *name,  const char *field, char *res)
+{
+	return sysfs_read(SYSFS_NET, name, 0, field, res);
+}
+
+static struct dev_map *dev_map_alloc(char *dev_name)
+{
+	struct dev_map *dev_map;
+
+	dev_map = calloc(1, sizeof(*dev_map));
+	if (!dev_map)
+		return NULL;
+	dev_map->dev_name = strdup(dev_name);
+	INIT_LIST_HEAD(&dev_map->port_map_list);
+
+	return dev_map;
+}
+
+static void port_map_free(struct port_map *port_map)
+{
+	free(port_map->ifname);
+	free(port_map);
+}
+
+static void dev_map_free(struct dev_map *dev_map)
+{
+	struct port_map *port_map, *tmp;
+
+	list_for_each_entry_safe(port_map, tmp,
+				 &dev_map->port_map_list, list) {
+		list_del(&port_map->list);
+		port_map_free(port_map);
+	}
+
+	free(dev_map->dev_name);
+	free(dev_map);
+}
+
+void dev_map_cleanup(struct rdma *rd)
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
+uint32_t get_port_from_argv(struct rdma *rd)
+{
+	char *slash;
+
+	slash = strchr(rd_argv(rd), '/');
+	/* if no port found, return 0 */
+	return (slash) ? (atoi(slash + 1)):0;
+}
+
+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index)
+{
+	struct dev_map *dev_map;
+	char *dev_name;
+	char *slash;
+
+	dev_name = strdup(rd_argv(rd));
+	if (allow_port_index) {
+		slash = strrchr(dev_name, '/');
+		if (slash)
+			*slash = '\0';
+	}
+
+	list_for_each_entry(dev_map, &rd->dev_map_list, list)
+		if (strcmp(dev_name, dev_map->dev_name) == 0) {
+			free(dev_name);
+			return dev_map;
+		}
+
+	free(dev_name);
+	return NULL;
+}
+
+static bool is_dots(char *name)
+{
+	if (!strcmp(name, ".") || !strcmp(name, ".."))
+		return true;
+	return false;
+}
+
+static char *find_ifname(struct dev_map *dev_map, uint32_t port)
+{
+	struct dirent *dentry, *drentry;
+	char data[4096];
+	char drpath[64];
+	uint32_t net_port;
+	DIR *dir, *drdir;
+	char *ifname = NULL;
+
+	dir = opendir(SYSFS_NET);
+	if (!dir)
+		return NULL;
+
+	while ((dentry = readdir(dir))) {
+		if (is_dots(dentry->d_name))
+			continue;
+
+		if (sysfs_read_net(dentry->d_name, "dev_id", data))
+			continue;
+
+		/* handle up to 9 ports, due to insufficient handling of hex  */
+		net_port = strtoul(data, NULL, 16);
+
+		snprintf(drpath, 64, "%s/%s/device/infiniband/", SYSFS_NET, dentry->d_name);
+
+		drdir = opendir(drpath);
+		if (!drdir)
+			continue;
+
+		while ((drentry = readdir(drdir))) {
+			if (is_dots(drentry->d_name))
+				continue;
+			if (!strcmp(drentry->d_name, dev_map->dev_name) &&
+			    net_port == port - 1) {
+				ifname = strdup(dentry->d_name);
+				closedir(drdir);
+				return ifname;
+			}
+		}
+
+		closedir(drdir);
+
+	}
+
+	closedir(dir);
+	return NULL;
+}
+
+static struct port_map *port_map_alloc(struct dev_map *dev_map, uint32_t port)
+{
+	struct port_map *port_map;
+
+	port_map = calloc(1, sizeof(*port_map));
+	if (!port_map)
+		return NULL;
+
+	port_map->idx = port;
+	/*
+	 * Expensive operation in sysfs world, need to rescan all net devices.
+	 * Hopefuly, it is one time operation.
+	 * In netlink, it will be simpler
+	 */
+	port_map->ifname = find_ifname(dev_map, port);
+	return port_map;
+}
+
+int dev_map_init(struct rdma *rd)
+{
+	struct dev_map *dev_map;
+	struct port_map *port_map;
+	struct dirent *dentry, *pentry;
+	uint32_t i = 1;
+	uint32_t num_ports = 0;
+	char ports_name[64];
+	DIR *dir, *pdir;
+	dir = opendir(SYSFS_INFINIBAND);
+	if (!dir)
+		return -ENOENT;
+
+	while ((dentry = readdir(dir))) {
+		num_ports = 0;
+		if (is_dots(dentry->d_name))
+			continue;
+
+		dev_map = dev_map_alloc(dentry->d_name);
+		if (!dev_map)
+			/* The main function will cleanup the allocations */
+			return -ENOMEM;
+		list_add_tail(&dev_map->list, &rd->dev_map_list);
+		dev_map->idx = i;
+		i++;
+
+		snprintf(ports_name, 64, "%s/%s/ports/", SYSFS_INFINIBAND, dentry->d_name);
+		pdir = opendir(ports_name);
+		while ((pentry = readdir(pdir))) {
+			int port;
+			if (is_dots(pentry->d_name))
+				continue;
+
+			port = atoi(pentry->d_name);
+			port_map = port_map_alloc(dev_map, port);
+			if (!port_map)
+				return -ENOENT;
+			list_add_tail(&port_map->list, &dev_map->port_map_list);
+			num_ports = MAX(num_ports, port);
+		}
+		closedir(pdir);
+		dev_map->num_ports = num_ports;
+	}
+	closedir(dir);
+
+	/* num_ports == 0 => no devices in infiniband folder */
+	return (num_ports) ? 0:(-ENOENT);
+}
+
+int rdma_exec_cmd(struct rdma *rd, const struct rdma_obj *objs, const char *str)
+{
+	const struct rdma_obj *o;
+
+	/* First argument in objs table is default variant */
+	if (rd_no_arg(rd))
+		return objs->func(rd);
+
+	for (o = objs + 1; o->cmd; ++o) {
+		if (rd_argv_match(rd, o->cmd)) {
+			/* Move to next argument */
+			rd_arg_inc(rd);
+			return o->func(rd);
+		}
+	}
+
+	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
+	return 0;
+}
--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
