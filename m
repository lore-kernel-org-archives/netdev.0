From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH][IPROUTE2] clean xfrm message format
Date: Tue, 3 Aug 2004 16:45:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803164539.41a0a975@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This is a patch for ip xfrm and against for the latest
snapshot(iproute2-2.6.8-ss040730.tar.gz). Please apply it.

Here is log:

  fix xfrm command line option and clean its output message format
  (commented by Herbert Xu <herbert@gondor.apana.org.au>).
  * fix to specify algorithm key correctly and its output format.
  * omit some items when they are zero/default.
  * fix output can be one line.
  * use "enc/auth/comp" instead of "E/A/C" for altorithm type.
  * show SPI in hex.
  * remove "sel" and "upspec" from command.

diff -uNr iproute2-2.6.8.orig/ip/ipxfrm.c iproute2-2.6.8/ip/ipxfrm.c
--- iproute2-2.6.8.orig/ip/ipxfrm.c	2004-07-30 15:28:47.000000000 -0700
+++ iproute2-2.6.8/ip/ipxfrm.c	2004-08-02 17:27:43.000000000 -0700
@@ -52,6 +52,48 @@
 	exit(-1);
 }
 
+struct typeent {
+	const char *t_name;
+	int t_type;
+};
+
+static const struct typeent algo_types[]= {
+	{ "enc", XFRMA_ALG_CRYPT }, { "auth", XFRMA_ALG_AUTH },
+	{ "comp", XFRMA_ALG_COMP }, { NULL, -1 }
+};
+
+int xfrm_algotype_getbyname(char *name)
+{
+	int i;
+
+	for (i = 0; ; i++) {
+		const struct typeent *t = &algo_types[i];
+		if (!t->t_name || t->t_type == -1)
+			break;
+
+		if (strcmp(t->t_name, name) == 0)
+			return t->t_type;
+	}
+
+	return -1;
+}
+
+const char *strxf_algotype(int type)
+{
+	int i;
+
+	for (i = 0; ; i++) {
+		const struct typeent *t = &algo_types[i];
+		if (!t->t_name || t->t_type == -1)
+			break;
+
+		if (t->t_type == type)
+			return t->t_name;
+	}
+
+	return NULL;
+}
+
 const char *strxf_flags(__u8 flags)
 {
 	static char str[16];
@@ -84,7 +126,7 @@
 		strcpy(str, "unique");
 		break;
 	default:
-		sprintf(str, "unknown-share(%d)", share);
+		sprintf(str, "%d", share);
 		break;
 	}
 
@@ -114,9 +156,6 @@
 {
 	char abuf[256];
 	__u32 spi;
-	struct protoent *pp;
-	char pbuf[32];
-	char *p;
 
 	if (prefix)
 		fprintf(fp, prefix);
@@ -125,26 +164,20 @@
 	fprintf(fp, "src %s ", rt_addr_n2a(family, sizeof(*saddr),
 					   saddr, abuf, sizeof(abuf)));
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s\n", rt_addr_n2a(family, sizeof(id->daddr),
-					    &id->daddr, abuf, sizeof(abuf)));
+	fprintf(fp, "dst %s", rt_addr_n2a(family, sizeof(id->daddr),
+					  &id->daddr, abuf, sizeof(abuf)));
+	fprintf(fp, "%s", _SL_);
 
 	if (prefix)
 		fprintf(fp, prefix);
 	fprintf(fp, "\t");
 
-	pp = getprotobynumber(id->proto);
-	if (pp)
-		p = pp->p_name;
-	else {
-		sprintf(pbuf, "%d", id->proto);
-		p = pbuf;
-	}
-	fprintf(fp, "proto %s ", p);
+	fprintf(fp, "proto %s ", strxf_proto(id->proto));
 
 	spi = ntohl(id->spi);
-	fprintf(fp, "spi %u", spi);
+	fprintf(fp, "spi 0x%08x", spi);
 	if (show_stats > 0)
-		fprintf(fp, "(0x%08x)", spi);
+		fprintf(fp, "(%u)", spi);
 	fprintf(fp, " ");
 
 	fprintf(fp, "reqid %u", reqid);
@@ -152,7 +185,19 @@
 		fprintf(fp, "(0x%08x)", reqid);
 	fprintf(fp, " ");
 
-	fprintf(fp, "mode %s\n", (mode ? "tunnel" : "transport"));
+	fprintf(fp, "mode ");
+	switch (mode) {
+	case 0:
+		fprintf(fp, "transport");
+		break;
+	case 1:
+		fprintf(fp, "tunnel");
+		break;
+	default:
+		fprintf(fp, "%u", mode);
+		break;
+	}
+	fprintf(fp, "%s", _SL_);
 }
 
 static const char *strxf_limit(__u64 limit)
