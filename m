From: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
Subject: [PATCH net-next 3/3] tools: bpftool: optionally show filenames of pinned objects
Date: Tue, 31 Oct 2017 16:36:32 +0900
Message-ID: <20171031073632.8140-4-bhole_prashant_q7@lab.ntt.co.jp>
References: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47998 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752745AbdJaIeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 04:34:07 -0400
In-Reply-To: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Making it optional to show file names of pinned objects because
it scans complete bpf-fs filesystem which is costly.
Added option -l|--pinned

Signed-off-by: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
---
 tools/bpf/bpftool/main.c | 14 +++++++++++---
 tools/bpf/bpftool/main.h |  3 ++-
 tools/bpf/bpftool/map.c  |  3 ++-
 tools/bpf/bpftool/prog.c |  3 ++-
 4 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/tools/bpf/bpftool/main.c b/tools/bpf/bpftool/main.c
index 6ad53f1..2ae26c6 100644
--- a/tools/bpf/bpftool/main.c
+++ b/tools/bpf/bpftool/main.c
@@ -54,6 +54,7 @@
 json_writer_t *json_wtr;
 bool pretty_output;
 bool json_output;
+bool show_pinned;
 struct pinned_obj_table prog_table;
 struct pinned_obj_table map_table;
 
@@ -265,6 +266,7 @@ int main(int argc, char **argv)
 		{ "help",	no_argument,	NULL,	'h' },
 		{ "pretty",	no_argument,	NULL,	'p' },
 		{ "version",	no_argument,	NULL,	'V' },
+		{ "pinned",	no_argument,	NULL,	'l' },
 		{ 0 }
 	};
 	int opt, ret;
@@ -272,12 +274,13 @@ int main(int argc, char **argv)
 	last_do_help = do_help;
 	pretty_output = false;
 	json_output = false;
+	show_pinned = false;
 	bin_name = argv[0];
 
 	hash_init(prog_table.table);
 	hash_init(map_table.table);
 
-	while ((opt = getopt_long(argc, argv, "Vhpj",
+	while ((opt = getopt_long(argc, argv, "Vhpjl",
 				  options, NULL)) >= 0) {
 		switch (opt) {
 		case 'V':
@@ -290,6 +293,9 @@ int main(int argc, char **argv)
 		case 'j':
 			json_output = true;
 			break;
+		case 'l':
+			show_pinned = true;
+			break;
 		default:
 			usage();
 		}
@@ -316,8 +322,10 @@ int main(int argc, char **argv)
 	if (json_output)
 		jsonw_destroy(&json_wtr);
 
-	delete_pinned_obj_table(&prog_table);
-	delete_pinned_obj_table(&map_table);
+	if (show_pinned) {
+		delete_pinned_obj_table(&prog_table);
+		delete_pinned_obj_table(&map_table);
+	}
 
 	return ret;
 }
diff --git a/tools/bpf/bpftool/main.h b/tools/bpf/bpftool/main.h
index 3abaa17..6c668a6 100644
--- a/tools/bpf/bpftool/main.h
+++ b/tools/bpf/bpftool/main.h
@@ -59,7 +59,7 @@
 #define HELP_SPEC_PROGRAM						\
 	"PROG := { id PROG_ID | pinned FILE | tag PROG_TAG }"
 #define HELP_SPEC_OPTIONS						\
-	"OPTIONS := { {-j|--json} [{-p|--pretty}] }"
+	"OPTIONS := { {-j|--json} [{-p|--pretty}] {-l |--pinned} }"
 
 enum bpf_obj_type {
 	BPF_OBJ_UNKNOWN,
@@ -71,6 +71,7 @@ enum bpf_obj_type {
 
 extern json_writer_t *json_wtr;
 extern bool json_output;
+extern bool show_pinned;
 extern struct pinned_obj_table prog_table;
 extern struct pinned_obj_table map_table;
 
diff --git a/tools/bpf/bpftool/map.c b/tools/bpf/bpftool/map.c
index fbe236e..c4354f8 100644
--- a/tools/bpf/bpftool/map.c
+++ b/tools/bpf/bpftool/map.c
@@ -496,7 +496,8 @@ static int do_show(int argc, char **argv)
 	int err;
 	int fd;
 
-	build_pinned_obj_table(&map_table, BPF_OBJ_MAP);
+	if (show_pinned)
+		build_pinned_obj_table(&map_table, BPF_OBJ_MAP);
 
 	if (argc == 2) {
 		fd = map_parse_fd_and_info(&argc, &argv, &info, &len);
diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index cd29eae..c97c954 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -350,7 +350,8 @@ static int do_show(int argc, char **argv)
 	int err;
 	int fd;
 
-	build_pinned_obj_table(&prog_table, BPF_OBJ_PROG);
+	if (show_pinned)
+		build_pinned_obj_table(&prog_table, BPF_OBJ_PROG);
 
 	if (argc == 2) {
 		fd = prog_parse_fd(&argc, &argv);
-- 
1.8.3.1
