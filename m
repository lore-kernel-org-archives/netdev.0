From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 v3] lib: json_print: rework 'new_json_obj' drop FILE* argument
Date: Tue, 26 Sep 2017 16:45:39 -0700
Message-ID: <20170926234540.80743-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:50364 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968440AbdIZXpp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 19:45:45 -0400
Received: by mail-pg0-f53.google.com with SMTP id p5so6767643pgn.7
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 16:45:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

As Stephen Hemminger mentioned on the last submission the new_json_obj
function is always called with fp == stdout, so right now, there's no
need of this extra argument.

The background for the rework is the following:
The ip monitor didn't call `new_json_obj` (even for in non json context),
so the static FILE* _fp variable wasn't initialized, thus raising a
SIGSEGV in ipaddress.c. This patch should fix this issue for good, new
paths won't have to call `new_json_obj`.

How to reproduce:

$ ip -t mon label link
(gdb) bt
.#0  _IO_vfprintf_internal (s=s@entry=0x0, format=format@entry=0x45460d “%d: “, ap=ap@entry=0x7fffffff7f18) at vfprintf.c:1278
.#1  0x0000000000451310 in color_fprintf (fp=0x0, attr=<optimized out>, fmt=0x45460d “%d: “) at color.c:108
.#2  0x000000000044a856 in print_color_int (t=t@entry=PRINT_ANY, color=color@entry=4294967295, key=key@entry=0x4545fc “ifindex”,
    fmt=fmt@entry=0x45460d “%d: “, value=<optimized out>) at ip_print.c:132
.#3  0x000000000040ccd2 in print_int (value=<optimized out>, fmt=0x45460d “%d: “, key=0x4545fc “ifindex”, t=PRINT_ANY) at ip_common.h:189
.#4  print_linkinfo (who=<optimized out>, n=0x7fffffffa380, arg=0x7ffff77a82a0 <_IO_2_1_stdout_>) at ipaddress.c:1107
.#5  0x0000000000422e13 in accept_msg (who=0x7fffffff8320, ctrl=0x7fffffff8310, n=0x7fffffffa380, arg=0x7ffff77a82a0 <_IO_2_1_stdout_>) at ipmonitor.c:89
.#6  0x000000000044c58f in rtnl_listen (rtnl=0x672160 <rth>, handler=handler@entry=0x422c70 <accept_msg>, jarg=0x7ffff77a82a0 <_IO_2_1_stdout_>)
    at libnetlink.c:761
.#7  0x00000000004233db in do_ipmonitor (argc=<optimized out>, argv=0x7fffffffe5a0) at ipmonitor.c:310
.#8  0x0000000000408f74 in do_cmd (argv0=0x7fffffffe7f5 “mon”, argc=3, argv=0x7fffffffe588) at ip.c:116
.#9  0x0000000000408a94 in main (argc=4, argv=0x7fffffffe580) at ip.c:311

Fixes: 6377572f ("ip: ip_print: add new API to print JSON or regular format output")
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 include/json_print.h |  4 +---
 ip/ipaddress.c       |  4 ++--
 lib/json_print.c     | 31 ++++++++++---------------------
 3 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/include/json_print.h b/include/json_print.h
index 44cf5ac5..b6ce1f9f 100644
--- a/include/json_print.h
+++ b/include/json_print.h
@@ -29,13 +29,11 @@ enum output_type {
 	PRINT_ANY = 4,
 };
 
-void new_json_obj(int json, FILE *fp);
+void new_json_obj(int json);
 void delete_json_obj(void);
 
 bool is_json_context(void);
 
-void set_current_fp(FILE *fp);
-
 void fflush_fp(void);
 
 void open_json_object(const char *str);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index b8bc387a..9e9a7e0a 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1815,7 +1815,7 @@ static int ipaddr_showdump(void)
 	if (ipadd_dump_check_magic())
 		exit(-1);
 
-	new_json_obj(json, stdout);
+	new_json_obj(json);
 	open_json_object(NULL);
 	open_json_array(PRINT_JSON, "addr_info");
 
@@ -2176,7 +2176,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 	 * Initialize a json_writer and open an array object
 	 * if -json was specified.
 	 */
