From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] XFRM: replay-window and DECAP_DSCP flag
Date: Tue, 11 Jan 2005 13:15:55 +0900
Message-ID: <20050111131555.06dd9144@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Stephen,

This is an update for iproute2 xfrm.
 - add an interface to specify replay-window.
 - support DECAP_DSCP flag.
 - minor fixes. (Mainly it improves output format.)
I've tested with 2.6.10. Please apply it.

The ChangeSet is also available at:
<bk://bk.skbuff.net:38000/iproute2-xfrm/>

Regards,


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/09 15:21:35+09:00 nakam@linux-ipv6.org 
#   add an interface to specify replay-window.
#   support DECAP_DSCP flag.
#   minor fixes.
# 
# BitKeeper/etc/logging_ok
#   2005/01/09 15:21:35+09:00 nakam@linux-ipv6.org +1 -0
#   Logging to logging@openlogging.org accepted
# 
# ip/xfrm_state.c
#   2005/01/09 15:21:30+09:00 nakam@linux-ipv6.org +41 -26
#   fix to compare addresses correctly.
#   improve output style.
#   add an interface to specify replay-window.
#   support DECAP_DSCP flag.
# 
# ip/xfrm_policy.c
#   2005/01/09 15:21:30+09:00 nakam@linux-ipv6.org +7 -11
#   fix to compare addresses correctly.
#   improve output style.
# 
# ip/xfrm.h
#   2005/01/09 15:21:30+09:00 nakam@linux-ipv6.org +26 -16
#   improve output style.
# 
# ip/ipxfrm.c
#   2005/01/09 15:21:30+09:00 nakam@linux-ipv6.org +152 -96
#   fix to verify lengh of RTA_DATA before print it.
#   improve output style.
#   add a function to compare xfrm address.
# 
diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2005-01-09 15:31:16 +09:00
+++ b/ip/ipxfrm.c	2005-01-09 15:31:16 +09:00
@@ -52,14 +52,43 @@
 	exit(-1);
 }
 
+/* This is based on utils.c(inet_addr_match) */
+int xfrm_addr_match(xfrm_address_t *x1, xfrm_address_t *x2, int bits)
+{
+	__u32 *a1 = (__u32 *)x1;
+	__u32 *a2 = (__u32 *)x2;
+	int words = bits >> 0x05;
+
+	bits &= 0x1f;
+
+	if (words)
+		if (memcmp(a1, a2, words << 2))
+			return -1;
+
+	if (bits) {
+		__u32 w1, w2;
+		__u32 mask;
+
+		w1 = a1[words];
+		w2 = a2[words];
+
+		mask = htonl((0xffffffff) << (0x20 - bits));
+
+		if ((w1 ^ w2) & mask)
+			return 1;
+	}
+
+	return 0;
+}
+
 struct typeent {
 	const char *t_name;
 	int t_type;
 };
 
 static const struct typeent xfrmproto_types[]= {
-	{ "esp", IPPROTO_ESP }, { "ah", IPPROTO_AH },
-	{ "comp", IPPROTO_COMP }, { NULL, -1 }
+	{ "esp", IPPROTO_ESP }, { "ah", IPPROTO_AH }, { "comp", IPPROTO_COMP },
+	{ NULL, -1 }
 };
 
 int xfrm_xfrmproto_getbyname(char *name)
@@ -131,20 +160,29 @@
 	return NULL;
 }
 
-const char *strxf_flags(__u8 flags)
+const char *strxf_mask8(__u8 mask)
 {
 	static char str[16];
-	const int sn = sizeof(flags) * 8 - 1;
+	const int sn = sizeof(mask) * 8 - 1;
 	__u8 b;
 	int i = 0;
 
 	for (b = (1 << sn); b > 0; b >>= 1)
-		str[i++] = ((b & flags) ? '1' : '0');
+		str[i++] = ((b & mask) ? '1' : '0');
 	str[i] = '\0';
 
 	return str;
 }
 
+const char *strxf_mask32(__u32 mask)
+{
+	static char str[16];
+
+	sprintf(str, "%.8x", mask);
+
+	return str;
+}
+
 const char *strxf_share(__u8 share)
 {
 	static char str[32];
@@ -163,7 +201,7 @@
 		strcpy(str, "unique");
 		break;
 	default:
-		sprintf(str, "%d", share);
+		sprintf(str, "%u", share);
 		break;
 	}
 
