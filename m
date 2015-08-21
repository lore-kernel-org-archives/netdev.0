From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] iproute2: provide common json output formatter
Date: Fri, 21 Aug 2015 14:17:50 -0700
Message-ID: <1440191870-3898-1-git-send-email-shemming@brocade.com>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34682 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbbHUVSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 17:18:07 -0400
Received: by padfo6 with SMTP id fo6so14815691pad.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 14:18:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Formatting JSON is moderately painful.
Provide a simple API to do the syntax formatting.
Use it to replace existing json in *stat commands.

---
 include/json_writer.h |  61 ++++++++++
 lib/Makefile          |   3 +-
 lib/json_writer.c     | 312 ++++++++++++++++++++++++++++++++++++++++++++++++++
 misc/Makefile         |   2 +-
 misc/ifstat.c         | 103 +++++++++--------
 misc/lnstat.c         |  22 ++--
 misc/nstat.c          |  59 ++++++----
 7 files changed, 477 insertions(+), 85 deletions(-)
 create mode 100644 include/json_writer.h
 create mode 100644 lib/json_writer.c

diff --git a/include/json_writer.h b/include/json_writer.h
new file mode 100644
index 0000000..ab9a008
--- /dev/null
+++ b/include/json_writer.h
@@ -0,0 +1,61 @@
+/*
+ * Simple streaming JSON writer
+ *
+ * This takes care of the annoying bits of JSON syntax like the commas
+ * after elements
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <stephen@networkplumber.org>
+ */
+
+#ifndef _JSON_WRITER_H_
+#define _JSON_WRITER_H_
+
+#include <stdbool.h>
+#include <stdint.h>
+
+/* Opaque class structure */
+typedef struct json_writer json_writer_t;
+
+/* Create a new JSON stream */
+json_writer_t *jsonw_new(FILE *f);
+/* End output to JSON stream */
+void jsonw_destroy(json_writer_t **self_p);
+
+/* Cause output to have pretty whitespace */
+void jsonw_pretty(json_writer_t *self, bool on);
+
+/* Add property name */
+void jsonw_name(json_writer_t *self, const char *name);
+
+/* Add value  */
+void jsonw_string(json_writer_t *self, const char *value);
+void jsonw_bool(json_writer_t *self, bool value);
+void jsonw_float(json_writer_t *self, double number);
+void jsonw_uint(json_writer_t *self, uint64_t number);
+void jsonw_int(json_writer_t *self, int64_t number);
+void jsonw_null(json_writer_t *self);
+
+/* Useful Combinations of name and value */
+void jsonw_string_field(json_writer_t *self, const char *prop, const char *val);
+void jsonw_bool_field(json_writer_t *self, const char *prop, bool value);
+void jsonw_float_field(json_writer_t *self, const char *prop, double num);
+void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num);
+void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num);
+void jsonw_null_field(json_writer_t *self, const char *prop);
+
+/* Collections */
+void jsonw_start_object(json_writer_t *self);
+void jsonw_end_object(json_writer_t *self);
+
+void jsonw_start_array(json_writer_t *self);
+void jsonw_end_array(json_writer_t *self);
+
+/* Override default exception handling */
+typedef void (jsonw_err_handler_fn)(const char *);
+
+#endif /* _JSON_WRITER_H_ */
diff --git a/lib/Makefile b/lib/Makefile
index 1d4045f..9d1307d 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -6,7 +6,8 @@ endif
 
 CFLAGS += -fPIC
 
-UTILOBJ=utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o inet_proto.o namespace.o \
+UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
+	inet_proto.o namespace.o json_writer.o \
 	names.o color.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
