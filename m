From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: Fix meta match u32 with 0xffffffff
Date: Tue, 12 Apr 2011 10:31:24 -0700
Message-ID: <20110412103124.27dfb91e@nehalam>
References: <20110411115234.74b5936b@nehalam>
	<1302595009.3664.8.camel@lsx>
	<20110412081907.4f2e21fd@nehalam>
	<1302628925.3664.20.camel@lsx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: tgraf@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53019 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757068Ab1DLRb1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 13:31:27 -0400
In-Reply-To: <1302628925.3664.20.camel@lsx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 19:22:05 +0200
Thomas Graf <tgraf@redhat.com> wrote:

> On Tue, 2011-04-12 at 08:19 -0700, Stephen Hemminger wrote:
> 
> > > 
> > > This is definitely much better but we still can't parse ULONG_MAX
> > > as string representative. Checking glibc docs, the only way to do it is
> > > to ignore the return value for error checking and look errno.
> > > 
> > 
> > I think the error case is ret == ULONG_MAX && errno == ERANGE
> > If there is no error, then strtoul doesn't set errno.
> 
> That's ok too but your patch adds ret == ULONG_MAX || errno == ERANGE
> which will not allow to parse ULONG_MAX as a string. You probably
> still have to clear errno to 0 before calling strtoul in case
> ULONG_MAX is meant as legitimate return value but a previous glibc
> function has left errno set to ERANGE.
> 

I changed to && in final version.
Still needs more work because most of the code assumes that
unsigned long can be used for mask etc, when infact the code only
allows for u32. 

>From 63da1ed89970af18383c7318deb38bdb062fe74e Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 11 Apr 2011 11:48:55 -0700
Subject: [PATCH 1/2] Fix meta match u32 with 0xffffffff

The value 0xffffffff is a valid mask and bstrtoul() would return
ULONG_MAX which was the error value.
---
 tc/em_cmp.c   |   12 ++++--------
 tc/em_meta.c  |    9 +++------
 tc/em_nbyte.c |    6 ++----
 tc/em_u32.c   |   19 +++++++++----------
 tc/m_ematch.c |   17 +++++++++++------
 tc/m_ematch.h |    2 +-
 6 files changed, 30 insertions(+), 35 deletions(-)

diff --git a/tc/em_cmp.c b/tc/em_cmp.c
index 6addce0..af3e591 100644
--- a/tc/em_cmp.c
+++ b/tc/em_cmp.c
@@ -69,8 +69,7 @@ static int cmp_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 				return PARSE_ERR(a, "cmp: missing argument");
 			a = bstr_next(a);
 
-			offset = bstrtoul(a);
-			if (offset == ULONG_MAX)
+			if (bstrtoul(a, &offset) < 0)
 				return PARSE_ERR(a, "cmp: invalid offset, " \
 				    "must be numeric");
 
@@ -82,8 +81,7 @@ static int cmp_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 
 			layer = parse_layer(a);
 			if (layer == INT_MAX) {
-				layer = bstrtoul(a);
-				if (layer == ULONG_MAX)
+				if (bstrtoul(a, &layer) < 0)
 					return PARSE_ERR(a, "cmp: invalid " \
 					    "layer");
 			}
@@ -96,8 +94,7 @@ static int cmp_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 				return PARSE_ERR(a, "cmp: missing argument");
 			a = bstr_next(a);
 