@@ -180,7 +218,7 @@
 	if (pp)
 		p = pp->p_name;
 	else {
-		sprintf(buf, "%d", proto);
+		sprintf(buf, "%u", proto);
 		p = buf;
 	}
 
@@ -188,11 +226,10 @@
 }
 
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
-			__u8 mode, __u32 reqid, __u16 family, FILE *fp,
-			const char *prefix)
+			__u8 mode, __u32 reqid, __u16 family, int force_spi,
+			FILE *fp, const char *prefix)
 {
 	char abuf[256];
-	__u32 spi;
 
 	if (prefix)
 		fprintf(fp, prefix);
@@ -211,11 +248,14 @@
 
 	fprintf(fp, "proto %s ", strxf_xfrmproto(id->proto));
 
-	spi = ntohl(id->spi);
-	fprintf(fp, "spi 0x%08x", spi);
-	if (show_stats > 0)
-		fprintf(fp, "(%u)", spi);
-	fprintf(fp, " ");
+
+	if (show_stats > 0 || force_spi || id->spi) {
+		__u32 spi = ntohl(id->spi);
+		fprintf(fp, "spi 0x%08x", spi);
+		if (show_stats > 0)
+			fprintf(fp, "(%u)", spi);
+		fprintf(fp, " ");
+	}
 
 	fprintf(fp, "reqid %u", reqid);
 	if (show_stats > 0)
@@ -258,9 +298,9 @@
 	if (prefix)
 		fprintf(fp, prefix);
 	fprintf(fp, "  ");
-	fprintf(fp, "replay-window %d ", s->replay_window);
-	fprintf(fp, "replay %d ", s->replay);
-	fprintf(fp, "failed %d", s->integrity_failed);
+	fprintf(fp, "replay-window %u ", s->replay_window);
+	fprintf(fp, "replay %u ", s->replay);
+	fprintf(fp, "failed %u", s->integrity_failed);
 	fprintf(fp, "%s", _SL_);
 }
 
@@ -378,12 +418,12 @@
 		fprintf(fp, prefix);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "src %s/%d ", rt_addr_n2a(f, sizeof(sel->saddr),
+	fprintf(fp, "src %s/%u ", rt_addr_n2a(f, sizeof(sel->saddr),
 					      &sel->saddr, abuf, sizeof(abuf)),
 		sel->prefixlen_s);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s/%d ", rt_addr_n2a(f, sizeof(sel->daddr),
+	fprintf(fp, "dst %s/%u ", rt_addr_n2a(f, sizeof(sel->daddr),
 					      &sel->daddr, abuf, sizeof(abuf)),
 		sel->prefixlen_d);
 
@@ -423,65 +463,56 @@
 	fprintf(fp, "%s", _SL_);
 }
 
-static void xfrm_algo_print(struct xfrm_algo *algo, int type, FILE *fp,
-			    const char *prefix)
+static void xfrm_algo_print(struct xfrm_algo *algo, int type, int len,
+			    FILE *fp, const char *prefix)
 {
-	int len;
+	int keylen;
 	int i;
 
 	if (prefix)
 		fprintf(fp, prefix);
 
 	fprintf(fp, "%s ", strxf_algotype(type));
+
+	if (len < sizeof(*algo)) {
+		fprintf(fp, "(ERROR truncated)");
+		goto fin;
+	}
+	len -= sizeof(*algo);
+
 	fprintf(fp, "%s ", algo->alg_name);
 
+	keylen = algo->alg_key_len / 8;
+	if (len < keylen) {
+		fprintf(fp, "(ERROR truncated)");
+		goto fin;
+	}
+
 	fprintf(fp, "0x");
-	len = algo->alg_key_len / 8;
-	for (i = 0; i < len; i ++)
+	for (i = 0; i < keylen; i ++)
 		fprintf(fp, "%.2x", (unsigned char)algo->alg_key[i]);
 
 	if (show_stats > 0)
 		fprintf(fp, " (%d bits)", algo->alg_key_len);
 
+ fin:
 	fprintf(fp, "%s", _SL_);
 }
 