diff --git a/lib/json_writer.c b/lib/json_writer.c
new file mode 100644
index 0000000..2af16e1
--- /dev/null
+++ b/lib/json_writer.c
@@ -0,0 +1,312 @@
+/*
+ * Simple streaming JSON writer
+ *
+ * This takes care of the annoying bits of JSON syntax like the commas
+ * after elements
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Stephen Hemminger <stephen@networkplumber.org>
+ */
+
+#include <stdio.h>
+#include <stdbool.h>
+#include <stdarg.h>
+#include <assert.h>
+#include <malloc.h>
+#include <inttypes.h>
+#include <stdint.h>
+
+#include "json_writer.h"
+
+struct json_writer {
+	FILE		*out;	/* output file */
+	unsigned	depth;  /* nesting */
+	bool		pretty; /* optional whitepace */
+	char		sep;	/* either nul or comma */
+};
+
+/* indentation for pretty print */
+static void jsonw_indent(json_writer_t *self)
+{
+	unsigned i;
+	for (i = 0; i <= self->depth; ++i)
+		fputs("    ", self->out);
+}
+
+/* end current line and indent if pretty printing */
+static void jsonw_eol(json_writer_t *self)
+{
+	if (!self->pretty)
+		return;
+
+	putc('\n', self->out);
+	jsonw_indent(self);
+}
+
+/* If current object is not empty print a comma */
+static void jsonw_eor(json_writer_t *self)
+{
+	if (self->sep != '\0')
+		putc(self->sep, self->out);
+	self->sep = ',';
+}
+
+
+/* Output JSON encoded string */
+/* Handles C escapes, does not do Unicode */
+static void jsonw_puts(json_writer_t *self, const char *str)
+{
+	putc('"', self->out);
+	for (; *str; ++str)
+		switch (*str) {
+		case '\t':
+			fputs("\\t", self->out);
+			break;
+		case '\n':
+			fputs("\\n", self->out);
+			break;
+		case '\r':
+			fputs("\\r", self->out);
+			break;
+		case '\f':
+			fputs("\\f", self->out);
+			break;
+		case '\b':
+			fputs("\\b", self->out);
+			break;
+		case '\\':
+			fputs("\\n", self->out);
+			break;
+		case '"':
+			fputs("\\\"", self->out);
+			break;
+		case '\'':
+			fputs("\\\'", self->out);
+			break;
+		default:
+			putc(*str, self->out);
+		}
+	putc('"', self->out);
+}
+
+/* Create a new JSON stream */
+json_writer_t *jsonw_new(FILE *f)
+{
+	json_writer_t *self = malloc(sizeof(*self));
+	if (self) {
+		self->out = f;
+		self->depth = 0;
+		self->pretty = false;
+		self->sep = '\0';
+		putc('{', self->out);
+	}
+	return self;
+}
+
+/* End output to JSON stream */
+void jsonw_destroy(json_writer_t **self_p)
+{
+	json_writer_t *self = *self_p;
+
+	assert(self->depth == 0);
+	jsonw_eol(self);
+	fputs("}\n", self->out);
+	fflush(self->out);
+	free(self);
+	*self_p = NULL;
+}
+
+void jsonw_pretty(json_writer_t *self, bool on)
+{
+	self->pretty = on;
+}
+
+/* Basic blocks */
+static void jsonw_begin(json_writer_t *self, int c)
+{
+	jsonw_eor(self);
+	putc(c, self->out);
+	++self->depth;
+	self->sep = '\0';
+}
+
+static void jsonw_end(json_writer_t *self, int c)
+{
+	assert(self->depth > 0);
+
+	--self->depth;
+	if (self->sep != '\0')
+		jsonw_eol(self);
+	putc(c, self->out);
+	self->sep = ',';
+}
+
+
+/* Add a JSON property name */
+void jsonw_name(json_writer_t *self, const char *name)
+{
+	jsonw_eor(self);
+	jsonw_eol(self);
+	self->sep = '\0';
+	jsonw_puts(self, name);
+	putc(':', self->out);
+	if (self->pretty)
+		putc(' ', self->out);
+}
+
+static void jsonw_printf(json_writer_t *self, const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	jsonw_eor(self);
+	vfprintf(self->out, fmt, ap);
+	va_end(ap);
+}
+
+/* Collections */
+void jsonw_start_object(json_writer_t *self)
+{
+	jsonw_begin(self, '{');
+}
+
+void jsonw_end_object(json_writer_t *self)
+{
+	jsonw_end(self, '}');
+}
+
+void jsonw_start_array(json_writer_t *self)
+{
+	jsonw_begin(self, '[');
+}
+
+void jsonw_end_array(json_writer_t *self)
+{
+	jsonw_end(self, ']');
+}
+
+/* JSON value types */
+void jsonw_string(json_writer_t *self, const char *value)
+{
+	jsonw_eor(self);
+	jsonw_puts(self, value);
+}
+
+void jsonw_bool(json_writer_t *self, bool val)
+{
+	jsonw_printf(self, "%s", val ? "true" : "false");
+}
+
+#ifdef notused
+void jsonw_null(json_writer_t *self)
+{
+	jsonw_printf(self, "null");
+}
+
+void jsonw_float(json_writer_t *self, double num)
+{
+	jsonw_printf(self, "%g", num);
+}
+#endif
+
+void jsonw_uint(json_writer_t *self, uint64_t num)
+{
+	jsonw_printf(self, "%"PRIu64, num);
+}
+
+void jsonw_int(json_writer_t *self, int64_t num)
+{
+	jsonw_printf(self, "%"PRId64, num);
+}
+
+/* Basic name/value objects */
+void jsonw_string_field(json_writer_t *self, const char *prop, const char *val)
+{
+	jsonw_name(self, prop);
+	jsonw_string(self, val);
+}
+
+void jsonw_bool_field(json_writer_t *self, const char *prop, bool val)
+{
+	jsonw_name(self, prop);
+	jsonw_bool(self, val);
+}
+
+#ifdef notused
+void jsonw_float_field(json_writer_t *self, const char *prop, double val)
+{
+	jsonw_name(self, prop);
+	jsonw_float(self, val);
+}
+#endif
+
+void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num)
+{
+	jsonw_name(self, prop);
+	jsonw_uint(self, num);
+}
+
+void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num)
+{
+	jsonw_name(self, prop);
+	jsonw_int(self, num);
+}
+
+#ifdef notused
+void jsonw_null_field(json_writer_t *self, const char *prop)
+{
+	jsonw_name(self, prop);
+	jsonw_null(self);
+}
+#endif
+
+#ifdef TEST
+int main(int argc, char **argv)
+{
+	json_writer_t *wr = jsonw_new(stdout);
+
+	jsonw_pretty(wr, true);
+	jsonw_name(wr, "Vyatta");
+	jsonw_start_object(wr);
+	jsonw_string_field(wr, "url", "http://vyatta.com");
+	jsonw_uint_field(wr, "downloads", 2000000ul);
+	jsonw_float_field(wr, "stock", 8.16);
+
+	jsonw_name(wr, "ARGV");
+	jsonw_start_array(wr);
+	while (--argc)
+		jsonw_string(wr, *++argv);
+	jsonw_end_array(wr);
+
+	jsonw_name(wr, "empty");
+	jsonw_start_array(wr);
+	jsonw_end_array(wr);
+
+	jsonw_name(wr, "NIL");
+	jsonw_start_object(wr);
+	jsonw_end_object(wr);
+
+	jsonw_null_field(wr, "my_null");
+
+	jsonw_name(wr, "special chars");
+	jsonw_start_array(wr);
+	jsonw_string_field(wr, "slash", "/");
+	jsonw_string_field(wr, "newline", "\n");
+	jsonw_string_field(wr, "tab", "\t");
+	jsonw_string_field(wr, "ff", "\f");
+	jsonw_string_field(wr, "quote", "\"");
+	jsonw_string_field(wr, "tick", "\'");
+	jsonw_string_field(wr, "backslash", "\\");
+	jsonw_end_array(wr);
+
+	jsonw_end_object(wr);
+
+	jsonw_destroy(&wr);
+	return 0;
+}
+
+#endif
diff --git a/misc/Makefile b/misc/Makefile
index fb67ead..2fe3555 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -19,7 +19,7 @@ all: $(TARGETS)
 ss: $(SSOBJ)
 
 nstat: nstat.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c -lm
