From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Identify more netlink protocol names
Date: Thu, 30 Oct 2014 17:33:36 +0200
Message-ID: <1414683216-9728-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:46493 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932860AbaJ3Pmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 11:42:45 -0400
Received: by mail-wg0-f49.google.com with SMTP id x13so4543202wgg.36
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 08:42:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There were only few Netlink protocol names
which were printed on the screen:

    rtnl, fw, tcpdiag

So added the ability to identify Netlink proto name
from /etc/iproute/nl_protos or from static table.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 etc/iproute2/nl_protos | 23 ++++++++++++++
 include/rt_names.h     |  2 ++
 lib/rt_names.c         | 82 ++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/ss.c              | 17 ++++++-----
 4 files changed, 116 insertions(+), 8 deletions(-)
 create mode 100644 etc/iproute2/nl_protos

diff --git a/etc/iproute2/nl_protos b/etc/iproute2/nl_protos
new file mode 100644
index 0000000..43418f3
--- /dev/null
+++ b/etc/iproute2/nl_protos
@@ -0,0 +1,23 @@
+# Netlink protocol names mapping
+
+0   rtnl
+1   unused
+2   usersock
+3   fw
+4   tcpdiag
+5   nflog
+6   xfrm
+7   selinux
+8   iscsi
+9   audit
+10  fiblookup
+11  connector
+12  nft 
+13  ip6fw
+14  dec-rt
+15  uevent
+16  genl
+18  scsi-trans
+19  ecryptfs
+20  rdma
+21  crypto 
diff --git a/include/rt_names.h b/include/rt_names.h
index 56b649a..c0ea4f9 100644
--- a/include/rt_names.h
+++ b/include/rt_names.h
@@ -29,5 +29,7 @@ int ll_addr_a2n(char *lladdr, int len, const char *arg);
 const char * ll_proto_n2a(unsigned short id, char *buf, int len);
 int ll_proto_a2n(unsigned short *id, const char *buf);
 
+const char *nl_proto_n2a(int id, char *buf, int len);
+int nl_proto_a2n(__u32 *id, const char *arg);
 
 #endif
diff --git a/lib/rt_names.c b/lib/rt_names.c
index 911e4d2..184f590 100644
--- a/lib/rt_names.c
+++ b/lib/rt_names.c
@@ -525,3 +525,85 @@ const char *rtnl_group_n2a(int id, char *buf, int len)
 	snprintf(buf, len, "%d", id);
 	return buf;
 }
+
+static char *nl_proto_tab[256] = {
+	[NETLINK_ROUTE]          = "rtnl",
+	[NETLINK_UNUSED]         = "unused",
+	[NETLINK_USERSOCK]       = "usersock",
+	[NETLINK_FIREWALL]       = "fw",
+	[NETLINK_SOCK_DIAG]      = "tcpdiag",
+	[NETLINK_NFLOG]          = "nflog",
+	[NETLINK_XFRM]           = "xfrm",
+	[NETLINK_SELINUX]        = "selinux",
+	[NETLINK_ISCSI]          = "iscsi",
+	[NETLINK_AUDIT]          = "audit",
+	[NETLINK_FIB_LOOKUP]     = "fiblookup",
+	[NETLINK_CONNECTOR]      = "connector",
+	[NETLINK_NETFILTER]      = "nft",
+	[NETLINK_IP6_FW]         = "ip6fw",
+	[NETLINK_DNRTMSG]        = "dec-rt",
+	[NETLINK_KOBJECT_UEVENT] = "uevent",
+	[NETLINK_GENERIC]        = "genl",
+	[NETLINK_SCSITRANSPORT]  = "scsi-trans",
+	[NETLINK_ECRYPTFS]       = "ecryptfs",
+	[NETLINK_RDMA]           = "rdma",
+	[NETLINK_CRYPTO]         = "crypto",
+};
+
+static int nl_proto_init;
+
+static void nl_proto_initialize(void)
+{
+	nl_proto_init = 1;
+	rtnl_tab_initialize(CONFDIR "/nl_protos",
+			    nl_proto_tab, 256);
+}
+
+const char *nl_proto_n2a(int id, char *buf, int len)
+{
+	if (id < 0 || id >= 256) {
+		snprintf(buf, len, "%u", id);
+		return buf;
+	}
+
+	if (!nl_proto_init)
+		nl_proto_initialize();
+
+	if (nl_proto_tab[id])
+		return nl_proto_tab[id];
+
+	snprintf(buf, len, "%u", id);
+	return buf;
+}
+
+int nl_proto_a2n(__u32 *id, const char *arg)
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
+	if (!nl_proto_init)
+		nl_proto_initialize();
+
+	for (i = 0; i < 256; i++) {
+		if (nl_proto_tab[i] &&
+		    strcmp(nl_proto_tab[i], arg) == 0) {
+			cache = nl_proto_tab[i];
+			res = i;
+			*id = res;
+			return 0;
+		}
+	}
+
+	res = strtoul(arg, &end, 0);
+	if (!end || end == arg || *end || res > 255)
+		return -1;
+	*id = res;
+	return 0;
+}
diff --git a/misc/ss.c b/misc/ss.c
index b7e0ef0..291d85f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2979,6 +2979,8 @@ static void netlink_show_one(struct filter *f,
 				int rq, int wq,
 				unsigned long long sk, unsigned long long cb)
 {
+	SPRINT_BUF(prot_name);
+
 	if (f->f) {
 		struct tcpstat tst;
 		tst.local.family = AF_NETLINK;
@@ -2996,14 +2998,13 @@ static void netlink_show_one(struct filter *f,
 	if (state_width)
 		printf("%-*s ", state_width, "UNCONN");
 	printf("%-6d %-6d ", rq, wq);
-	if (resolve_services && prot == 0)
-		printf("%*s:", addr_width, "rtnl");
-	else if (resolve_services && prot == 3)
-		printf("%*s:", addr_width, "fw");
-	else if (resolve_services && prot == 4)
-		printf("%*s:", addr_width, "tcpdiag");
-	else
-		printf("%*d:", addr_width, prot);
+
+	if (resolve_services)
+	{
+		printf("%*s:", addr_width, nl_proto_n2a(prot, prot_name,
+					sizeof(prot_name)));
+	}
+
 	if (pid == -1) {
 		printf("%-*s ", serv_width, "*");
 	} else if (resolve_services) {
-- 
2.1.0
