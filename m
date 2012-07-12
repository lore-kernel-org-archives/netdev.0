From: hamid jafarian <hamid.jafarian@pdnsoft.com>
Subject: [PATCH iproute2] Ability to compile iproute2 as shared library
Date: Thu, 12 Jul 2012 16:14:54 +0430
Message-ID: <1342093501.19963.11.camel@gol>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-N0lUE7XsVY0nmWumH9AS"
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static.32.95.40.188.clients.your-server.de ([188.40.95.32]:60628
	"EHLO host4drupal.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab2GLLy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 07:54:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-N0lUE7XsVY0nmWumH9AS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

Hi,

This is a try with minimum changes to compile iproute2 as shared
library.
Some functions would be used when we compile iproute2 as
shared library has been defined in "ip.c".
Also NICs caching strategy has been changed because, when we use
"libiproute2.so", system NIC list may change, so we should
re-cache all NICs at each call to NIC manipulation functions.
Also some call of "exit(*)" changed to "return *".
HOWTO Make: # export LIBIPROUTE2_SO=y; make

in attached files there is a simple wrapper to work with 
libiproute2.so ...

---
 ip/Makefile  |   13 ++++++++++++-
 ip/ip.c      |   40 ++++++++++++++++++++++++++++++++++++++++
 ip/iproute.c |    2 +-
 lib/Makefile |    3 +++
 lib/ll_map.c |   25 ++++++++++++++++++++++++-
 lib/utils.c  |    7 ++++---
 6 files changed, 84 insertions(+), 6 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index e029ea1..23fc22f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -13,14 +13,25 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(LIBIPROUTE2_SO), y))
+	CFLAGS += -fPIC -DLIBIPROUTE2_SO
+endif
+
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
-TARGETS=ip rtmon
+
+ifeq ($(LIBIPROUTE2_SO), y)
+	TARGETS=libiproute2.so rtmon
+else
+	TARGETS=ip rtmon	
+endif
 
 all: $(TARGETS) $(SCRIPTS)
 
 ip: $(IPOBJ) $(LIBNETLINK)
 
+libiproute2.so: $(IPOBJ) $(LIBNETLINK)
+	$(CC) $(CFLAGS) -shared $(IPOBJ) $(LIBNETLINK) -o $(@)
 
 rtmon: $(RTMONOBJ)
 
diff --git a/ip/ip.c b/ip/ip.c
index 20dc3b5..d5c7b2f 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -87,6 +87,44 @@ static const struct cmd {
 	{ 0 }
 };
 
+#ifdef LIBIPROUTE2_SO
+int do_ipinit()
+{
+
+	if (rtnl_open(&rth, 0) < 0)
+		return 1;
+	_SL_="\n";
+	return 0;
+}
+
+int do_ipfini()
+{
+	rtnl_close(&rth);
+	return 0;
+}
+
+void do_ipflushloop(int loop)
+{
+	max_flush_loops = loop;
+}
+
+int do_ipfamily(char *family)
+{
+	if (strcmp(family, "inet") == 0)
+		preferred_family = AF_INET;
+	else if (strcmp(family, "inet6") == 0)
+		preferred_family = AF_INET6;
+	else if (strcmp(family, "dnet") == 0)
+		preferred_family = AF_DECnet;
+	else if (strcmp(family, "link") == 0)
+		preferred_family = AF_PACKET;
+	else if (strcmp(family, "ipx") == 0)
+		preferred_family = AF_IPX;
+	else return -1;
+	return 0;
+}
+#endif //#ifdef LIBIPROUTE2_SO
+
 static int do_cmd(const char *argv0, int argc, char **argv)
 {
 	const struct cmd *c;
@@ -101,6 +139,7 @@ static int do_cmd(const char *argv0, int argc, char
**argv)
 	return EXIT_FAILURE;
 }
 
+#ifndef LIBIPROUTE2_SO
 static int batch(const char *name)
 {
 	char *line = NULL;
@@ -264,3 +303,4 @@ int main(int argc, char **argv)
 	rtnl_close(&rth);
 	usage();
 }
