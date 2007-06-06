From: Pavel Emelianov <xemul@openvz.org>
Subject: [PATCH] Module for ip utility to support veth device
Date: Wed, 06 Jun 2007 19:17:19 +0400
Message-ID: <4666CFFF.9020204@openvz.org>
References: <4666CEAA.8010903@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@openvz.org>
To: Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:17499 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758334AbXFFPMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 11:12:41 -0400
In-Reply-To: <4666CEAA.8010903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage is
# ip link add [name] type veth [peer <name>] [mac <mac>] [peer_mac <mac>]

The Makefile is maybe not as beautiful as it could be. It
is to be discussed.

One thing I noticed during testing is the following. When launching
this with link_veth.so module and not specifying any module specific
parameters, the kernel refuses to accept the packet when parsing the
IFLA_LINKINFO. So the hunk for ip/iplink.c doesn't add an empty extra 
header if no extra data expected.

Signed-off-by: Pavel Emelianov <xemul@openvz.org>

---

diff --git a/ip/Makefile b/ip/Makefile
index 9a5bfe3..b46bce3 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -8,8 +8,9 @@ RTMONOBJ=rtmon.o
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
+LIBS=link_veth.so
 
-all: $(TARGETS) $(SCRIPTS)
+all: $(TARGETS) $(SCRIPTS) $(LIBS)
 
 ip: $(IPOBJ) $(LIBNETLINK) $(LIBUTIL)
 
@@ -24,3 +25,6 @@ clean:
 
 LDLIBS	+= -ldl
 LDFLAGS	+= -Wl,-export-dynamic
+
+%.so: %.c
+	$(CC) $(CFLAGS) -shared $< -o $@
diff --git a/ip/iplink.c b/ip/iplink.c
index 5170419..6975990 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -287,7 +287,7 @@ static int iplink_modify(int cmd, unsign
 			 strlen(type));
 
 		lu = get_link_type(type);
-		if (lu) {
+		if (lu && argc) {
 			struct rtattr * data = NLMSG_TAIL(&req.n);
 			addattr_l(&req.n, sizeof(req), IFLA_INFO_DATA, NULL, 0);
 
diff --git a/ip/link_veth.c b/ip/link_veth.c
new file mode 100644
index 0000000..adfdef6
--- /dev/null
+++ b/ip/link_veth.c
@@ -0,0 +1,77 @@
+#include <string.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "veth.h"
+
+#define ETH_ALEN	6
+
+static void usage(void)
+{
+	printf("Usage: ip link add ... "
+			"[peer <peer-name>] [mac <mac>] [peer_mac <mac>]\n");
+}
+
+static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
+		struct nlmsghdr *hdr)
+{
+	__u8 mac[ETH_ALEN];
+
+	for (; argc != 0; argv++, argc--) {
+		if (strcmp(*argv, "peer") == 0) {
+			argv++;
+			argc--;
+			if (argc == 0) {
+				usage();
+				return -1;
+			}
+
+			addattr_l(hdr, 1024, VETH_INFO_PEER,
+					*argv, strlen(*argv));
+
+			continue;
+		}
+
+		if (strcmp(*argv, "mac") == 0) {
+			argv++;
+			argc--;
+			if (argc == 0) {
+				usage();
+				return -1;
+			}
+
+			if (hexstring_a2n(*argv, mac, sizeof(mac)) == NULL)
+				return -1;
+
+			addattr_l(hdr, 1024, VETH_INFO_MAC,
+					mac, ETH_ALEN);
+			continue;
+		}
+
+		if (strcmp(*argv, "peer_mac") == 0) {
+			argv++;
+			argc--;
+			if (argc == 0) {
+				usage();
+				return -1;
+			}
+
+			if (hexstring_a2n(*argv, mac, sizeof(mac)) == NULL)
+				return -1;
+
+			addattr_l(hdr, 1024, VETH_INFO_PEER_MAC,
+					mac, ETH_ALEN);
+			continue;
+		}
+
+		usage();
+		return -1;
+	}
+
+	return 0;
+}
+
+struct link_util veth_link_util = {
+	.id = "veth",
+	.parse_opt = veth_parse_opt,
+};
diff --git a/ip/veth.h b/ip/veth.h
new file mode 100644
index 0000000..74c8e1e
--- /dev/null
+++ b/ip/veth.h
@@ -0,0 +1,13 @@
+#ifndef __NET_VETH_H__
+#define __NET_VETH_H__
+
+enum {
+	VETH_INFO_UNSPEC,
+	VETH_INFO_MAC,
+	VETH_INFO_PEER,
+	VETH_INFO_PEER_MAC,
+
+	VETH_INFO_MAX
+};
+
+#endif