-static const char *strxf_mask(__u32 mask)
-{
-	static char str[128];
-	const int sn = 	sizeof(mask) * 8 - 1;
-	__u32 b;
-	int finish = 0;
-	int broken = 0;
-	int i = 0;
-
-	for (b = (1 << sn); b > 0; b >>= 1) {
-		if ((b & mask) == 0) {
-			if (!finish)
-				finish = 1;
-		} else {
-			if (!finish)
-				i ++;
-			else {
-				broken = 1;
-				break;
-			}
-		}
-	}
-
-	if (!broken)
-		sprintf(str, "%u", i);
-	else
-		sprintf(str, "broken(%u)", mask);
-
-	return str;
-}
-
-static void xfrm_tmpl_print(struct xfrm_user_tmpl *tmpls, int ntmpls,
+static void xfrm_tmpl_print(struct xfrm_user_tmpl *tmpls, int len,
 			    __u16 family, FILE *fp, const char *prefix)
 {
+	int ntmpls = len / sizeof(struct xfrm_user_tmpl);
 	int i;
 
+	if (ntmpls <= 0) {
+		if (prefix)
+			fprintf(fp, prefix);
+		fprintf(fp, "(ERROR \"tmpl\" truncated)");
+		fprintf(fp, "%s", _SL_);
+		return;
+	}
+
 	for (i = 0; i < ntmpls; i++) {
 		struct xfrm_user_tmpl *tmpl = &tmpls[i];
 
@@ -490,38 +521,47 @@
 
 		fprintf(fp, "tmpl");
 		xfrm_id_info_print(&tmpl->saddr, &tmpl->id, tmpl->mode,
-				   tmpl->reqid, family, fp, prefix);
+				   tmpl->reqid, family, 0, fp, prefix);
+
+		if (show_stats > 0 || tmpl->optional) {
+			if (prefix)
+				fprintf(fp, prefix);
+			fprintf(fp, "\t");
+			switch (tmpl->optional) {
+			case 0:
+				if (show_stats > 0)
+					fprintf(fp, "level required ");
+				break;
+			case 1:
+				fprintf(fp, "level use ");
+				break;
+			default:
+				fprintf(fp, "level %u ", tmpl->optional);
+				break;
+			}
 
-		if (prefix)
-			fprintf(fp, prefix);
-		fprintf(fp, "\t");
-		switch (tmpl->optional) {
-		case 0:
 			if (show_stats > 0)
-				fprintf(fp, "level required ");
-			break;
-		case 1:
-			fprintf(fp, "level use ");
-			break;
-		default:
-			fprintf(fp, "level %d ", tmpl->optional);
-			break;
+				fprintf(fp, "share %s ", strxf_share(tmpl->share));
+
+			fprintf(fp, "%s", _SL_);
 		}
 
 		if (show_stats > 0) {
-			fprintf(fp, "share %s ", strxf_share(tmpl->share));
-			fprintf(fp, "algo-mask:");
-			fprintf(fp, "%s=%s, ",
+			if (prefix)
+				fprintf(fp, prefix);
+			fprintf(fp, "\t");
+			fprintf(fp, "%s-mask %s ",
 				strxf_algotype(XFRMA_ALG_CRYPT),
-				strxf_mask(tmpl->ealgos));
-			fprintf(fp, "%s=%s, ",
+				strxf_mask32(tmpl->ealgos));
+			fprintf(fp, "%s-mask %s ",
 				strxf_algotype(XFRMA_ALG_AUTH),
-				strxf_mask(tmpl->aalgos));
-			fprintf(fp, "%s=%s",
+				strxf_mask32(tmpl->aalgos));
+			fprintf(fp, "%s-mask %s",
 				strxf_algotype(XFRMA_ALG_COMP),
-				strxf_mask(tmpl->calgos));
+				strxf_mask32(tmpl->calgos));
+
+			fprintf(fp, "%s", _SL_);
 		}
-		fprintf(fp, "%s", _SL_);
 	}
 }
 
@@ -532,31 +572,47 @@
 
 	for (i = 0; i < ntb; i++) {
 		__u16 type = tb[i]->rta_type;
+		int len = RTA_PAYLOAD(tb[i]);
 		void *data = RTA_DATA(tb[i]);
 
 		switch (type) {
 		case XFRMA_ALG_CRYPT:
 		case XFRMA_ALG_AUTH:
 		case XFRMA_ALG_COMP:
-			xfrm_algo_print((struct xfrm_algo *)data, type, fp,
-					prefix);
+			xfrm_algo_print((struct xfrm_algo *)data, type, len,
+					fp, prefix);
 			break;
 		case XFRMA_ENCAP:
+		{
+			struct xfrm_encap_tmpl *e;
+			char abuf[256];
+
 			if (prefix)
 				fprintf(fp, prefix);
-			/* XXX */
-			fprintf(fp, "encap (not implemented yet!)");
+			fprintf(fp, "encap ");
+
+			if (len < sizeof(*e)) {
+				fprintf(fp, "(ERROR truncated)");
+				fprintf(fp, "%s", _SL_);
+				break;
+			}
+			e = (struct xfrm_encap_tmpl *)data;
+
+			fprintf(fp, "type %u ", e->encap_type);
+			fprintf(fp, "sport %u ", ntohs(e->encap_sport));
+			fprintf(fp, "dport %u ", ntohs(e->encap_dport));
+
+			memset(abuf, '\0', sizeof(abuf));
+			fprintf(fp, "addr %s",
+				rt_addr_n2a(family, sizeof(e->encap_oa),
+					    &e->encap_oa, abuf, sizeof(abuf)));
 			fprintf(fp, "%s", _SL_);
 			break;
+		}
 		case XFRMA_TMPL:
-		{
-			int len = tb[i]->rta_len;
-			int ntmpls = len / sizeof(struct xfrm_user_tmpl);
-
 			xfrm_tmpl_print((struct xfrm_user_tmpl *)data,
-					ntmpls, family, fp, prefix);
+					len, family, fp, prefix);
 			break;
-		}
 		default:
 			if (prefix)
 				fprintf(fp, prefix);
@@ -584,7 +640,7 @@
 
 			get_prefix(&src, *argv, preferred_family);
 			if (src.family == AF_UNSPEC)
-				invarg("\"SADDR\" address family is AF_UNSPEC", *argv);
+				invarg("\"src\" address family is AF_UNSPEC", *argv);
 			if (family)
 				*family = src.family;
 
@@ -597,7 +653,7 @@
 
 			get_prefix(&dst, *argv, preferred_family);
 			if (dst.family == AF_UNSPEC)
-				invarg("\"DADDR\" address family is AF_UNSPEC", *argv);
+				invarg("\"dst\" address family is AF_UNSPEC", *argv);
 			if (family)
 				*family = dst.family;
 
@@ -641,7 +697,7 @@
 	}
 
 	if (src.family && dst.family && (src.family != dst.family))
-		invarg("the same address family is required between \"SADDR\" and \"DADDR\"", *argv);
+		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
 
 	if (loose == 0 && id->proto == 0)
 		missarg("XFRM_PROTO");
@@ -828,7 +884,7 @@
 
 			get_prefix(&src, *argv, preferred_family);
 			if (src.family == AF_UNSPEC)
-				invarg("\"SADDR\" address family is AF_UNSPEC", *argv);
+				invarg("\"src\" address family is AF_UNSPEC", *argv);
 			sel->family = src.family;
 
 			memcpy(&sel->saddr, &src.data, sizeof(sel->saddr));
@@ -841,7 +897,7 @@
 
 			get_prefix(&dst, *argv, preferred_family);
 			if (dst.family == AF_UNSPEC)
-				invarg("\"DADDR\" address family is AF_UNSPEC", *argv);
+				invarg("\"dst\" address family is AF_UNSPEC", *argv);
 			sel->family = dst.family;
 
 			memcpy(&sel->daddr, &dst.data, sizeof(sel->daddr));
@@ -882,7 +938,7 @@
 	}
 
 	if (src.family && dst.family && (src.family != dst.family))