+#endif //#ifndef LIBIPROUTE2_SO
diff --git a/ip/iproute.c b/ip/iproute.c
index 5cd313e..8ae253b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1012,7 +1012,7 @@ int iproute_modify(int cmd, unsigned flags, int
argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return 2;
 
 	return 0;
 }
diff --git a/lib/Makefile b/lib/Makefile
index da2f0fc..aa9a10f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,4 +1,7 @@
 CFLAGS += -fPIC
+ifeq ($(LIBIPROUTE2_SO), y))
+	CFLAGS += -DLIBIPROUTE2_SO
+endif
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 
diff --git a/lib/ll_map.c b/lib/ll_map.c
index 1ca781e..6923511 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -172,15 +172,18 @@ unsigned ll_name_to_index(const char *name)
 
 	if (name == NULL)
 		return 0;
-
+#ifndef LIBIPROUTE2_SO
 	if (icache && strcmp(name, ncache) == 0)
 		return icache;
+#endif
 
 	for (i=0; i<IDXMAP_SIZE; i++) {
 		for (im = idx_head[i]; im; im = im->idx_next) {
 			if (strcmp(im->name, name) == 0) {
+#ifndef LIBIPROUTE2_SO
 				icache = im->index;
 				strcpy(ncache, name);
+#endif
 				return im->index;
 			}
 		}
@@ -192,12 +195,32 @@ unsigned ll_name_to_index(const char *name)
 	return idx;
 }
 
+#ifdef LIBIPROUTE2_SO
+int ll_free_map()
+{
+	int i;
+	struct ll_cache *im, *imt;
+	for (i=0; i<IDXMAP_SIZE; i++) {
+		for (im = idx_head[i]; im; im = imt) {
+			imt = im->idx_next;
+			free(im);
+		}
+		idx_head[i] = NULL;
+	}
+	return 0;
+}
+#endif
+
 int ll_init_map(struct rtnl_handle *rth)
 {
 	static int initialized;
 
+#ifdef LIBIPROUTE2_SO
+	ll_free_map();
+#else
 	if (initialized)
 		return 0;
+#endif
 
 	if (rtnl_wilddump_request(rth, AF_UNSPEC, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
diff --git a/lib/utils.c b/lib/utils.c
index d80f79b..6b7cdee 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -330,6 +330,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int
family)
 	int err;
 	unsigned plen;
 	char *slash;
+	char *addr = arg;
 
 	memset(dst, 0, sizeof(*dst));
 
@@ -346,9 +347,9 @@ int get_prefix_1(inet_prefix *dst, char *arg, int
family)
 
 	slash = strchr(arg, '/');
 	if (slash)
-		*slash = 0;
+		addr = strndup(arg, slash - arg);
 
-	err = get_addr_1(dst, arg, family);
+	err = get_addr_1(dst, addr, family);
 	if (err == 0) {
 		switch(dst->family) {
 			case AF_INET6:
@@ -373,7 +374,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int
family)
 	}
 done:
 	if (slash)
-		*slash = '/';
+		free(addr);
 	return err;
 }
 
-- 
1.7.6.4


--=-N0lUE7XsVY0nmWumH9AS
Content-Disposition: attachment;
	filename="0001-Ability-to-compile-iproute2-as-shared-library.patch"
Content-Type: text/x-patch;
	name="0001-Ability-to-compile-iproute2-as-shared-library.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 623097d32e26f51aca72bcd75979c187f656b4ff Mon Sep 17 00:00:00 2001
From: "Hamid Jafarian (hm.t.)" <hamid@pdnsoft.com>
Date: Thu, 12 Jul 2012 15:26:20 +0430
Subject: [PATCH] Ability to compile iproute2 as shared library

This is a try with minimum changes to compile iproute2 as shared
library.
Some functions would be used when we compile iproute2 as
shared library has been defined in "ip.c".
Also NICs caching strategy has been changed because, when we use
"libiproute2.so", system NIC list may change, so we should
re-cache all NICs at each call to NIC manipulation functions.
Also some call of "exit(*)" changed to "return *".
HOWTO Make: # export LIBIPROUTE2_SO=y; make
---
 ip/Makefile  |   13 ++++++++++++-
 ip/ip.c      |   40 ++++++++++++++++++++++++++++++++++++++++
 ip/iproute.c |    2 +-
 lib/Makefile |    3 +++
 lib/ll_map.c |   25 ++++++++++++++++++++++++-
 lib/utils.c  |    7 ++++---
 6 files changed, 84 insertions(+), 6 deletions(-)

diff --git a/ip/Makefile b/ip/Makefile
index e029ea1..23fc22f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -13,14 +13,25 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(LIBIPROUTE2_SO), y))
+	CFLAGS += -fPIC -DLIBIPROUTE2_SO
+endif
+
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
-TARGETS=ip rtmon
+
+ifeq ($(LIBIPROUTE2_SO), y)
+	TARGETS=libiproute2.so rtmon
+else
+	TARGETS=ip rtmon	
+endif
 
 all: $(TARGETS) $(SCRIPTS)
 
 ip: $(IPOBJ) $(LIBNETLINK)
 
