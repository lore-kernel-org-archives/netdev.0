From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] tools: bpftool: try to mount bpffs if required for pinning objects
Date: Tue, 24 Oct 2017 20:11:28 -0700
Message-ID: <20171025031128.13990-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:55093 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751806AbdJYDL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 23:11:56 -0400
Received: by mail-pf0-f196.google.com with SMTP id n89so21166794pfk.11
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 20:11:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

One possible cause of failure for `bpftool {prog|map} pin * file FILE`
is the FILE not being in an eBPF virtual file system (bpffs). In this
case, make bpftool attempt to mount bpffs on the parent directory of the
FILE. Then, if this operation is successful, try again to pin the
object.

The code for mnt_bpffs() is a copy of function bpf_mnt_fs() from
iproute2 package (under lib/bpf.c, taken at commit 4b73d52f8a81), with
modifications regarding handling of error messages.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/common.c | 71 ++++++++++++++++++++++++++++++++++++++++------
 tools/bpf/bpftool/main.h   |  2 ++
 2 files changed, 65 insertions(+), 8 deletions(-)

diff --git a/tools/bpf/bpftool/common.c b/tools/bpf/bpftool/common.c
index b2533f1cae3e..f0288269dae8 100644
--- a/tools/bpf/bpftool/common.c
+++ b/tools/bpf/bpftool/common.c
@@ -42,6 +42,7 @@
 #include <unistd.h>
 #include <linux/limits.h>
 #include <linux/magic.h>
+#include <sys/mount.h>
 #include <sys/types.h>
 #include <sys/vfs.h>
 
@@ -59,6 +60,37 @@ static bool is_bpffs(char *path)
 	return (unsigned long)st_fs.f_type == BPF_FS_MAGIC;
 }
 
+static int mnt_bpffs(const char *target, char *buff, size_t bufflen)
+{
+	bool bind_done = false;
+
+	while (mount("", target, "none", MS_PRIVATE | MS_REC, NULL)) {
+		if (errno != EINVAL || bind_done) {
+			snprintf(buff, bufflen,
+				 "mount --make-private %s failed: %s",
+				 target, strerror(errno));
+			return -1;
+		}
+
+		if (mount(target, target, "none", MS_BIND, NULL)) {
+			snprintf(buff, bufflen,
+				 "mount --bind %s %s failed: %s",
+				 target, target, strerror(errno));
+			return -1;
+		}
+
+		bind_done = true;
+	}
+
+	if (mount("bpf", target, "bpf", 0, "mode=0700")) {
+		snprintf(buff, bufflen, "mount -t bpf bpf %s failed: %s",
+			 target, strerror(errno));
+		return -1;
+	}
+
+	return 0;
+}
+
 int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type)
 {
 	enum bpf_obj_type type;
@@ -89,8 +121,11 @@ int open_obj_pinned_any(char *path, enum bpf_obj_type exp_type)
 
 int do_pin_any(int argc, char **argv, int (*get_fd_by_id)(__u32))
 {
+	char err_str[ERR_MAX_LEN];
 	unsigned int id;
 	char *endptr;
+	char *file;
+	char *dir;
 	int err;
 	int fd;
 
@@ -117,16 +152,36 @@ int do_pin_any(int argc, char **argv, int (*get_fd_by_id)(__u32))
 	}
 
 	err = bpf_obj_pin(fd, *argv);
-	close(fd);
-	if (err) {
-		p_err("can't pin the object (%s): %s", *argv,
-		      errno == EACCES && !is_bpffs(dirname(*argv)) ?
-		    "directory not in bpf file system (bpffs)" :
-		    strerror(errno));
-		return -1;
+	if (!err)
+		goto out_close;
+
+	file = malloc(strlen(*argv) + 1);
+	strcpy(file, *argv);
+	dir = dirname(file);
+
+	if (errno != EPERM || is_bpffs(dir)) {
+		p_err("can't pin the object (%s): %s", *argv, strerror(errno));
+		goto out_free;
 	}
 
-	return 0;
+	/* Attempt to mount bpffs, then retry pinning. */
+	err = mnt_bpffs(dir, err_str, ERR_MAX_LEN);
+	if (!err) {
+		err = bpf_obj_pin(fd, *argv);
+		if (err)
+			p_err("can't pin the object (%s): %s", *argv,
+			      strerror(errno));
+	} else {
+		err_str[ERR_MAX_LEN - 1] = '\0';
+		p_err("can't mount BPF file system to pin the object (%s): %s",
+		      *argv, err_str);
+	}
+
+out_free:
+	free(file);
+out_close:
+	close(fd);
+	return err;
 }
 
 const char *get_fd_type_name(enum bpf_obj_type type)
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index 2f94bed03a8d..d315d01be645 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -51,6 +51,8 @@
 #define NEXT_ARGP()	({ (*argc)--; (*argv)++; if (*argc < 0) usage(); })
 #define BAD_ARG()	({ p_err("what is '%s'?\n", *argv); -1; })
 
+#define ERR_MAX_LEN	1024
+
 #define BPF_TAG_FMT	"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
 
 #define HELP_SPEC_PROGRAM						\
-- 
2.14.1
