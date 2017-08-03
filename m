From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 04/27] ip: ip_print: add new API to print JSON or regular format output
Date: Thu,  3 Aug 2017 17:54:52 +0200
Message-ID: <20170803155515.99226-5-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:36019 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdHCPzj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:39 -0400
Received: by mail-wr0-f172.google.com with SMTP id y43so7400773wrd.3
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:38 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

To avoid code duplication and have a ligther impact on most of the files,
these functions were made to handle both stdout (FP context) or JSON
output. Using this api, the changes are easier to read and the code
stays as compact as possible.

includes json_writer.h in ip_common.h to make the lib/json_writer.c
functions available to the new "ip_print" api.

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/Makefile    |   2 +-
 ip/ip_common.h |  56 ++++++++++++++
 ip/ip_print.c  | 233 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 290 insertions(+), 1 deletion(-)
 create mode 100644 ip/ip_print.c

diff --git a/ip/Makefile b/ip/Makefile
index 8424b1f6..760f0ddc 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -9,7 +9,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
     iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o \
-    ipvrf.o iplink_xstats.o ipseg6.o
+    ipvrf.o iplink_xstats.o ipseg6.o ip_print.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 77e9dd06..efc789cb 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -140,3 +140,59 @@ int name_is_vrf(const char *name);
 #endif
 
 void print_num(FILE *fp, unsigned int width, uint64_t count);
