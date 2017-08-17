From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 03/27] json_writer: add new json handlers (null, float with format, lluint, hu)
Date: Thu, 17 Aug 2017 10:35:50 -0700
Message-ID: <20170817173614.54987-4-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:38409 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753393AbdHQRkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:20 -0400
Received: by mail-wr0-f173.google.com with SMTP id 5so25401074wrz.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:20 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 include/json_writer.h |  9 +++++++++
 lib/json_writer.c     | 44 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/include/json_writer.h b/include/json_writer.h
index ab9a008a..1516aafb 100644
--- a/include/json_writer.h
+++ b/include/json_writer.h
@@ -33,20 +33,29 @@ void jsonw_pretty(json_writer_t *self, bool on);
 void jsonw_name(json_writer_t *self, const char *name);
 
 /* Add value  */
+void jsonw_printf(json_writer_t *self, const char *fmt, ...);
 void jsonw_string(json_writer_t *self, const char *value);
 void jsonw_bool(json_writer_t *self, bool value);
 void jsonw_float(json_writer_t *self, double number);
+void jsonw_float_fmt(json_writer_t *self, const char *fmt, double num);
 void jsonw_uint(json_writer_t *self, uint64_t number);
+void jsonw_hu(json_writer_t *self, unsigned short number);
 void jsonw_int(json_writer_t *self, int64_t number);
 void jsonw_null(json_writer_t *self);
+void jsonw_lluint(json_writer_t *self, unsigned long long int num);
 
 /* Useful Combinations of name and value */
 void jsonw_string_field(json_writer_t *self, const char *prop, const char *val);
 void jsonw_bool_field(json_writer_t *self, const char *prop, bool value);
 void jsonw_float_field(json_writer_t *self, const char *prop, double num);
 void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num);
+void jsonw_hu_field(json_writer_t *self, const char *prop, unsigned short num);
 void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num);
 void jsonw_null_field(json_writer_t *self, const char *prop);
+void jsonw_lluint_field(json_writer_t *self, const char *prop,
+			unsigned long long int num);
+void jsonw_float_field_fmt(json_writer_t *self, const char *prop,
+			   const char *fmt, double val);
 
 /* Collections */
 void jsonw_start_object(json_writer_t *self);
diff --git a/lib/json_writer.c b/lib/json_writer.c
index 9fc05e96..6b77d288 100644
--- a/lib/json_writer.c
+++ b/lib/json_writer.c
@@ -156,7 +156,7 @@ void jsonw_name(json_writer_t *self, const char *name)
 		putc(' ', self->out);
 }
 
-static void jsonw_printf(json_writer_t *self, const char *fmt, ...)
+void jsonw_printf(json_writer_t *self, const char *fmt, ...)
 {
 	va_list ap;
 
@@ -199,23 +199,38 @@ void jsonw_bool(json_writer_t *self, bool val)
 	jsonw_printf(self, "%s", val ? "true" : "false");
 }
 
-#ifdef notused
 void jsonw_null(json_writer_t *self)
 {
 	jsonw_printf(self, "null");
 }
 
+void jsonw_float_fmt(json_writer_t *self, const char *fmt, double num)
+{
+	jsonw_printf(self, fmt, num);
+}
+
+#ifdef notused
 void jsonw_float(json_writer_t *self, double num)
 {
 	jsonw_printf(self, "%g", num);
 }
 #endif
 
+void jsonw_hu(json_writer_t *self, unsigned short num)
+{
+	jsonw_printf(self, "%hu", num);
+}
+
 void jsonw_uint(json_writer_t *self, uint64_t num)
 {
 	jsonw_printf(self, "%"PRIu64, num);
 }
 
+void jsonw_lluint(json_writer_t *self, unsigned long long int num)
+{
+	jsonw_printf(self, "%llu", num);
+}
+
 void jsonw_int(json_writer_t *self, int64_t num)
 {
 	jsonw_printf(self, "%"PRId64, num);
@@ -242,25 +257,46 @@ void jsonw_float_field(json_writer_t *self, const char *prop, double val)
 }
 #endif
 
+void jsonw_float_field_fmt(json_writer_t *self,
+			   const char *prop,
+			   const char *fmt,
+			   double val)
+{
+	jsonw_name(self, prop);
+	jsonw_float_fmt(self, fmt, val);
+}
+
 void jsonw_uint_field(json_writer_t *self, const char *prop, uint64_t num)
 {
 	jsonw_name(self, prop);
 	jsonw_uint(self, num);
 }
 
+void jsonw_hu_field(json_writer_t *self, const char *prop, unsigned short num)
+{
+	jsonw_name(self, prop);
+	jsonw_hu(self, num);
+}
+
+void jsonw_lluint_field(json_writer_t *self,
+			const char *prop,
+			unsigned long long int num)
+{
+	jsonw_name(self, prop);
+	jsonw_lluint(self, num);
+}
+
 void jsonw_int_field(json_writer_t *self, const char *prop, int64_t num)
 {
 	jsonw_name(self, prop);
 	jsonw_int(self, num);
 }
 
-#ifdef notused
 void jsonw_null_field(json_writer_t *self, const char *prop)
 {
 	jsonw_name(self, prop);
 	jsonw_null(self);
 }
-#endif
 
 #ifdef TEST
 int main(int argc, char **argv)
-- 
2.14.1