@@ -170,7 +215,8 @@
 {
 	if (prefix)
 		fprintf(fp, prefix);
-	fprintf(fp, "stats:\n");
+	fprintf(fp, "stats:");
+	fprintf(fp, "%s", _SL_);
 
 	if (prefix)
 		fprintf(fp, prefix);
@@ -178,25 +224,26 @@
 	fprintf(fp, "replay-window %d ", s->replay_window);
 	fprintf(fp, "replay %d ", s->replay);
 	fprintf(fp, "failed %d", s->integrity_failed);
-	fprintf(fp, "\n");
+	fprintf(fp, "%s", _SL_);
 }
 
 static const char *strxf_time(__u64 time)
 {
 	static char str[32];
-	struct tm *tp;
-	time_t t;
 
-	if (time == 0) {
-		strcpy(str, "(undefined)");
-	} else {
-		/* XXX: treat time in the same manner of xfrm_{user,state}.c */
+	if (time == 0)
+		strcpy(str, "-");
+	else {
+		time_t t;
+		struct tm *tp;
+
+		/* XXX: treat time in the same manner of kernel's 
+		 * net/xfrm/xfrm_{user,state}.c
+		 */
 		t = (long)time;
 		tp = localtime(&t);
 
-		sprintf(str, "%04d/%02d/%02d %02d:%02d:%02d",
-			tp->tm_year + 1900, tp->tm_mon + 1, tp->tm_mday,
-			tp->tm_hour, tp->tm_min, tp->tm_sec);
+		strftime(str, sizeof(str), "%F %T", tp);
 	}
 
 	return str;
@@ -209,7 +256,8 @@
 	if (cfg) {
 		if (prefix)
 			fprintf(fp, prefix);
-		fprintf(fp, "lifetime config:\n");
+		fprintf(fp, "lifetime config:");
+		fprintf(fp, "%s", _SL_);
 
 		if (prefix)
 			fprintf(fp, prefix);
@@ -219,7 +267,8 @@
 		fprintf(fp, strxf_limit(cfg->soft_byte_limit));
 		fprintf(fp, "(bytes), hard ");
 		fprintf(fp, strxf_limit(cfg->hard_byte_limit));
-		fprintf(fp, "(bytes)\n");
+		fprintf(fp, "(bytes)");
+		fprintf(fp, "%s", _SL_);
 
 		if (prefix)
 			fprintf(fp, prefix);
@@ -229,7 +278,8 @@
 		fprintf(fp, strxf_limit(cfg->soft_packet_limit));
 		fprintf(fp, "(packets), hard ");
 		fprintf(fp, strxf_limit(cfg->hard_packet_limit));
-		fprintf(fp, "(packets)\n");
+		fprintf(fp, "(packets)");
+		fprintf(fp, "%s", _SL_);
 
 		if (prefix)
 			fprintf(fp, prefix);
@@ -239,7 +289,8 @@
 		fprintf(fp, "%llu", cfg->soft_add_expires_seconds);
 		fprintf(fp, "(sec), hard ");
 		fprintf(fp, "%llu", cfg->hard_add_expires_seconds);
-		fprintf(fp, "(sec)\n");
+		fprintf(fp, "(sec)");
+		fprintf(fp, "%s", _SL_);
 
 		if (prefix)
 			fprintf(fp, prefix);
@@ -249,24 +300,28 @@
 		fprintf(fp, "%llu", cfg->soft_use_expires_seconds);
 		fprintf(fp, "(sec), hard ");
 		fprintf(fp, "%llu", cfg->hard_use_expires_seconds);
-		fprintf(fp, "(sec)\n");
+		fprintf(fp, "(sec)");
+		fprintf(fp, "%s", _SL_);
 	}
 	if (cur) {
 		if (prefix)
 			fprintf(fp, prefix);
-		fprintf(fp, "lifetime current:\n");
+		fprintf(fp, "lifetime current:");
+		fprintf(fp, "%s", _SL_);
 
 		if (prefix)
 			fprintf(fp, prefix);
 		fprintf(fp, "  ");
 		fprintf(fp, "%llu(bytes), ", cur->bytes);
-		fprintf(fp, "%llu(packets)\n", cur->packets);
+		fprintf(fp, "%llu(packets)", cur->packets);
+		fprintf(fp, "%s", _SL_);
+
 		if (prefix)
 			fprintf(fp, prefix);
 		fprintf(fp, "  ");
 		fprintf(fp, "add %s ", strxf_time(cur->add_time));
 		fprintf(fp, "use %s", strxf_time(cur->use_time));
-		fprintf(fp, "\n");
+		fprintf(fp, "%s", _SL_);
 	}
 }
 
@@ -291,18 +346,16 @@
 		sel->prefixlen_s);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s/%d", rt_addr_n2a(f, sizeof(sel->daddr),
+	fprintf(fp, "dst %s/%d ", rt_addr_n2a(f, sizeof(sel->daddr),
 					      &sel->daddr, abuf, sizeof(abuf)),
 		sel->prefixlen_d);
 
