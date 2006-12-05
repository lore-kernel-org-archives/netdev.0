From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 5/7] [IP] XFRM: Mobile IPv6 route optimization support.
Date: Tue,  5 Dec 2006 19:15:47 +0900
Message-ID: <11653137472972-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38930 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S937414AbWLEKQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:16:17 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To support Mobile IPv6 RO, the following extension is included:
o Use XFRM_MODE_XXX macro instead of magic number
o New attribute option for all state: source address for
  deleting or getting message
o New attribute options for RO: care-of address, last-used timestamp
  and wild-receive flag

Note:
Flush command like `ip xfrm state flush` is to remove all XFRM state.
It has been effected for IPsec SAD but with this patch it flushes both
IPsec SAD and Mobile IPv6 RO states.
To make only IPsec SA flush, it is recommanded to specify each XFRM
protocol like below:
 `ip x s f proto esp ; ip x s f proto ah ; ip x s f proto comp`

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/ipxfrm.c      |   84 ++++++++++++++++++++++++++++++++++++++----
 ip/xfrm.h        |    2 +
 ip/xfrm_policy.c |    7 ++--
 ip/xfrm_state.c  |  107 ++++++++++++++++++++++++++++++++++++++++++++----------
 4 files changed, 169 insertions(+), 31 deletions(-)

diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 79fc133..7c9fd0b 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -94,6 +94,19 @@ int xfrm_addr_match(xfrm_address_t *x1, 
 	return 0;
 }
 