+libiproute2.so: $(IPOBJ) $(LIBNETLINK)
+	$(CC) $(CFLAGS) -shared $(IPOBJ) $(LIBNETLINK) -o $(@)
 
 rtmon: $(RTMONOBJ)
 
diff --git a/ip/ip.c b/ip/ip.c
index 20dc3b5..d5c7b2f 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -87,6 +87,44 @@ static const struct cmd {
 	{ 0 }
 };
 
+#ifdef LIBIPROUTE2_SO
+int do_ipinit()
+{
+
+	if (rtnl_open(&rth, 0) < 0)
+		return 1;
+	_SL_="\n";
+	return 0;
+}
+
+int do_ipfini()
+{
+	rtnl_close(&rth);
+	return 0;
+}
+
+void do_ipflushloop(int loop)
+{
+	max_flush_loops = loop;
+}
+
+int do_ipfamily(char *family)
+{
+	if (strcmp(family, "inet") == 0)
+		preferred_family = AF_INET;
+	else if (strcmp(family, "inet6") == 0)
+		preferred_family = AF_INET6;
+	else if (strcmp(family, "dnet") == 0)
+		preferred_family = AF_DECnet;
+	else if (strcmp(family, "link") == 0)
+		preferred_family = AF_PACKET;
+	else if (strcmp(family, "ipx") == 0)
+		preferred_family = AF_IPX;
+	else return -1;
+	return 0;
+}
+#endif //#ifdef LIBIPROUTE2_SO
+
 static int do_cmd(const char *argv0, int argc, char **argv)
 {
 	const struct cmd *c;
@@ -101,6 +139,7 @@ static int do_cmd(const char *argv0, int argc, char **argv)
 	return EXIT_FAILURE;
 }
 
+#ifndef LIBIPROUTE2_SO
 static int batch(const char *name)
 {
 	char *line = NULL;
@@ -264,3 +303,4 @@ int main(int argc, char **argv)
 	rtnl_close(&rth);
 	usage();
 }
+#endif //#ifndef LIBIPROUTE2_SO
diff --git a/ip/iproute.c b/ip/iproute.c
index 5cd313e..8ae253b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1012,7 +1012,7 @@ int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		exit(2);
+		return 2;
 
 	return 0;
 }
diff --git a/lib/Makefile b/lib/Makefile
index da2f0fc..aa9a10f 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,4 +1,7 @@
 CFLAGS += -fPIC
+ifeq ($(LIBIPROUTE2_SO), y))
+	CFLAGS += -DLIBIPROUTE2_SO
+endif
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 
diff --git a/lib/ll_map.c b/lib/ll_map.c
index 1ca781e..6923511 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -172,15 +172,18 @@ unsigned ll_name_to_index(const char *name)
 
 	if (name == NULL)
 		return 0;
-
+#ifndef LIBIPROUTE2_SO
 	if (icache && strcmp(name, ncache) == 0)
 		return icache;