-		invarg("the same address family is required between \"SADDR\" and \"DADDR\"", *argv);
+		invarg("the same address family is required between \"src\" and \"dst\"", *argv);
 
 	if (argc == *argcp)
 		missarg("SELECTOR");
diff -Nru a/ip/xfrm.h b/ip/xfrm.h
--- a/ip/xfrm.h	2005-01-09 15:31:16 +09:00
+++ b/ip/xfrm.h	2005-01-09 15:31:16 +09:00
@@ -41,6 +41,14 @@
 #define XFRMP_RTA(x)  ((struct rtattr*)(((char*)(x)) + NLMSG_ALIGN(sizeof(struct xfrm_userpolicy_info))))
 #define XFRMP_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct xfrm_userpoilcy_info))
 
+#define XFRM_FLAG_PRINT(fp, flags, f, s) \
+	do { \
+		if (flags & f) { \
+			flags &= ~f; \
+			fprintf(fp, s "%s", (flags ? " " : "")); \
+		} \
+	} while(0)
+
 struct xfrm_buffer {
 	char *buf;
 	int size;
@@ -54,43 +62,45 @@
 	int use;
 
 	struct xfrm_usersa_info xsinfo;
-	__u32 id_src_mask;
-	__u32 id_dst_mask;
-	__u32 id_proto_mask;
+	__u8 id_src_mask;
+	__u8 id_dst_mask;
+	__u8 id_proto_mask;
 	__u32 id_spi_mask;
-	__u32 mode_mask;
+	__u8 mode_mask;
 	__u32 reqid_mask;
-	__u32 state_flags_mask;
+	__u8 state_flags_mask;
 
 	struct xfrm_userpolicy_info xpinfo;
-	__u32 dir_mask;
-	__u32 sel_src_mask;
-	__u32 sel_dst_mask;
+	__u8 dir_mask;
+	__u8 sel_src_mask;
+	__u8 sel_dst_mask;
 	__u32 sel_dev_mask;
-	__u32 upspec_proto_mask;
-	__u32 upspec_sport_mask;
-	__u32 upspec_dport_mask;
+	__u8 upspec_proto_mask;
+	__u16 upspec_sport_mask;
+	__u16 upspec_dport_mask;
 	__u32 index_mask;
-	__u32 action_mask;
+	__u8 action_mask;
 	__u32 priority_mask;
 };