+	$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c $(LIBNETLINK) -lm
 
 ifstat: ifstat.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -o ifstat ifstat.c $(LIBNETLINK) -lm
diff --git a/misc/ifstat.c b/misc/ifstat.c
index ab2cbc7..9118c80 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -29,6 +29,7 @@
 #include <getopt.h>
 
 #include <libnetlink.h>
+#include <json_writer.h>
 #include <linux/if.h>
 #include <linux/if_link.h>
 
@@ -43,6 +44,7 @@ int no_update = 0;
 int scan_interval = 0;
 int time_constant = 0;
 int show_errors = 0;
+int pretty;
 double W;
 char **patterns;
 int npatterns;
@@ -238,13 +240,15 @@ static void load_raw_table(FILE *fp)
 
 static void dump_raw_db(FILE *fp, int to_hist)
 {
+	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
 	struct ifstat_ent *n, *h;
-	const char *eol = "\n";
 
 	h = hist_db;
-	if (json_output)
-		fprintf(fp, "{ \"%s\":{", info_source);
-	else
+	if (jw) {
+		jsonw_pretty(jw, pretty);
+		jsonw_name(jw, info_source);
+		jsonw_start_object(jw);
+	} else
 		fprintf(fp, "#%s\n", info_source);
 
 	for (n=kern_db; n; n=n->next) {
@@ -265,14 +269,13 @@ static void dump_raw_db(FILE *fp, int to_hist)
 			}
 		}
 
