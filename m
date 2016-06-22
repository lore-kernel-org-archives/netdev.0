From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2 3/3] ss: Add support to filter on device
Date: Tue, 21 Jun 2016 20:38:26 -0700
Message-ID: <1466566706-1511-4-git-send-email-dsa@cumulusnetworks.com>
References: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33421 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbcFVDij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 23:38:39 -0400
Received: by mail-pf0-f176.google.com with SMTP id i123so13017530pfg.0
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 20:38:37 -0700 (PDT)
In-Reply-To: <1466566706-1511-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for device names in the filter. Example:

    root@kenny:~# ss -t  'sport == :22 && dev == red'
    State      Recv-Q Send-Q     Local Address:Port      Peer Address:Port
    ESTAB      0      0          10.100.1.2%red:ssh      10.100.1.254:47814
    ESTAB      0      0           2100:1::2%red:ssh        2100:1::64:49406

Since kernel does not support iface in the filter specifying a
device name means all filtering is done in userspace.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 misc/ss.c       | 32 ++++++++++++++++++++++++++++++++
 misc/ssfilter.h |  2 ++
 misc/ssfilter.y | 22 +++++++++++++++++++++-
 3 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3419a88c33be..6f0ad0295918 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1043,6 +1043,7 @@ static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex
 struct aafilter {
 	inet_prefix	addr;
 	int		port;
+	unsigned int	iface;
 	struct aafilter *next;
 };
 
@@ -1157,7 +1158,12 @@ static int run_ssfilter(struct ssfilter *f, struct sockstat *s)
 
 		return s->lport <= a->port;
 	}
+		case SSF_DEVCOND:
+	{
+		struct aafilter *a = (void *)f->pred;
 
+		return s->iface == a->iface;
+	}
 		/* Yup. It is recursion. Sorry. */
 		case SSF_AND:
 		return run_ssfilter(f->pred, s) && run_ssfilter(f->post, s);
@@ -1328,6 +1334,11 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
 		*bytecode = a;
 		return l1+4;
 	}
+               case SSF_DEVCOND:
+	{
+		/* bytecompile for SSF_DEVCOND not supported yet */
+                return 0;
+	}
 		default:
 		abort();
 	}
@@ -1416,6 +1427,27 @@ static int xll_name_to_index(const char *dev)
 	return ll_name_to_index(dev);
 }
 
+void *parse_devcond(char *name)
+{
+	struct aafilter a = { .iface = 0 };
+	struct aafilter *res;
+
+	a.iface = xll_name_to_index(name);
+	if (a.iface == 0) {
+		char *end;
+		unsigned long res;
+
+		res = strtoul(name, &end, 0);
+		if (!end || end == name || *end || res > UINT_MAX)
+			return NULL;
+	}
+
+	res = malloc(sizeof(*res));
+	*res = a;
+
+	return res;
+}
+
 void *parse_hostcond(char *addr, bool is_port)
 {
 	char *port = NULL;
diff --git a/misc/ssfilter.h b/misc/ssfilter.h
index 53922a844457..c7db8eee9578 100644
--- a/misc/ssfilter.h
+++ b/misc/ssfilter.h
@@ -8,6 +8,7 @@
 #define SSF_S_GE  7
 #define SSF_S_LE  8
 #define SSF_S_AUTO  9
+#define SSF_DEVCOND 10
 
 #include <stdbool.h>
 
@@ -20,3 +21,4 @@ struct ssfilter
 
 int ssfilter_parse(struct ssfilter **f, int argc, char **argv, FILE *fp);
 void *parse_hostcond(char *addr, bool is_port);
+void *parse_devcond(char *name);
diff --git a/misc/ssfilter.y b/misc/ssfilter.y
index a258d04b85d7..14bf9817f2c3 100644
--- a/misc/ssfilter.y
+++ b/misc/ssfilter.y
@@ -36,7 +36,7 @@ static void yyerror(char *s)
 
 %}
 
-%token HOSTCOND DCOND SCOND DPORT SPORT LEQ GEQ NEQ AUTOBOUND
+%token HOSTCOND DCOND SCOND DPORT SPORT LEQ GEQ NEQ AUTOBOUND DEVCOND DEVNAME
 %left '|'
 %left '&'
 %nonassoc '!'
@@ -108,6 +108,14 @@ expr:	DCOND HOSTCOND
         {
 		$$ = alloc_node(SSF_NOT, alloc_node(SSF_SCOND, $3));
         }
+        | DEVNAME '=' DEVCOND
+        {
+		$$ = alloc_node(SSF_DEVCOND, $3);
+        }
+        | DEVNAME NEQ DEVCOND
+        {
+		$$ = alloc_node(SSF_NOT, alloc_node(SSF_DEVCOND, $3));
+        }
 
         | AUTOBOUND
         {
@@ -237,6 +245,10 @@ int yylex(void)
 		tok_type = SPORT;
 		return SPORT;
 	}
+	if (strcmp(curtok, "dev") == 0) {
+		tok_type = DEVNAME;
+		return DEVNAME;
+	}
 	if (strcmp(curtok, ">=") == 0 ||
 	    strcmp(curtok, "ge") == 0 ||
 	    strcmp(curtok, "geq") == 0)
@@ -263,6 +275,14 @@ int yylex(void)
 		tok_type = AUTOBOUND;
 		return AUTOBOUND;
 	}
+	if (tok_type == DEVNAME) {
+		yylval = (void*)parse_devcond(curtok);
+		if (yylval == NULL) {
+			fprintf(stderr, "Cannot parse device.\n");
+			exit(1);
+		}
+		return DEVCOND;
+	}
 	yylval = (void*)parse_hostcond(curtok, tok_type == SPORT || tok_type == DPORT);
 	if (yylval == NULL) {
 		fprintf(stderr, "Cannot parse dst/src address.\n");
-- 
2.1.4