+int xfrm_xfrmproto_is_ipsec(__u8 proto)
+{
+	return (proto ==  IPPROTO_ESP ||
+		proto ==  IPPROTO_AH  ||
+		proto ==  IPPROTO_COMP);
+}
+
+int xfrm_xfrmproto_is_ro(__u8 proto)
+{
+	return (proto ==  IPPROTO_ROUTING ||
+		proto ==  IPPROTO_DSTOPTS);
+}
+
 struct typeent {
 	const char *t_name;
 	int t_type;
@@ -101,6 +114,7 @@ struct typeent {
 
 static const struct typeent xfrmproto_types[]= {
 	{ "esp", IPPROTO_ESP }, { "ah", IPPROTO_AH }, { "comp", IPPROTO_COMP },
+	{ "route2", IPPROTO_ROUTING }, { "hao", IPPROTO_DSTOPTS },
 	{ NULL, -1 }
 };
 
@@ -276,13 +290,19 @@ void xfrm_id_info_print(xfrm_address_t *
 
 	fprintf(fp, "mode ");
 	switch (mode) {
-	case 0:
+	case XFRM_MODE_TRANSPORT:
 		fprintf(fp, "transport");
 		break;
-	case 1:
+	case XFRM_MODE_TUNNEL:
 		fprintf(fp, "tunnel");
 		break;
-	case 4:
+	case XFRM_MODE_ROUTEOPTIMIZATION:
+		fprintf(fp, "ro");
+		break;
+	case XFRM_MODE_IN_TRIGGER:
+		fprintf(fp, "in_trigger");
+		break;
+	case XFRM_MODE_BEET:
 		fprintf(fp, "beet");
 		break;
 	default:
@@ -643,6 +663,48 @@ void xfrm_xfrma_print(struct rtattr *tb[
 		xfrm_tmpl_print((struct xfrm_user_tmpl *) RTA_DATA(rta),
 				RTA_PAYLOAD(rta), family, fp, prefix);
 	}
+
+	if (tb[XFRMA_COADDR]) {
+		char abuf[256];
+		xfrm_address_t *coa;
+
+		if (prefix)
+			fprintf(fp, prefix);
+		fprintf(fp, "coa ");
+
+		coa = (xfrm_address_t *)RTA_DATA(tb[XFRMA_COADDR]);
+
+		if (RTA_PAYLOAD(tb[XFRMA_COADDR]) < sizeof(*coa)) {
+			fprintf(fp, "(ERROR truncated)");
+			fprintf(fp, "%s", _SL_);
+			return;
+		}
+
+		memset(abuf, '\0', sizeof(abuf));
+		fprintf(fp, "%s",
+			rt_addr_n2a(family, sizeof(*coa), coa, 
+				    abuf, sizeof(abuf)));
+		fprintf(fp, "%s", _SL_);
+	}
+
+	if (tb[XFRMA_LASTUSED]) {
+		__u64 lastused;
+
+		if (prefix)
+			fprintf(fp, prefix);
+		fprintf(fp, "lastused ");
+
+		if (RTA_PAYLOAD(tb[XFRMA_LASTUSED]) < sizeof(lastused)) {
+			fprintf(fp, "(ERROR truncated)");
+			fprintf(fp, "%s", _SL_);
+			return;
+		}
+
+		lastused = *(__u64 *)RTA_DATA(tb[XFRMA_LASTUSED]);
+
+		fprintf(fp, "%s", strxf_time(lastused));
+		fprintf(fp, "%s", _SL_);
+	}
 }
 
 static int xfrm_selector_iszero(struct xfrm_selector *s)
@@ -659,12 +721,13 @@ void xfrm_state_info_print(struct xfrm_u
 			    const char *title)
 {
 	char buf[STRBUF_SIZE];
+	int force_spi = xfrm_xfrmproto_is_ipsec(xsinfo->id.proto);
 
 	memset(buf, '\0', sizeof(buf));
 
 	xfrm_id_info_print(&xsinfo->saddr, &xsinfo->id, xsinfo->mode,
-			   xsinfo->reqid, xsinfo->family, 1, fp, prefix,
-			   title);
+			   xsinfo->reqid, xsinfo->family, force_spi, fp,
+			   prefix, title);
 
 	if (prefix)
 		STRBUF_CAT(buf, prefix);
@@ -680,6 +743,7 @@ void xfrm_state_info_print(struct xfrm_u
 		fprintf(fp, "flag ");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_NOECN, "noecn");
 		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_DECAP_DSCP, "decap-dscp");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_WILDRECV, "wildrecv");
 		if (flags)
 			fprintf(fp, "%x", flags);
 		if (show_stats > 0)
@@ -884,11 +948,15 @@ int xfrm_mode_parse(__u8 *mode, int *arg
 	char **argv = *argvp;
 
 	if (matches(*argv, "transport") == 0)
-		*mode = 0;
+		*mode = XFRM_MODE_TRANSPORT;
 	else if (matches(*argv, "tunnel") == 0)
-		*mode = 1;
+		*mode = XFRM_MODE_TUNNEL;
+	else if (matches(*argv, "ro") == 0)
+		*mode = XFRM_MODE_ROUTEOPTIMIZATION;
+	else if (matches(*argv, "in_trigger") == 0)
+		*mode = XFRM_MODE_IN_TRIGGER;
 	else if (matches(*argv, "beet") == 0)
-		*mode = 4;
+		*mode = XFRM_MODE_BEET;
 	else
 		invarg("\"MODE\" is invalid", *argv);
 
diff --git a/ip/xfrm.h b/ip/xfrm.h
index 7a53e59..51ffa4b 100644
--- a/ip/xfrm.h
+++ b/ip/xfrm.h
@@ -110,6 +110,8 @@ int do_xfrm_policy(int argc, char **argv
 int do_xfrm_monitor(int argc, char **argv);
 
 int xfrm_addr_match(xfrm_address_t *x1, xfrm_address_t *x2, int bits);
+int xfrm_xfrmproto_is_ipsec(__u8 proto);
+int xfrm_xfrmproto_is_ro(__u8 proto);
 int xfrm_xfrmproto_getbyname(char *name);
 int xfrm_algotype_getbyname(char *name);
 const char *strxf_xfrmproto(__u8 proto);
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 6be7bfd..44aff79 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -82,12 +82,13 @@ static void usage(void)
 	fprintf(stderr, "TMPL := ID [ mode MODE ] [ reqid REQID ] [ level LEVEL ]\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 
-	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
 	fprintf(stderr, "XFRM_PROTO := [ ");
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
-	fprintf(stderr, "%s", strxf_xfrmproto(IPPROTO_COMP));
-	fprintf(stderr, " ]\n");
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_COMP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ROUTING));
+	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_DSTOPTS));
+	fprintf(stderr, "]\n");
 
  	fprintf(stderr, "MODE := [ transport | tunnel | beet ](default=transport)\n");
  	//fprintf(stderr, "REQID - number(default=0)\n");
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index bb073c0..57dc4b5 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -55,7 +55,7 @@ static void usage(void) __attribute__((n
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ ALGO-LIST ] [ mode MODE ]\n");
+	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ XFRM_OPT ] [ mode MODE ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "        [ encap ENCAP ] [ sel SELECTOR ] [ LIMIT-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ reqid REQID ] [ seq SEQ ]\n");
@@ -70,16 +70,18 @@ static void usage(void)
 	fprintf(stderr, "XFRM_PROTO := [ ");
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
 	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
-	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_COMP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_COMP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ROUTING));
+	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_DSTOPTS));
 	fprintf(stderr, "]\n");
 
 	//fprintf(stderr, "SPI - security parameter index(default=0)\n");
 
