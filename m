From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/12] tools: bpftool: introduce --json and --pretty options
Date: Mon, 23 Oct 2017 09:24:07 -0700
Message-ID: <20171023162416.32753-4-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:49645 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751548AbdJWQY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:24:57 -0400
Received: by mail-pf0-f193.google.com with SMTP id i5so17476716pfe.6
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:24:57 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

These two options can be used to ask for a JSON output (--j or -json),
and to make this JSON human-readable (-p or --pretty).

A json_writer object is created when JSON is required, and will be used
in follow-up commits to produce JSON output.

Note that --pretty implies --json.

Update for the manual pages and interactive help messages comes in a
later patch of the series.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/main.c | 33 ++++++++++++++++++++++++++++++---
 tools/bpf/bpftool/main.h |  5 +++++
 2 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 613e3c75f78a..14bfc17cd4de 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -51,6 +51,9 @@ const char *bin_name;
 static int last_argc;
 static char **last_argv;
 static int (*last_do_help)(int argc, char **argv);
+json_writer_t *json_wtr;
+bool pretty_output;
+bool json_output;
 
 void usage(void)
 {
@@ -217,22 +220,32 @@ static int do_batch(int argc, char **argv)
 int main(int argc, char **argv)
 {
 	static const struct option options[] = {
+		{ "json",	no_argument,	NULL,	'j' },
 		{ "help",	no_argument,	NULL,	'h' },
+		{ "pretty",	no_argument,	NULL,	'p' },
 		{ "version",	no_argument,	NULL,	'V' },
 		{ 0 }
 	};
-	int opt;
+	int opt, ret;
 
 	last_do_help = do_help;
+	pretty_output = false;
+	json_output = false;
 	bin_name = argv[0];
 
-	while ((opt = getopt_long(argc, argv, "Vh",
+	while ((opt = getopt_long(argc, argv, "Vhpj",
 				  options, NULL)) >= 0) {
 		switch (opt) {
 		case 'V':
 			return do_version(argc, argv);
 		case 'h':
 			return do_help(argc, argv);
+		case 'p':
+			pretty_output = true;
+			/* fall through */
+		case 'j':
+			json_output = true;
+			break;
 		default:
 			usage();
 		}
@@ -243,7 +256,21 @@ int main(int argc, char **argv)
 	if (argc < 0)
 		usage();
 
+	if (json_output) {
+		json_wtr = jsonw_new(stdout);
+		if (!json_wtr) {
+			err("failed to create JSON writer\n");
+			return -1;
+		}
+		jsonw_pretty(json_wtr, pretty_output);
+	}
+
 	bfd_init();
 
-	return cmd_select(cmds, argc, argv, do_help);
+	ret = cmd_select(cmds, argc, argv, do_help);
+
+	if (json_output)
+		jsonw_destroy(&json_wtr);
+
+	return ret;
 }
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index 41e6c7d3fcad..15927fc9fb31 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -43,6 +43,8 @@
 #include <linux/bpf.h>
 #include <linux/kernel.h>
 
+#include "json_writer.h"
+
 #define err(msg...)	fprintf(stderr, "Error: " msg)
 #define warn(msg...)	fprintf(stderr, "Warning: " msg)
 #define info(msg...)	fprintf(stderr, msg)
@@ -66,6 +68,9 @@ enum bpf_obj_type {
 
 extern const char *bin_name;
 
+extern json_writer_t *json_wtr;
+extern bool json_output;
+
 bool is_prefix(const char *pfx, const char *str);
 void fprint_hex(FILE *f, void *arg, unsigned int n, const char *sep);
 void usage(void) __attribute__((noreturn));
-- 
2.14.1
