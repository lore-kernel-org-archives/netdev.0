From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/3] iproute2 and xfrm
Date: Thu, 15 Jul 2004 15:02:19 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040715150219.24a498a6@localhost>
References: <20040703094632.GA14235@gondor.apana.org.au>
	<20040705160500.208591b5@localhost>
	<20040706140550.2d483dc8@dell_ss3.pdx.osdl.net>
	<20040707130950.0112edf6@localhost>
	<20040707140533.41c66c03@localhost>
	<20040707155602.4698121a@localhost>
	<20040707110315.GA26100@gondor.apana.org.au>
	<20040709125100.3edce4e9@localhost>
	<20040714174233.2fc7dbc2@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040714174233.2fc7dbc2@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

This patch is for iproute2.
Please check comment in a ChangeSet below.

Regards,


ChangeSet@1.56, 2004-07-12 20:00:04+09:00, nakam@linux-ipv6.org
  fix output format to follow command line option style when using
  without "-s" option.

diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
+++ b/ip/ipxfrm.c	2004-07-14 16:35:49 +09:00
@@ -105,11 +105,11 @@
 		fprintf(fp, prefix);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "%s ", rt_addr_n2a(family, sizeof(*saddr),
-				       saddr, abuf, sizeof(abuf)));
+	fprintf(fp, "src %s ", rt_addr_n2a(family, sizeof(*saddr),
+					   saddr, abuf, sizeof(abuf)));
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "%s\n", rt_addr_n2a(family, sizeof(id->daddr),
-					&id->daddr, abuf, sizeof(abuf)));
+	fprintf(fp, "dst %s\n", rt_addr_n2a(family, sizeof(id->daddr),
+					    &id->daddr, abuf, sizeof(abuf)));
 
 	if (prefix)
 		fprintf(fp, prefix);
@@ -122,30 +122,20 @@
 		sprintf(pbuf, "%d", id->proto);
 		p = pbuf;
 	}
+	fprintf(fp, "proto %s ", p);
 
-	switch (id->proto) {
-	case IPPROTO_ESP:
-	case IPPROTO_AH:
-	case IPPROTO_COMP:
-		fprintf(fp, "%s ", p);
-		break;
-	default:
-		fprintf(fp, "unspec(%s)", p);
-		break;
-	}
-
-	switch (id->proto) {
-	case IPPROTO_ESP:
-	case IPPROTO_AH:
-	case IPPROTO_COMP:
-	default:
-		spi = ntohl(id->spi);
-		fprintf(fp, "spi %d(0x%08x) ", spi, spi);
-		break;
-	}
+	spi = ntohl(id->spi);
+	fprintf(fp, "spi %u", spi);
+	if (show_stats > 0)
+		fprintf(fp, "(0x%08x)", spi);
+	fprintf(fp, " ");
+
+	fprintf(fp, "reqid %u", reqid);
+	if (show_stats > 0)
+		fprintf(fp, "(0x%08x)", reqid);
+	fprintf(fp, " ");
 
-	fprintf(fp, "reqid %d ", reqid);
-	fprintf(fp, "%s\n", (mode ? "tunnel" : "transport"));
+	fprintf(fp, "mode %s\n", (mode ? "tunnel" : "transport"));
 }
 
 static const char *strxf_limit(__u64 limit)
@@ -279,16 +269,14 @@
 		fprintf(fp, prefix);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "%s/%d[%u]", rt_addr_n2a(f, sizeof(sel->saddr),
-					     &sel->saddr,
-					     abuf, sizeof(abuf)),
-		sel->prefixlen_s, sel->sport);
+	fprintf(fp, "src %s/%d ", rt_addr_n2a(f, sizeof(sel->saddr),
+					      &sel->saddr, abuf, sizeof(abuf)),
+		sel->prefixlen_s);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, " %s/%d[%u]", rt_addr_n2a(f, sizeof(sel->daddr),
-					      &sel->daddr,
-					      abuf, sizeof(abuf)),
-		sel->prefixlen_d, sel->dport);
+	fprintf(fp, "dst %s/%d", rt_addr_n2a(f, sizeof(sel->daddr),
+					      &sel->daddr, abuf, sizeof(abuf)),
+		sel->prefixlen_d);
 
 	fprintf(fp, "\n");
 
@@ -296,7 +284,8 @@
 		fprintf(fp, prefix);
 	fprintf(fp, "\t");
 
