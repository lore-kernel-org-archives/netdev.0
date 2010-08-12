From: Narendra K <Narendra_K@dell.com>
Subject: [PATCH] Add firmware label support to iproute2
Date: Thu, 12 Aug 2010 12:35:37 -0500
Message-ID: <20100812173537.GA29784@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, charles_rose@dell.com,
	jordan_hargrave@dell.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:62613 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab0HLRfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 13:35:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have proposed solutions to resolve the specific issue of
"eth0 does not always map to Integrated NIC port 1 on the 
server chassis". Below are the approaches we proposed which
were not acceptable -

1. Create char device node for every network device and have udev
create alternate names in the form of /dev/netdev/.

http://marc.info/?l=linux-netdev&m=125510301513312&w=2

2. Achieve the above in userspace only using udev

3. Provide an option in the installers for users to rename network
interfaces based on various policies such as chassis label, mac
addresses etc.

https://www.redhat.com/archives/anaconda-devel-list/2009-November/msg00516.html

The approach to export firmware provided index and labels was more
acceptable.
 
http://marc.info/?l=linux-pci&m=126713402415401&w=3 -

This feature is now part of the kernel and firmware labels of
network devices are available to user space via sysfs.

http://git.kernel.org/?p=linux/kernel/git/next/linux-next.git;a=commit;
h=911e1c9b05a8e3559a7aa89083930700a0b9e7ee
(PCI: export SMBIOS provided firmware instance and label to sysfs)

cat /sys/class/net/ethN/device/label
Embedded NIC N

Next step would be to enable applications to support the firmware
names.

With the patch below, Iproute2 can support firmware labels like
"Embedded NIC 1". We can refer to the network interfaces with firmware
names as labeled on the system chassis. With this "Embedded NIC 1"
would always refer to the 'integrated NIC port 1' on the system chassis.

Requirements -

1. Package be linked to libnetdevname library which maps firmware names
to kernel names. It is available here -

git clone http://linux.dell.com/git/libnetdevname.git

2. The kernel patch mentioned above.

Please let us know your views on this approach and if acceptable,
please consider this patch for inclusion.


From: Narendra K <narendra_k@dell.com>
Subject: [PATCH] Add firmware label support to iproute2

This patch enables iproute2 to support firmware provided
labels for network devices. Ex:

/sbin/ip maddr show dev "Embedded NIC N"
/sbin/ip addr show dev "Embedded NIC N"

/sbin/tc qdisc add dev "Embedded NIC N" root tbf rate Xkbit \
latency Yms burst 1540

The patch makes calls to libnetdevname library which maps
the "Embedded NIC N" names to ethN kernel names.

This makes sure that above commands that use "Embedded NIC 1" as
the dev argument, will refer to the integrated port 1 on the
chassis label.

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 Makefile       |    5 +++++
 ip/ipaddress.c |   14 ++++++++++++++
 ip/iplink.c    |   14 ++++++++++++++
 ip/ipmaddr.c   |   18 ++++++++++++++++++
 lib/ll_map.c   |   16 ++++++++++++++++
 tc/f_fw.c      |   15 +++++++++++++++
 tc/tc_class.c  |   25 +++++++++++++++++++++++++
 tc/tc_filter.c |   25 +++++++++++++++++++++++++
 tc/tc_qdisc.c  |   24 ++++++++++++++++++++++++
 9 files changed, 156 insertions(+), 0 deletions(-)

diff --git a/Makefile b/Makefile
index 77a85c6..ee82640 100644
--- a/Makefile
+++ b/Makefile
@@ -35,6 +35,11 @@ YACCFLAGS = -d -t -v
 
 LDLIBS += -L../lib -lnetlink -lutil
 
+ifeq ($(shell test -L /usr/local/lib/libnetdevname.so; echo $$?),0)
+LDLIBS +=-lnetdevname
+DEFINES += -DLIBNETDEVNAME_PRESENT
+endif
+
 SUBDIRS=lib ip tc misc netem genl
 
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3a411b1..6fafa2e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -28,6 +28,10 @@
 #include <linux/if_arp.h>
 #include <linux/sockios.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#endif
+
 #include "rt_names.h"
 #include "utils.h"
 #include "ll_map.h"
@@ -712,6 +716,10 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 	char *filter_dev = NULL;
 	int no_link = 0;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	ipaddr_reset_filter(oneline);
 	filter.showqueue = 1;
 
