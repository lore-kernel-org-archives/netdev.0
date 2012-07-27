From: Kozlov Dmitry <xeb@mail.ru>
Subject: [PATCH iproute2] GRE over IPv6 tunnels support
Date: Fri, 27 Jul 2012 16:29:03 +0400
Message-ID: <2176918.fzOOYiNNmM@dima>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2201742.1d2rMxPZCJ"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:45871 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab2G0Oie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 10:38:34 -0400
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id 44A187DFD95
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 16:29:26 +0400 (MSK)
Received: from [195.24.254.26] (port=28077 helo=dima.localnet)
	by smtp11.mail.ru with esmtpa (envelope-from <xeb@mail.ru>)
	id 1SujfE-0000fF-3q
	for netdev@vger.kernel.org; Fri, 27 Jul 2012 16:29:04 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2201742.1d2rMxPZCJ
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

GRE over IPv6 tunnels support.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
 
--nextPart2201742.1d2rMxPZCJ
Content-Disposition: attachment; filename="patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="UTF-8"; name="patch"

 include/linux/if_arp.h     |   15 +++++
 include/linux/if_tunnel.h  |   21 +++++++
 include/linux/ip6_tunnel.h |   18 ++++++
 ip/ip6tunnel.c             |  131 ++++++++++++++++++++++++++++++++++++++------
 4 files changed, 168 insertions(+), 17 deletions(-)
 
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index d2de0f9..9adcc29 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -92,6 +92,7 @@
 #define ARPHRD_PHONET	820		/* PhoNet media type		*/
 #define ARPHRD_PHONET_PIPE 821		/* PhoNet pipe header		*/
 #define ARPHRD_CAIF	822		/* CAIF media type		*/
+#define ARPHRD_IP6GRE	823		/* GRE over IPv6		*/
 
 #define ARPHRD_VOID	  0xFFFF	/* Void type, nothing is known */
 #define ARPHRD_NONE	  0xFFFE	/* zero header length */
@@ -154,5 +155,19 @@ struct arphdr {
 
 };
 
+#ifdef __KERNEL__
+#include <linux/skbuff.h>
+
+static inline struct arphdr *arp_hdr(const struct sk_buff *skb)
+{
+	return (struct arphdr *)skb_network_header(skb);
+}
+
+static inline int arp_hdr_len(struct net_device *dev)
+{
+	/* ARP header, plus 2 device addresses, plus 2 IP addresses. */
+	return sizeof(struct arphdr) + (dev->addr_len + sizeof(u32)) * 2;
+}
+#endif
 
 #endif	/* _LINUX_IF_ARP_H */
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 8c819b8..8c5035a 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -4,6 +4,10 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
 
+#ifdef __KERNEL__
+#include <linux/ip.h>
+#include <linux/in6.h>
+#endif
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
@@ -71,9 +75,26 @@ enum {
 	IFLA_GRE_TTL,
 	IFLA_GRE_TOS,
 	IFLA_GRE_PMTUDISC,
+	IFLA_GRE_ENCAP_LIMIT,
+	IFLA_GRE_FLOWINFO,
+	IFLA_GRE_FLAGS,
 	__IFLA_GRE_MAX,
 };
 
 #define IFLA_GRE_MAX	(__IFLA_GRE_MAX - 1)
 
+/* VTI-mode i_flags */
+#define VTI_ISVTI 0x0001
+
+enum {
+	IFLA_VTI_UNSPEC,
+	IFLA_VTI_LINK,
+	IFLA_VTI_IKEY,
+	IFLA_VTI_OKEY,
+	IFLA_VTI_LOCAL,
+	IFLA_VTI_REMOTE,
+	__IFLA_VTI_MAX,
+};
+
+#define IFLA_VTI_MAX	(__IFLA_VTI_MAX - 1)
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
index bf22b03..1efe2e0 100644
--- a/include/linux/ip6_tunnel.h
+++ b/include/linux/ip6_tunnel.h
@@ -31,4 +31,22 @@ struct ip6_tnl_parm {
 	struct in6_addr raddr;	/* remote tunnel end-point address */
 };
 
