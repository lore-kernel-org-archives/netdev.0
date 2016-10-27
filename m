From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/5] samples: bpf: Add prog_subtype to bpf_prog_load
Date: Wed, 26 Oct 2016 17:58:41 -0700
Message-ID: <1477529922-4806-5-git-send-email-dsa@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35102 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934576AbcJ0A6x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:58:53 -0400
Received: by mail-pf0-f179.google.com with SMTP id s8so6054368pfj.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 17:58:53 -0700 (PDT)
In-Reply-To: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add bpf_prog_subtype argument to bpf_prog_load. If arg is non-NULL,
it is added to the attr passed to the bpf system call.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 samples/bpf/bpf_load.c     | 2 +-
 samples/bpf/fds_example.c  | 2 +-
 samples/bpf/libbpf.c       | 5 ++++-
 samples/bpf/libbpf.h       | 3 ++-
 samples/bpf/sock_example.c | 2 +-
 5 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 97913e109b14..634fcd7f7498 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -77,7 +77,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		return -1;
 	}
 
-	fd = bpf_prog_load(prog_type, prog, size, license, kern_version);
+	fd = bpf_prog_load(prog_type, prog, size, license, kern_version, NULL);
 	if (fd < 0) {
 		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
 		return -1;
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 625e797be6ef..df38b68f3586 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -59,7 +59,7 @@ static int bpf_prog_create(const char *object)
 		return prog_fd[0];
 	} else {
 		return bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-				     insns, sizeof(insns), "GPL", 0);
+				     insns, sizeof(insns), "GPL", 0, NULL);
 	}
 }
 
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 9ce707bf02a7..53987b1ab191 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -82,7 +82,8 @@ char bpf_log_buf[LOG_BUF_SIZE];
 
 int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int prog_len,
-		  const char *license, int kern_version)
+		  const char *license, int kern_version,
+		  union bpf_prog_subtype *prog_subtype)
 {
 	union bpf_attr attr = {
 		.prog_type = prog_type,
@@ -98,6 +99,8 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	 * padding is zero initialized
 	 */
 	attr.kern_version = kern_version;
+	if (prog_subtype)
+		attr.prog_subtype = *prog_subtype;
 
 	bpf_log_buf[0] = 0;
 
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index d0a799a52eaf..949c89c85c70 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -13,7 +13,8 @@ int bpf_get_next_key(int fd, void *key, void *next_key);
 
 int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
-		  const char *license, int kern_version);
+		  const char *license, int kern_version,
+		  union bpf_prog_subtype *prog_subtype);
 
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index 28b60baa9fa8..521f918ab34d 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -56,7 +56,7 @@ static int test_sock(void)
 	};
 
 	prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
-				"GPL", 0);
+				"GPL", 0, NULL);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
 		goto cleanup;
-- 
2.1.4
