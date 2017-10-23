From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/12] tools: bpftool: add JSON output for `bpftool prog dump jited *` command
Date: Mon, 23 Oct 2017 09:24:09 -0700
Message-ID: <20171023162416.32753-6-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:43350 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdJWQY7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:24:59 -0400
Received: by mail-pf0-f195.google.com with SMTP id a8so17478939pfc.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:24:59 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Reuse the json_writer API introduced in an earlier commit to make
bpftool able to generate JSON output on `bpftool prog show *` commands.
A new printing function is created to be passed as an argument to the
disassembler.

Similarly to plain output, opcodes are printed on request.

Outputs from sample programs have been successfully tested against a
JSON validator.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 tools/bpf/bpftool/jit_disasm.c | 86 +++++++++++++++++++++++++++++++++++++++---
 1 file changed, 80 insertions(+), 6 deletions(-)

diff --git a/tools/bpf/bpftool/jit_disasm.c b/tools/bpf/bpftool/jit_disasm.c
index 70e480b59e9d..5937e134e408 100644
--- a/tools/bpf/bpftool/jit_disasm.c
+++ b/tools/bpf/bpftool/jit_disasm.c
@@ -10,6 +10,7 @@
  * Licensed under the GNU General Public License, version 2.0 (GPLv2)
  */
 
+#include <stdarg.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -21,6 +22,9 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 
+#include "json_writer.h"
+#include "main.h"
+
 static void get_exec_path(char *tpath, size_t size)
 {
 	ssize_t len;
@@ -39,6 +43,38 @@ static void get_exec_path(char *tpath, size_t size)
 	free(path);
 }
 
+static int oper_count;
+static int fprintf_json(void *out, const char *fmt, ...)
+{
+	va_list ap;
+	char *s;
+
+	va_start(ap, fmt);
+	if (!oper_count) {
+		int i;
+
+		s = va_arg(ap, char *);
+
+		/* Strip trailing spaces */
+		i = strlen(s) - 1;
+		while (s[i] == ' ')
+			s[i--] = '\0';
+
+		jsonw_string_field(json_wtr, "operation", s);
+		jsonw_name(json_wtr, "operands");
+		jsonw_start_array(json_wtr);
+		oper_count++;
+	} else if (!strcmp(fmt, ",")) {
+		   /* Skip */
+	} else {
+		s = va_arg(ap, char *);
+		jsonw_string(json_wtr, s);
+		oper_count++;
+	}
+	va_end(ap);
+	return 0;
+}
+
 void disasm_print_insn(unsigned char *image, ssize_t len, int opcodes)
 {
 	disassembler_ftype disassemble;
@@ -57,7 +93,12 @@ void disasm_print_insn(unsigned char *image, ssize_t len, int opcodes)
 	assert(bfdf);
 	assert(bfd_check_format(bfdf, bfd_object));
 
-	init_disassemble_info(&info, stdout, (fprintf_ftype) fprintf);
+	if (json_output)
+		init_disassemble_info(&info, stdout,
+				      (fprintf_ftype) fprintf_json);
+	else
+		init_disassemble_info(&info, stdout,
+				      (fprintf_ftype) fprintf);
 	info.arch = bfd_get_arch(bfdf);
 	info.mach = bfd_get_mach(bfdf);
 	info.buffer = image;
@@ -68,20 +109,53 @@ void disasm_print_insn(unsigned char *image, ssize_t len, int opcodes)
 	disassemble = disassembler(bfdf);
 	assert(disassemble);
 
+	if (json_output)
+		jsonw_start_array(json_wtr);
 	do {
-		printf("%4x:\t", pc);
+		if (json_output) {
+			jsonw_start_object(json_wtr);
+			oper_count = 0;
+			jsonw_name(json_wtr, "pc");
+			jsonw_printf(json_wtr, "\"0x%x\"", pc);
+		} else {
+			printf("%4x:\t", pc);
+		}
 
 		count = disassemble(pc, &info);
+		if (json_output) {
+			/* Operand array, was started in fprintf_json. Before
+			 * that, make sure we have a _null_ value if no operand
+			 * other than operation code was present.
+			 */
+			if (oper_count == 1)
+				jsonw_null(json_wtr);
+			jsonw_end_array(json_wtr);
+		}
 
 		if (opcodes) {
-			printf("\n\t");
-			for (i = 0; i < count; ++i)
-				printf("%02x ", (uint8_t) image[pc + i]);
+			if (json_output) {
+				jsonw_name(json_wtr, "opcodes");
+				jsonw_start_array(json_wtr);
+				for (i = 0; i < count; ++i)
+					jsonw_printf(json_wtr, "\"0x%02hhx\"",
+						     (uint8_t)image[pc + i]);
+				jsonw_end_array(json_wtr);
+			} else {
+				printf("\n\t");
+				for (i = 0; i < count; ++i)
+					printf("%02x ",
+					       (uint8_t)image[pc + i]);
+			}
 		}
-		printf("\n");
+		if (json_output)
+			jsonw_end_object(json_wtr);
+		else
+			printf("\n");
 
 		pc += count;
 	} while (count > 0 && pc < len);
+	if (json_output)
+		jsonw_end_array(json_wtr);
 
 	bfd_close(bfdf);
 }
-- 
2.14.1