-	fprintf(fp, "upspec %u ", sel->proto);
+	fprintf(fp, "upspec proto %u ", sel->proto);
+	fprintf(fp, "sport %u dport %u ", sel->sport, sel->dport);
 
 	if (sel->ifindex > 0) {
 		char buf[IF_NAMESIZE];
@@ -304,10 +293,10 @@
 		memset(buf, '\0', sizeof(buf));
 		if_indextoname(sel->ifindex, buf);
 		fprintf(fp, "dev %s ", buf);
-	} else
-		fprintf(fp, "dev (none) ");
+	}
 
-	fprintf(fp, "uid %u", sel->user);
+	if (show_stats > 0)
+		fprintf(fp, "uid %u", sel->user);
 	fprintf(fp, "\n");
 }
 
@@ -367,35 +356,41 @@
 			    __u16 family, FILE *fp, const char *prefix)
 {
 	char buf[32];
-	const char *p = NULL;
 	int i;
 
-	if (prefix) {
-		strcpy(buf, prefix);
-		strcat(buf, "  ");
-	} else
-		strcpy(buf, "  ");
-	p = buf;
-
 	for (i = 0; i < ntmpls; i++) {
 		struct xfrm_user_tmpl *tmpl = &tmpls[i];
 
 		if (prefix)
 			fprintf(fp, prefix);
-		fprintf(fp, "tmpl-%d:\n", i+1);
+
+		fprintf(fp, "tmpl");
 		xfrm_id_info_print(&tmpl->saddr, &tmpl->id, tmpl->mode,
-				   tmpl->reqid, family, fp, p);
+				   tmpl->reqid, family, fp, prefix);
 
-		fprintf(fp, p);
+		fprintf(fp, prefix);
 		fprintf(fp, "\t");
-		fprintf(fp, "level %s ", ((tmpl->optional == 0) ? "required" :
-					  (tmpl->optional == 1) ? "use" :
-					  "unknown-level"));
-		fprintf(fp, "share %s ", strxf_share(tmpl->share));
-		fprintf(fp, "algo-mask:");
-		fprintf(fp, "E=%s, ", strxf_mask(tmpl->ealgos));
-		fprintf(fp, "A=%s, ", strxf_mask(tmpl->aalgos));
-		fprintf(fp, "C=%s", strxf_mask(tmpl->calgos));
+		fprintf(fp, "level ");
+		switch (tmpl->optional) {
+		case 0:
+			fprintf(fp, "required");
+			break;
+		case 1:
+			fprintf(fp, "use");
+			break;
+		default:
+			fprintf(fp, "%d", tmpl->optional);
+			break;
+		}
+		fprintf(fp, " ");
+
+		if (show_stats > 0) {
+			fprintf(fp, "share %s ", strxf_share(tmpl->share));
+			fprintf(fp, "algo-mask:");
+			fprintf(fp, "E=%s, ", strxf_mask(tmpl->ealgos));
+			fprintf(fp, "A=%s, ", strxf_mask(tmpl->aalgos));
+			fprintf(fp, "C=%s", strxf_mask(tmpl->calgos));
+		}
 		fprintf(fp, "\n");
 	}
 }
@@ -413,17 +408,17 @@
 		case XFRMA_ALG_CRYPT:
 			if (prefix)
 				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "E:");
+			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo E ");
 			break;
 		case XFRMA_ALG_AUTH:
 			if (prefix)
 				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "A:");
+			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo A ");
 			break;
 		case XFRMA_ALG_COMP:
 			if (prefix)
 				fprintf(fp, prefix);
-			xfrm_algo_print((struct xfrm_algo *)data, fp, "C:");
+			xfrm_algo_print((struct xfrm_algo *)data, fp, "algo C ");
 			break;
 		case XFRMA_ENCAP:
 			if (prefix)
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm_policy.c	2004-07-14 16:35:49 +09:00
@@ -357,20 +357,47 @@
 	if (n->nlmsg_type == XFRM_MSG_DELPOLICY)
 		fprintf(fp, "Deleted ");
 
+	fprintf(fp, "sel ");
 	xfrm_selector_print(&xpinfo->sel, preferred_family, fp, NULL);
 
 	fprintf(fp, "\t");