-			mask = bstrtoul(a);
-			if (mask == ULONG_MAX)
+			if (bstrtoul(a, &mask) < 0)
 				return PARSE_ERR(a, "cmp: invalid mask");
 		} else if (!bstrcmp(a, "trans")) {
 			cmp.flags |= TCF_EM_CMP_TRANS;
@@ -115,8 +112,7 @@ static int cmp_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 				return PARSE_ERR(a, "cmp: missing argument");
 			a = bstr_next(a);
 
-			value = bstrtoul(a);
-			if (value == ULONG_MAX)
+			if (bstrtoul(a, &value) < 0)
 				return PARSE_ERR(a, "cmp: invalid value");
 
 			value_present = 1;
diff --git a/tc/em_meta.c b/tc/em_meta.c
index 033e29f..276223a 100644
--- a/tc/em_meta.c
+++ b/tc/em_meta.c
@@ -260,8 +260,7 @@ parse_object(struct bstr *args, struct bstr *arg, struct tcf_meta_val *obj,
 		return bstr_next(arg);
 	}
 
-	num = bstrtoul(arg);
-	if (num != ULONG_MAX) {
+	if (bstrtoul(arg, &num) < 0) {
 		obj->kind = TCF_META_TYPE_INT << 12;
 		obj->kind |= TCF_META_ID_VALUE;
 		*dst = (unsigned long) num;
@@ -318,8 +317,7 @@ compatible:
 			}
 			a = bstr_next(a);
 
-			shift = bstrtoul(a);
-			if (shift == ULONG_MAX) {
+			if (bstrtoul(a, &shift) < 0) {
 				PARSE_ERR(a, "meta: invalid shift, must " \
 				    "be numeric");
 				return PARSE_FAILURE;
@@ -336,8 +334,7 @@ compatible:
 			}
 			a = bstr_next(a);
 
-			mask = bstrtoul(a);
-			if (mask == ULONG_MAX) {
+			if (bstrtoul(a, &mask) < 0) {
 				PARSE_ERR(a, "meta: invalid mask, must be " \
 				    "numeric");
 				return PARSE_FAILURE;
diff --git a/tc/em_nbyte.c b/tc/em_nbyte.c
index 87f3e9d..9a52ffc 100644
--- a/tc/em_nbyte.c
+++ b/tc/em_nbyte.c
@@ -63,8 +63,7 @@ static int nbyte_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 				return PARSE_ERR(a, "nbyte: missing argument");
 			a = bstr_next(a);
 
-			offset = bstrtoul(a);
-			if (offset == ULONG_MAX)
+			if (bstrtoul(a, &offset) < 0)
 				return PARSE_ERR(a, "nbyte: invalid offset, " \
 				    "must be numeric");
 
@@ -76,8 +75,7 @@ static int nbyte_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 
 			layer = parse_layer(a);
 			if (layer == INT_MAX) {
-				layer = bstrtoul(a);
-				if (layer == ULONG_MAX)
+				if (bstrtoul(a, &layer) < 0)
 					return PARSE_ERR(a, "nbyte: invalid " \
 					    "layer");
 			}
diff --git a/tc/em_u32.c b/tc/em_u32.c
index 21ed70f..88b5fa1 100644
--- a/tc/em_u32.c
+++ b/tc/em_u32.c
@@ -33,6 +33,7 @@ static void u32_print_usage(FILE *fd)
 	    "Example: u32(u16 0x1122 0xffff at nexthdr+4)\n");
 }
 
+
 static int u32_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 			  struct bstr *args)
 {
@@ -62,16 +63,14 @@ static int u32_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 	if (a == NULL)
 		return PARSE_ERR(a, "u32: missing key");
 
-	key = bstrtoul(a);
-	if (key == ULONG_MAX)
+	if (bstrtoul(a, &key) < 0)
 		return PARSE_ERR(a, "u32: invalid key, must be numeric");
 
 	a = bstr_next(a);
 	if (a == NULL)
 		return PARSE_ERR(a, "u32: missing mask");
 
-	mask = bstrtoul(a);
-	if (mask == ULONG_MAX)
+	if (bstrtoul(a, &mask) < 0)
 		return PARSE_ERR(a, "u32: invalid mask, must be numeric");
 
 	a = bstr_next(a);
@@ -92,12 +91,12 @@ static int u32_parse_eopt(struct nlmsghdr *n, struct tcf_ematch_hdr *hdr,
 		a = bstr_next(a);
 		if (a == NULL)
 			return PARSE_ERR(a, "u32: missing offset");
-		offset = bstrtoul(a);
-	} else
-		offset = bstrtoul(a);
-
-	if (offset == ULONG_MAX)
-		return PARSE_ERR(a, "u32: invalid offset");
+		if (bstrtoul(a, &offset) < 0)
+			return PARSE_ERR(a, "u32: invalid offset");
+	} else {
+		if (bstrtoul(a, &offset) < 0)
+			return PARSE_ERR(a, "u32: invalid offset");
+	}
 
 	if (a->next)
 		return PARSE_ERR(a->next, "u32: unexpected trailer");
diff --git a/tc/m_ematch.c b/tc/m_ematch.c
index 4c3acf8..b7eed18 100644
--- a/tc/m_ematch.c
+++ b/tc/m_ematch.c
@@ -510,20 +510,25 @@ struct bstr * bstr_alloc(const char *text)
 	return b;
 }
 
-unsigned long bstrtoul(const struct bstr *b)
+int bstrtoul(const struct bstr *b, unsigned long *lp)
 {
 	char *inv = NULL;
-	unsigned long l;
 	char buf[b->len+1];
 
+	if (b->len == 0)
+		return -EINVAL;
+
 	memcpy(buf, b->data, b->len);
 	buf[b->len] = '\0';
 
-	l = strtoul(buf, &inv, 0);
-	if (l == ULONG_MAX || inv == buf)
-		return ULONG_MAX;
+	*lp = strtoul(buf, &inv, 0);
+	if (inv == buf)
+		return -EINVAL;
+
+	if (*lp == ULONG_MAX && errno == ERANGE)
+		return -ERANGE;
 
-	return l;
+	return 0;
 }
 
 void bstr_print(FILE *fd, const struct bstr *b, int ascii)
diff --git a/tc/m_ematch.h b/tc/m_ematch.h
index 5036e9b..e676290 100644
--- a/tc/m_ematch.h
+++ b/tc/m_ematch.h
@@ -49,7 +49,7 @@ static inline struct bstr *bstr_next(struct bstr *b)
 	return b->next;
 }
 
-extern unsigned long bstrtoul(const struct bstr *b);
+extern int bstrtoul(const struct bstr *b, unsigned long *lp);
 extern void bstr_print(FILE *fd, const struct bstr *b, int ascii);
 
 
-- 
1.7.1

