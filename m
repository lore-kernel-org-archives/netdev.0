From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 1/2] iproute2: add libgenl files
Date: Sat,  8 Sep 2012 12:48:24 +0300
Message-ID: <1347097705-2906-2-git-send-email-ja@ssi.bg>
References: <1347097705-2906-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:47834 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752754Ab2IHJpn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 05:45:43 -0400
In-Reply-To: <1347097705-2906-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Create libgenl.h and libgenl.c. They will contain
common code for GENL users such as ipl2tp, tcp_metrics, etc.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/libgenl.h |   25 ++++++++++++++++++++
 lib/Makefile      |    2 +-
 lib/libgenl.c     |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 91 insertions(+), 1 deletions(-)
 create mode 100644 include/libgenl.h
 create mode 100644 lib/libgenl.c

diff --git a/include/libgenl.h b/include/libgenl.h
new file mode 100644
index 0000000..ef455c1
--- /dev/null
+++ b/include/libgenl.h
@@ -0,0 +1,25 @@
+#ifndef __LIBGENL_H__
+#define __LIBGENL_H__
+
+#include "libnetlink.h"
+
+#define GENL_DEFINE_REQUEST(req, hdrsize, bufsiz)			\
+struct {								\
+	struct nlmsghdr		n;					\
+	struct genlmsghdr	g;					\
+	char			buf[NLMSG_ALIGN(hdrsize) + bufsiz];	\
+} req
+
+#define GENL_INIT_REQUEST(req, family, hdrsize, ver, cmd_, flags)	\
+	do {								\
+		memset(&req, 0, sizeof(req));				\
+		req.n.nlmsg_type = family;				\
+		req.n.nlmsg_flags = flags;				\
+		req.n.nlmsg_len = NLMSG_LENGTH(GENL_HDRLEN + hdrsize);	\
+		req.g.cmd = cmd_;					\
+		req.g.version = ver;					\
+	} while (0)
+
+int libgenl_resolve_family(struct rtnl_handle *grth, const char *family);
+
+#endif /* __LIBGENL_H__ */
diff --git a/lib/Makefile b/lib/Makefile
index da2f0fc..bfbe672 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -2,7 +2,7 @@ CFLAGS += -fPIC
 
 UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o
 
-NLOBJ=ll_map.o libnetlink.o
+NLOBJ=libgenl.o ll_map.o libnetlink.o
 
 all: libnetlink.a libutil.a
 
diff --git a/lib/libgenl.c b/lib/libgenl.c
new file mode 100644
index 0000000..c1bf399
--- /dev/null
+++ b/lib/libgenl.c
@@ -0,0 +1,65 @@
+/*
+ * libgenl.c	GENL library
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+
+#include <linux/genetlink.h>
+#include "libgenl.h"
+
+static int libgenl_parse_getfamily(struct nlmsghdr *nlh)
+{
+	struct rtattr *tb[CTRL_ATTR_MAX + 1];
+	struct genlmsghdr *ghdr = NLMSG_DATA(nlh);
+	int len = nlh->nlmsg_len;
+	struct rtattr *attrs;
+
+	if (nlh->nlmsg_type != GENL_ID_CTRL) {
+		fprintf(stderr, "Not a controller message, nlmsg_len=%d "
+			"nlmsg_type=0x%x\n", nlh->nlmsg_len, nlh->nlmsg_type);
+		return -1;
+	}
+
+	len -= NLMSG_LENGTH(GENL_HDRLEN);
+
+	if (len < 0) {
+		fprintf(stderr, "wrong controller message len %d\n", len);
+		return -1;
+	}
+
+	if (ghdr->cmd != CTRL_CMD_NEWFAMILY) {
+		fprintf(stderr, "Unknown controller command %d\n", ghdr->cmd);
+		return -1;
+	}
+
+	attrs = (struct rtattr *) ((char *) ghdr + GENL_HDRLEN);
+	parse_rtattr(tb, CTRL_ATTR_MAX, attrs, len);
+
+	if (tb[CTRL_ATTR_FAMILY_ID] == NULL) {
+		fprintf(stderr, "Missing family id TLV\n");
+		return -1;
+	}
+
+	return rta_getattr_u16(tb[CTRL_ATTR_FAMILY_ID]);
+}
+
+int libgenl_resolve_family(struct rtnl_handle *grth, const char *family)
+{
+	GENL_DEFINE_REQUEST(req, 0, 1024);
+
+	GENL_INIT_REQUEST(req, GENL_ID_CTRL, 0, 0, CTRL_CMD_GETFAMILY,
+			  NLM_F_REQUEST);
+
+	addattr_l(&req.n, 1024, CTRL_ATTR_FAMILY_NAME,
+		  family, strlen(family) + 1);
+
+	if (rtnl_talk(grth, &req.n, 0, 0, &req.n) < 0) {
+		fprintf(stderr, "Error talking to the kernel\n");
+		return -2;
+	}
+
+	return libgenl_parse_getfamily(&req.n);
+}
+
-- 
1.7.3.4