+struct ip6_tnl_parm2 {
+	char name[IFNAMSIZ];	/* name of tunnel device */
+	int link;		/* ifindex of underlying L2 interface */
+	__u8 proto;		/* tunnel protocol */
+	__u8 encap_limit;	/* encapsulation limit for tunnel */
+	__u8 hop_limit;		/* hop limit for tunnel */
+	__be32 flowinfo;	/* traffic class and flowlabel for tunnel */
+	__u32 flags;		/* tunnel flags */
+	struct in6_addr laddr;	/* local tunnel end-point address */
+	struct in6_addr raddr;	/* remote tunnel end-point address */
+
+	__be16			i_flags;
+	__be16			o_flags;
+	__be32			i_key;
+	__be32			o_key;
+};
+
+
 #endif
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index c9720eb..2e84f63 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -48,11 +48,12 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | ip6gre | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(stderr, "          [ dscp inherit ]\n");
+	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME      := STRING\n");
 	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
@@ -62,10 +63,11 @@ static void usage(void)
 		DEFAULT_TNL_HOP_LIMIT);
 	fprintf(stderr, "       TOS       := { 0x0..0xff | inherit }\n");
 	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(stderr, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
 	exit(-1);
 }
 
-static void print_tunnel(struct ip6_tnl_parm *p)
+static void print_tunnel(struct ip6_tnl_parm2 *p)
 {
 	char remote[64];
 	char local[64];
@@ -104,9 +106,29 @@ static void print_tunnel(struct ip6_tnl_parm *p)
 
 	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
 		printf(" dscp inherit");
+	
+	if (p->proto == IPPROTO_GRE) {
+		if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
+			printf(" key %u", ntohl(p->i_key));
+		else if ((p->i_flags|p->o_flags)&GRE_KEY) {
+			if (p->i_flags&GRE_KEY)
+				printf(" ikey %u ", ntohl(p->i_key));
+			if (p->o_flags&GRE_KEY)
+				printf(" okey %u ", ntohl(p->o_key));
+		}
+
+		if (p->i_flags&GRE_SEQ)
+			printf("%s  Drop packets out of sequence.\n", _SL_);
+		if (p->i_flags&GRE_CSUM)
+			printf("%s  Checksum in received packet is required.", _SL_);
+		if (p->o_flags&GRE_SEQ)
+			printf("%s  Sequence packets on output.", _SL_);
+		if (p->o_flags&GRE_CSUM)
+			printf("%s  Checksum output packets.", _SL_);
+	}
 }
 
-static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
+static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
@@ -124,6 +146,9 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				 strcmp(*argv, "ipip6") == 0 ||
 				 strcmp(*argv, "ip4ip6") == 0)
 				p->proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "ip6gre") == 0 ||
+				 strcmp(*argv, "gre/ipv6") == 0)
+				p->proto = IPPROTO_GRE;
 			else if (strcmp(*argv, "any/ipv6") == 0 ||
 				 strcmp(*argv, "any") == 0)
 				p->proto = 0;
@@ -199,6 +224,60 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 			if (strcmp(*argv, "inherit") != 0)
 				invarg("not inherit", *argv);
 			p->flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "key") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->i_flags |= GRE_KEY;
+			p->o_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->i_key = p->o_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"key\"\n");
+					exit(-1);
+				}
+				p->i_key = p->o_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "ikey") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->i_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->i_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"ikey\"\n");
+					exit(-1);
+				}
+				p->i_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "okey") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->o_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->o_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"okey\"\n");
+					exit(-1);
+				}
+				p->o_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "seq") == 0) {
+			p->i_flags |= GRE_SEQ;
+			p->o_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "iseq") == 0) {
+			p->i_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "oseq") == 0) {
+			p->o_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "csum") == 0) {
+			p->i_flags |= GRE_CSUM;
+			p->o_flags |= GRE_CSUM;
+		} else if (strcmp(*argv, "icsum") == 0) {
+			p->i_flags |= GRE_CSUM;
+		} else if (strcmp(*argv, "ocsum") == 0) {
+			p->o_flags |= GRE_CSUM;
 		} else {
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
@@ -209,7 +288,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
-				struct ip6_tnl_parm old_p;
+				struct ip6_tnl_parm2 old_p;
 				memset(&old_p, 0, sizeof(old_p));
 				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
@@ -227,7 +306,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 	return 0;
 }
 
