From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 1/4] libgenl: introduce genl_init_handle
Date: Tue, 16 Aug 2016 16:26:55 +0200
Message-ID: <3cc24a2451fc2aafa7ba554a414b323225657e65.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Cc: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455AbcHPO1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 10:27:15 -0400
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
In-Reply-To: <cover.1471356460.git.sd@queasysnail.net>
References: <cover.1471356460.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All users of genl have the same code to open a genl socket and resolve
the family for their specific protocol.  Introduce a helper to intialize
the handle, and use it in all the genl code.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 include/libgenl.h |  2 ++
 ip/ipfou.c        | 12 ++----------
 ip/ipila.c        | 12 ++----------
 ip/ipl2tp.c       | 12 ++----------
 ip/ipmacsec.c     | 18 ++----------------
 ip/tcp_metrics.c  | 14 +++-----------
 lib/libgenl.c     | 17 +++++++++++++++++
 7 files changed, 30 insertions(+), 57 deletions(-)

diff --git a/include/libgenl.h b/include/libgenl.h
index 9db4bafd511b..2dbb4b36adcb 100644
--- a/include/libgenl.h
+++ b/include/libgenl.h
@@ -21,5 +21,7 @@ struct {								\
 }
 
 extern int genl_resolve_family(struct rtnl_handle *grth, const char *family);
+extern int genl_init_handle(struct rtnl_handle *grth, const char *family,
+			    int *genl_family);
 
 #endif /* __LIBGENL_H__ */
diff --git a/ip/ipfou.c b/ip/ipfou.c
index 0673d11ff6f9..9f0911215749 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -136,16 +136,8 @@ static int do_del(int argc, char **argv)
 
 int do_ipfou(int argc, char **argv)
 {
-	if (genl_family < 0) {
-		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
-			fprintf(stderr, "Cannot open generic netlink socket\n");
-			exit(1);
-		}
-
-		genl_family = genl_resolve_family(&genl_rth, FOU_GENL_NAME);
-		if (genl_family < 0)
-			exit(1);
-	}
+	if (genl_init_handle(&genl_rth, FOU_GENL_NAME, &genl_family))
+		exit(1);
 
 	if (argc < 1)
 		usage();
diff --git a/ip/ipila.c b/ip/ipila.c
index c30bdbf166a6..244245ca3c40 100644
--- a/ip/ipila.c
+++ b/ip/ipila.c
@@ -237,16 +237,8 @@ static int do_del(int argc, char **argv)
 
 int do_ipila(int argc, char **argv)
 {
-	if (genl_family < 0) {
-		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
-			fprintf(stderr, "Cannot open generic netlink socket\n");
-			exit(1);
-		}
-
-		genl_family = genl_resolve_family(&genl_rth, ILA_GENL_NAME);
-		if (genl_family < 0)
-			exit(1);
-	}
+	if (genl_init_handle(&genl_rth, ILA_GENL_NAME, &genl_family))
+		exit(1);
 
 	if (argc < 1)
 		usage();
diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 9ebda135e5d6..d3338acecc9c 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -767,16 +767,8 @@ int do_ipl2tp(int argc, char **argv)
 	if (argc < 1 || !matches(*argv, "help"))
 		usage();
 
-	if (genl_family < 0) {
-		if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
-			fprintf(stderr, "Cannot open generic netlink socket\n");
-			exit(1);
-		}
-
-		genl_family = genl_resolve_family(&genl_rth, L2TP_GENL_NAME);
-		if (genl_family < 0)
-			exit(1);
-	}
+	if (genl_init_handle(&genl_rth, L2TP_GENL_NAME, &genl_family))
+		exit(1);
 
 	if (matches(*argv, "add") == 0)
 		return do_add(argc-1, argv+1);
diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 329be00fb32b..9eabfe241980 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -79,21 +79,6 @@ static int genl_family = -1;
 		     _cmd, _flags)
 
 
-static void init_genl(void)
-{
-	if (genl_family >= 0)
-		return;
-
-	if (rtnl_open_byproto(&genl_rth, 0, NETLINK_GENERIC) < 0) {
-		fprintf(stderr, "Cannot open generic netlink socket\n");
-		exit(1);
-	}
-
-	genl_family = genl_resolve_family(&genl_rth, MACSEC_GENL_NAME);
-	if (genl_family < 0)
-		exit(1);
-}
-
 static void ipmacsec_usage(void)
 {
 	fprintf(stderr, "Usage: ip macsec add DEV tx sa { 0..3 } [ OPTS ] key ID KEY\n");
@@ -1001,7 +986,8 @@ static int do_show(int argc, char **argv)
 
 int do_ipmacsec(int argc, char **argv)
 {
-	init_genl();
+	if (genl_init_handle(&genl_rth, MACSEC_GENL_NAME, &genl_family))
+		exit(1);
 
 	if (argc < 1)
 		ipmacsec_usage();
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index ac2613a0a880..8972acd05fb2 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -398,17 +398,9 @@ static int tcpm_do_cmd(int cmd, int argc, char **argv)
 		ack = 0;
 	}
 
-	if (genl_family < 0) {
-		if (rtnl_open_byproto(&grth, 0, NETLINK_GENERIC) < 0) {
-			fprintf(stderr, "Cannot open generic netlink socket\n");
-			exit(1);
-		}
-		genl_family = genl_resolve_family(&grth,
-						  TCP_METRICS_GENL_NAME);
-		if (genl_family < 0)
-			exit(1);
-		req.n.nlmsg_type = genl_family;
-	}
+	if (genl_init_handle(&grth, TCP_METRICS_GENL_NAME, &genl_family))
+		exit(1);
+	req.n.nlmsg_type = genl_family;
 
 	if (!(cmd & CMD_FLUSH) && (atype >= 0 || (cmd & CMD_DEL))) {
 		if (ack)
diff --git a/lib/libgenl.c b/lib/libgenl.c
index a1a37a440f64..5fba1d86c624 100644
--- a/lib/libgenl.c
+++ b/lib/libgenl.c
@@ -60,3 +60,20 @@ int genl_resolve_family(struct rtnl_handle *grth, const char *family)
 
 	return genl_parse_getfamily(&req.n);
 }
+
+int genl_init_handle(struct rtnl_handle *grth, const char *family, int *genl_family)
+{
+	if (*genl_family >= 0)
+		return 0;
+
+	if (rtnl_open_byproto(grth, 0, NETLINK_GENERIC) < 0) {
+		fprintf(stderr, "Cannot open generic netlink socket\n");
+		return -1;
+	}
+
+	*genl_family = genl_resolve_family(grth, family);
+	if (*genl_family < 0)
+		return -1;
+
+	return 0;
+}
-- 
2.9.3
