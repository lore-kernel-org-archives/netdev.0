From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: speedup resolve_service()
Date: Fri, 29 May 2015 04:45:48 -0700
Message-ID: <1432899948.7456.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:36010 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755443AbbE2Lpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 07:45:50 -0400
Received: by iepj10 with SMTP id j10so60269827iep.3
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 04:45:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lets implement a full cache with proper hash table, memory got cheaper
these days.

Before :

$ time ss -t | wc -l
529678

real	0m22.708s
user	0m19.591s
sys	0m2.969s

After :

$ time ss -t | wc -l 
528291

real	0m5.078s
user	0m4.099s
sys	0m0.985s


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |   71 +++++++++++++++++++++++-----------------------------
 1 file changed, 32 insertions(+), 39 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 347e3a1..3f4b7f1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -858,8 +858,7 @@ static const char *print_ms_timer(int timeout)
 	return buf;
 }
 
-struct scache
-{
+struct scache {
 	struct scache *next;
 	int port;
 	char *name;
@@ -949,11 +948,15 @@ static const char *__resolve_service(int port)
 	return NULL;
 }
 
+#define SCACHE_BUCKETS 1024
+static struct scache *cache_htab[SCACHE_BUCKETS];
 
 static const char *resolve_service(int port)
 {
 	static char buf[128];
-	static struct scache cache[256];
+	struct scache *c;
+	const char *res;
+	int hash;
 
 	if (port == 0) {
 		buf[0] = '*';
@@ -961,45 +964,35 @@ static const char *resolve_service(int port)
 		return buf;
 	}
 
-	if (resolve_services) {
-		if (dg_proto == RAW_PROTO) {
-			return inet_proto_n2a(port, buf, sizeof(buf));
-		} else {
-			struct scache *c;
-			const char *res;
-			int hash = (port^(((unsigned long)dg_proto)>>2))&255;
-
-			for (c = &cache[hash]; c; c = c->next) {
-				if (c->port == port &&
-				    c->proto == dg_proto) {
-					if (c->name)
-						return c->name;
-					goto do_numeric;
-				}
-			}
+	if (!resolve_services)
+		goto do_numeric;
 
-			if ((res = __resolve_service(port)) != NULL) {
-				if ((c = malloc(sizeof(*c))) == NULL)
-					goto do_numeric;
-			} else {
-				c = &cache[hash];
-				if (c->name)
-					free(c->name);
-			}
-			c->port = port;
-			c->name = NULL;
-			c->proto = dg_proto;
-			if (res) {
-				c->name = strdup(res);
-				c->next = cache[hash].next;
-				cache[hash].next = c;
-			}
-			if (c->name)
-				return c->name;
-		}
+	if (dg_proto == RAW_PROTO)
+		return inet_proto_n2a(port, buf, sizeof(buf));
+
+
+	hash = (port^(((unsigned long)dg_proto)>>2)) % SCACHE_BUCKETS;
+
+	for (c = cache_htab[hash]; c; c = c->next) {
+		if (c->port == port && c->proto == dg_proto)
+			goto do_cache;
 	}
 
-	do_numeric:
+	c = malloc(sizeof(*c));
+	if (!c)
+		goto do_numeric;
+	res = __resolve_service(port);
+	c->port = port;
+	c->name = res ? strdup(res) : NULL;
+	c->proto = dg_proto;
+	c->next = cache_htab[hash];
+	cache_htab[hash] = c;
+
+do_cache:
+	if (c->name)
+		return c->name;
+
+do_numeric:
 	sprintf(buf, "%u", port);
 	return buf;
 }