-static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
+static void ip6_tnl_parm_init(struct ip6_tnl_parm2 *p, int apply_default)
 {
 	memset(p, 0, sizeof(*p));
 	p->proto = IPPROTO_IPV6;
@@ -241,8 +320,8 @@ static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
  * @p1: user specified parameter
  * @p2: database entry
  */
-static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
-			      const struct ip6_tnl_parm *p2)
+static int ip6_tnl_parm_match(const struct ip6_tnl_parm2 *p1,
+			      const struct ip6_tnl_parm2 *p2)
 {
 	return ((!p1->link || p1->link == p2->link) &&
 		(!p1->name[0] || strcmp(p1->name, p2->name) == 0) &&
@@ -260,7 +339,7 @@ static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
 		(!p1->flags || (p1->flags & p2->flags)));
 }
 
-static int do_tunnels_list(struct ip6_tnl_parm *p)
+static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 {
 	char buf[512];
 	int err = -1;
@@ -284,7 +363,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			rx_fifo, rx_frame,
 			tx_bytes, tx_packets, tx_errs, tx_drops,
 			tx_fifo, tx_colls, tx_carrier, rx_multi;
-		struct ip6_tnl_parm p1;
+		struct ip6_tnl_parm2 p1;
 		char *ptr;
 
 		buf[sizeof(buf) - 1] = '\0';
@@ -309,10 +388,12 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			fprintf(stderr, "Failed to get type of [%s]\n", name);
 			continue;
 		}
-		if (type != ARPHRD_TUNNEL6)
+		if (type != ARPHRD_TUNNEL6 && type != ARPHRD_IP6GRE)
 			continue;
 		memset(&p1, 0, sizeof(p1));
 		ip6_tnl_parm_init(&p1, 0);
+		if (type == ARPHRD_IP6GRE)
+			p1.proto = IPPROTO_GRE;
 		strcpy(p1.name, name);
 		p1.link = ll_name_to_index(p1.name);
 		if (p1.link == 0)
@@ -343,7 +424,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 
 static int do_show(int argc, char **argv)
 {
-        struct ip6_tnl_parm p;
+        struct ip6_tnl_parm2 p;
 
 	ll_init_map(&rth);
 	ip6_tnl_parm_init(&p, 0);
@@ -366,28 +447,44 @@ static int do_show(int argc, char **argv)
 
 static int do_add(int cmd, int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
 
-	return tnl_add_ioctl(cmd,
-			     cmd == SIOCCHGTUNNEL && p.name[0] ?
-			     p.name : "ip6tnl0", p.name, &p);
+	switch (p.proto) {
+	case IPPROTO_IPIP:
+	case IPPROTO_IPV6:
+		return tnl_add_ioctl(cmd, "ip6tnl0", p.name, &p);
+	case IPPROTO_GRE:
+		return tnl_add_ioctl(cmd, "ip6gre0", p.name, &p);
+	default:
+		fprintf(stderr, "cannot determine tunnel mode (ip6ip6, ipip6 or gre)\n");
+	}
+	return -1;
 }
 
 static int do_del(int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
-	return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0", p.name, &p);
+	switch (p.proto) {
+	case IPPROTO_IPIP:
+	case IPPROTO_IPV6:
+		return tnl_del_ioctl("ip6tnl0", p.name, &p);
+	case IPPROTO_GRE:
+		return tnl_del_ioctl("ip6gre0", p.name, &p);
+	default:
+		return tnl_del_ioctl(p.name, p.name, &p);
+	}
+	return -1;
 }
 
 int do_ip6tunnel(int argc, char **argv)

--nextPart2201742.1d2rMxPZCJ--
