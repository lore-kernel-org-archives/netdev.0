From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv7 iproute2 2/2] Interface group as new ip link option
Date: Thu, 29 Nov 2007 17:11:49 +0100
Message-ID: <11963527101117-git-send-email-panther@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu>
 <11963527103201-git-send-email-panther@balabit.hu>
 <1196352710402-git-send-email-panther@balabit.hu>
 <11963527101876-git-send-email-panther@balabit.hu>
 <11963527103391-git-send-email-panther@balabit.hu>
 <11963527102332-git-send-email-panther@balabit.hu>
 <11963527101629-git-send-email-panther@balabit.hu>
 <11963527101123-git-send-email-panther@balabit.hu>
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50917 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756773AbXK2QL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 11:11:56 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 88380C1481
	for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 17:11:55 +0100 (CET)
In-Reply-To: <11963527101123-git-send-email-panther@balabit.hu>
In-Reply-To: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
References: <ifgroup-20071129-165736-1196351856-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interfaces can be grouped and each group has an unique positive integer ID.
It can be set via ip link. Symbolic names can be specified in
/etc/iproute2/rt_ifgroup. Any value of unsigned int32 is valid.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c948395..5a2d071 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -79,6 +79,8 @@ enum
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
+	IFLA_IFGROUP,
+#define	IFLA_IFGROUP IFLA_IFGROUP
 	__IFLA_MAX
 };
 
diff --git a/include/rt_names.h b/include/rt_names.h
index 07a10e0..ea2d46a 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -8,11 +8,13 @@ char* rtnl_rtscope_n2a(int id, char *buf, int len);
 char* rtnl_rttable_n2a(__u32 id, char *buf, int len);
 char* rtnl_rtrealm_n2a(int id, char *buf, int len);
 char* rtnl_dsfield_n2a(int id, char *buf, int len);
+char* rtnl_ifgroup_n2a(__u32 id, char *buf, int len);
 int rtnl_rtprot_a2n(__u32 *id, char *arg);
 int rtnl_rtscope_a2n(__u32 *id, char *arg);
 int rtnl_rttable_a2n(__u32 *id, char *arg);
 int rtnl_rtrealm_a2n(__u32 *id, char *arg);
 int rtnl_dsfield_a2n(__u32 *id, char *arg);
+int rtnl_ifgroup_a2n(__u32 *id, char *arg);
 
 const char *inet_proto_n2a(int proto, char *buf, int len);
 int inet_proto_a2n(char *buf);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d1c6620..1ecbe03 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -227,6 +227,10 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		fprintf(fp, "mtu %u ", *(int*)RTA_DATA(tb[IFLA_MTU]));
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", (char*)RTA_DATA(tb[IFLA_QDISC]));
+	if (tb[IFLA_IFGROUP]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "group %s ", rtnl_ifgroup_n2a(*(int*)RTA_DATA(tb[IFLA_IFGROUP]), b1, sizeof(b1)));
+	}
 #ifdef IFLA_MASTER
 	if (tb[IFLA_MASTER]) {
 		SPRINT_BUF(b1);
diff --git a/ip/iplink.c b/ip/iplink.c
index f28f91c..cdef533 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -27,6 +27,7 @@
 #include <string.h>
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
+#include <linux/rtnetlink.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -46,6 +47,7 @@ void iplink_usage(void)
 	fprintf(stderr, "	                     promisc { on | off } |\n");
 	fprintf(stderr, "	                     trailers { on | off } |\n");
 	fprintf(stderr, "	                     txqueuelen PACKETS |\n");
+	fprintf(stderr, "	                     group GROUP |\n");
 	fprintf(stderr, "	                     name NEWNAME |\n");
 	fprintf(stderr, "	                     address LLADDR | broadcast LLADDR |\n");
 	fprintf(stderr, "	                     mtu MTU }\n");
@@ -146,6 +148,7 @@ static int iplink_have_newlink(void)
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	int qlen = -1;
+	__u32 group = 0;
 	int mtu = -1;
 	int len;
 	char abuf[32];
@@ -198,6 +201,14 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
 			addattr_l(&req.n, sizeof(req), IFLA_TXQLEN, &qlen, 4);
+		} else if (matches(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (group != 0)
+				duparg("group", *argv);
+
+			if (rtnl_ifgroup_a2n(&group, *argv))
+				invarg("\"group\" value is invalid\n", *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_IFGROUP, &group, sizeof(group));
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
diff --git a/lib/rt_names.c b/lib/rt_names.c
index 8d019a0..ec6638c 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -439,10 +439,72 @@ int rtnl_dsfield_a2n(__u32 *id, char *arg)
 		}
 	}
 
-	res = strtoul(arg, &end, 16);
+	res = strtoul(arg, &end, 0);
 	if (!end || end == arg || *end || res > 255)
 		return -1;
 	*id = res;
 	return 0;
 }
 
+static char * rtnl_rtifgroup_tab[256] = {
+	"0",
+};
+
+static int rtnl_rtifgroup_init;
+
+static void rtnl_rtifgroup_initialize(void)
+{
+	rtnl_rtifgroup_init = 1;
+	rtnl_tab_initialize("/etc/iproute2/rt_ifgroup",
+			    rtnl_rtifgroup_tab, 256);
+}
+
+char * rtnl_ifgroup_n2a(__u32 id, char *buf, int len)
+{
+	if (id>=256) {
+		snprintf(buf, len, "0x%x", id);
+		return buf;
+	}
+	if (!rtnl_rtifgroup_tab[id]) {
+		if (!rtnl_rtifgroup_init)
+			rtnl_rtifgroup_initialize();
+	}
+	if (rtnl_rtifgroup_tab[id])
+		return rtnl_rtifgroup_tab[id];
+	snprintf(buf, len, "0x%02x", id);
+	return buf;
+}
+
+
+int rtnl_ifgroup_a2n(__u32 *id, char *arg)
+{
+	static char *cache = NULL;
+	static unsigned long res;
+	char *end;
+	int i;
+
+	if (cache && strcmp(cache, arg) == 0) {
+		*id = res;
+		return 0;
+	}
+
+	if (!rtnl_rtifgroup_init)
+		rtnl_rtifgroup_initialize();
+
+	for (i=0; i<256; i++) {
+		if (rtnl_rtifgroup_tab[i] &&
+		    strcmp(rtnl_rtifgroup_tab[i], arg) == 0) {
+			cache = rtnl_rtifgroup_tab[i];
+			res = i;
+			*id = res;
+			return 0;
+		}
+	}
+
+	res = strtoul(arg, &end, 0);
+	if (!end || end == arg || *end)
+		return -1;
+	*id = res;
+	return 0;
+}
+
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 8fd6d52..0338dab 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -511,6 +511,11 @@ already configured.
 change the transmit queue length of the device.
 
 .TP
+.BI group " GROUP"
+.TP 
+change the interface group identifier of the device.
+
+.TP
 .BI mtu " NUMBER"
 change the 
 .I MTU
-- 
1.5.2.5

