From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/2] Module for ip utility to support veth device
Date: Thu, 19 Jul 2007 13:33:56 +0400
Message-ID: <469F3004.8020501@openvz.org>
References: <469F2DE7.9090407@openvz.org> <469F2F30.5080602@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:5694 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932817AbXGSJeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 05:34:05 -0400
In-Reply-To: <469F2F30.5080602@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The link_veth.so itself.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Patrick McHardy <kaber@trash.net>

---

 Makefile    |    6 ++++-
 link_veth.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 veth.h      |   12 +++++++++++
 3 files changed, 80 insertions(+), 1 deletion(-)

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
index 0000000..ded2cdd
--- /dev/null
+++ b/ip/link_veth.c
@@ -0,0 +1,63 @@
+/*
+ * link_veth.c	veth driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Pavel Emelianov <xemul@openvz.org>
+ *
+ */
+
+#include <string.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "veth.h"
+
+#define	IFNAMSIZ	16
+
+static void usage(void)
+{
+	printf("Usage: ip link add ... type veth "
+			"[peer <peer-name>] [mac <mac>] [peer_mac <mac>]\n");
+}
+
+static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
+		struct nlmsghdr *hdr)
+{
+	char *name, *type, *link, *dev;
+	int err, len;
+	struct rtattr * data;
+
+	if (strcmp(argv[0], "peer") != 0) {
+		usage();
+		return -1;
+	}
+
+	data = NLMSG_TAIL(hdr);
+	addattr_l(hdr, 1024, VETH_INFO_PEER, NULL, 0);
+
+	hdr->nlmsg_len += sizeof(struct ifinfomsg);
+
+	err = iplink_parse(argc - 1, argv + 1, (struct iplink_req *)hdr,
+			&name, &type, &link, &dev);
+	if (err < 0)
+		return err;
+
+	if (name) {
+		len = strlen(name) + 1;
+		if (len > IFNAMSIZ)
+			invarg("\"name\" too long\n", *argv);
+		addattr_l(hdr, 1024, IFLA_IFNAME, name, len);
+	}
+
+	data->rta_len = (void *)NLMSG_TAIL(hdr) - (void *)data;
+	return argc - 1 - err;
+}
+
+struct link_util veth_link_util = {
+	.id = "veth",
+	.parse_opt = veth_parse_opt,
+};
diff --git a/ip/veth.h b/ip/veth.h
new file mode 100644
index 0000000..aa2e6f9
--- /dev/null
+++ b/ip/veth.h
@@ -0,0 +1,12 @@
+#ifndef __NET_VETH_H__
+#define __NET_VETH_H__
+
+enum {
+	VETH_INFO_UNSPEC,
+	VETH_INFO_PEER,
+
+	__VETH_INFO_MAX
+#define VETH_INFO_MAX	(__VETH_INFO_MAX - 1)
+};
+
+#endif