-	fprintf(fp, "%s ", (xpinfo->dir == XFRM_POLICY_IN ? "in " :
-			    xpinfo->dir == XFRM_POLICY_OUT ? "out" :
-			    xpinfo->dir == XFRM_POLICY_FWD ? "fwd" :
-			    "unknown-dir"));
-	fprintf(fp, "%s ", (xpinfo->action == XFRM_POLICY_ALLOW ? "allow" :
-			   xpinfo->action == XFRM_POLICY_BLOCK ? "block" :
-			   "unknown-action"));
+	fprintf(fp, "dir ");
+	switch (xpinfo->dir) {
+	case XFRM_POLICY_IN:
+		fprintf(fp, "in");
+		break;
+	case XFRM_POLICY_OUT:
+		fprintf(fp, "out");
+		break;
+	case XFRM_POLICY_FWD:
+		fprintf(fp, "fwd");
+		break;
+	default:
+		fprintf(fp, "%d", xpinfo->dir);
+		break;
+	}
+	fprintf(fp, " ");
+
+	fprintf(fp, "action ");
+	switch (xpinfo->action) {
+	case XFRM_POLICY_ALLOW:
+		fprintf(fp, "allow");
+		break;
+	case XFRM_POLICY_BLOCK:
+		fprintf(fp, "block");
+		break;
+	default:
+		fprintf(fp, "%d", xpinfo->action);
+		break;
+	}
+	fprintf(fp, " ");
+
 	fprintf(fp, "index %u ", xpinfo->index);
 	fprintf(fp, "priority %u ", xpinfo->priority);
-	fprintf(fp, "share %s ", strxf_share(xpinfo->share));
-	fprintf(fp, "flags 0x%s", strxf_flags(xpinfo->flags));
+	if (show_stats > 0) {
+		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
+		fprintf(fp, "flags 0x%s", strxf_flags(xpinfo->flags));
+	}
 	fprintf(fp, "\n");
 
 	if (show_stats > 0)
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-07-14 16:35:49 +09:00
+++ b/ip/xfrm_state.c	2004-07-14 16:35:49 +09:00
@@ -142,11 +142,20 @@
 {
 	int argc = *argcp;
 	char **argv = *argvp;
+	int len = strlen(*argv);
 
-	if (strcmp(*argv, "noecn") == 0)
-		*flags |= XFRM_STATE_NOECN;
-	else
-		invarg("\"FLAG\" is invalid", *argv);
+	if (len > 2 && strncmp(*argv, "0x", 2) == 0) {
+		__u8 val = 0;
+
+		if (get_u8(&val, *argv, 16))
+			invarg("\"FLAG\" is invalid", *argv);
+		*flags = val;
+	} else {
+		if (strcmp(*argv, "noecn") == 0)
+			*flags |= XFRM_STATE_NOECN;
+		else
+			invarg("\"FLAG\" is invalid", *argv);
+	}
 
 	filter.state_flags_mask = XFRM_FILTER_MASK_FULL;
 
@@ -357,22 +366,26 @@
 	xfrm_id_info_print(&xsinfo->saddr, &xsinfo->id, xsinfo->mode,
 			   xsinfo->reqid, xsinfo->family, fp, NULL);
 
+	fprintf(fp, "\t");
 	if (show_stats > 0) {
-		fprintf(fp, "\t");
 		fprintf(fp, "seq 0x%08u ", xsinfo->seq);
 		fprintf(fp, "replay-window %d ", xsinfo->replay_window);
-		fprintf(fp, "flags ");
-		if (xsinfo->flags & XFRM_STATE_NOECN)
-			fprintf(fp, "noecn ");
-		fprintf(fp, "(0x%s)", strxf_flags(xsinfo->flags));
-
-		fprintf(fp, "\n");
 	}
+	fprintf(fp, "flag 0x%s", strxf_flags(xsinfo->flags));
+	if (show_stats > 0) {
+		if (xsinfo->flags) {
+			fprintf(fp, "(");
+			if (xsinfo->flags & XFRM_STATE_NOECN)
+				fprintf(fp, "noecn");
+			fprintf(fp, ")");
+		}
+	}
+	fprintf(fp, "\n");
 
 	xfrm_xfrma_print(tb, ntb, xsinfo->family, fp, "\t");
 
 	if (show_stats > 0) {
-		fprintf(fp, "\tsel:\n");
+		fprintf(fp, "\tsel\n");
 		xfrm_selector_print(&xsinfo->sel, xsinfo->family, fp, "\t  ");
 	}
 




-- 
Masahide NAKAMURA