-	fprintf(fp, "\n");
-
-	if (prefix)
-		fprintf(fp, prefix);
-	fprintf(fp, "\t");
-
-	fprintf(fp, "upspec proto %u ", sel->proto);
-	fprintf(fp, "sport %u dport %u ", sel->sport, sel->dport);
+	if (sel->proto)
+		fprintf(fp, "proto %s ", strxf_proto(sel->proto));
+	if (sel->sport)
+		fprintf(fp, "sport %u ", ntohs(sel->sport));
+	if (sel->dport)
+		fprintf(fp, "dport %u ", ntohs(sel->dport));
 
 	if (sel->ifindex > 0) {
 		char buf[IF_NAMESIZE];
@@ -314,10 +367,11 @@
 
 	if (show_stats > 0)
 		fprintf(fp, "uid %u", sel->user);
-	fprintf(fp, "\n");
+
+	fprintf(fp, "%s", _SL_);
 }
 
-static void xfrm_algo_print(struct xfrm_algo *algo, FILE *fp,
+static void xfrm_algo_print(struct xfrm_algo *algo, int type, FILE *fp,
 			    const char *prefix)
 {
 	int len;
@@ -326,16 +380,18 @@
 	if (prefix)
 		fprintf(fp, prefix);
 
-	fprintf(fp, "%s", algo->alg_name);
+	fprintf(fp, "%s ", strxf_algotype(type));
+	fprintf(fp, "%s ", algo->alg_name);
 
+	fprintf(fp, "0x");
 	len = algo->alg_key_len / 8;
-	for (i = 0; i < len; i ++) {
-		if (i % 4 == 0)
-			fprintf(fp, " ");
-		fprintf(fp, "%x", algo->alg_key[i]);
-	}
+	for (i = 0; i < len; i ++)
+		fprintf(fp, "%.2x", (unsigned char)algo->alg_key[i]);
 
-	fprintf(fp, "\n");
+	if (show_stats > 0)
+		fprintf(fp, " (%d bits)", algo->alg_key_len);
+
+	fprintf(fp, "%s", _SL_);
 }
 
 static const char *strxf_mask(__u32 mask)
@@ -384,30 +440,36 @@
 		xfrm_id_info_print(&tmpl->saddr, &tmpl->id, tmpl->mode,
 				   tmpl->reqid, family, fp, prefix);
 
-		fprintf(fp, prefix);
+		if (prefix)
+			fprintf(fp, prefix);
 		fprintf(fp, "\t");
-		fprintf(fp, "level ");
 		switch (tmpl->optional) {
 		case 0:
-			fprintf(fp, "required");
+			if (show_stats > 0)
+				fprintf(fp, "level required ");
 			break;
 		case 1:
-			fprintf(fp, "use");
+			fprintf(fp, "level use ");
 			break;
 		default:
-			fprintf(fp, "%d", tmpl->optional);
+			fprintf(fp, "level %d ", tmpl->optional);
 			break;
 		}
-		fprintf(fp, " ");
 
 		if (show_stats > 0) {
 			fprintf(fp, "share %s ", strxf_share(tmpl->share));
 			fprintf(fp, "algo-mask:");
-			fprintf(fp, "E=%s, ", strxf_mask(tmpl->ealgos));
-			fprintf(fp, "A=%s, ", strxf_mask(tmpl->aalgos));
-			fprintf(fp, "C=%s", strxf_mask(tmpl->calgos));
+			fprintf(fp, "%s=%s, ",
+				strxf_algotype(XFRMA_ALG_CRYPT),
+				strxf_mask(tmpl->ealgos));
+			fprintf(fp, "%s=%s, ",
+				strxf_algotype(XFRMA_ALG_AUTH),
+				strxf_mask(tmpl->aalgos));
+			fprintf(fp, "%s=%s",
+				strxf_algotype(XFRMA_ALG_COMP),
+				strxf_mask(tmpl->calgos));
 		}
-		fprintf(fp, "\n");
+		fprintf(fp, "%s", _SL_);
 	}
 }
 
@@ -422,25 +484,17 @@
 
 		switch (type) {
 		case XFRMA_ALG_CRYPT:
-			if (prefix)
-				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo E ");
-			break;
 		case XFRMA_ALG_AUTH:
-			if (prefix)
-				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo A ");
-			break;
 		case XFRMA_ALG_COMP:
-			if (prefix)
-				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo C ");
+			xfrm_algo_print((struct xfrm_algo *)data, type, fp,
+					prefix);
 			break;
 		case XFRMA_ENCAP:
 			if (prefix)
 				fprintf(fp, prefix);
 			/* XXX */
-			fprintf(fp, "encap: (not implemented yet!)\n");
+			fprintf(fp, "encap (not implemented yet!)");
+			fprintf(fp, "%s", _SL_);
 			break;
 		case XFRMA_TMPL:
 		{
@@ -454,14 +508,15 @@
 		default:
 			if (prefix)
 				fprintf(fp, prefix);
-			fprintf(fp, "unknown rta_type: %u\n", type);
+			fprintf(fp, "%u (unknown rta_type)", type);
+			fprintf(fp, "%s", _SL_);
 			break;
 		}
 	}
 }
 
 int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
