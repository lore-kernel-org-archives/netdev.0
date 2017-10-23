From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 08/12] tools: bpftool: add JSON output for `bpftool batch file FILE` command
Date: Mon, 23 Oct 2017 09:24:12 -0700
Message-ID: <20171023162416.32753-9-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:44744 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751612AbdJWQZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:25:02 -0400
Received: by mail-pg0-f66.google.com with SMTP id j3so12171108pga.1
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:25:02 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

`bpftool batch file FILE` takes FILE as an argument and executes all the
bpftool commands it finds inside (or stops if an error occurs).

To obtain a consistent JSON output, create a root JSON array, then for
each command create a new object containing two fields: one with the
command arguments, the other with the output (which is the JSON object
that the command would have produced, if called on its own).

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/main.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 14bfc17cd4de..71b01bf73912 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -155,6 +155,7 @@ static int do_batch(int argc, char **argv)
 	int n_argc;
 	FILE *fp;
 	int err;
+	int i;
 
 	if (argc < 2) {
 		err("too few parameters for batch\n");
@@ -174,6 +175,8 @@ static int do_batch(int argc, char **argv)
 		return -1;
 	}
 
+	if (json_output)
+		jsonw_start_array(json_wtr);
 	while (fgets(buf, sizeof(buf), fp)) {
 		if (strlen(buf) == sizeof(buf) - 1) {
 			errno = E2BIG;
@@ -197,7 +200,21 @@ static int do_batch(int argc, char **argv)
 		if (!n_argc)
 			continue;
 
+		if (json_output) {
+			jsonw_start_object(json_wtr);
+			jsonw_name(json_wtr, "command");
+			jsonw_start_array(json_wtr);
+			for (i = 0; i < n_argc; i++)
+				jsonw_string(json_wtr, n_argv[i]);
+			jsonw_end_array(json_wtr);
+			jsonw_name(json_wtr, "output");
+		}
+
 		err = cmd_select(cmds, n_argc, n_argv, do_help);
+
+		if (json_output)
+			jsonw_end_object(json_wtr);
+
 		if (err)
 			goto err_close;
 
@@ -214,6 +231,9 @@ static int do_batch(int argc, char **argv)
 err_close:
 	fclose(fp);
 
+	if (json_output)
+		jsonw_end_array(json_wtr);
+
 	return err;
 }
 
-- 
2.14.1
