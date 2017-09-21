From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 2/2] bpf: properly output json for xdp
Date: Thu, 21 Sep 2017 10:42:29 +0200
Message-ID: <e0a30e266c6eb9a5ebe99ee42b3b3dc6fea170f8.1505956723.git.daniel@iogearbox.net>
References: <cover.1505956723.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40233 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdIUImn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 04:42:43 -0400
In-Reply-To: <cover.1505956723.git.daniel@iogearbox.net>
In-Reply-To: <cover.1505956723.git.daniel@iogearbox.net>
References: <cover.1505956723.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After merging net-next branch into master, Stephen asked
to fix up json dump for XDP. Thus, rework the json dump a
bit, such that 'ip -json l' looks as below.

  [{
        "ifindex": 1,
        "ifname": "lo",
        "flags": ["LOOPBACK","UP","LOWER_UP"],
        "mtu": 65536,
        "xdp": {
            "mode": 2,
            "prog": {
                "id": 5,
                "tag": "e1e9d0ec0f55d638",
                "jited": 1
            }
        },
        "qdisc": "noqueue",
        "operstate": "UNKNOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "loopback",
        "address": "00:00:00:00:00:00",
        "broadcast": "00:00:00:00:00:00"
    },[...]
  ]

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ip/iplink_xdp.c | 74 ++++++++++++++++++++++++++++++++++-----------------------
 lib/bpf.c       | 19 ++++++++++-----
 2 files changed, 57 insertions(+), 36 deletions(-)

diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 71f7798..2d2953a 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -14,9 +14,9 @@
 
 #include <linux/bpf.h>
 
+#include "json_print.h"
 #include "xdp.h"
 #include "bpf_util.h"
-#include "ip_common.h"
 
 extern int force;
 
@@ -82,6 +82,22 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
 	return 0;
 }
 
+static void xdp_dump_json(struct rtattr *tb[IFLA_XDP_MAX + 1])
+{
+	__u32 prog_id = 0;
+	__u8 mode;
+
+	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
+	if (tb[IFLA_XDP_PROG_ID])
+		prog_id = rta_getattr_u32(tb[IFLA_XDP_PROG_ID]);
+
+	open_json_object("xdp");
+	print_uint(PRINT_JSON, "mode", NULL, mode);
+	if (prog_id)
+		bpf_dump_prog_info(NULL, prog_id);
+	close_json_object();
+}
+
 void xdp_dump(FILE *fp, struct rtattr *xdp, bool link, bool details)
 {
 	struct rtattr *tb[IFLA_XDP_MAX + 1];
@@ -94,34 +110,32 @@ void xdp_dump(FILE *fp, struct rtattr *xdp, bool link, bool details)
 		return;
 
 	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
-	if (is_json_context()) {
-		print_uint(PRINT_JSON, "attached", NULL, mode);
-	} else {
-		if (mode == XDP_ATTACHED_NONE)
-			return;
-		else if (details && link)
-			fprintf(fp, "%s    prog/xdp", _SL_);
-		else if (mode == XDP_ATTACHED_DRV)
-			fprintf(fp, "xdp");
-		else if (mode == XDP_ATTACHED_SKB)
-			fprintf(fp, "xdpgeneric");
-		else if (mode == XDP_ATTACHED_HW)
-			fprintf(fp, "xdpoffload");
-		else
-			fprintf(fp, "xdp[%u]", mode);
-
-		if (tb[IFLA_XDP_PROG_ID])
-			prog_id = rta_getattr_u32(tb[IFLA_XDP_PROG_ID]);
-		if (!details) {
-			if (prog_id && !link)
-				fprintf(fp, "/id:%u", prog_id);
-			fprintf(fp, " ");
-			return;
-		}
-
-		if (prog_id) {
-			fprintf(fp, " ");
-			bpf_dump_prog_info(fp, prog_id);
-		}
+	if (mode == XDP_ATTACHED_NONE)
+		return;
+	else if (is_json_context())
+		return details ? (void)0 : xdp_dump_json(tb);
+	else if (details && link)
+		fprintf(fp, "%s    prog/xdp", _SL_);
+	else if (mode == XDP_ATTACHED_DRV)
+		fprintf(fp, "xdp");
+	else if (mode == XDP_ATTACHED_SKB)
+		fprintf(fp, "xdpgeneric");
+	else if (mode == XDP_ATTACHED_HW)
+		fprintf(fp, "xdpoffload");
+	else
+		fprintf(fp, "xdp[%u]", mode);
+
+	if (tb[IFLA_XDP_PROG_ID])
+		prog_id = rta_getattr_u32(tb[IFLA_XDP_PROG_ID]);
+	if (!details) {
+		if (prog_id && !link)
+			fprintf(fp, "/id:%u", prog_id);
+		fprintf(fp, " ");
+		return;
+	}
+
+	if (prog_id) {
+		fprintf(fp, " ");
+		bpf_dump_prog_info(fp, prog_id);
 	}
 }
diff --git a/lib/bpf.c b/lib/bpf.c
index cfa1f79..10ea23a 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -40,6 +40,7 @@
 #include <arpa/inet.h>
 
 #include "utils.h"
+#include "json_print.h"
 
 #include "bpf_util.h"
 #include "bpf_elf.h"
@@ -186,23 +187,29 @@ int bpf_dump_prog_info(FILE *f, uint32_t id)
 	int fd, ret, dump_ok = 0;
 	SPRINT_BUF(tmp);
 
-	fprintf(f, "id %u ", id);
+	open_json_object("prog");
+	print_uint(PRINT_ANY, "id", "id %u ", id);
 
 	fd = bpf_prog_fd_by_id(id);
 	if (fd < 0)
-		return dump_ok;
+		goto out;
 
 	ret = bpf_prog_info_by_fd(fd, &info, &len);
 	if (!ret && len) {
-		fprintf(f, "tag %s ",
-			hexstring_n2a(info.tag, sizeof(info.tag),
-				      tmp, sizeof(tmp)));
-		if (info.jited_prog_len)
+		int jited = !!info.jited_prog_len;
+
+		print_string(PRINT_ANY, "tag", "tag %s ",
+			     hexstring_n2a(info.tag, sizeof(info.tag),
+					   tmp, sizeof(tmp)));
+		print_uint(PRINT_JSON, "jited", NULL, jited);
+		if (jited && !is_json_context())
 			fprintf(f, "jited ");
 		dump_ok = 1;
 	}
 
 	close(fd);
+out:
+	close_json_object();
 	return dump_ok;
 }
 
-- 
1.9.3
