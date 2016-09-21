From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH iproute2] ss: Support displaying and filtering on socket marks.
Date: Thu, 22 Sep 2016 01:02:50 +0900
Message-ID: <1474473770-81126-1-git-send-email-lorenzo@google.com>
Cc: shemming@brocade.com, zenczykowski@gmail.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33930 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933689AbcIUQDx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 12:03:53 -0400
Received: by mail-pa0-f41.google.com with SMTP id wk8so19725058pab.1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 09:02:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows the user to dump sockets with a given mark (via
"fwmark = 0x1234/0x1234" or "fwmark = 12345", etc.) , and to
display the socket marks of dumped sockets.

The relevant kernel commits are: d545caca827b ("net: inet: diag:
expose the socket mark to privileged processes.") and
- a52e95abf772 ("net: diag: allow socket bytecode filters to
match socket marks")

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/linux/inet_diag.h |  7 +++++++
 misc/ss.c                 | 52 +++++++++++++++++++++++++++++++++++++++++++++++
 misc/ssfilter.h           |  2 ++
 misc/ssfilter.y           | 23 +++++++++++++++++++--
 4 files changed, 82 insertions(+), 2 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index beb74ee..016de88 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -73,6 +73,7 @@ enum {
 	INET_DIAG_BC_S_COND,
 	INET_DIAG_BC_D_COND,
 	INET_DIAG_BC_DEV_COND,   /* u32 ifindex */
+	INET_DIAG_BC_MARK_COND,
 };
 
 struct inet_diag_hostcond {
@@ -82,6 +83,11 @@ struct inet_diag_hostcond {
 	__be32	addr[0];
 };
 
+struct inet_diag_markcond {
+	__u32 mark;
+	__u32 mask;
+};
+
 /* Base info structure. It contains socket identity (addrs/ports/cookie)
  * and, alas, the information shown by netstat. */
 struct inet_diag_msg {
@@ -117,6 +123,7 @@ enum {
 	INET_DIAG_LOCALS,
 	INET_DIAG_PEERS,
 	INET_DIAG_PAD,
+	INET_DIAG_MARK,
 	__INET_DIAG_MAX,
 };
 
diff --git a/misc/ss.c b/misc/ss.c
index 3b268d9..83fb01f 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -737,6 +737,7 @@ struct sockstat {
 	unsigned long long  sk;
 	char *name;
 	char *peer_name;
+	__u32		    mark;
 };
 
 struct dctcpstat {
@@ -807,6 +808,9 @@ static void sock_details_print(struct sockstat *s)
 
 	printf(" ino:%u", s->ino);
 	printf(" sk:%llx", s->sk);
+
+	if (s->mark)
+		printf(" fwmark:0x%x", s->mark);
 }
 
 static void sock_addr_print_width(int addr_len, const char *addr, char *delim,
@@ -1046,6 +1050,8 @@ struct aafilter {
 	inet_prefix	addr;
 	int		port;
 	unsigned int	iface;
+	__u32		mark;
+	__u32		mask;
 	struct aafilter *next;
 };
 
@@ -1166,6 +1172,12 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 
 		return s->iface == a->iface;
 	}
+		case SSF_MARKMASK:
+	{
+		struct aafilter *a = (void *)f->pred;
+
+		return (s->mark & a->mask) == a->mark;
+	}
 		/* Yup. It is recursion. Sorry. */
 		case SSF_AND:
 		return run_ssfilter(f->pred, s) && run_ssfilter(f->post, s);
@@ -1341,6 +1353,23 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 		/* bytecompile for SSF_DEVCOND not supported yet */
 		return 0;
 	}
+		case SSF_MARKMASK:
+	{
+		struct aafilter *a = (void *)f->pred;
+		struct instr {
+			struct inet_diag_bc_op op;
+			struct inet_diag_markcond cond;
+		};
+		int inslen = sizeof(struct instr);
+
+		if (!(*bytecode = malloc(inslen))) abort();
+		((struct instr *)*bytecode)[0] = (struct instr) {
+			{ INET_DIAG_BC_MARK_COND, inslen, inslen + 4 },
+			{ a->mark, a->mask},
+		};
+
+		return inslen;
+	}
 		default:
 		abort();
 	}
@@ -1620,6 +1649,25 @@ out:
 	return res;
 }
 
+void *parse_markmask(const char *markmask)
+{
+	struct aafilter a, *res;
+
+	if (strchr(markmask, '/')) {
+		if (sscanf(markmask, "%i/%i", &a.mark, &a.mask) != 2)
+			return NULL;
+	} else {
+		a.mask = 0xffffffff;
+		if (sscanf(markmask, "%i", &a.mark) != 1)
+			return NULL;
+	}
+
+	res = malloc(sizeof(*res));
+	if (res)
+		memcpy(res, &a, sizeof(a));
+	return res;
+}
+
 static char *proto_name(int protocol)
 {
 	switch (protocol) {
@@ -2107,6 +2155,10 @@ static void parse_diag_msg(struct nlmsghdr *nlh, struct sockstat *s)
 	s->iface	= r->id.idiag_if;
 	s->sk		= cookie_sk_get(&r->id.idiag_cookie[0]);
 
+	s->mark = 0;
+	if (tb[INET_DIAG_MARK])
+		s->mark = *(__u32 *) RTA_DATA(tb[INET_DIAG_MARK]);
+
 	if (s->local.family == AF_INET)
 		s->local.bytelen = s->remote.bytelen = 4;
 	else
diff --git a/misc/ssfilter.h b/misc/ssfilter.h
index c7db8ee..dfc5b93 100644
--- a/misc/ssfilter.h
+++ b/misc/ssfilter.h
@@ -9,6 +9,7 @@
 #define SSF_S_LE  8
 #define SSF_S_AUTO  9
 #define SSF_DEVCOND 10
+#define SSF_MARKMASK 11
 
 #include <stdbool.h>
 
@@ -22,3 +23,4 @@ struct ssfilter
 int ssfilter_parse(struct ssfilter **f, int argc, char **argv, FILE *fp);
 void *parse_hostcond(char *addr, bool is_port);
 void *parse_devcond(char *name);
+void *parse_markmask(const char *markmask);
diff --git a/misc/ssfilter.y b/misc/ssfilter.y
index 14bf981..ba82b65 100644
--- a/misc/ssfilter.y
+++ b/misc/ssfilter.y
@@ -36,7 +36,7 @@ static void yyerror(char *s)
 
 %}
 
-%token HOSTCOND DCOND SCOND DPORT SPORT LEQ GEQ NEQ AUTOBOUND DEVCOND DEVNAME
+%token HOSTCOND DCOND SCOND DPORT SPORT LEQ GEQ NEQ AUTOBOUND DEVCOND DEVNAME MARKMASK FWMARK
 %left '|'
 %left '&'
 %nonassoc '!'
@@ -116,7 +116,14 @@ expr:	DCOND HOSTCOND
         {
 		$$ = alloc_node(SSF_NOT, alloc_node(SSF_DEVCOND, $3));
         }
-
+        | FWMARK '=' MARKMASK
+        {
+                $$ = alloc_node(SSF_MARKMASK, $3);
+        }
+        | FWMARK NEQ MARKMASK
+        {
+                $$ = alloc_node(SSF_NOT, alloc_node(SSF_MARKMASK, $3));
+        }
         | AUTOBOUND
         {
                 $$ = alloc_node(SSF_S_AUTO, NULL);
@@ -249,6 +256,10 @@ int yylex(void)
 		tok_type = DEVNAME;
 		return DEVNAME;
 	}
+	if (strcmp(curtok, "fwmark") == 0) {
+		tok_type = FWMARK;
+		return FWMARK;
+	}
 	if (strcmp(curtok, ">=") == 0 ||
 	    strcmp(curtok, "ge") == 0 ||
 	    strcmp(curtok, "geq") == 0)
@@ -283,6 +294,14 @@ int yylex(void)
 		}
 		return DEVCOND;
 	}
+	if (tok_type == FWMARK) {
+		yylval = (void*)parse_markmask(curtok);
+		if (yylval == NULL) {
+			fprintf(stderr, "Cannot parse mark %s.\n", curtok);
+			exit(1);
+		}
+		return MARKMASK;
+	}
 	yylval = (void*)parse_hostcond(curtok, tok_type == SPORT || tok_type == DPORT);
 	if (yylval == NULL) {
 		fprintf(stderr, "Cannot parse dst/src address.\n");
-- 
2.8.0.rc3.226.g39d4020
