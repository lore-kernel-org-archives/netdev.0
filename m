From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] XFRM: fixing protocol
Date: Mon, 6 Sep 2004 16:47:03 +0900
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040906164703.3e674496@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
List-Id: netdev.vger.kernel.org

Talking about "protocol" on IPsec/XFRM, there are two
kinds of it, one is in selector and the other is in
SA(state for transformation). This patch makes it
is managed separately.

The ChangeSets are also available at:
<bk clone bk://bk.skbuff.net:38000/iproute2-FIX-proto/>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/02 19:11:13+09:00 nakam@linux-ipv6.org 
#   fix error message.
# 
# ip/xfrm_state.c
#   2004/09/02 19:11:13+09:00 nakam@linux-ipv6.org +2 -2
#   fix error message to use strxf_xfrmproto().
# 
# ChangeSet
#   2004/09/02 13:35:13+09:00 nakam@linux-ipv6.org 
#   distinguish xfrm protocol and selector protocol.
# 
# ip/xfrm_state.c
#   2004/09/02 13:35:10+09:00 nakam@linux-ipv6.org +4 -4
#   fix usage.
# 
# ip/xfrm_policy.c
#   2004/09/02 13:35:10+09:00 nakam@linux-ipv6.org +4 -4
#   fix usage.
# 
# ip/xfrm.h
#   2004/09/02 13:35:10+09:00 nakam@linux-ipv6.org +2 -0
#   add interfaces of xfrmproto.
# 
# ip/ipxfrm.c
#   2004/09/02 13:35:10+09:00 nakam@linux-ipv6.org +45 -21
#   add "xfrmproto" to distinguish xfrm protocol and selector protocol.
# 
diff -Nru a/ip/ipxfrm.c b/ip/ipxfrm.c
--- a/ip/ipxfrm.c	2004-09-02 23:03:08 +09:00
+++ b/ip/ipxfrm.c	2004-09-02 23:03:08 +09:00
@@ -57,6 +57,43 @@
 	int t_type;
 };
 
