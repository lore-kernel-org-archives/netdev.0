From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 3/3] bpf: dump id/jited info for cls/act programs
Date: Mon, 17 Jul 2017 17:18:52 +0200
Message-ID: <65c52b23f2a5e2457f4c2778782d19cc4737daf0.1500301061.git.daniel@iogearbox.net>
References: <cover.1500301061.git.daniel@iogearbox.net>
Cc: kafai@fb.com, ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48068 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdGQPTH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 11:19:07 -0400
In-Reply-To: <cover.1500301061.git.daniel@iogearbox.net>
In-Reply-To: <cover.1500301061.git.daniel@iogearbox.net>
References: <cover.1500301061.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of TCA_BPF_ID/TCA_ACT_BPF_ID that we exposed and print the ID
of the programs loaded and use the new BPF_OBJ_GET_INFO_BY_FD command
for dumping further information about the program, currently whether
the attached program is jited.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/bpf_util.h |  2 ++
 lib/bpf.c          | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 tc/f_bpf.c         |  3 +++
 tc/m_bpf.c         |  3 +++
 4 files changed, 56 insertions(+)

diff --git a/include/bpf_util.h b/include/bpf_util.h
index 5361dab..6582ec8 100644
--- a/include/bpf_util.h
+++ b/include/bpf_util.h
@@ -261,6 +261,8 @@ int bpf_prog_load(enum bpf_prog_type type, const struct bpf_insn *insns,
 int bpf_prog_attach_fd(int prog_fd, int target_fd, enum bpf_attach_type type);
 int bpf_prog_detach_fd(int target_fd, enum bpf_attach_type type);
 
+void bpf_dump_prog_info(FILE *f, uint32_t id);
+
 #ifdef HAVE_ELF
 int bpf_send_map_fds(const char *path, const char *obj);
 int bpf_recv_map_fds(const char *path, int *fds, struct bpf_map_aux *aux,
diff --git a/lib/bpf.c b/lib/bpf.c
index 45747d2..7eb5cd9 100644
--- a/lib/bpf.c
+++ b/lib/bpf.c
@@ -152,6 +152,54 @@ static int bpf_map_update(int fd, const void *key, const void *value,
 	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
+static int bpf_prog_fd_by_id(uint32_t id)
+{
+	union bpf_attr attr = {};
+
+	attr.prog_id = id;
+
+	return bpf(BPF_PROG_GET_FD_BY_ID, &attr, sizeof(attr));
+}
+
+static int bpf_prog_info_by_fd(int fd, struct bpf_prog_info *info,
+			       uint32_t *info_len)
+{
+	union bpf_attr attr = {};
+	int ret;
+
+	attr.info.bpf_fd = fd;
+	attr.info.info = bpf_ptr_to_u64(info);
+	attr.info.info_len = *info_len;
+
+	*info_len = 0;
+	ret = bpf(BPF_OBJ_GET_INFO_BY_FD, &attr, sizeof(attr));
+	if (!ret)
+		*info_len = attr.info.info_len;
+
+	return ret;
+}
+
+void bpf_dump_prog_info(FILE *f, uint32_t id)
+{
+	struct bpf_prog_info info = {};
+	uint32_t len = sizeof(info);
+	int fd, ret;
+
+	fprintf(f, "id %u ", id);
+
+	fd = bpf_prog_fd_by_id(id);
+	if (fd < 0)
+		return;
+
+	ret = bpf_prog_info_by_fd(fd, &info, &len);
+	if (!ret && len) {
+		if (info.jited_prog_len)
+			fprintf(f, "jited ");
+	}
+
+	close(fd);
+}
+
 static int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 			    char **bpf_string, bool *need_release,
 			    const char separator)
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 75c44c0..2f8d12a 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -230,6 +230,9 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 				      b, sizeof(b)));
 	}
 
+	if (tb[TCA_BPF_ID])
+		bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_BPF_ID]));
+
 	if (tb[TCA_BPF_POLICE]) {
 		fprintf(f, "\n");
 		tc_print_police(f, tb[TCA_BPF_POLICE]);
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 5728303..df559bc 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -186,6 +186,9 @@ static int bpf_print_opt(struct action_util *au, FILE *f, struct rtattr *arg)
 				      b, sizeof(b)));
 	}
 
+        if (tb[TCA_ACT_BPF_ID])
+                bpf_dump_prog_info(f, rta_getattr_u32(tb[TCA_ACT_BPF_ID]));
+
 	print_action_control(f, "default-action ", parm->action, "\n");
 	fprintf(f, "\tindex %u ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
-- 
1.9.3