- 	fprintf(stderr, "MODE := [ transport | tunnel | beet ](default=transport)\n");
+ 	fprintf(stderr, "MODE := [ transport | tunnel | ro | beet ](default=transport)\n");
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
 	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
-	fprintf(stderr, "FLAG := [ noecn | decap-dscp ]\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp | wildrecv ]\n");
  
         fprintf(stderr, "ENCAP := ENCAP-TYPE SPORT DPORT OADDR\n");
         fprintf(stderr, "ENCAP-TYPE := espinudp | espinudp-nonike\n");
@@ -200,6 +202,8 @@ static int xfrm_state_flag_parse(__u8 *f
 				*flags |= XFRM_STATE_NOECN;
 			else if (strcmp(*argv, "decap-dscp") == 0)
 				*flags |= XFRM_STATE_DECAP_DSCP;
+			else if (strcmp(*argv, "wildrecv") == 0)
+				*flags |= XFRM_STATE_WILDRECV;
 			else {
 				PREV_ARG(); /* back track */
 				break;
@@ -231,6 +235,7 @@ static int xfrm_state_modify(int cmd, un
 	char *ealgop = NULL;
 	char *aalgop = NULL;
 	char *calgop = NULL;
+	char *coap = NULL;
 
 	memset(&req, 0, sizeof(req));
 
@@ -285,6 +290,27 @@ static int xfrm_state_modify(int cmd, un
 			memcpy(&encap.encap_oa, &oa.data, sizeof(encap.encap_oa));
 			addattr_l(&req.n, sizeof(req.buf), XFRMA_ENCAP,
 				  (void *)&encap, sizeof(encap));
+		} else if (strcmp(*argv, "coa") == 0) {
+			inet_prefix coa;
+			xfrm_address_t xcoa;
+
+			if (coap)
+				duparg("coa", *argv);
+			coap = *argv;
+
+			NEXT_ARG();
+
+			get_prefix(&coa, *argv, preferred_family);
+			if (coa.family == AF_UNSPEC)
+				invarg("\"coa\" address family is AF_UNSPEC", *argv);
+			if (coa.bytelen > sizeof(xcoa))
+				invarg("\"coa\" address length is too large", *argv);
+
+			memset(&xcoa, 0, sizeof(xcoa));
+			memcpy(&xcoa, &coa.data, coa.bytelen);
+
+			addattr_l(&req.n, sizeof(req.buf), XFRMA_COADDR,
+				  (void *)&xcoa, sizeof(xcoa));
 		} else {
 			/* try to assume ALGO */
 			int type = xfrm_algotype_getbyname(*argv);
@@ -364,18 +390,56 @@ static int xfrm_state_modify(int cmd, un
 		exit(1);
 	}
 
+	switch (req.xsinfo.mode) {
+	case XFRM_MODE_TRANSPORT:
+	case XFRM_MODE_TUNNEL:
+		if (!xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"mode\" is invalid with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
+			exit(1);
+		}
+		break;
+	case XFRM_MODE_ROUTEOPTIMIZATION:
+	case XFRM_MODE_IN_TRIGGER:
+		if (!xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"mode\" is invalid with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
+			exit(1);
+		}
+		if (req.xsinfo.id.spi != 0) {
+			fprintf(stderr, "\"spi\" must be 0 with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
+			exit(1);
+		}
+		break;
+	default:
+		break;
+	}
+
 	if (ealgop || aalgop || calgop) {
-		if (req.xsinfo.id.proto != IPPROTO_ESP &&
-		    req.xsinfo.id.proto != IPPROTO_AH &&
-		    req.xsinfo.id.proto != IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n", strxf_xfrmproto(req.xsinfo.id.proto));
+		if (!xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
+			exit(1);
+		}
+	} else {
+		if (xfrm_xfrmproto_is_ipsec(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"ALGO\" is required with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
+			exit (1);
+		}
+	}
+
+	if (coap) {
+		if (!xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"coa\" is invalid with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
 	} else {
-		if (req.xsinfo.id.proto == IPPROTO_ESP ||
-		    req.xsinfo.id.proto == IPPROTO_AH ||
-		    req.xsinfo.id.proto == IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is required with proto=%s\n", strxf_xfrmproto(req.xsinfo.id.proto));
+		if (xfrm_xfrmproto_is_ro(req.xsinfo.id.proto)) {
+			fprintf(stderr, "\"coa\" is required with proto=%s\n",
+				strxf_xfrmproto(req.xsinfo.id.proto));
 			exit (1);
 		}
 	}
@@ -645,6 +709,7 @@ static int xfrm_state_get_or_delete(int 
 	struct {
 		struct nlmsghdr 	n;
 		struct xfrm_usersa_id	xsid;
+		char   			buf[RTA_BUF_SIZE];
 	} req;
 	struct xfrm_id id;
 	char *idp = NULL;
@@ -657,12 +722,7 @@ static int xfrm_state_get_or_delete(int 
 	req.xsid.family = preferred_family;
 
 	while (argc > 0) {
-		/*
-		 * XXX: Source address is not used and ignore it to follow
-		 * XXX: a manner of setkey e.g. in the case of deleting/getting
-		 * XXX: message of IPsec SA.
-		 */
-		xfrm_address_t ignore_saddr;
+		xfrm_address_t saddr;
 
 		if (idp)
 			invarg("unknown", *argv);
@@ -670,13 +730,17 @@ static int xfrm_state_get_or_delete(int 
 
 		/* ID */
 		memset(&id, 0, sizeof(id));
-		xfrm_id_parse(&ignore_saddr, &id, &req.xsid.family, 0,
+		memset(&saddr, 0, sizeof(saddr));
+		xfrm_id_parse(&saddr, &id, &req.xsid.family, 0,
 			      &argc, &argv);
 
 		memcpy(&req.xsid.daddr, &id.daddr, sizeof(req.xsid.daddr));
 		req.xsid.spi = id.spi;
 		req.xsid.proto = id.proto;
 
+		addattr_l(&req.n, sizeof(req.buf), XFRMA_SRCADDR,
+			  (void *)&saddr, sizeof(saddr));
+
 		argc--; argv++;
 	}
 
@@ -756,6 +820,9 @@ static int xfrm_state_keep(const struct 
 	xsid->spi = xsinfo->id.spi;
 	xsid->proto = xsinfo->id.proto;
 
+	addattr_l(new_n, xb->size, XFRMA_SRCADDR, &xsinfo->saddr,
+		  sizeof(xsid->daddr));
+
 	xb->offset += new_n->nlmsg_len;
 	xb->nlmsg_count ++;
 
@@ -880,7 +947,7 @@ static int xfrm_state_flush(int argc, ch
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(req.xsf));
 	req.n.nlmsg_flags = NLM_F_REQUEST;
 	req.n.nlmsg_type = XFRM_MSG_FLUSHSA;
-	req.xsf.proto = IPSEC_PROTO_ANY;
+	req.xsf.proto = 0;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "proto") == 0) {
-- 
1.4.2