-		  int *argcp, char ***argvp)
+		  int loose, int *argcp, char ***argvp)
 {
 	int argc = *argcp;
 	char **argv = *argvp;
@@ -509,7 +564,7 @@
 				proto = pp->p_proto;
 			else {
 				if (get_u8(&proto, *argv, 0))
-					invarg("\"PROTO\" is invalid", *argv);
+					invarg("\"XFRM_PROTO\" is invalid", *argv);
 			}
 
 			switch (proto) {
@@ -519,7 +574,7 @@
 				id->proto = proto;
 				break;
 			default:
-				invarg("\"PROTO\" is unsuppored proto", *argv);
+				invarg("\"XFRM_PROTO\" is unsuppored proto", *argv);
 			}
 
 			filter.id_proto_mask = XFRM_FILTER_MASK_FULL;
@@ -548,9 +603,9 @@
 
 	if (src.family && dst.family && (src.family != dst.family))
 		invarg("the same address family is required between \"SADDR\" and \"DADDR\"", *argv);
-	if (proto == 0)
-		missarg("PROTO");
 
+	if (loose == 0 && proto == 0)
+		missarg("PROTO");
 	if (argc == *argcp)
 		missarg("ID");
 
@@ -598,10 +653,11 @@
 {
 	int argc = *argcp;
 	char **argv = *argvp;
-	__u8 upspec;
 
 	while (1) {
 		if (strcmp(*argv, "proto") == 0) {
+			__u8 upspec;
+
 			NEXT_ARG();
 
 			if (strcmp(*argv, "any") == 0)
@@ -613,7 +669,7 @@
 					upspec = pp->p_proto;
 				else {
 					if (get_u8(&upspec, *argv, 0))
-						invarg("\"UPSPEC\" is invalid", *argv);
+						invarg("\"PROTO\" is invalid", *argv);
 				}
 			}
 			sel->proto = upspec;
@@ -666,6 +722,7 @@
 	char **argv = *argvp;
 	inet_prefix dst;
 	inet_prefix src;
+	char *upspecp = NULL;
 
 	memset(&dst, 0, sizeof(dst));
 	memset(&src, 0, sizeof(src));
@@ -697,11 +754,6 @@
 
 			filter.sel_dst_mask = dst.bitlen;
 
-		} else if (strcmp(*argv, "upspec") == 0) {
-			NEXT_ARG();
-
-			xfrm_selector_upspec_parse(sel, &argc, &argv);
-
 		} else if (strcmp(*argv, "dev") == 0) {
 			int ifindex;
 
@@ -719,8 +771,13 @@
 			filter.sel_dev_mask = XFRM_FILTER_MASK_FULL;
 
 		} else {
-			PREV_ARG(); /* back track */
-			break;
+			if (upspecp) {
+				PREV_ARG(); /* back track */
+				break;
+			} else {
+				upspecp = *argv;
+				xfrm_selector_upspec_parse(sel, &argc, &argv);
+			}
 		}
 
 		if (!NEXT_ARG_OK())
diff -uNr iproute2-2.6.8.orig/ip/xfrm.h iproute2-2.6.8/ip/xfrm.h
--- iproute2-2.6.8.orig/ip/xfrm.h	2004-07-30 15:28:47.000000000 -0700
+++ iproute2-2.6.8/ip/xfrm.h	2004-08-02 17:27:43.000000000 -0700
@@ -78,6 +78,8 @@
 int do_xfrm_state(int argc, char **argv);
 int do_xfrm_policy(int argc, char **argv);
 
+int xfrm_algotype_getbyname(char *name);
+const char *strxf_algotype(int type);
 const char *strxf_flags(__u8 flags);
 const char *strxf_share(__u8 share);
 const char *strxf_proto(__u8 proto);
@@ -93,7 +95,7 @@
 void xfrm_xfrma_print(struct rtattr *tb[], int ntb, __u16 family,
 		      FILE *fp, const char *prefix);
 int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
-		    int *argcp, char ***argvp);
+		  int loose, int *argcp, char ***argvp);
 int xfrm_mode_parse(__u8 *mode, int *argcp, char ***argvp);
 int xfrm_reqid_parse(__u32 *reqid, int *argcp, char ***argvp);
 int xfrm_selector_parse(struct xfrm_selector *sel, int *argcp, char ***argvp);