-#define XFRM_FILTER_MASK_FULL (~(__u32)0)
+#define XFRM_FILTER_MASK_FULL (~0)
 
 extern struct xfrm_filter filter;
 
 int do_xfrm_state(int argc, char **argv);
 int do_xfrm_policy(int argc, char **argv);
 
+int xfrm_addr_match(xfrm_address_t *x1, xfrm_address_t *x2, int bits);
 int xfrm_xfrmproto_getbyname(char *name);
 int xfrm_algotype_getbyname(char *name);
 const char *strxf_xfrmproto(__u8 proto);
 const char *strxf_algotype(int type);
-const char *strxf_flags(__u8 flags);
+const char *strxf_mask8(__u8 mask);
+const char *strxf_mask32(__u32 mask);
 const char *strxf_share(__u8 share);
 const char *strxf_proto(__u8 proto);
 void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
-			__u8 mode, __u32 reqid, __u16 family, FILE *fp,
-			const char *prefix);
+			__u8 mode, __u32 reqid, __u16 family, int force_spi,
+			FILE *fp, const char *prefix);
 void xfrm_stats_print(struct xfrm_stats *s, FILE *fp, const char *prefix);
 void xfrm_lifetime_print(struct xfrm_lifetime_cfg *cfg,
 			 struct xfrm_lifetime_cur *cur,
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2005-01-09 15:31:16 +09:00
+++ b/ip/xfrm_policy.c	2005-01-09 15:31:16 +09:00
@@ -292,18 +292,14 @@
 		return 0;
 
 	if (filter.sel_src_mask) {
-		if (memcmp(&xpinfo->sel.saddr, &filter.xpinfo.sel.saddr,
-			   filter.sel_src_mask) != 0)
-			return 0;
-		if (xpinfo->sel.prefixlen_s != filter.xpinfo.sel.prefixlen_s)
+		if (xfrm_addr_match(&xpinfo->sel.saddr, &filter.xpinfo.sel.saddr,
+				    filter.sel_src_mask))
 			return 0;
 	}
 
 	if (filter.sel_dst_mask) {
-		if (memcmp(&xpinfo->sel.daddr, &filter.xpinfo.sel.daddr,
-			   filter.sel_dst_mask) != 0)
-			return 0;
-		if (xpinfo->sel.prefixlen_d != filter.xpinfo.sel.prefixlen_d)
+		if (xfrm_addr_match(&xpinfo->sel.daddr, &filter.xpinfo.sel.daddr,
+				    filter.sel_dst_mask))
 			return 0;
 	}
 
@@ -381,7 +377,7 @@
 		fprintf(fp, "fwd");
 		break;
 	default:
-		fprintf(fp, "%d", xpinfo->dir);
+		fprintf(fp, "%u", xpinfo->dir);
 		break;
 	}
 	fprintf(fp, " ");
