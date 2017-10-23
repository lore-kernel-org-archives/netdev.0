From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/12] tools: bpftool: provide JSON output for all possible commands
Date: Mon, 23 Oct 2017 09:24:14 -0700
Message-ID: <20171023162416.32753-11-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:50504 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdJWQZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:25:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id b6so17475979pfh.7
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:25:04 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

As all commands can now return JSON output (possibly just a "null"
value), output of `bpftool --json batch file FILE` should also be fully
JSON compliant.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/main.c | 25 +++++++++++++++++++++----
 tools/bpf/bpftool/map.c  | 16 +++++++++++++++-
 tools/bpf/bpftool/prog.c | 12 +++++++++++-
 3 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 9989a77fdc4a..55ba0a04c102 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -64,6 +64,11 @@ void usage(void)
 
 static int do_help(int argc, char **argv)
 {
+	if (json_output) {
+		jsonw_null(json_wtr);
+		return 0;
+	}
+
 	fprintf(stderr,
 		"Usage: %s OBJECT { COMMAND | help }\n"
 		"       %s batch file FILE\n"
@@ -77,10 +82,22 @@ static int do_help(int argc, char **argv)
 
 static int do_version(int argc, char **argv)
 {
-	printf("%s v%d.%d.%d\n", bin_name,
-	       LINUX_VERSION_CODE >> 16,
-	       LINUX_VERSION_CODE >> 8 & 0xf,
-	       LINUX_VERSION_CODE & 0xf);
+	unsigned int version[3];
+
+	version[0] = LINUX_VERSION_CODE >> 16;
+	version[1] = LINUX_VERSION_CODE >> 8 & 0xf;
+	version[2] = LINUX_VERSION_CODE & 0xf;
+
+	if (json_output) {
+		jsonw_start_object(json_wtr);
+		jsonw_name(json_wtr, "version");
+		jsonw_printf(json_wtr, "\"%u.%u.%u\"",
+			     version[0], version[1], version[2]);
+		jsonw_end_object(json_wtr);
+	} else {
+		printf("%s v%u.%u.%u\n", bin_name,
+		       version[0], version[1], version[2]);
+	}
 	return 0;
 }
 
diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
index 86c128c433ba..a611f31f574f 100644
--- a/tools/bpf/bpftool/map.c
+++ b/tools/bpf/bpftool/map.c
@@ -651,6 +651,8 @@ static int do_update(int argc, char **argv)
 	free(value);
 	close(fd);
 
+	if (!err && json_output)
+		jsonw_null(json_wtr);
 	return err;
 }
 
@@ -812,16 +814,28 @@ static int do_delete(int argc, char **argv)
 	free(key);
 	close(fd);
 
+	if (!err && json_output)
+		jsonw_null(json_wtr);
 	return err;
 }
 
 static int do_pin(int argc, char **argv)
 {
-	return do_pin_any(argc, argv, bpf_map_get_fd_by_id);
+	int err;
+
+	err = do_pin_any(argc, argv, bpf_map_get_fd_by_id);
+	if (!err && json_output)
+		jsonw_null(json_wtr);
+	return err;
 }
 
 static int do_help(int argc, char **argv)
 {
+	if (json_output) {
+		jsonw_null(json_wtr);
+		return 0;
+	}
+
 	fprintf(stderr,
 		"Usage: %s %s show   [MAP]\n"
 		"       %s %s dump    MAP\n"
diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index 41bd5390b4fc..e07f35ff80d1 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -602,11 +602,21 @@ static int do_dump(int argc, char **argv)
 
 static int do_pin(int argc, char **argv)
 {
-	return do_pin_any(argc, argv, bpf_prog_get_fd_by_id);
+	int err;
+
+	err = do_pin_any(argc, argv, bpf_prog_get_fd_by_id);
+	if (!err && json_output)
+		jsonw_null(json_wtr);
+	return err;
 }
 
 static int do_help(int argc, char **argv)
 {
+	if (json_output) {
+		jsonw_null(json_wtr);
+		return 0;
+	}
+
 	fprintf(stderr,
 		"Usage: %s %s show [PROG]\n"
 		"       %s %s dump xlated PROG [{ file FILE | opcodes }]\n"
-- 
2.14.1
