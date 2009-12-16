From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH][RESEND 2] IPv6: 6rd iproute2 support
Date: Wed, 16 Dec 2009 13:38:29 +0100
Message-ID: <20091216123829.GA3258@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:58332 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933319AbZLPMih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 07:38:37 -0500
Received: from smtp2-g21.free.fr (localhost [127.0.0.1])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 2318B4B01D0
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 13:38:31 +0100 (CET)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp2-g21.free.fr (Postfix) with ESMTP id 4AA634B00B3
	for <netdev@vger.kernel.org>; Wed, 16 Dec 2009 13:38:29 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides iproute2 facilities to configure 6rd tunnel. To
configure a 6rd tunnel, you need to configure a sit tunnel and set
6rd prefix as following :

  ip tunnel add sit1 mode sit local a.b.c.d ttl 64
  ip tunnel 6rd dev sit1 6rd-prefix xxxx:yyyy::/z

Optionally you can provide a relay prefix :

  ip tunnel 6rd dev sit1 6rd-relay_prefix e.f.g.h/i

Finally you can reset previous tunnel settings :

  ip tunnel 6rd dev sit1 6rd-reset

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 include/linux/if_tunnel.h |   11 +++++++
 ip/iptunnel.c             |   64 ++++++++++++++++++++++++++++++++++++++++++++-
 ip/tunnel.c               |   17 +++++++++++-
 ip/tunnel.h               |    2 +
 4 files changed, 92 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 3036cec..fac7be7 100644
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
@@ -48,6 +52,13 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+struct ip_tunnel_6rd {
+	struct in6_addr		prefix;
+	__be32			relay_prefix;
+	__u16			prefixlen;
+	__u16			relay_prefixlen;
+};
+
 enum
 {
 	IFLA_GRE_UNSPEC,
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index dcd7ee6..1cd9fbd 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -32,10 +32,11 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl } [ NAME ]\n");
+	fprintf(stderr, "Usage: ip tunnel { add | change | del | show | prl | 6rd } [ NAME ]\n");
 	fprintf(stderr, "          [ mode { ipip | gre | sit | isatap } ] [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "          [ prl-default ADDR ] [ prl-nodefault ADDR ] [ prl-delete ADDR ]\n");
+	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
@@ -302,11 +303,13 @@ static int do_del(int argc, char **argv)
 
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
 
@@ -362,6 +365,17 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (!(p->iph.frag_off&htons(IP_DF)))
 		printf(" nopmtudisc");
 
+	if (!tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
+		printf(" 6rd-prefix %s/%u ",
+		       inet_ntop(AF_INET6, &ip6rd.prefix, s1, sizeof(s1)),
+		       ip6rd.prefixlen);
+		if (ip6rd.relay_prefix) {
+			printf("6rd-relay_prefix %s/%u ",
+			       format_host(AF_INET, 4, &ip6rd.relay_prefix, s1, sizeof(s1)),
+			       ip6rd.relay_prefixlen);
+		}
+	}
+
 	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
 		printf(" key %s", s3);
 	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
@@ -528,6 +542,52 @@ static int do_prl(int argc, char **argv)
 	return tnl_prl_ioctl(cmd, medium, &p);
 }
 
+static int do_6rd(int argc, char **argv)
+{
+	struct ip_tunnel_6rd ip6rd;
+	int devname = 0;
+	int cmd = 0;
+	char medium[IFNAMSIZ];
+	inet_prefix prefix;
+
+	memset(&ip6rd, 0, sizeof(ip6rd));
+	memset(&medium, 0, sizeof(medium));
+
+	while (argc > 0) {
+		if (strcmp(*argv, "6rd-prefix") == 0) {
+			NEXT_ARG();
+			if (get_prefix(&prefix, *argv, AF_INET6))
+				invarg("invalid 6rd_prefix\n", *argv);
+			cmd = SIOCADD6RD;
+			memcpy(&ip6rd.prefix, prefix.data, 16);
+			ip6rd.prefixlen = prefix.bitlen;
+		} else if (strcmp(*argv, "6rd-relay_prefix") == 0) {
+			NEXT_ARG();
+			if (get_prefix(&prefix, *argv, AF_INET))
+				invarg("invalid 6rd-relay_prefix\n", *argv);
+			cmd = SIOCADD6RD;
+			memcpy(&ip6rd.relay_prefix, prefix.data, 4);
+			ip6rd.relay_prefixlen = prefix.bitlen;
+		} else if (strcmp(*argv, "6rd-reset") == 0) {
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
@@ -561,6 +621,8 @@ int do_iptunnel(int argc, char **argv)
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
1.6.3.3