diff -uNr iproute2-2.6.8.orig/ip/xfrm_policy.c iproute2-2.6.8/ip/xfrm_policy.c
--- iproute2-2.6.8.orig/ip/xfrm_policy.c	2004-07-30 15:28:47.000000000 -0700
+++ iproute2-2.6.8/ip/xfrm_policy.c	2004-08-02 17:27:43.000000000 -0700
@@ -53,14 +53,14 @@
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR sel SELECTOR [ index INDEX ] \n");
+	fprintf(stderr, "Usage: ip xfrm policy { add | update } dir DIR SELECTOR [ index INDEX ] \n");
 	fprintf(stderr, "        [ action ACTION ] [ priority PRIORITY ] [ LIMIT-LIST ] [ TMPL-LIST ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ sel SELECTOR | index INDEX ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { flush | list } [ dir DIR ] [ sel SELECTOR ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { delete | get } dir DIR [ SELECTOR | index INDEX ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { flush | list } [ dir DIR ] [ SELECTOR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "DIR := [ in | out | fwd ]\n");
 
-	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ upspec UPSPEC ] [ dev DEV ]\n");
+	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
 
 	fprintf(stderr, "UPSPEC := proto PROTO [ sport PORT ] [ dport PORT ]\n");
 
@@ -134,7 +134,7 @@
 			else if (strcmp(*argv, "use") == 0)
 				tmpl->optional = 1;
 			else
-				invarg("\"level\" value is invalid\n", *argv);
+				invarg("\"LEVEL\" is invalid\n", *argv);
 
 		} else {
 			if (idp) {
@@ -143,7 +143,7 @@
 			}
 			idp = *argv;
 			xfrm_id_parse(&tmpl->saddr, &tmpl->id, &tmpl->family,
-				      &argc, &argv);
+				      0, &argc, &argv);
 			if (preferred_family == AF_UNSPEC)
 				preferred_family = tmpl->family;
 		}
@@ -171,6 +171,7 @@
 		char				buf[RTA_BUF_SIZE];
 	} req;
 	char *dirp = NULL;
+	char *selp = NULL;
 	char tmpls_buf[XFRM_TMPLS_BUF_SIZE];
 	int tmpls_len = 0;
 
@@ -198,12 +199,6 @@
 
 			filter.dir_mask = XFRM_FILTER_MASK_FULL;
 
-		} else if (strcmp(*argv, "sel") == 0) {
-			NEXT_ARG();
-			xfrm_selector_parse(&req.xpinfo.sel, &argc, &argv);
-			if (preferred_family == AF_UNSPEC)
-				preferred_family = req.xpinfo.sel.family;
-
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.index, *argv, 0))
@@ -250,8 +245,15 @@
 			xfrm_tmpl_parse(tmpl, &argc, &argv);
 
 			tmpls_len += sizeof(*tmpl);
-		} else
-			invarg("unknown", *argv);
+		} else {
+			if (selp)
+				duparg("unknown", *argv);
+			selp = *argv;
+
+			xfrm_selector_parse(&req.xpinfo.sel, &argc, &argv);
+			if (preferred_family == AF_UNSPEC)
+				preferred_family = req.xpinfo.sel.family;
+		}
 
 		argc--; argv++;
 	}
@@ -362,7 +364,6 @@
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
 		fprintf(fp, "Deleted ");
 
-	fprintf(fp, "sel ");
 	xfrm_selector_print(&xpinfo->sel, preferred_family, fp, NULL);
 
 	fprintf(fp, "\t");
@@ -383,33 +384,36 @@
 	}
 	fprintf(fp, " ");
 
-	fprintf(fp, "action ");
 	switch (xpinfo->action) {
 	case XFRM_POLICY_ALLOW:
-		fprintf(fp, "allow");
+		if (show_stats > 0)
+			fprintf(fp, "action allow ");
 		break;
 	case XFRM_POLICY_BLOCK:
-		fprintf(fp, "block");
+		fprintf(fp, "action block ");
 		break;
 	default:
-		fprintf(fp, "%d", xpinfo->action);
+		fprintf(fp, "action %d ", xpinfo->action);
 		break;
 	}
-	fprintf(fp, " ");
 
-	fprintf(fp, "index %u ", xpinfo->index);
+	if (show_stats)
+		fprintf(fp, "index %u ", xpinfo->index);
 	fprintf(fp, "priority %u ", xpinfo->priority);
 	if (show_stats > 0) {
 		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
 		fprintf(fp, "flags 0x%s", strxf_flags(xpinfo->flags));
 	}
-	fprintf(fp, "\n");
+	fprintf(fp, "%s", _SL_);
 
 	if (show_stats > 0)
 		xfrm_lifetime_print(&xpinfo->lft, &xpinfo->curlft, fp, "\t");
 
 	xfrm_xfrma_print(tb, ntb, xpinfo->sel.family, fp, "\t");
 
+	if (oneline)
+		fprintf(fp, "\n");
+
 	return 0;
 }
 
@@ -440,16 +444,6 @@
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpid.dir, &argc, &argv);
 