-	new_json_obj(json, stdout);
+	new_json_obj(json);
 
 	/*
 	 * If only filter_dev present and none of the other
diff --git a/lib/json_print.c b/lib/json_print.c
index 93b4119d..aa527af6 100644
--- a/lib/json_print.c
+++ b/lib/json_print.c
@@ -16,15 +16,14 @@
 #include "json_print.h"
 
 static json_writer_t *_jw;
-static FILE *_fp;
 
 #define _IS_JSON_CONTEXT(type) ((type & PRINT_JSON || type & PRINT_ANY) && _jw)
 #define _IS_FP_CONTEXT(type) (!_jw && (type & PRINT_FP || type & PRINT_ANY))
 
-void new_json_obj(int json, FILE *fp)
+void new_json_obj(int json)
 {
 	if (json) {
-		_jw = jsonw_new(fp);
+		_jw = jsonw_new(stdout);
 		if (!_jw) {
 			perror("json object");
 			exit(1);
@@ -32,7 +31,6 @@ void new_json_obj(int json, FILE *fp)
 		jsonw_pretty(_jw, true);
 		jsonw_start_array(_jw);
 	}
-	set_current_fp(fp);
 }
 
 void delete_json_obj(void)
@@ -48,15 +46,6 @@ bool is_json_context(void)
 	return _jw != NULL;
 }
 
-void set_current_fp(FILE *fp)
-{
-	if (!fp) {
-		fprintf(stderr, "Error: invalid file pointer.\n");
-		exit(1);
-	}
-	_fp = fp;
-}
-
 json_writer_t *get_json_writer(void)
 {
 	return _jw;
@@ -89,7 +78,7 @@ void open_json_array(enum output_type type, const char *str)
 			jsonw_name(_jw, str);
 		jsonw_start_array(_jw);
 	} else if (_IS_FP_CONTEXT(type)) {
-		fprintf(_fp, "%s", str);
+		printf("%s", str);
 	}
 }
 
@@ -103,7 +92,7 @@ void close_json_array(enum output_type type, const char *str)
 		jsonw_end_array(_jw);
 		jsonw_pretty(_jw, true);
 	} else if (_IS_FP_CONTEXT(type)) {
-		fprintf(_fp, "%s", str);
+		printf("%s", str);
 	}
 }
 
@@ -124,7 +113,7 @@ void close_json_array(enum output_type type, const char *str)
 			else						\
 				jsonw_##type_name##_field(_jw, key, value); \
 		} else if (_IS_FP_CONTEXT(t)) {				\
-			color_fprintf(_fp, color, fmt, value);          \
+			color_fprintf(stdout, color, fmt, value);          \
 		}							\
 	}
 _PRINT_FUNC(int, int);
@@ -147,7 +136,7 @@ void print_color_string(enum output_type type,
 		else
 			jsonw_string_field(_jw, key, value);
 	} else if (_IS_FP_CONTEXT(type)) {
-		color_fprintf(_fp, color, fmt, value);
+		color_fprintf(stdout, color, fmt, value);
 	}
 }
 
@@ -168,7 +157,7 @@ void print_color_bool(enum output_type type,
 		else
 			jsonw_bool(_jw, value);
 	} else if (_IS_FP_CONTEXT(type)) {
-		color_fprintf(_fp, color, fmt, value ? "true" : "false");
+		color_fprintf(stdout, color, fmt, value ? "true" : "false");
 	}
 }
 
@@ -187,7 +176,7 @@ void print_color_0xhex(enum output_type type,
 		snprintf(b1, sizeof(b1), "%#x", hex);
 		print_string(PRINT_JSON, key, NULL, b1);
 	} else if (_IS_FP_CONTEXT(type)) {
-		color_fprintf(_fp, color, fmt, hex);
+		color_fprintf(stdout, color, fmt, hex);
 	}
 }
 
@@ -206,7 +195,7 @@ void print_color_hex(enum output_type type,
 		else
 			jsonw_string(_jw, b1);
 	} else if (_IS_FP_CONTEXT(type)) {
-		color_fprintf(_fp, color, fmt, hex);
+		color_fprintf(stdout, color, fmt, hex);
 	}
 }
 
@@ -226,6 +215,6 @@ void print_color_null(enum output_type type,
 		else
 			jsonw_null(_jw);
 	} else if (_IS_FP_CONTEXT(type)) {
-		color_fprintf(_fp, color, fmt, value);
+		color_fprintf(stdout, color, fmt, value);
 	}
 }
-- 
2.14.1