+static const struct typeent xfrmproto_types[]= {
+	{ "esp", IPPROTO_ESP }, { "ah", IPPROTO_AH },
+	{ "comp", IPPROTO_COMP }, { NULL, -1 }
+};
+
+int xfrm_xfrmproto_getbyname(char *name)
+{
+	int i;
+
+	for (i = 0; ; i++) {
+		const struct typeent *t = &xfrmproto_types[i];
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
+const char *strxf_xfrmproto(__u8 proto)
+{
+	int i;
+
+	for (i = 0; ; i++) {
+		const struct typeent *t = &xfrmproto_types[i];
+		if (!t->t_name || t->t_type == -1)
+			break;
+
+		if (t->t_type == proto)
+			return t->t_name;
+	}
+
+	return NULL;
+}
+
 static const struct typeent algo_types[]= {
 	{ "enc", XFRMA_ALG_CRYPT }, { "auth", XFRMA_ALG_AUTH },
 	{ "comp", XFRMA_ALG_COMP }, { NULL, -1 }
@@ -172,7 +209,7 @@
 		fprintf(fp, prefix);
 	fprintf(fp, "\t");
 
-	fprintf(fp, "proto %s ", strxf_proto(id->proto));
+	fprintf(fp, "proto %s ", strxf_xfrmproto(id->proto));
 
 	spi = ntohl(id->spi);
 	fprintf(fp, "spi 0x%08x", spi);
@@ -522,7 +559,6 @@
 	char **argv = *argvp;
 	inet_prefix dst;
 	inet_prefix src;
-	__u8 proto = 0;
 
 	memset(&dst, 0, sizeof(dst));
 	memset(&src, 0, sizeof(src));
@@ -555,27 +591,15 @@
 			filter.id_dst_mask = dst.bitlen;
 
 		} else if (strcmp(*argv, "proto") == 0) {
-			struct protoent *pp;
+			int ret;
 
 			NEXT_ARG();
 
-			pp = getprotobyname(*argv);
-			if (pp)
-				proto = pp->p_proto;
-			else {
-				if (get_u8(&proto, *argv, 0))
-					invarg("\"XFRM_PROTO\" is invalid", *argv);
-			}
+			ret = xfrm_xfrmproto_getbyname(*argv);
+			if (ret < 0)
+				invarg("\"XFRM_PROTO\" is invalid", *argv);
 
-			switch (proto) {
-			case IPPROTO_ESP:
-			case IPPROTO_AH:
-			case IPPROTO_COMP:
-				id->proto = proto;
-				break;
-			default:
-				invarg("\"XFRM_PROTO\" is unsuppored proto", *argv);
-			}
+			id->proto = (__u8)ret;
 
 			filter.id_proto_mask = XFRM_FILTER_MASK_FULL;
 
@@ -604,8 +628,8 @@
 	if (src.family && dst.family && (src.family != dst.family))
 		invarg("the same address family is required between \"SADDR\" and \"DADDR\"", *argv);
 
-	if (loose == 0 && proto == 0)
-		missarg("PROTO");
+	if (loose == 0 && id->proto == 0)
+		missarg("XFRM_PROTO");
 	if (argc == *argcp)
 		missarg("ID");
 
diff -Nru a/ip/xfrm.h b/ip/xfrm.h
--- a/ip/xfrm.h	2004-09-02 23:03:08 +09:00
+++ b/ip/xfrm.h	2004-09-02 23:03:08 +09:00
@@ -78,7 +78,9 @@
 int do_xfrm_state(int argc, char **argv);
 int do_xfrm_policy(int argc, char **argv);
 
+int xfrm_xfrmproto_getbyname(char *name);
 int xfrm_algotype_getbyname(char *name);
+const char *strxf_xfrmproto(__u8 proto);
 const char *strxf_algotype(int type);
 const char *strxf_flags(__u8 flags);
 const char *strxf_share(__u8 share);
diff -Nru a/ip/xfrm_policy.c b/ip/xfrm_policy.c
--- a/ip/xfrm_policy.c	2004-09-02 23:03:08 +09:00
+++ b/ip/xfrm_policy.c	2004-09-02 23:03:08 +09:00
@@ -78,11 +78,11 @@
 	fprintf(stderr, "TMPL := ID [ mode MODE ] [ reqid REQID ] [ level LEVEL ]\n");
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
 
-	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
 	fprintf(stderr, "XFRM_PROTO := [ ");
-	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ESP));
-	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_AH));
-	fprintf(stderr, "%s", strxf_proto(IPPROTO_COMP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
+	fprintf(stderr, "%s", strxf_xfrmproto(IPPROTO_COMP));
 	fprintf(stderr, " ]\n");
 
  	fprintf(stderr, "MODE := [ transport | tunnel ](default=transport)\n");
diff -Nru a/ip/xfrm_state.c b/ip/xfrm_state.c
--- a/ip/xfrm_state.c	2004-09-02 23:03:08 +09:00
+++ b/ip/xfrm_state.c	2004-09-02 23:03:08 +09:00
@@ -63,11 +63,11 @@
 	fprintf(stderr, "        [ FLAG_LIST ]\n");
 
 	fprintf(stderr, "ID := [ src ADDR ] [ dst ADDR ] [ proto XFRM_PROTO ] [ spi SPI ]\n");
-	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | ipcomp ]\n");
+	//fprintf(stderr, "XFRM_PROTO := [ esp | ah | comp ]\n");
 	fprintf(stderr, "XFRM_PROTO := [ ");
-	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_ESP));
-	fprintf(stderr, "%s | ", strxf_proto(IPPROTO_AH));
-	fprintf(stderr, "%s ", strxf_proto(IPPROTO_COMP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_ESP));
+	fprintf(stderr, "%s | ", strxf_xfrmproto(IPPROTO_AH));
+	fprintf(stderr, "%s ", strxf_xfrmproto(IPPROTO_COMP));
 	fprintf(stderr, "]\n");
 
 	//fprintf(stderr, "SPI - security parameter index(default=0)\n");
@@ -308,14 +308,14 @@
 		if (req.xsinfo.id.proto != IPPROTO_ESP &&
 		    req.xsinfo.id.proto != IPPROTO_AH &&
 		    req.xsinfo.id.proto != IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n", strxf_proto(req.xsinfo.id.proto));
+			fprintf(stderr, "\"ALGO\" is invalid with proto=%s\n", strxf_xfrmproto(req.xsinfo.id.proto));
 			exit(1);
 		}
 	} else {
 		if (req.xsinfo.id.proto == IPPROTO_ESP ||
 		    req.xsinfo.id.proto == IPPROTO_AH ||
 		    req.xsinfo.id.proto == IPPROTO_COMP) {
-			fprintf(stderr, "\"ALGO\" is required with proto=%s\n", strxf_proto(req.xsinfo.id.proto));
+			fprintf(stderr, "\"ALGO\" is required with proto=%s\n", strxf_xfrmproto(req.xsinfo.id.proto));
 			exit (1);
 		}
 	}







-- 
Masahide NAKAMURA
