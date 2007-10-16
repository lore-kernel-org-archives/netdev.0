From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IPROUTE2 PATCH] Interface group as new ip link option
Date: Tue, 16 Oct 2007 10:01:43 +0200
Message-ID: <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther__40718.1642055095$1192521765$gmane$org@balabit.hu>
References: <1192521703479-git-send-email-panther@balabit.hu>
 <11925217031287-git-send-email-panther@balabit.hu>
 <11925217031728-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11925217031728-git-send-email-panther@balabit.hu>
Message-Id: <a6713ba13c49b7fa20073d8abf1862480c2799e0.1192457385.git.panther@balabit.hu>
In-Reply-To: <ifgroup.20071015.1192520046.panther@balabit.hu>
References: <ifgroup.20071015.1192520046.panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interfaces can be grouped and each group has an unique positive integer ID.
It can be set via ip link.

Signed-off-by: Laszlo Attila Toth <panther@aldaris.(none)>
---
 include/linux/if_link.h |    2 +
 include/rt_names.h      |    2 +
 ip/ipaddress.c          |    4 +++
 ip/iplink.c             |   49 +++++++++++++++++++++++++++++++++++++
 lib/rt_names.c          |   62 +++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip.8           |    8 ++++++
 6 files changed, 127 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 23b3a8e..2dfb0b7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,8 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_IFGROUP,
+#define	IFLA_IFGROUP IFLA_IFGROUP
 	__IFLA_MAX
 };
 
diff --git a/include/rt_names.h b/include/rt_names.h
index 07a10e0..72c5247 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -8,11 +8,13 @@ char* rtnl_rtscope_n2a(int id, char *buf, int len);
 char* rtnl_rttable_n2a(__u32 id, char *buf, int len);
 char* rtnl_rtrealm_n2a(int id, char *buf, int len);
 char* rtnl_dsfield_n2a(int id, char *buf, int len);
+char* rtnl_ifgroup_n2a(int id, char *buf, int len);
 int rtnl_rtprot_a2n(__u32 *id, char *arg);
 int rtnl_rtscope_a2n(__u32 *id, char *arg);
 int rtnl_rttable_a2n(__u32 *id, char *arg);
 int rtnl_rtrealm_a2n(__u32 *id, char *arg);
 int rtnl_dsfield_a2n(__u32 *id, char *arg);
+int rtnl_ifgroup_a2n(__u32 *id, char *arg);
 
 const char *inet_proto_n2a(int proto, char *buf, int len);
 int inet_proto_a2n(char *buf);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 518d8cd..405e85c 100644
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
index 8e0ed2a..87901e7 100644
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
@@ -145,6 +147,7 @@ static int iplink_have_newlink(void)
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	int qlen = -1;
+	__u32 group = 0;
 	int mtu = -1;
 	int len;
 	char abuf[32];
@@ -197,6 +200,14 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
 			addattr_l(&req.n, sizeof(req), IFLA_TXQLEN, &qlen, 4);
+		} else if (matches(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (group != 0)
+				duparg("group", *argv);
+
+			if (rtnl_ifgroup_a2n(&group, *argv) || group == 0)
+				invarg("\"group\" value is invalid\n", *argv);
+			addattr_l(&req.n, sizeof(req), IFLA_IFGROUP, &group, sizeof(group));
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
@@ -462,6 +473,32 @@ static int set_mtu(const char *dev, int mtu)
 	return 0;
 }
 
+static int set_group(const char *dev, int ifgroup)
+{
+	struct {
+		struct nlmsghdr 	n;
+		struct ifinfomsg 	ifi;
+		char   			buf[256];
+	} req;
+	struct rtnl_handle rth;
+	
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.ifi));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_SETLINK;
+	
+	req.ifi.ifi_index = -1;
+	
+	addattr_l(&req.n, sizeof(req), IFLA_IFNAME, dev, strlen(dev)+1);
+	addattr_l(&req.n, sizeof(req), IFLA_IFGROUP, &ifgroup, sizeof(ifgroup));
+	if (rtnl_open(&rth, 0) < 0)
+		exit(1);
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL, NULL, NULL) < 0)
+		return -1;
+	rtnl_close(&rth);
+	return 0;
+}
+
 static int get_address(const char *dev, int *htype)
 {
 	struct ifreq ifr;
@@ -545,6 +582,7 @@ static int do_set(int argc, char **argv)
 	__u32 mask = 0;
 	__u32 flags = 0;
 	int qlen = -1;
+	__u32 group = 0;
 	int mtu = -1;
 	char *newaddr = NULL;
 	char *newbrd = NULL;
@@ -577,6 +615,13 @@ static int do_set(int argc, char **argv)
 				duparg("txqueuelen", *argv);
 			if (get_integer(&qlen,  *argv, 0))
 				invarg("Invalid \"txqueuelen\" value\n", *argv);
+		} else if (matches(*argv, "group") == 0) {
+			NEXT_ARG();
+			if (group != 0)
+				duparg("group", *argv);
+
+			if (rtnl_ifgroup_a2n(&group, *argv) || group == 0)
+				invarg("\"group\" value is invalid\n", *argv);
 		} else if (strcmp(*argv, "mtu") == 0) {
 			NEXT_ARG();
 			if (mtu != -1)
@@ -696,6 +741,10 @@ static int do_set(int argc, char **argv)
 				return -1;
 		}
 	}
+	if (group) {
+		if (set_group(dev, group) < 0)
+			return -1;
+	}
 	if (mask)
 		return do_chflags(dev, flags, mask);
 	return 0;
diff --git a/lib/rt_names.c b/lib/rt_names.c
index 8d019a0..a067e74 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -446,3 +446,65 @@ int rtnl_dsfield_a2n(__u32 *id, char *arg)
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
+char * rtnl_ifgroup_n2a(int id, char *buf, int len)
+{
+	if (id<0 || id>=256) {
+		snprintf(buf, len, "%d", id);
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
+	res = strtoul(arg, &end, 16);
+	if (!end || end == arg || *end || res > 255)
+		return -1;
+	*id = res;
+	return 0;
+}
+
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index c74440a..8e6a9a3 100644
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
@@ -1835,3 +1840,6 @@ was written by Alexey N. Kuznetsov and added in Linux 2.2.
 
 .SH AUTHOR
 Original Manpage  by Michail Litvak <mci@owl.openwall.com>
+.br
+Modified for ZorpOS by Tamas Pal <folti@balabit.hu>
+
-- 
1.5.2.5