@@ -395,7 +391,7 @@
 		fprintf(fp, "action block ");
 		break;
 	default:
-		fprintf(fp, "action %d ", xpinfo->action);
+		fprintf(fp, "action %u ", xpinfo->action);
 		break;
 	}
 
@@ -404,7 +400,7 @@
 	fprintf(fp, "priority %u ", xpinfo->priority);
 	if (show_stats > 0) {
 		fprintf(fp, "share %s ", strxf_share(xpinfo->share));
-		fprintf(fp, "flags 0x%s", strxf_flags(xpinfo->flags));
+		fprintf(fp, "flag 0x%s", strxf_mask8(xpinfo->flags));
 	}
 	fprintf(fp, "%s", _SL_);
 
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2005-01-09 15:31:16 +09:00
+++ b/ip/xfrm_state.c	2005-01-09 15:31:16 +09:00
@@ -56,11 +56,12 @@
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip xfrm state { add | update } ID [ ALGO-LIST ] [ mode MODE ]\n");
-	fprintf(stderr, "        [ reqid REQID ] [ FLAG-LIST ] [ sel SELECTOR ] [ LIMIT-LIST ]\n");
+	fprintf(stderr, "        [ reqid REQID ] [ replay-window SIZE ] [ flag FLAG-LIST ]\n");
+	fprintf(stderr, "        [ sel SELECTOR ] [ LIMIT-LIST ]\n");
 
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID\n");
 	fprintf(stderr, "Usage: ip xfrm state { flush | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
-	fprintf(stderr, "        [ FLAG_LIST ]\n");
+	fprintf(stderr, "        [ flag FLAG_LIST ]\n");
 
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
@@ -75,8 +76,8 @@
  	fprintf(stderr, "MODE := [ transport | tunnel ](default=transport)\n");
  	//fprintf(stderr, "REQID - number(default=0)\n");
 
-	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] [ flag FLAG ]\n");
-	fprintf(stderr, "FLAG := [ noecn ]\n");
+	fprintf(stderr, "FLAG-LIST := [ FLAG-LIST ] FLAG\n");
+	fprintf(stderr, "FLAG := [ noecn | decap-dscp ]\n");
 
 	fprintf(stderr, "ALGO-LIST := [ ALGO-LIST ] | [ ALGO ]\n");
 	fprintf(stderr, "ALGO := ALGO_TYPE ALGO_NAME ALGO_KEY\n");
@@ -89,7 +90,7 @@
 	//fprintf(stderr, "ALGO_NAME - algorithm name\n");
 	//fprintf(stderr, "ALGO_KEY - algorithm key\n");
 
-	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ upspec UPSPEC ] [ dev DEV ]\n");
+	fprintf(stderr, "SELECTOR := src ADDR[/PLEN] dst ADDR[/PLEN] [ UPSPEC ] [ dev DEV ]\n");
 
 	fprintf(stderr, "UPSPEC := proto PROTO [ [ sport PORT ] [ dport PORT ] |\n");
 	fprintf(stderr, "                        [ type NUMBER ] [ code NUMBER ] ]\n");
@@ -108,7 +109,7 @@
 	int len;
 	int slen = strlen(key);
 
