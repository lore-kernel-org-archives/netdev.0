From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v3 1/5] json_writer: allow base json
 data type to be array or object
Date: Tue, 21 Jun 2016 09:12:10 -0700
Message-ID: <20160621091210.092baa99@xeon-e3>
References: <1466491187-8536-1-git-send-email-roopa@cumulusnetworks.com>
	<1466491187-8536-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, anuradhak@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, julien@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33363 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbcFUQNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 12:13:49 -0400
Received: by mail-pf0-f180.google.com with SMTP id i123so8027191pfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 09:11:57 -0700 (PDT)
In-Reply-To: <1466491187-8536-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Jun 2016 23:39:43 -0700
Roopa Prabhu <roopa@cumulusnetworks.com> wrote:

> From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> 
> This patch adds a type qualifier to json_writer. Type can be a
> json object or array. This can be extended to other types like
> json-string, json-number etc in the future.
> 
> Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Since json writer is not used in many places yet, why not just
get rid of the automatic object in the constructor.



diff --git a/lib/json_writer.c b/lib/json_writer.c
index 2af16e1..5e588d8 100644
--- a/lib/json_writer.c
+++ b/lib/json_writer.c
@@ -102,7 +102,6 @@ json_writer_t *jsonw_new(FILE *f)
 		self->depth = 0;
 		self->pretty = false;
 		self->sep = '\0';
-		putc('{', self->out);
 	}
 	return self;
 }
@@ -114,7 +113,6 @@ void jsonw_destroy(json_writer_t **self_p)
 
 	assert(self->depth == 0);
 	jsonw_eol(self);
-	fputs("}\n", self->out);
 	fflush(self->out);
 	free(self);
 	*self_p = NULL;
diff --git a/misc/ifstat.c b/misc/ifstat.c
index abbb4e7..d9a7e50 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -246,7 +246,6 @@ static void dump_raw_db(FILE *fp, int to_hist)
 	h = hist_db;
 	if (jw) {
 		jsonw_pretty(jw, pretty);
-		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
 	} else
 		fprintf(fp, "#%s\n", info_source);
@@ -452,7 +451,6 @@ static void dump_kern_db(FILE *fp)
 
 	if (jw) {
 		jsonw_pretty(jw, pretty);
-		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
 	} else
 		print_head(fp);
@@ -466,8 +464,10 @@ static void dump_kern_db(FILE *fp)
 		else
 			print_one_if(fp, n, n->val);
 	}
-	if (json_output)
-		fprintf(fp, "\n} }\n");
+	if (jw) {
+		jsonw_end_object(jw);
+		jsonw_destroy(&jw);
+	}
 }
 
 static void dump_incr_db(FILE *fp)
@@ -478,7 +478,6 @@ static void dump_incr_db(FILE *fp)
 	h = hist_db;
 	if (jw) {
 		jsonw_pretty(jw, pretty);
-		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
 	} else
 		print_head(fp);
diff --git a/misc/nstat.c b/misc/nstat.c
index a9e0f20..411cd87 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -285,7 +285,6 @@ static void dump_kern_db(FILE *fp, int to_hist)
 	h = hist_db;
 	if (jw) {
 		jsonw_pretty(jw, pretty);
-		jsonw_name(jw, info_source);
 		jsonw_start_object(jw);
 	} else
 		fprintf(fp, "#%s\n", info_source);
