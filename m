From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v3 1/5] json_writer: allow base json data type to be array or object
Date: Mon, 20 Jun 2016 23:39:43 -0700
Message-ID: <1466491187-8536-2-git-send-email-roopa@cumulusnetworks.com>
References: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36255 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109AbcFUGj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 02:39:58 -0400
Received: by mail-pa0-f50.google.com with SMTP id wo6so3290530pac.3
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 23:39:57 -0700 (PDT)
In-Reply-To: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

This patch adds a type qualifier to json_writer. Type can be a
json object or array. This can be extended to other types like
json-string, json-number etc in the future.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
---
 include/json_writer.h |  5 +++--
 lib/json_writer.c     | 39 +++++++++++++++++++++++++++++++++++----
 misc/ifstat.c         |  6 +++---
 misc/lnstat.c         |  2 +-
 misc/nstat.c          |  4 ++--
 5 files changed, 44 insertions(+), 12 deletions(-)

diff --git a/include/json_writer.h b/include/json_writer.h
index ab9a008..e04a40a 100644
--- a/include/json_writer.h
+++ b/include/json_writer.h
@@ -21,8 +21,9 @@
 /* Opaque class structure */
 typedef struct json_writer json_writer_t;
 
-/* Create a new JSON stream */
-json_writer_t *jsonw_new(FILE *f);
+/* Create a new JSON stream with data type */
+json_writer_t *jsonw_new_object(FILE *f);
+json_writer_t *jsonw_new_array(FILE *f);
 /* End output to JSON stream */
 void jsonw_destroy(json_writer_t **self_p);
 
diff --git a/lib/json_writer.c b/lib/json_writer.c
index 2af16e1..420cd87 100644
--- a/lib/json_writer.c
+++ b/lib/json_writer.c
@@ -22,11 +22,17 @@
 
 #include "json_writer.h"
 
+enum jsonw_data_type {
+	JSONW_TYPE_OBJECT,
+	JSONW_TYPE_ARRAY
+};
+
 struct json_writer {
 	FILE		*out;	/* output file */
 	unsigned	depth;  /* nesting */
 	bool		pretty; /* optional whitepace */
 	char		sep;	/* either nul or comma */
+	int		type;	/* currently either object or array */
 };
 
 /* indentation for pretty print */
@@ -94,7 +100,7 @@ static void jsonw_puts(json_writer_t *self, const char *str)
 }
 
 /* Create a new JSON stream */
-json_writer_t *jsonw_new(FILE *f)
+static json_writer_t *jsonw_new(FILE *f, int type)
 {
 	json_writer_t *self = malloc(sizeof(*self));
 	if (self) {
@@ -102,11 +108,29 @@ json_writer_t *jsonw_new(FILE *f)
 		self->depth = 0;
 		self->pretty = false;
 		self->sep = '\0';
-		putc('{', self->out);
+		self->type = type;
+		switch (self->type) {
+		case JSONW_TYPE_OBJECT:
+			putc('{', self->out);
+			break;
+		case JSONW_TYPE_ARRAY:
+			putc('[', self->out);
+			break;
+		}
 	}
 	return self;
 }
 
+json_writer_t *jsonw_new_object(FILE *f)
+{
+	return jsonw_new(f, JSONW_TYPE_OBJECT);
+}
+
+json_writer_t *jsonw_new_array(FILE *f)
+{
+	return jsonw_new(f, JSONW_TYPE_ARRAY);
+}
+
 /* End output to JSON stream */
 void jsonw_destroy(json_writer_t **self_p)
 {
@@ -114,7 +138,14 @@ void jsonw_destroy(json_writer_t **self_p)
 
 	assert(self->depth == 0);
 	jsonw_eol(self);
-	fputs("}\n", self->out);
+	switch (self->type) {
+	case JSONW_TYPE_OBJECT:
+		fputs("}\n", self->out);
+		break;
+	case JSONW_TYPE_ARRAY:
+		fputs("]\n", self->out);
+		break;
+	}
 	fflush(self->out);
 	free(self);
 	*self_p = NULL;
@@ -267,7 +298,7 @@ void jsonw_null_field(json_writer_t *self, const char *prop)
 #ifdef TEST
 int main(int argc, char **argv)
 {
-	json_writer_t *wr = jsonw_new(stdout);
+	json_writer_t *wr = jsonw_new_object(stdout);
 
 	jsonw_pretty(wr, true);
 	jsonw_name(wr, "Vyatta");
diff --git a/misc/ifstat.c b/misc/ifstat.c
index abbb4e7..29aa63c 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -240,7 +240,7 @@ static void load_raw_table(FILE *fp)
 
 static void dump_raw_db(FILE *fp, int to_hist)
 {
-	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
+	json_writer_t *jw = json_output ? jsonw_new_object(fp) : NULL;
 	struct ifstat_ent *n, *h;
 
 	h = hist_db;
@@ -447,7 +447,7 @@ static void print_one_if(FILE *fp, const struct ifstat_ent *n,
 
 static void dump_kern_db(FILE *fp)
 {
-	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
+	json_writer_t *jw = json_output ? jsonw_new_object(fp) : NULL;
 	struct ifstat_ent *n;
 
 	if (jw) {
@@ -473,7 +473,7 @@ static void dump_kern_db(FILE *fp)
 static void dump_incr_db(FILE *fp)
 {
 	struct ifstat_ent *n, *h;
-	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
+	json_writer_t *jw = json_output ? jsonw_new_object(fp) : NULL;
 
 	h = hist_db;
 	if (jw) {
diff --git a/misc/lnstat.c b/misc/lnstat.c
index 659a01b..2988e9e 100644
--- a/misc/lnstat.c
+++ b/misc/lnstat.c
@@ -110,7 +110,7 @@ static void print_line(FILE *of, const struct lnstat_file *lnstat_files,
 static void print_json(FILE *of, const struct lnstat_file *lnstat_files,
 		       const struct field_params *fp)
 {
-	json_writer_t *jw = jsonw_new(of);
+	json_writer_t *jw = jsonw_new_object(of);
 	int i;
 
 	jsonw_start_object(jw);
diff --git a/misc/nstat.c b/misc/nstat.c
index a9e0f20..7ca6204 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -279,7 +279,7 @@ static void load_netstat(void)
 
 static void dump_kern_db(FILE *fp, int to_hist)
 {
-	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
+	json_writer_t *jw = json_output ? jsonw_new_object(fp) : NULL;
 	struct nstat_ent *n, *h;
 
 	h = hist_db;
@@ -323,7 +323,7 @@ static void dump_kern_db(FILE *fp, int to_hist)
 
 static void dump_incr_db(FILE *fp)
 {
-	json_writer_t *jw = json_output ? jsonw_new(fp) : NULL;
+	json_writer_t *jw = json_output ? jsonw_new_object(fp) : NULL;
 	struct nstat_ent *n, *h;
 
 	h = hist_db;
-- 
1.9.1