+
+#include "json_writer.h"
+
+json_writer_t   *get_json_writer(void);
+/*
+ * use:
+ *      - PRINT_ANY for context based output
+ *      - PRINT_FP for non json specific output
+ *      - PRINT_JSON for json specific output
+ */
+enum output_type {
+	PRINT_FP = 1,
+	PRINT_JSON = 2,
+	PRINT_ANY = 4,
+};
+
+void new_json_obj(int json, FILE *fp);
+void delete_json_obj(void);
+
+bool is_json_context(void);
+
+void set_current_fp(FILE *fp);
+
+void fflush_fp(void);
+
+void open_json_object(const char *str);
+void close_json_object(void);
+void open_json_array(enum output_type type, const char *delim);
+void close_json_array(enum output_type type, const char *delim);
+
+#include "color.h"
+
+#define _PRINT_FUNC(type_name, type)					\
+	void print_color_##type_name(enum output_type t,		\
+				     enum color_attr color,		\
+				     const char *key,			\
+				     const char *fmt,			\
+				     type value);			\
+									\
+	static inline void print_##type_name(enum output_type t,	\
+					     const char *key,		\
+					     const char *fmt,		\
+					     type value)		\
+	{								\
+		print_color_##type_name(t, -1, key, fmt, value);	\
+	}
+_PRINT_FUNC(int, int);
+_PRINT_FUNC(bool, bool);
+_PRINT_FUNC(null, const char*);
+_PRINT_FUNC(string, const char*);
+_PRINT_FUNC(uint, uint64_t);
+_PRINT_FUNC(hu, unsigned short);
+_PRINT_FUNC(hex, unsigned int);
+_PRINT_FUNC(0xhex, unsigned int);
+_PRINT_FUNC(lluint, unsigned long long int);
+#undef _PRINT_FUNC
diff --git a/ip/ip_print.c b/ip/ip_print.c
new file mode 100644
index 00000000..4cd6a0bc
--- /dev/null
+++ b/ip/ip_print.c
@@ -0,0 +1,233 @@
+/*
+ * ip_print.c          "ip print regular or json output".
+ *
+ *             This program is free software; you can redistribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; either version
+ *             2 of the License, or (at your option) any later version.
+ *
+ * Authors:    Julien Fortin, <julien@cumulusnetworks.com>
+ *
+ */
+
+#include <stdarg.h>
+#include <stdio.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "json_writer.h"
+
+static json_writer_t *_jw;
+static FILE *_fp;
+
+#define _IS_JSON_CONTEXT(type) ((type & PRINT_JSON || type & PRINT_ANY) && _jw)
+#define _IS_FP_CONTEXT(type) (!_jw && (type & PRINT_FP || type & PRINT_ANY))
+
+void new_json_obj(int json, FILE *fp)
+{
+	if (json) {
+		_jw = jsonw_new(fp);
+		if (!_jw) {
+			perror("json object");
+			exit(1);
+		}
+		jsonw_pretty(_jw, true);
+		jsonw_start_array(_jw);
+	}
+	set_current_fp(fp);
+}
+
+void delete_json_obj(void)
+{
+	if (_jw) {
+		jsonw_end_array(_jw);
+		jsonw_destroy(&_jw);
+	}
+}
+
+bool is_json_context(void)
+{
+	return _jw != NULL;
+}
+
+void set_current_fp(FILE *fp)
+{
+	if (!fp) {
+		fprintf(stderr, "Error: invalid file pointer.\n");
+		exit(1);
+	}
+	_fp = fp;
+}
+
+json_writer_t *get_json_writer(void)
+{
+	return _jw;
+}
+
+void open_json_object(const char *str)
+{
+	if (_IS_JSON_CONTEXT(PRINT_JSON)) {
+		if (str)
+			jsonw_name(_jw, str);
+		jsonw_start_object(_jw);
+	}
+}
+
+void close_json_object(void)
+{
+	if (_IS_JSON_CONTEXT(PRINT_JSON))
+		jsonw_end_object(_jw);
+}
+
+/*
+ * Start json array or string array using
+ * the provided string as json key (if not null)
+ * or as array delimiter in non-json context.
+ */
+void open_json_array(enum output_type type, const char *str)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		if (str)
+			jsonw_name(_jw, str);
+		jsonw_start_array(_jw);
+	} else if (_IS_FP_CONTEXT(type)) {
+		fprintf(_fp, "%s", str);
+	}
+}
+
+/*
+ * End json array or string array
+ */
+void close_json_array(enum output_type type, const char *str)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		jsonw_pretty(_jw, false);
+		jsonw_end_array(_jw);
+		jsonw_pretty(_jw, true);
+	} else if (_IS_FP_CONTEXT(type)) {
+		fprintf(_fp, "%s", str);
+	}
+}
+
+/*
+ * pre-processor directive to generate similar
+ * functions handling different types
+ */
+#define _PRINT_FUNC(type_name, type)					\
+	void print_color_##type_name(enum output_type t,		\
+				     enum color_attr color,		\
+				     const char *key,			\
+				     const char *fmt,			\
+				     type value)			\
+	{								\
+		if (_IS_JSON_CONTEXT(t)) {				\
+			if (!key)					\
+				jsonw_##type_name(_jw, value);		\
+			else						\
+				jsonw_##type_name##_field(_jw, key, value); \
+		} else if (_IS_FP_CONTEXT(t)) {				\
+			color_fprintf(_fp, color, fmt, value);          \
+		}							\
+	}
+_PRINT_FUNC(int, int);
+_PRINT_FUNC(hu, unsigned short);
+_PRINT_FUNC(uint, uint64_t);
+_PRINT_FUNC(lluint, unsigned long long int);
+#undef _PRINT_FUNC
+
+void print_color_string(enum output_type type,
+			enum color_attr color,
+			const char *key,
+			const char *fmt,
+			const char *value)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		if (key && !value)
+			jsonw_name(_jw, key);
+		else if (!key && value)
+			jsonw_string(_jw, value);
+		else
+			jsonw_string_field(_jw, key, value);
+	} else if (_IS_FP_CONTEXT(type)) {
+		color_fprintf(_fp, color, fmt, value);
+	}
+}
+
+/*
+ * value's type is bool. When using this function in FP context you can't pass
+ * a value to it, you will need to use "is_json_context()" to have different
+ * branch for json and regular output. grep -r "print_bool" for example
+ */
+void print_color_bool(enum output_type type,
+		      enum color_attr color,
+		      const char *key,
+		      const char *fmt,
+		      bool value)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		if (key)
+			jsonw_bool_field(_jw, key, value);
+		else
+			jsonw_bool(_jw, value);
+	} else if (_IS_FP_CONTEXT(type)) {
+		color_fprintf(_fp, color, fmt, value ? "true" : "false");
+	}
+}
+
+/*
+ * In JSON context uses hardcode %#x format: 42 -> 0x2a
+ */
+void print_color_0xhex(enum output_type type,
+		       enum color_attr color,
+		       const char *key,
+		       const char *fmt,
+		       unsigned int hex)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		SPRINT_BUF(b1);
+
+		snprintf(b1, sizeof(b1), "%#x", hex);
+		print_string(PRINT_JSON, key, NULL, b1);
+	} else if (_IS_FP_CONTEXT(type)) {
+		color_fprintf(_fp, color, fmt, hex);
+	}
+}
+
+void print_color_hex(enum output_type type,
+		     enum color_attr color,
+		     const char *key,
+		     const char *fmt,
+		     unsigned int hex)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		SPRINT_BUF(b1);
+
+		snprintf(b1, sizeof(b1), "%x", hex);
+		if (key)
+			jsonw_string_field(_jw, key, b1);
+		else
+			jsonw_string(_jw, b1);
+	} else if (_IS_FP_CONTEXT(type)) {
+		color_fprintf(_fp, color, fmt, hex);
+	}
+}
+
+/*
+ * In JSON context we don't use the argument "value" we simply call jsonw_null
+ * whereas FP context can use "value" to output anything
+ */
+void print_color_null(enum output_type type,
+		      enum color_attr color,
+		      const char *key,
+		      const char *fmt,
+		      const char *value)
+{
+	if (_IS_JSON_CONTEXT(type)) {
+		if (key)
+			jsonw_null_field(_jw, key);
+		else
+			jsonw_null(_jw);
+	} else if (_IS_FP_CONTEXT(type)) {
+		color_fprintf(_fp, color, fmt, value);
+	}
+}
-- 
2.13.3
