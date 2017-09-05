From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 2/2] bpf: consolidate dumps to use bpf_dump_prog_info
Date: Tue,  5 Sep 2017 02:24:32 +0200
Message-ID: <1e96ef342a4f34ee8c8119ee8cc1ed7092ea5ced.1504570627.git.daniel@iogearbox.net>
References: <cover.1504570627.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49481 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754049AbdIEAYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 20:24:47 -0400
In-Reply-To: <cover.1504570627.git.daniel@iogearbox.net>
In-Reply-To: <cover.1504570627.git.daniel@iogearbox.net>
References: <cover.1504570627.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate dump of prog info to use bpf_dump_prog_info() when possible.
Moving forward, we want to have a consistent output for BPF progs when
being dumped. E.g. in cls/act case we used to dump tag as a separate
netlink attribute before we had BPF_OBJ_GET_INFO_BY_FD bpf(2) command.

Move dumping tag into bpf_dump_prog_info() as well, and only dump the
netlink attribute for older kernels. Also, reuse bpf_dump_prog_info()
for XDP case, so we can dump tag and whether program was jited, which
we currently don't show.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/bpf_util.h |  2 +-
 ip/ipaddress.c     |  6 ++++--
 ip/iplink_xdp.c    | 19 +++++++++++++++----
 ip/xdp.h           |  2 +-
 lib/bpf.c          | 12 +++++++++---
 tc/f_bpf.c         |  8 ++++----
 tc/m_bpf.c         |  8 ++++----
 7 files changed, 38 insertions(+), 19 deletions(-)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 6582ec8..e818221 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -261,7 +261,7 @@ int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_prog_attach_fd(int prog_fd, int target_fd, enum bpf_attach_type type);
 int bpf_prog_detach_fd(int target_fd, enum bpf_attach_type type);
 
-void bpf_dump_prog_info(FILE *f, uint32_t id);
+int bpf_dump_prog_info(FILE *f, uint32_t id);
 
 #ifdef HAVE_ELF
 int bpf_send_map_fds(const char *path, const char *obj);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index c9312f0..dbdd839 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -837,7 +837,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (tb[IFLA_MTU])
 		fprintf(fp, "mtu %u ", rta_getattr_u32(tb[IFLA_MTU]));
 	if (tb[IFLA_XDP])
-		xdp_dump(fp, tb[IFLA_XDP]);
+		xdp_dump(fp, tb[IFLA_XDP], do_link, false);
 	if (tb[IFLA_QDISC])
 		fprintf(fp, "qdisc %s ", rta_getattr_str(tb[IFLA_QDISC]));
 	if (tb[IFLA_MASTER]) {
@@ -951,12 +951,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
 		}
 	}
 
-
 	if ((do_link || show_details) && tb[IFLA_IFALIAS]) {
 		fprintf(fp, "%s    alias %s", _SL_,
 			rta_getattr_str(tb[IFLA_IFALIAS]));
 	}
 
+	if ((do_link || show_details) && tb[IFLA_XDP])
+		xdp_dump(fp, tb[IFLA_XDP], true, true);
+
 	if (do_link && show_stats) {
 		fprintf(fp, "%s", _SL_);
 		__print_link_stats(fp, tb);
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 9ae9ee5..5aa66fe 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -81,9 +81,10 @@ int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
 	return 0;
 }
 
-void xdp_dump(FILE *fp, struct rtattr *xdp)
+void xdp_dump(FILE *fp, struct rtattr *xdp, bool link, bool details)
 {
 	struct rtattr *tb[IFLA_XDP_MAX + 1];
+	__u32 prog_id = 0;
 	__u8 mode;
 
 	parse_rtattr_nested(tb, IFLA_XDP_MAX, xdp);
@@ -94,6 +95,8 @@ void xdp_dump(FILE *fp, struct rtattr *xdp)
 	mode = rta_getattr_u8(tb[IFLA_XDP_ATTACHED]);
 	if (mode == XDP_ATTACHED_NONE)
 		return;
+	else if (details && link)
+		fprintf(fp, "%s    prog/xdp", _SL_);
 	else if (mode == XDP_ATTACHED_DRV)
 		fprintf(fp, "xdp");
 	else if (mode == XDP_ATTACHED_SKB)
@@ -104,8 +107,16 @@ void xdp_dump(FILE *fp, struct rtattr *xdp)
 		fprintf(fp, "xdp[%u]", mode);
 
 	if (tb[IFLA_XDP_PROG_ID])
-		fprintf(fp, "/id:%u",
-			rta_getattr_u32(tb[IFLA_XDP_PROG_ID]));
+		prog_id = rta_getattr_u32(tb[IFLA_XDP_PROG_ID]);
+	if (!details) {
+		if (prog_id && !link)
+			fprintf(fp, "/id:%u", prog_id);
+		fprintf(fp, " ");
+		return;
+	}
 
-	fprintf(fp, " ");
+	if (prog_id) {
+		fprintf(fp, " ");
+		bpf_dump_prog_info(fp, prog_id);
+	}
 }