-		} else if (strcmp(*argv, "sel") == 0) {
-			if (selp)
-				duparg("sel", *argv);
-			selp = *argv;
-
-			NEXT_ARG();
-			xfrm_selector_parse(&req.xpid.sel, &argc, &argv);
-			if (preferred_family == AF_UNSPEC)
-				preferred_family = req.xpid.sel.family;
-
 		} else if (strcmp(*argv, "index") == 0) {
 			if (indexp)
 				duparg("index", *argv);
@@ -459,8 +453,16 @@
 			if (get_u32(&req.xpid.index, *argv, 0))
 				invarg("\"INDEX\" is invalid", *argv);
 
-		} else
-			invarg("unknown", *argv);
+		} else {
+			if (selp)
+				invarg("unknown", *argv);
+			selp = *argv;
+
+			xfrm_selector_parse(&req.xpid.sel, &argc, &argv);
+			if (preferred_family == AF_UNSPEC)
+				preferred_family = req.xpid.sel.family;
+
+		}
 
 		argc--; argv++;
 	}
@@ -564,6 +566,7 @@
 
 static int xfrm_policy_list_or_flush(int argc, char **argv, int flush)
 {
+	char *selp = NULL;
 	struct rtnl_handle rth;
 
 	if (argc > 0)
@@ -577,12 +580,6 @@
 
 			filter.dir_mask = XFRM_FILTER_MASK_FULL;
 
-		} else if (strcmp(*argv, "sel") == 0) {
-			NEXT_ARG();
-			xfrm_selector_parse(&filter.xpinfo.sel, &argc, &argv);
-			if (preferred_family == AF_UNSPEC)
-				preferred_family = filter.xpinfo.sel.family;
-
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&filter.xpinfo.index, *argv, 0))
@@ -597,7 +594,7 @@
 			else if (strcmp(*argv, "block") == 0)
 				filter.xpinfo.action = XFRM_POLICY_BLOCK;
 			else
-				invarg("\"action\" value is invalid\n", *argv);
+				invarg("\"ACTION\" is invalid\n", *argv);
 
 			filter.action_mask = XFRM_FILTER_MASK_FULL;
 
@@ -608,8 +605,16 @@
 
 			filter.priority_mask = XFRM_FILTER_MASK_FULL;
 
-		} else
-			invarg("unknown", *argv);
+		} else {
+			if (selp)
+				invarg("unknown", *argv);
+			selp = *argv;
+
+			xfrm_selector_parse(&filter.xpinfo.sel, &argc, &argv);
+			if (preferred_family == AF_UNSPEC)
+				preferred_family = filter.xpinfo.sel.family;
+
+		}
 
 		argc--; argv++;
 	}
diff -uNr iproute2-2.6.8.orig/ip/xfrm_state.c iproute2-2.6.8/ip/xfrm_state.c
--- iproute2-2.6.8.orig/ip/xfrm_state.c	2004-07-30 15:28:47.000000000 -0700
+++ iproute2-2.6.8/ip/xfrm_state.c	2004-08-02 17:27:43.000000000 -0700
@@ -67,8 +67,8 @@
 	fprintf(stderr, "XFRM_PROTO := [ ");
 	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ESP));
 	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_AH));
-	fprintf(stderr, "%s", strxf_proto(IPPROTO_COMP));
-	fprintf(stderr, " ]\n");
+	fprintf(stderr, "%s ", strxf_proto(IPPROTO_COMP));
+	fprintf(stderr, "]\n");
 
 	//fprintf(stderr, "SPI - security parameter index(default=0)\n");
 
@@ -78,9 +78,14 @@
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] [ flag FLAG ]\n");
 	fprintf(stderr, "FLAG := [ noecn ]\n");
 
-	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ algo ALGO ]\n");
+	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
 	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY\n");
-	fprintf(stderr, "ALGO_TYPE := [ E | A | C ]\n");
+	fprintf(stderr, "ALGO_TYPE := [ ");
+	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_CRYPT));
+	fprintf(stderr, "%s | ", strxf_algotype(XFRMA_ALG_AUTH));
+	fprintf(stderr, "%s ", strxf_algotype(XFRMA_ALG_COMP));
+	fprintf(stderr, "]\n");
+
 	//fprintf(stderr, "ALGO_NAME - algorithm name\n");
 	//fprintf(stderr, "ALGO_KEY - algorithm key\n");
 