-#if 1
+#if 0
 	/* XXX: verifying both name and key is required! */
 	fprintf(stderr, "warning: ALGONAME/ALGOKEY will send to kernel promiscuously!(verifying them isn't implemented yet)\n");
 #endif
@@ -173,10 +174,20 @@
 			invarg("\"FLAG\" is invalid", *argv);
 		*flags = val;
 	} else {
-		if (strcmp(*argv, "noecn") == 0)
-			*flags |= XFRM_STATE_NOECN;
-		else
-			invarg("\"FLAG\" is invalid", *argv);
+		while (1) {
+			if (strcmp(*argv, "noecn") == 0)
+				*flags |= XFRM_STATE_NOECN;
+			else if (strcmp(*argv, "decap-dscp") == 0)
+				*flags |= XFRM_STATE_DECAP_DSCP;
+			else {
+				PREV_ARG(); /* back track */
+				break;
+			}
+
+			if (!NEXT_ARG_OK())
+				break;
+			NEXT_ARG();
+		}
 	}
 
 	filter.state_flags_mask = XFRM_FILTER_MASK_FULL;
@@ -219,6 +230,10 @@
 		} else if (strcmp(*argv, "reqid") == 0) {
 			NEXT_ARG();
 			xfrm_reqid_parse(&req.xsinfo.reqid, &argc, &argv);
+		} else if (strcmp(*argv, "replay-window") == 0) {
+			NEXT_ARG();
+			if (get_u8(&req.xsinfo.replay_window, *argv, 0))
+				invarg("\"replay-window\" value is invalid", *argv);
 		} else if (strcmp(*argv, "flag") == 0) {
 			NEXT_ARG();
 			xfrm_state_flag_parse(&req.xsinfo.flags, &argc, &argv);
@@ -343,12 +358,12 @@
 		return 1;
 
 	if (filter.id_src_mask)
-		if (memcmp(&xsinfo->saddr, &filter.xsinfo.saddr,
-			   filter.id_src_mask) != 0)
+		if (xfrm_addr_match(&xsinfo->saddr, &filter.xsinfo.saddr,
+				    filter.id_src_mask))
 			return 0;
 	if (filter.id_dst_mask)
-		if (memcmp(&xsinfo->id.daddr, &filter.xsinfo.id.daddr,
-			   filter.id_dst_mask) != 0)
+		if (xfrm_addr_match(&xsinfo->id.daddr, &filter.xsinfo.id.daddr,
+				    filter.id_dst_mask))
 			return 0;
 	if ((xsinfo->id.proto^filter.xsinfo.id.proto)&filter.id_proto_mask)
 		return 0;
@@ -407,22 +422,22 @@
 		fprintf(fp, "Deleted ");
 
 	xfrm_id_info_print(&xsinfo->saddr, &xsinfo->id, xsinfo->mode,
-			   xsinfo->reqid, xsinfo->family, fp, NULL);
+			   xsinfo->reqid, xsinfo->family, 1, fp, NULL);
 
 	fprintf(fp, "\t");
-	fprintf(fp, "replay-window %d ", xsinfo->replay_window);
+	fprintf(fp, "replay-window %u ", xsinfo->replay_window);
 	if (show_stats > 0)
 		fprintf(fp, "seq 0x%08u ", xsinfo->seq);
-	if (xsinfo->flags) {
-		fprintf(fp, "flag 0x%s", strxf_flags(xsinfo->flags));
-		if (show_stats > 0) {
-			if (xsinfo->flags) {
-				fprintf(fp, "(");
-				if (xsinfo->flags & XFRM_STATE_NOECN)
-					fprintf(fp, "noecn");
-				fprintf(fp, ")");
-			}
-		}
+	if (show_stats > 0 || xsinfo->flags) {
+		__u8 flags = xsinfo->flags;
+
+		fprintf(fp, "flag ");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_NOECN, "noecn");
+		XFRM_FLAG_PRINT(fp, flags, XFRM_STATE_DECAP_DSCP, "decap-dscp");
+		if (flags)
+			fprintf(fp, "%x", flags);
+		if (show_stats > 0)
+			fprintf(fp, " (0x%s)", strxf_mask8(flags));
 	}
 	fprintf(fp, "%s", _SL_);
 



-- 
Masahide NAKAMURA