diff --git a/ip/xdp.h b/ip/xdp.h
index ba897a2..1efd591 100644
--- a/ip/xdp.h
+++ b/ip/xdp.h
@@ -5,6 +5,6 @@
 
 int xdp_parse(int *argc, char ***argv, struct iplink_req *req, bool generic,
 	      bool drv, bool offload);
-void xdp_dump(FILE *fp, struct rtattr *tb);
+void xdp_dump(FILE *fp, struct rtattr *tb, bool link, bool details);
 
 #endif /* __XDP__ */
diff --git a/lib/bpf.c b/lib/bpf.c
index 7463fdc..cfa1f79 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -179,25 +179,31 @@ static int bpf_prog_info_by_fd(int fd, struct bpf_prog_info *info,
 	return ret;
 }
 
-void bpf_dump_prog_info(FILE *f, uint32_t id)
+int bpf_dump_prog_info(FILE *f, uint32_t id)
 {
 	struct bpf_prog_info info = {};
 	uint32_t len = sizeof(info);
-	int fd, ret;
+	int fd, ret, dump_ok = 0;
+	SPRINT_BUF(tmp);
 
 	fprintf(f, "id %u ", id);
 
 	fd = bpf_prog_fd_by_id(id);
 	if (fd < 0)
-		return;
+		return dump_ok;
 
 	ret = bpf_prog_info_by_fd(fd, &info, &len);
 	if (!ret && len) {
+		fprintf(f, "tag %s ",
+			hexstring_n2a(info.tag, sizeof(info.tag),
+				      tmp, sizeof(tmp)));
 		if (info.jited_prog_len)
 			fprintf(f, "jited ");
+		dump_ok = 1;
 	}
 
 	close(fd);
+	return dump_ok;
 }
 
 static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 2f8d12a..4fb9209 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -177,6 +177,7 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 			 struct rtattr *opt, __u32 handle)
 {
 	struct rtattr *tb[TCA_BPF_MAX + 1];
+	int dump_ok = 0;
 
 	if (opt == NULL)
 		return 0;
@@ -221,7 +222,9 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
 
-	if (tb[TCA_BPF_TAG]) {
+	if (tb[TCA_BPF_ID])
+		dump_ok = bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_BPF_ID]));
+	if (!dump_ok && tb[TCA_BPF_TAG]) {
 		SPRINT_BUF(b);
 
 		fprintf(f, "tag %s ",
@@ -230,9 +233,6 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 				      b, sizeof(b)));
 	}
 
-	if (tb[TCA_BPF_ID])
-		bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_BPF_ID]));
-
 	if (tb[TCA_BPF_POLICE]) {
 		fprintf(f, "\n");
 		tc_print_police(f, tb[TCA_BPF_POLICE]);
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index df559bc..e3d0a2b 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -154,6 +154,7 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_ACT_BPF_MAX + 1];
 	struct tc_act_bpf *parm;
+	int dump_ok = 0;
 
 	if (arg == NULL)
 		return -1;
@@ -177,7 +178,9 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " ");
 	}
 
-	if (tb[TCA_ACT_BPF_TAG]) {
+	if (tb[TCA_ACT_BPF_ID])
+		dump_ok = bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_ACT_BPF_ID]));
+	if (!dump_ok && tb[TCA_ACT_BPF_TAG]) {
 		SPRINT_BUF(b);
 
 		fprintf(f, "tag %s ",
@@ -186,9 +189,6 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 				      b, sizeof(b)));
 	}
 
-        if (tb[TCA_ACT_BPF_ID])
-                bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_ACT_BPF_ID]));
-
 	print_action_control(f, "default-action ", parm->action, "\n");
 	fprintf(f, "\tindex %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
-- 
1.9.3