@@ -99,6 +104,7 @@
 			   char *name, char *key, int max)
 {
 	int len;
+	int slen = strlen(key);
 
 #if 1
 	/* XXX: verifying both name and key is required! */
@@ -107,30 +113,37 @@
 
 	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
 
-	if (strncmp(key, "0x", 2) == 0) {
+	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
 		/*
 		 * XXX: fix me!!
 		 */
-		__u64 val = 0;
-		char *p = (char *)&val;
+		union {
+			__u64 x;
+			unsigned char p[8];
+		} val;
+
+		memset(&val, 0, sizeof(val));
 
-		if (get_u64(&val, key, 16))
+		if (get_u64(&val.x, key, 16))
 			invarg("\"ALGOKEY\" is invalid", key);
 
-		len = (strlen(key) - 2) / 2;
+		len = (slen - 2) / 2;
 		if (len > sizeof(val))
 			invarg("\"ALGOKEY\" is invalid: too large", key);
 
 		if (len > 0) {
-			int index = sizeof(val) - len;
+			int i;
+
 			if (len > max)
 				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
-
-			memcpy(alg->alg_key, &p[index], len);
+			for (i = sizeof(val.p) - 1; i >= 0; i--) {
+				int j = sizeof(val.p) - 1 - i;
+				alg->alg_key[j] = val.p[i];
+			}
 		}
 
 	} else {
-		len = strlen(key);
+		len = slen;
 		if (len > 0) {
 			if (len > max)
 				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
@@ -197,56 +210,7 @@
 	req.xsinfo.lft.hard_packet_limit = XFRM_INF;
 
 	while (argc > 0) {
-		if (strcmp(*argv, "algo") == 0) {
-			struct {
-				struct xfrm_algo alg;
-				char buf[XFRM_ALGO_KEY_BUF_SIZE];
-			} alg;
-			int len;
-			enum xfrm_attr_type_t type;
-			char *name;
-			char *key;
-
-			NEXT_ARG();
-
-			if (strcmp(*argv, "E") == 0) {
-				if (ealgop)
-					duparg("ALGOTYPE", *argv);
-				ealgop = *argv;
-				type = XFRMA_ALG_CRYPT;
-			} else if (strcmp(*argv, "A") == 0) {
-				if (aalgop)
-					duparg("ALGOTYPE", *argv);
-				aalgop = *argv;
-				type = XFRMA_ALG_AUTH;
-
-			} else if (strcmp(*argv, "C") == 0) {
-				if (calgop)
-					duparg("ALGOTYPE", *argv);
-				calgop = *argv;
-				type = XFRMA_ALG_COMP;
-			} else
-				invarg("\"ALGOTYPE\" is invalid\n", *argv);
-
-			if (!NEXT_ARG_OK())
-				missarg("ALGONAME");
-			NEXT_ARG();
-			name = *argv;
-
-			if (!NEXT_ARG_OK())
-				missarg("ALGOKEY");
-			NEXT_ARG();
-			key = *argv;
-
-			memset(&alg, 0, sizeof(alg));
-
-			xfrm_algo_parse((void *)&alg, type, name, key, sizeof(alg.buf));
-			len = sizeof(struct xfrm_algo) + alg.alg.alg_key_len;
-
-			addattr_l(&req.n, sizeof(req.buf), type,
-				  (void *)&alg, len);
-
-		} else if (strcmp(*argv, "mode") == 0) {
+		if (strcmp(*argv, "mode") == 0) {
 			NEXT_ARG();
 			xfrm_mode_parse(&req.xsinfo.mode, &argc, &argv);
 		} else if (strcmp(*argv, "reqid") == 0) {
@@ -258,20 +222,79 @@
 		} else if (strcmp(*argv, "sel") == 0) {
 			NEXT_ARG();
 			xfrm_selector_parse(&req.xsinfo.sel, &argc, &argv);
-
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			xfrm_lifetime_cfg_parse(&req.xsinfo.lft, &argc, &argv);
 		} else {
-			if (idp)
-				invarg("unknown", *argv);
-			idp = *argv;
+			/* try to assume ALGO */
+			int type = xfrm_algotype_getbyname(*argv);
+			switch (type) {
+			case XFRMA_ALG_CRYPT:
+			case XFRMA_ALG_AUTH:
+			case XFRMA_ALG_COMP:
+			{
+				/* ALGO */
+				struct {
+					struct xfrm_algo alg;
+					char buf[XFRM_ALGO_KEY_BUF_SIZE];
+				} alg;
+				int len;
+				char *name;
+				char *key;
+
+				switch (type) {
+				case XFRMA_ALG_CRYPT:
+					if (ealgop)
+						duparg("ALGOTYPE", *argv);
+					ealgop = *argv;
+					break;
+				case XFRMA_ALG_AUTH:
+					if (aalgop)
+						duparg("ALGOTYPE", *argv);
+					aalgop = *argv;
+					break;
+				case XFRMA_ALG_COMP:
+					if (calgop)
+						duparg("ALGOTYPE", *argv);
+					calgop = *argv;
+					break;
+				default:
+					/* not reached */
+					invarg("\"ALGOTYPE\" is invalid\n", *argv);
+				}
+
+				if (!NEXT_ARG_OK())
+					missarg("ALGONAME");
+				NEXT_ARG();
+				name = *argv;
+
+				if (!NEXT_ARG_OK())
+					missarg("ALGOKEY");
+				NEXT_ARG();
+				key = *argv;
+
+				memset(&alg, 0, sizeof(alg));
+
+				xfrm_algo_parse((void *)&alg, type, name, key,
+						sizeof(alg.buf));
+				len = sizeof(struct xfrm_algo) + alg.alg.alg_key_len;
 
-			/* ID */
-			xfrm_id_parse(&req.xsinfo.saddr, &req.xsinfo.id,
-				      &req.xsinfo.family, &argc, &argv);
-			if (preferred_family == AF_UNSPEC)
-				preferred_family = req.xsinfo.family;
+				addattr_l(&req.n, sizeof(req.buf), type,
+					  (void *)&alg, len);
+				break;
+			}
+			default:
+				/* try to assume ID */
+				if (idp)
+					invarg("unknown", *argv);
+				idp = *argv;
+
+				/* ID */
+				xfrm_id_parse(&req.xsinfo.saddr, &req.xsinfo.id,
+					      &req.xsinfo.family, 0, &argc, &argv);
+				if (preferred_family == AF_UNSPEC)
+					preferred_family = req.xsinfo.family;
+			}
 		}
 		argc--; argv++;
 	}
@@ -285,14 +308,14 @@
 		if (req.xsinfo.id.proto != IPPROTO_ESP &&
 		    req.xsinfo.id.proto != IPPROTO_AH &&
 		    req.xsinfo.id.proto != IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is invalid with proto=%d\n", req.xsinfo.id.proto);
+			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n", strxf_proto(req.xsinfo.id.proto));
 			exit(1);
 		}
 	} else {
 		if (req.xsinfo.id.proto == IPPROTO_ESP ||
 		    req.xsinfo.id.proto == IPPROTO_AH ||
 		    req.xsinfo.id.proto == IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is required with proto=%d\n", req.xsinfo.id.proto);
+			fprintf(stderr, "\"ALGO\" is required with proto=%s\n", strxf_proto(req.xsinfo.id.proto));
 			exit (1);
 		}
 	}
@@ -339,6 +362,15 @@
 	return 1;
 }
 
+static int xfrm_selector_iszero(struct xfrm_selector *s)
+{
+	struct xfrm_selector s0;
+
+	memset(&s0, 0, sizeof(s0));
+
+	return (memcmp(&s0, s, sizeof(s0)) == 0);
+}
+
 int xfrm_state_print(struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = (FILE*)arg;
@@ -373,33 +405,35 @@
 			   xsinfo->reqid, xsinfo->family, fp, NULL);
 
 	fprintf(fp, "\t");
-	if (show_stats > 0) {
+	fprintf(fp, "replay-window %d ", xsinfo->replay_window);
+	if (show_stats > 0)
 		fprintf(fp, "seq 0x%08u ", xsinfo->seq);
-		fprintf(fp, "replay-window %d ", xsinfo->replay_window);
-	}
-	fprintf(fp, "flag 0x%s", strxf_flags(xsinfo->flags));
-	if (show_stats > 0) {
-		if (xsinfo->flags) {
-			fprintf(fp, "(");
-			if (xsinfo->flags & XFRM_STATE_NOECN)
-				fprintf(fp, "noecn");
-			fprintf(fp, ")");
+	if (xsinfo->flags) {
+		fprintf(fp, "flag 0x%s", strxf_flags(xsinfo->flags));
+		if (show_stats > 0) {
+			if (xsinfo->flags) {
+				fprintf(fp, "(");
+				if (xsinfo->flags & XFRM_STATE_NOECN)
+					fprintf(fp, "noecn");
+				fprintf(fp, ")");
+			}
 		}
 	}
-	fprintf(fp, "\n");
+	fprintf(fp, "%s", _SL_);
 
 	xfrm_xfrma_print(tb, ntb, xsinfo->family, fp, "\t");
 
-	if (show_stats > 0) {
-		fprintf(fp, "\tsel\n");
-		xfrm_selector_print(&xsinfo->sel, xsinfo->family, fp, "\t  ");
-	}
+	if (!xfrm_selector_iszero(&xsinfo->sel))
+		xfrm_selector_print(&xsinfo->sel, xsinfo->family, fp, "\tsel ");
 
 	if (show_stats > 0) {
 		xfrm_lifetime_print(&xsinfo->lft, &xsinfo->curlft, fp, "\t");
 		xfrm_stats_print(&xsinfo->stats, fp, "\t");
 	}
 
+	if (oneline)
+		fprintf(fp, "\n");
+
 	return 0;
 }
 
@@ -434,7 +468,7 @@
 
 		/* ID */
 		memset(&id, 0, sizeof(id));
-		xfrm_id_parse(&ignore_saddr, &id, &req.xsid.family,
+		xfrm_id_parse(&ignore_saddr, &id, &req.xsid.family, 0,
 			      &argc, &argv);
 
 		memcpy(&req.xsid.daddr, &id.daddr, sizeof(req.xsid.daddr));
@@ -557,9 +591,8 @@
 			idp = *argv;
 
 			/* ID */
-			xfrm_id_parse(&filter.xsinfo.saddr,
-				      &filter.xsinfo.id,
-					&filter.xsinfo.family, &argc, &argv);
+			xfrm_id_parse(&filter.xsinfo.saddr, &filter.xsinfo.id,
+				      &filter.xsinfo.family, 1, &argc, &argv);
 			if (preferred_family == AF_UNSPEC)
 				preferred_family = filter.xsinfo.family;
 		}


-- 
Masahide NAKAMURA