+#endif
 
 	for (i=0; i<IDXMAP_SIZE; i++) {
 		for (im = idx_head[i]; im; im = im->idx_next) {
 			if (strcmp(im->name, name) == 0) {
+#ifndef LIBIPROUTE2_SO
 				icache = im->index;
 				strcpy(ncache, name);
+#endif
 				return im->index;
 			}
 		}
@@ -192,12 +195,32 @@ unsigned ll_name_to_index(const char *name)
 	return idx;
 }
 
+#ifdef LIBIPROUTE2_SO
+int ll_free_map()
+{
+	int i;
+	struct ll_cache *im, *imt;
+	for (i=0; i<IDXMAP_SIZE; i++) {
+		for (im = idx_head[i]; im; im = imt) {
+			imt = im->idx_next;
+			free(im);
+		}
+		idx_head[i] = NULL;
+	}
+	return 0;
+}
+#endif
+
 int ll_init_map(struct rtnl_handle *rth)
 {
 	static int initialized;
 
+#ifdef LIBIPROUTE2_SO
+	ll_free_map();
+#else
 	if (initialized)
 		return 0;
+#endif
 
 	if (rtnl_wilddump_request(rth, AF_UNSPEC, RTM_GETLINK) < 0) {
 		perror("Cannot send dump request");
diff --git a/lib/utils.c b/lib/utils.c
index d80f79b..6b7cdee 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -330,6 +330,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 	int err;
 	unsigned plen;
 	char *slash;
+	char *addr = arg;
 
 	memset(dst, 0, sizeof(*dst));
 
@@ -346,9 +347,9 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 
 	slash = strchr(arg, '/');
 	if (slash)
-		*slash = 0;
+		addr = strndup(arg, slash - arg);
 
-	err = get_addr_1(dst, arg, family);
+	err = get_addr_1(dst, addr, family);
 	if (err == 0) {
 		switch(dst->family) {
 			case AF_INET6:
@@ -373,7 +374,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 	}
 done:
 	if (slash)
-		*slash = '/';
+		free(addr);
 	return err;
 }
 
-- 
1.7.6.4


--=-N0lUE7XsVY0nmWumH9AS
Content-Disposition: attachment; filename="ipw.c"
Content-Type: text/x-csrc; name="ipw.c"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

#include "ipw.h"

int ip_initialize()
{
	return do_ipinit();
}

int ip_finalize()
{
	return do_ipfini();
}

int ip_setflushloop(int loop)
{
	do_ipflushloop(loop);
}

int ip_nicAddVLAN(const char *dev, int vlanID)
{
	char vlan[5];
	char vlanDevice[15];
	const char *argv[10];

	sprintf(vlan, "%d", vlanID);
	sprintf(vlanDevice, "%s.%d", dev, vlanID);
	argv[0] = "add"; //command
	argv[1] = "link";
	argv[2] = dev;
	argv[3] = "name";
	argv[4] = vlanDevice;
	argv[5] = "type";
	argv[6] = "vlan";
	argv[7] = "id";
	argv[8] = vlan;
	argv[9] = NULL;

	return do_iplink(9, (char **)argv);
}

int ip_nicDelVLAN(const char *dev)
{
	const char *argv[5];
	argv[0] = "delete";
	argv[1] = dev;
	argv[2] = "type";
	argv[3] = "vlan";
	argv[4] = NULL;

	return do_iplink(4, (char **)argv);
}

int ip_nicAddAddress(const char *dev, const char *family, const char *ifaddr, 
				const char *broadcast, const char *anycast)
{
	const char *argv[9];
	int i = 0;

	argv[i++] = "add";
	argv[i++] = ifaddr;
	if (broadcast != NULL) {
		argv[i++] = "broadcast";
		argv[i++] = broadcast;
	}
	if (anycast != NULL) {
		argv[i++] = "anycast";
		argv[i++] = anycast;
	}
	argv[i++] = "dev";
	argv[i++] = dev;
	argv[i++] = NULL;

	if (do_ipfamily(family)) return -1;
	return do_ipaddr(i - 1, (char **)argv);
}

int ip_nicDelAddress(const char *dev, const char *family, const char *ifaddr,
				const char *broadcast, const char *anycast)
{
	const char *argv[9];
	int i = 0;

	argv[i++] = "del";
	argv[i++] = ifaddr;
	if (broadcast != NULL) {
		argv[i++] = "broadcast";
		argv[i++] = broadcast;
	}
	if (anycast != NULL) {
		argv[i++] = "anycast";
		argv[i++] = anycast;
	}
	argv[i++] = "dev";
	argv[i++] = dev;
	argv[i++] = NULL;

	if (do_ipfamily(family)) return -1;
	return do_ipaddr(i - 1, (char **)argv);
}

int ip_nicFlushAddresses(const char *dev)
{
	const char *argv[4];
	argv[0] = "flush";
	argv[1] = "dev";
	argv[2] = dev;
	argv[3] = NULL;

	return do_ipaddr(3, (char **)argv);
}

int ip_nicSetMTU(const char *dev, const char *mtu)
{
	const char *argv[5];
	argv[0] = "set";
	argv[1] = dev;
	argv[2] = "mtu";
	argv[3] = mtu;
	argv[4] = NULL;

	return do_iplink(4, (char **)argv);
}

int ip_nicSetMulticast(const char *dev, unsigned short do_enable)
{
	const char *argv[5];
	argv[0] = "set";
	argv[1] = dev;
	argv[2] = "multicast";
	argv[3] = (do_enable)? "on" : "off";
	argv[4] = NULL;

	return do_iplink(4, (char **)argv);
}

int ip_nicSetAllMulticast(const char *dev, unsigned short do_enable)
{
	const char *argv[5];
	argv[0] = "set";
	argv[1] = dev;
	argv[2] = "allmulticast";
	argv[3] = (do_enable)? "on" : "off";
	argv[4] = NULL;

	return do_iplink(4, (char **)argv);
}

int ip_nicSetARP(const char *dev, unsigned short do_enable)
{
	const char *argv[5];
	argv[0] = "set";
	argv[1] = dev;
	argv[2] = "arp";
	argv[3] = (do_enable)? "on" : "off";
	argv[4] = NULL;

	return do_iplink(4, (char **)argv);
}

int ip_nicChangeState(const char *dev, unsigned short do_up)
{
	const char *argv[4];
	argv[0] = "set";
	argv[1] = dev;
	argv[2] = (do_up)? "up" : "down";
	argv[3] = NULL;

	return do_iplink(3, (char **)argv);
}

int ip_rtAdd(const struct RouteInfo *ri)
{
	const char *argv[26];
	argv[0] = "add";
	int num = _ip_rtArgv(ri, argv + 1);

	return do_iproute(num + 1, (char **)argv);
}

int ip_rtDel(const struct RouteInfo *ri)
{
	const char *argv[26];
	argv[0] = "del";
	int num = _ip_rtArgv(ri, argv + 1);

	return do_iproute(num + 1, (char **)argv);
}

int ip_rtRep(const struct RouteInfo *ri)
{
	const char *argv[26];
	argv[0] = "replace";
	int num = _ip_rtArgv(ri, argv + 1);

	return do_iproute(num + 1, (char **)argv);
}

int _ip_rtArgv(const struct RouteInfo *ri, const char **argv)
{
	int i = 0;

	if (ri->rt_type)
		argv[i++] = ri->rt_type;
	argv[i++] = ri->rt_prefix;
	if (ri->rt_tos) {
		argv[i++] = "tos";
		argv[i++] = ri->rt_tos;
	}
	if (ri->rt_table) {
		argv[i++] = "table";
		argv[i++] = ri->rt_table;
	}
	if (ri->rt_scope) {
		argv[i++] = "scope";
		argv[i++] = ri->rt_scope;
	}
	if (ri->rt_metric) {
		argv[i++] = "metric";
		argv[i++] = ri->rt_metric;
	}
	if (ri->rt_preference) {
		argv[i++] = "preference";
		argv[i++] = ri->rt_preference;
	}
	argv[i++] = "via";
	argv[i++] = ri->rt_via;
	argv[i++] = "dev";
	argv[i++] = ri->rt_dev;
	if (ri->rt_weight) {
		argv[i++] = "weight";
		argv[i++] = ri->rt_weight;
	}
	if (ri->rt_mtu) {
		argv[i++] = "mtu";
		if (ri->rt_mtu_lock)
			argv[i++] = "lock";
		argv[i++] = ri->rt_mtu;
	}
	if (ri->rt_tcp_window) {
		argv[i++] = "window";
		argv[i++] = ri->rt_tcp_window;
	}
	argv[i++] = NULL;

	return i - 1;
}

--=-N0lUE7XsVY0nmWumH9AS
Content-Disposition: attachment; filename="ipw.h"
Content-Type: text/x-chdr; name="ipw.h"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

/**
 * \file ipw.h
 * This is a wrapper definition for iproute2 package.
 *
 * \author Hamid Jafarian (hamid.jafarian@pdnsoft.com)
 *
 */
#ifndef _PTOOLS_IPW_H_
#define _PTOOLS_IPW_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include "utils.h"
#include "ip_common.h"

/**
 * Initialize "ip" command environment.
 */
int ip_initialize();
/**
 * Finalize "ip" commnd environment.
 */
int ip_finalize();
/**
 * Set maximum loops of address flush process.
 */
int ip_setflushloop(int loop);
/**
 * Add a vlan device on dev.
 *
 * Name of vlan device would be dev.vlan.
 */
int ip_nicAddVLAN(const char *dev, int vlanID);
/** 
 * Delete vlan device.
 *
 * \param dev is the name of vlan device.
 */
int ip_nicDelVLAN(const char *dev);
/**
 * Add defined address to the interface.
 *
 * \param dev device name.
 * \param family address family, may be inet or inet6.
 * \param ifaddr target address.
 * \param broadcast broadcast address.
 * \param anycast any cast address.
 */
int ip_nicAddAddress(const char *dev, const char *family, const char *ifaddr,
				const char *broadcast, const char *anycast);
/**
 * Delete specified address from device.
 * \see ip_nicAddAddress
 */
int ip_nicDelAddress(const char *dev, const char *family, const char *ifaddr, 
				const char *broadcast, const char *anycast);
/**
 * Delete all of the device addresses.
 */
int ip_nicFlushAddresses(const char *dev);
/**
 * Set mtu of device.
 */
int ip_nicSetMTU(const char *dev, const char *mtu);
/**
 * Set Muticast option of device.
 *
 * \param do_enable "1" means enable and "0" means disable.
 */
int ip_nicSetMulticast(const char *dev, unsigned short do_enable);
/**
 * Set AllMuticast option of device.
 *
 * \param do_enable "1" means enable and "0" means disable.
 */
int ip_nicSetAllMulticast(const char *dev, unsigned short do_enable);
/**
 * Set Arp option of device.
 *
 * \param do_enable "1" means enable and "0" means disable.
 */
int ip_nicSetARP(const char *dev, unsigned short do_enable);
/**
 * Change device state.
 *
 * \param do_up "1" means up and "0" means down.
 */
int ip_nicChangeState(const char *dev, unsigned short do_up);

/**
 * \struct RouteInfo
 *
 * Defines routing information to manage system routes.
 */
struct RouteInfo
{
	const char *rt_type; 
	const char *rt_prefix; 
	const char *rt_tos; 
	const char *rt_table;
	const char *rt_scope;
	const char *rt_metric;
	const char *rt_preference;
	const char *rt_via;
	const char *rt_dev; 
	const char *rt_weight;
	const char *rt_mtu; 
	unsigned short rt_mtu_lock; /* bool: 0:false, 1:true */
	const char *rt_tcp_window;
};
/**
 * Add defined route to system.
 */
int ip_rtAdd(const struct RouteInfo *ri);
/**
 * Delete defined route to system.
 */
int ip_rtDel(const struct RouteInfo *ri);
/**
 * Replace/Add defined route to system.
 */
int ip_rtRep(const struct RouteInfo *ri);
/**
 * Fill ip-route command args.
 */
int _ip_rtArgv(const struct RouteInfo *ri, const char **argv);

#ifdef __cplusplus
} // extern "C"
#endif
#endif // _PTOOLS_IPW_HPP_

--=-N0lUE7XsVY0nmWumH9AS--