@@ -787,7 +795,13 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				usage();
 			if (filter_dev)
 				duparg2("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			filter_dev = *argv;
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			filter_dev = kernel_name;
+#endif
 		}
 		argv++; argc--;
 	}
diff --git a/ip/iplink.c b/ip/iplink.c
index cb2c4f5..e9f70e2 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -28,6 +28,10 @@
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#endif
+
 #include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
@@ -703,6 +707,10 @@ static int do_set(int argc, char **argv)
 	char *newname = NULL;
 	int htype, halen;
 
+#ifdef	LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	while (argc > 0) {
 		if (strcmp(*argv, "up") == 0) {
 			mask |= IFF_UP;
@@ -798,7 +806,13 @@ static int do_set(int argc, char **argv)
 				usage();
 			if (dev)
 				duparg2("dev", *argv);
+#ifndef	LIBNETDEVNAME_PRESENT
 			dev = *argv;
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			dev = kernel_name;
+#endif
 		}
 		argc--; argv++;
 	}
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 44ffdfc..b5c8380 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -26,6 +26,10 @@
 #include <linux/if_arp.h>
 #include <linux/sockios.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#endif
+
 #include "rt_names.h"
 #include "utils.h"
 
@@ -245,6 +249,9 @@ static int multiaddr_list(int argc, char **argv)
 {
 	struct ma_info *list = NULL;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
 	if (!filter.family)
 		filter.family = preferred_family;
 
@@ -257,7 +264,13 @@ static int multiaddr_list(int argc, char **argv)
 				usage();
 			if (filter.dev)
 				duparg2("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			filter.dev = *argv;
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			filter.dev = kernel_name;
+#endif
 		}
 		argv++; argc--;
 	}
@@ -289,7 +302,12 @@ int multiaddr_modify(int cmd, int argc, char **argv)
 			NEXT_ARG();
 			if (ifr.ifr_name[0])
 				duparg("dev", *argv);
+#ifndef	LIBNETDEVNAME_PRESENT
 			strncpy(ifr.ifr_name, *argv, IFNAMSIZ);
