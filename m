From: Pavel Emelianov <xemul@openvz.org>
Subject: [PATCH] Module for ip utility to support veth device (v.2)
Date: Thu, 07 Jun 2007 15:16:34 +0400
Message-ID: <4667E912.3020204@openvz.org>
References: <4667E83E.2060405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Patrick McHardy <kaber@trash.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Kirill Korotaev <dev@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:33572 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836AbXFGLMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 07:12:36 -0400
In-Reply-To: <4667E83E.2060405@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The usage is
# ip link add [name] type veth [peer <name>] [mac <mac>] [peer_mac <mac>]

This version doesn't include the fix for ip/iplink.c as Patrick
said that he had included it into his patches already.

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
diff --git a/ip/link_veth.c b/ip/link_veth.c
new file mode 100644
index 0000000..f2e4079
--- /dev/null
+++ b/ip/link_veth.c
@@ -0,0 +1,86 @@
+/*
+ * ip/link_veth.c
+ *
+ * Virtual ETHernet tunnel supprt.
+ *
+ * Author: Pavel Emelianov <xemul@openvz.org>
+ */
+
+#include <stdio.h>
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
index 0000000..d52e0c5
--- /dev/null
+++ b/ip/veth.h
@@ -0,0 +1,15 @@
+#ifndef __NET_VETH_H__
+#define __NET_VETH_H__
+
+enum {
+	VETH_INFO_UNSPEC,
+	VETH_INFO_MAC,
+	VETH_INFO_PEER,
+	VETH_INFO_PEER_MAC,
+
+	__VETH_INFO_MAX
+};
+
+#define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
+
+#endif