-		if (json_output) {
-			fprintf(fp, "%s   \"%s\":{",
-				eol, n->name);
-			eol = ",\n";
+		if (jw) {
+			jsonw_name(jw, n->name);
+			jsonw_start_object(jw);
+			
 			for (i=0; i<MAXS && stats[i]; i++)
-				fprintf(fp, " \"%s\":%llu",
-					stats[i], vals[i]);
-			fprintf(fp, "}");
+				jsonw_uint_field(jw, stats[i], vals[i]);
+			jsonw_end_object(jw);
 		} else {
 			fprintf(fp, "%d %s ", n->ifindex, n->name);
 			for (i=0; i<MAXS; i++)
@@ -281,6 +284,10 @@ static void dump_raw_db(FILE *fp, int to_hist)
 			fprintf(fp, "\n");
 		}
 	}
+	if (jw) {
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
 }
 
 /* use communication definitions of meg/kilo etc */
@@ -373,20 +380,18 @@ static void print_head(FILE *fp)
 	}
 }
 
-static void print_one_json(FILE *fp, const struct ifstat_ent *n,
+static void print_one_json(json_writer_t *jw, const struct ifstat_ent *n,
 			   const unsigned long long *vals)
 {
-	int i, m;
-	const char *sep = " ";
-
-	m = show_errors ? 20 : 10;
-	fprintf(fp, "    \"%s\":{", n->name);
-	for (i=0; i < m && stats[i]; i++) {
-		fprintf(fp, "%s\"%s\":%llu",
-			sep, stats[i], vals[i]);
-		sep = ", ";
-	}
-	fprintf(fp, " }");
+	int i, m = show_errors ? 20 : 10;
+
+	jsonw_name(jw, n->name);
+	jsonw_start_object(jw);
+
+	for (i=0; i < m && stats[i]; i++)
+		jsonw_uint_field(jw, stats[i], vals[i]);
+
+	jsonw_end_object(jw);
 }
 
 static void print_one_if(FILE *fp, const struct ifstat_ent *n,
@@ -439,39 +444,40 @@ static void print_one_if(FILE *fp, const struct ifstat_ent *n,
 
 static void dump_kern_db(FILE *fp)
 {
+	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
 	struct ifstat_ent *n;
-	const char *eol = "\n";
 
-	if (json_output)
-		fprintf(fp, "{ \"%s\": {", info_source);
-	else
+	if (jw) {
+		jsonw_pretty(jw, pretty);
+		jsonw_name(jw, info_source);
+		jsonw_start_object(jw);
+	} else
 		print_head(fp);
 
 	for (n=kern_db; n; n=n->next) {
 		if (!match(n->name))
 			continue;
 
-		if (json_output) {
-			fprintf(fp, "%s", eol);
-			eol = ",\n";
-			print_one_json(fp, n, n->val);
-		} else
+		if (jw)
+			print_one_json(jw, n, n->val);
+		else
 			print_one_if(fp, n, n->val);
 	}
 	if (json_output)
 		fprintf(fp, "\n} }\n");
 }
 
-
 static void dump_incr_db(FILE *fp)
 {
 	struct ifstat_ent *n, *h;
-	const char *eol = "\n";
+	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
 
 	h = hist_db;
-	if (json_output)
-		fprintf(fp, "{ \"%s\":{", info_source);
-	else
+	if (jw) {
+		jsonw_pretty(jw, pretty);
+		jsonw_name(jw, info_source);
+		jsonw_start_object(jw);
+	} else
 		print_head(fp);
 
 	for (n=kern_db; n; n=n->next) {
@@ -492,17 +498,17 @@ static void dump_incr_db(FILE *fp)
 		if (!match(n->name))
 			continue;
 
-		if (json_output) {
-			fprintf(fp, "%s", eol);
-			eol = ",\n";
-			print_one_json(fp, n, n->val);
-		} else
+		if (jw)
+			print_one_json(jw, n, n->val);
+		else
 			print_one_if(fp, n, vals);
 	}
-	if (json_output)
-		fprintf(fp, "\n} }\n");
-}
 
+	if (jw) {
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
+}
 
 static int children;
 
@@ -646,6 +652,7 @@ static void usage(void)
 "   -e, --errors	show errors\n"
 "   -j, --json          format output in JSON\n"
 "   -n, --nooutput	do history only\n"
+"   -p, --pretty        pretty print\n"
 "   -r, --reset		reset history\n"
 "   -s, --noupdate	don\'t update history\n"
 "   -t, --interval=SECS	report average over the last SECS\n"
@@ -663,6 +670,7 @@ static const struct option longopts[] = {
 	{ "nooutput", 0, 0, 'n' },
 	{ "json", 0, 0, 'j' },
 	{ "reset", 0, 0, 'r' },
+	{ "pretty", 0, 0, 'p' },
 	{ "noupdate", 0, 0, 's' },
 	{ "interval", 1, 0, 't' },
 	{ "version", 0, 0, 'V' },
@@ -678,7 +686,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int fd;
 
-	while ((ch = getopt_long(argc, argv, "hjvVzrnasd:t:e",
+	while ((ch = getopt_long(argc, argv, "hjpvVzrnasd:t:e",
 			longopts, NULL)) != EOF) {
 		switch(ch) {
 		case 'z':
@@ -702,6 +710,9 @@ int main(int argc, char *argv[])
 		case 'j':
 			json_output = 1;
 			break;
+		case 'p':
+			pretty = 1;
+			break;
 		case 'd':
 			scan_interval = atoi(optarg) * 1000;
 			if (scan_interval <= 0) {
diff --git a/misc/lnstat.c b/misc/lnstat.c
index 931c093..1e547d0 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -36,6 +36,7 @@
 #include <string.h>
 #include <getopt.h>
 
+#include <json_writer.h>
 #include "lnstat.h"
 
 static struct option opts[] = {
@@ -49,6 +50,7 @@ static struct option opts[] = {
 	{ "keys", 1, NULL, 'k' },
 	{ "subject", 1, NULL, 's' },
 	{ "width", 1, NULL, 'w' },
+	{ "oneline", 0, NULL, 0 },
 };
 
 static int usage(char *name, int exit_code)
@@ -107,25 +109,17 @@ static void print_line(FILE *of, const struct lnstat_file *lnstat_files,
 static void print_json(FILE *of, const struct lnstat_file *lnstat_files,
 		       const struct field_params *fp)
 {
+	json_writer_t *jw = jsonw_new(of);
 	int i;
-	const char *sep;
-	const char *base = NULL;
 
-	fputs("{\n", of);
+	jsonw_start_object(jw);
 	for (i = 0; i < fp->num; i++) {
 		const struct lnstat_field *lf = fp->params[i].lf;
 
-		if (!base || lf->file->basename != base) {
-			if (base) fputs("},\n", of);
-			base = lf->file->basename;
-			sep = "\n\t";
-			fprintf(of, "    \"%s\":{", base);
-		}
-		fprintf(of, "%s\"%s\":%lu", sep,
-			lf->name, lf->result);
-		sep = ",\n\t";
+		jsonw_uint_field(jw, lf->name, lf->result);
 	}
-	fputs("}\n}\n", of);
+	jsonw_end_object(jw);
+	jsonw_destroy(&jw);
 }
 
 /* find lnstat_field according to user specification */
@@ -272,7 +266,7 @@ int main(int argc, char **argv)
 		num_req_files = 1;
 	}
 
-	while ((c = getopt_long(argc, argv,"Vc:djf:h?i:k:s:w:",
+	while ((c = getopt_long(argc, argv,"Vc:djpf:h?i:k:s:w:",
 				opts, NULL)) != -1) {
 		int len = 0;
 		char *tmp, *tok;
diff --git a/misc/nstat.c b/misc/nstat.c
index c2cb056..267e515 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -28,6 +28,7 @@
 #include <math.h>
 #include <getopt.h>
 
+#include <json_writer.h>
 #include <SNAPSHOT.h>
 
 int dump_zeros = 0;
@@ -35,6 +36,7 @@ int reset_history = 0;
 int ignore_history = 0;
 int no_output = 0;
 int json_output = 0;
+int pretty = 0;
 int no_update = 0;
 int scan_interval = 0;
 int time_constant = 0;
@@ -271,13 +273,15 @@ static void load_netstat(void)
 
 static void dump_kern_db(FILE *fp, int to_hist)
 {
+	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
 	struct nstat_ent *n, *h;
-	const char *eol = "\n";
 
 	h = hist_db;
-	if (json_output)
-		fprintf(fp, "{ \"%s\":{", info_source);
-	else
+	if (jw) {
+		jsonw_pretty(jw, pretty);
+		jsonw_name(jw, info_source);
+		jsonw_start_object(jw);
+	} else
 		fprintf(fp, "#%s\n", info_source);
 
 	for (n=kern_db; n; n=n->next) {
@@ -297,26 +301,29 @@ static void dump_kern_db(FILE *fp, int to_hist)
 			}
 		}
 
-		if (json_output) {
-			fprintf(fp, "%s    \"%s\":%llu",
-				eol, n->id, val);
-			eol = ",\n";
-		} else
+		if (jw)
+			jsonw_uint_field(jw, n->id, val);
+		else
 			fprintf(fp, "%-32s%-16llu%6.1f\n", n->id, val, n->rate);
 	}
-	if (json_output)
-		fprintf(fp, "\n} }\n");
+
+	if (jw) {
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
 }
 
 static void dump_incr_db(FILE *fp)
 {
+	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
 	struct nstat_ent *n, *h;
-	const char *eol = "\n";
 
 	h = hist_db;
-	if (json_output)
-		fprintf(fp, "{ \"%s\":{", info_source);
-	else
+	if (jw) {
+		jsonw_pretty(jw, pretty);
+		jsonw_name(jw, info_source);
+		jsonw_start_object(jw);
+	} else
 		fprintf(fp, "#%s\n", info_source);
 
 	for (n=kern_db; n; n=n->next) {
@@ -339,16 +346,17 @@ static void dump_incr_db(FILE *fp)
 		if (!match(n->id))
 			continue;
 
-		if (json_output) {
-			fprintf(fp, "%s    \"%s\":%llu",
-				eol, n->id, val);
-			eol = ",\n";
-		} else
+		if (jw)
+			jsonw_uint_field(jw, n->id, val);
+		else
 			fprintf(fp, "%-32s%-16llu%6.1f%s\n", n->id, val,
 				n->rate, ovfl?" (overflow)":"");
 	}
-	if (json_output)
-		fprintf(fp, "\n} }\n");
+
+	if (jw) {
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
 }
 
 static int children;
@@ -485,6 +493,7 @@ static void usage(void)
 "   -d, --scan=SECS	sample every statistics every SECS\n"
 "   -j, --json          format output in JSON\n"
 "   -n, --nooutput	do history only\n"
+"   -p, --pretty        pretty print\n"
 "   -r, --reset		reset history\n"
 "   -s, --noupdate	don\'t update history\n"
 "   -t, --interval=SECS	report average over the last SECS\n"
@@ -501,6 +510,7 @@ static const struct option longopts[] = {
 	{ "json", 0, 0, 'j' },
 	{ "reset", 0, 0, 'r' },
 	{ "noupdate", 0, 0, 's' },
+	{ "pretty", 0, 0, 'p' },
 	{ "interval", 1, 0, 't' },
 	{ "version", 0, 0, 'V' },
 	{ "zeros", 0, 0, 'z' },
@@ -515,7 +525,7 @@ int main(int argc, char *argv[])
 	int ch;
 	int fd;
 
-	while ((ch = getopt_long(argc, argv, "h?vVzrnasd:t:j",
+	while ((ch = getopt_long(argc, argv, "h?vVzrnasd:t:jp",
 				 longopts, NULL)) != EOF) {
 		switch(ch) {
 		case 'z':
@@ -546,6 +556,9 @@ int main(int argc, char *argv[])
 		case 'j':
 			json_output = 1;
 			break;
+		case 'p':
+			pretty = 1;
+			break;
 		case 'v':
 		case 'V':
 			printf("nstat utility, iproute2-ss%s\n", SNAPSHOT);
-- 
2.1.4