+#else
+			if (netdev_alias_to_kernelname(*argv, ifr.ifr_name) < 0)
+				show_firmware_alias_usage(*argv);
+#endif
 		} else {
 			if (matches(*argv, "address") == 0) {
 				NEXT_ARG();
diff --git a/lib/ll_map.c b/lib/ll_map.c
index b8b49aa..1476255 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -19,9 +19,15 @@
 #include <netinet/in.h>
 #include <string.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#include <linux/if.h>
+#endif
+
 #include "libnetlink.h"
 #include "ll_map.h"
 
+
 extern unsigned int if_nametoindex (const char *);
 
 struct idxmap
@@ -163,8 +169,18 @@ unsigned ll_name_to_index(const char *name)
 	int i;
 	unsigned idx;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
 	if (name == NULL)
 		return 0;
+
+#ifdef LIBNETDEVNAME_PRESENT
+	if (netdev_alias_to_kernelname(name, kernel_name) < 0)
+		show_firmware_alias_usage(name);
+	strncpy(name, kernel_name, IFNAMSIZ);
+#endif
+
 	if (icache && strcmp(name, ncache) == 0)
 		return icache;
 	for (i=0; i<16; i++) {
diff --git a/tc/f_fw.c b/tc/f_fw.c
index 219b404..244bc8a 100644
--- a/tc/f_fw.c
+++ b/tc/f_fw.c
@@ -20,6 +20,11 @@
 #include <arpa/inet.h>
 #include <string.h>
 #include <linux/if.h> /* IFNAMSIZ */
+
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#endif
+
 #include "utils.h"
 #include "tc_util.h"
 
@@ -39,6 +44,10 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 	__u32 mask = 0;
 	int mask_set = 0;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&tp, 0, sizeof(tp));
 
 	if (handle) {
@@ -100,7 +109,13 @@ static int fw_parse_opt(struct filter_util *qu, char *handle, int argc, char **a
 				fprintf(stderr, "Illegal indev\n");
 				return -1;
 			}
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof (d) - 1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 			addattr_l(n, MAX_MSG, TCA_FW_INDEV, d, strlen(d) + 1);
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 9d4eea5..bff90f8 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -21,6 +21,11 @@
 #include <string.h>
 #include <math.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#include <linux/if.h>
+#endif
+
 #include "utils.h"
 #include "tc_util.h"
 #include "tc_common.h"
@@ -52,6 +57,10 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
 	char  d[16];
 	char  k[16];
 
+#ifdef	LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&req, 0, sizeof(req));
 	memset(&est, 0, sizeof(est));
 	memset(d, 0, sizeof(d));
@@ -67,7 +76,13 @@ int tc_class_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (d[0])
 				duparg("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 		} else if (strcmp(*argv, "classid") == 0) {
 			__u32 handle;
 			NEXT_ARG();
@@ -237,6 +252,10 @@ int tc_class_list(int argc, char **argv)
 	struct tcmsg t;
 	char d[16];
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&t, 0, sizeof(t));
 	t.tcm_family = AF_UNSPEC;
 	memset(d, 0, sizeof(d));
@@ -246,7 +265,13 @@ int tc_class_list(int argc, char **argv)
 			NEXT_ARG();
 			if (d[0])
 				duparg("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 		} else if (strcmp(*argv, "qdisc") == 0) {
 			NEXT_ARG();
 			if (filter_qdisc)
diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 919c57c..e144f9d 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -21,6 +21,11 @@
 #include <string.h>
 #include <linux/if_ether.h>
 
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#include <linux/if.h>
+#endif
+
 #include "rt_names.h"
 #include "utils.h"
 #include "tc_util.h"
@@ -61,6 +66,10 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 	char  k[16];
 	struct tc_estimator est;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&req, 0, sizeof(req));
 	memset(&est, 0, sizeof(est));
 	memset(d, 0, sizeof(d));
@@ -80,7 +89,13 @@ int tc_filter_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (d[0])
 				duparg("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 		} else if (strcmp(*argv, "root") == 0) {
 			if (req.t.tcm_parent) {
 				fprintf(stderr, "Error: \"root\" is duplicate parent ID\n");
@@ -268,6 +283,10 @@ int tc_filter_list(int argc, char **argv)
 	__u32 protocol = 0;
 	char *fhandle = NULL;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&t, 0, sizeof(t));
 	t.tcm_family = AF_UNSPEC;
 	memset(d, 0, sizeof(d));
@@ -277,7 +296,13 @@ int tc_filter_list(int argc, char **argv)
 			NEXT_ARG();
 			if (d[0])
 				duparg("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 		} else if (strcmp(*argv, "root") == 0) {
 			if (t.tcm_parent) {
 				fprintf(stderr, "Error: \"root\" is duplicate parent ID\n");
diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index c7f2988..3a9b05c 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -21,6 +21,10 @@
 #include <string.h>
 #include <math.h>
 #include <malloc.h>
+#ifdef LIBNETDEVNAME_PRESENT
+#include <netdevname.h>
+#include <linux/if.h>
+#endif
 
 #include "utils.h"
 #include "tc_util.h"
@@ -60,6 +64,10 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 		char   			buf[TCA_BUF_MAX];
 	} req;
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&req, 0, sizeof(req));
 	memset(&stab, 0, sizeof(stab));
 	memset(&est, 0, sizeof(est));
@@ -76,7 +84,13 @@ int tc_qdisc_modify(int cmd, unsigned flags, int argc, char **argv)
 			NEXT_ARG();
 			if (d[0])
 				duparg("dev", *argv);
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 		} else if (strcmp(*argv, "handle") == 0) {
 			__u32 handle;
 			if (req.t.tcm_handle)
@@ -282,6 +296,10 @@ int tc_qdisc_list(int argc, char **argv)
 	struct tcmsg t;
 	char d[16];
 
+#ifdef LIBNETDEVNAME_PRESENT
+	char kernel_name[IFNAMSIZ];
+#endif
+
 	memset(&t, 0, sizeof(t));
 	t.tcm_family = AF_UNSPEC;
 	memset(&d, 0, sizeof(d));
@@ -289,7 +307,13 @@ int tc_qdisc_list(int argc, char **argv)
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
+#ifndef LIBNETDEVNAME_PRESENT
 			strncpy(d, *argv, sizeof(d)-1);
+#else
+			if (netdev_alias_to_kernelname(*argv, kernel_name) < 0)
+				show_firmware_alias_usage(*argv);
+			strncpy(d, kernel_name, sizeof (d) - 1);
+#endif
 #ifdef TC_H_INGRESS
                 } else if (strcmp(*argv, "ingress") == 0) {
                              if (t.tcm_parent) {
-- 
1.7.0.1

With regards,
Narendra K
