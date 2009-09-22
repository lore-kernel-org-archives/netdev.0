From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH iproute2][RESEND] IPv6: 6rd iproute2 support
Date: Tue, 22 Sep 2009 02:41:10 +0200
Message-ID: <20090922004110.GA19968@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:54475 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbZIVAlO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 20:41:14 -0400
Received: from smtp2-g21.free.fr (localhost [127.0.0.1])
	by smtp2-g21.free.fr (Postfix) with ESMTP id C0B104B0021
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2009 02:41:13 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp2-g21.free.fr (Postfix) with ESMTP id E3F044B001B
	for <netdev@vger.kernel.org>; Tue, 22 Sep 2009 02:41:10 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provide iproute2 facilities to configure 6rd tunnel. To
configure a 6rd tunnel, simply configure a sit tunnel and set
6rd prefix as following :

    ip tunnel add sit1 mode site local a.b.c.d ttl 64
    ip tunnel 6rd dev sit1 set-6rd_prefix xxxx:yyyy::/z

Additionaly you can reset 6rd_prefix :

    ip tunnel 6rd dev sit1 reset-6rd_prefix

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 include/linux/if_tunnel.h |   10 ++++++++
 ip/iptunnel.c             |   53 ++++++++++++++++++++++++++++++++++++++++++++-
 ip/tunnel.c               |   17 +++++++++++++-
 ip/tunnel.h               |    2 +
 4 files changed, 80 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 9229075..5ebe5a4 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -12,6 +12,10 @@
 #define SIOCADDPRL      (SIOCDEVPRIVATE + 5)
 #define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
 #define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
+#define SIOCGET6RD      (SIOCDEVPRIVATE + 8)
+#define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
+#define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
+#define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
 
 #define GRE_CSUM	__cpu_to_be16(0x8000)
 #define GRE_ROUTING	__cpu_to_be16(0x4000)
@@ -48,6 +52,12 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+/* 6RD parms */
+struct ip_tunnel_6rd {
+	struct in6_addr		addr;
+	__u8			prefixlen;
+};
+
 enum
 {
 	IFLA_GRE_UNSPEC,
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 338d8bd..31843ad 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -38,10 +38,11 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl } [ NAME ]\n");
+	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl | 6rd } [ NAME ]\n");
 	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ prl-default ADDR ] [ prl-nodefault ADDR ] [ prl-delete ADDR ]\n");
+	fprintf(stderr, "          [ set-6rd_prefix ADDR ] [ reset-6rd_prefix ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
@@ -308,11 +309,13 @@ static int do_del(int argc, char **argv)
 
 static void print_tunnel(struct ip_tunnel_parm *p)
 {
+	struct ip_tunnel_6rd ip6rd;
 	char s1[1024];
 	char s2[1024];
 	char s3[64];
 	char s4[64];
 
+	memset(&ip6rd, 0, sizeof(ip6rd));
 	inet_ntop(AF_INET, &p->i_key, s3, sizeof(s3));
 	inet_ntop(AF_INET, &p->o_key, s4, sizeof(s4));
 
@@ -368,6 +371,13 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (!(p->iph.frag_off&htons(IP_DF)))
 		printf(" nopmtudisc");
 
+	if (!tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
+		char buf[128];
+		printf(" 6rd_prefix %s/%u ",
+		       inet_ntop(AF_INET6, &ip6rd.addr, buf, 128),
+		       ip6rd.prefixlen);
+	}
+
 	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
 		printf(" key %s", s3);
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
@@ -534,6 +544,45 @@ static int do_prl(int argc, char **argv)
 	return tnl_prl_ioctl(cmd, medium, &p);
 }
 
+static int do_6rd(int argc, char **argv)
+{
+	struct ip_tunnel_6rd ip6rd;
+	int devname = 0;
+	int cmd = 0;
+	char medium[IFNAMSIZ];
+
+	memset(&ip6rd, 0, sizeof(ip6rd));
+	memset(&medium, 0, sizeof(medium));
+
+	while (argc > 0) {
+		if (strcmp(*argv, "set-6rd_prefix") == 0) {
+			inet_prefix prefix;
+			NEXT_ARG();
+			if (get_prefix(&prefix, *argv, AF_INET6))
+				invarg("invalid 6rd_prefix\n", *argv);
+			cmd = SIOCADD6RD;
+			memcpy(&ip6rd.addr, prefix.data, 16);
+			ip6rd.prefixlen = prefix.bitlen;
+		} else if (strcmp(*argv, "reset-6rd_prefix") == 0) {
+			cmd = SIOCDEL6RD;
+		} else if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			strncpy(medium, *argv, IFNAMSIZ-1);
+			devname++;
+		} else {
+			fprintf(stderr,"%s: Invalid 6RD parameter.\n", *argv);
+			exit(-1);
+		}
+		argc--; argv++;
+	}
+	if (devname == 0) {
+		fprintf(stderr, "Must specify dev.\n");
+		exit(-1);
+	}
+
+	return tnl_6rd_ioctl(cmd, medium, &ip6rd);
+}
+
 int do_iptunnel(int argc, char **argv)
 {
 	switch (preferred_family) {
@@ -567,6 +616,8 @@ int do_iptunnel(int argc, char **argv)
 			return do_show(argc-1, argv+1);
 		if (matches(*argv, "prl") == 0)
 			return do_prl(argc-1, argv+1);
+		if (matches(*argv, "6rd") == 0)
+			return do_6rd(argc-1, argv+1);
 		if (matches(*argv, "help") == 0)
 			usage();
 	} else
diff --git a/ip/tunnel.c b/ip/tunnel.c
index d1296e6..d389e86 100644
--- a/ip/tunnel.c
+++ b/ip/tunnel.c
@@ -168,7 +168,7 @@ int tnl_del_ioctl(const char *basedev, const char *name, void *p)
 	return err;
 }
 
-int tnl_prl_ioctl(int cmd, const char *name, void *p)
+static int tnl_gen_ioctl(int cmd, const char *name, void *p)
 {
 	struct ifreq ifr;
 	int fd;
@@ -183,3 +183,18 @@ int tnl_prl_ioctl(int cmd, const char *name, void *p)
 	close(fd);
 	return err;
 }
+
+int tnl_prl_ioctl(int cmd, const char *name, void *p)
+{
+	return tnl_gen_ioctl(cmd, name, p);
+}
+
+int tnl_6rd_ioctl(int cmd, const char *name, void *p)
+{
+	return tnl_gen_ioctl(cmd, name, p);
+}
+
+int tnl_ioctl_get_6rd(const char *name, void *p)
+{
+	return tnl_gen_ioctl(SIOCGET6RD, name, p);
+}
diff --git a/ip/tunnel.h b/ip/tunnel.h
index 0661e27..ded226b 100644
--- a/ip/tunnel.h
+++ b/ip/tunnel.h
@@ -32,5 +32,7 @@ int tnl_get_ioctl(const char *basedev, void *p);
 int tnl_add_ioctl(int cmd, const char *basedev, const char *name, void *p);
 int tnl_del_ioctl(const char *basedev, const char *name, void *p);
 int tnl_prl_ioctl(int cmd, const char *name, void *p);
+int tnl_6rd_ioctl(int cmd, const char *name, void *p);
+int tnl_ioctl_get_6rd(const char *name, void *p);
 
 #endif
-- 
1.6.0.4

