From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/7] utils: make rt_addr_n2a() non-reentrant by default
Date: Tue, 22 Mar 2016 19:35:16 +0100
Message-ID: <1458671719-14361-5-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44791 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbcCVSf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:35:57 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only a single user who needs it to be reentrant (not really,
but it's safer like this), add rt_addr_n2a_r() for it to use.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h       |  3 ++-
 ip/ip6tunnel.c        |  2 +-
 ip/iplink_bond.c      |  5 +----
 ip/ipmroute.c         |  7 ++-----
 ip/ipprefix.c         |  5 +----
 ip/iproute.c          | 10 +++-------
 ip/iproute_lwtunnel.c |  7 ++-----
 ip/iprule.c           |  8 ++------
 ip/iptunnel.c         |  2 +-
 ip/ipxfrm.c           | 29 ++++++-----------------------
 ip/link_ip6tnl.c      |  7 ++-----
 ip/xfrm_monitor.c     | 16 +++-------------
 lib/utils.c           | 11 +++++++++--
 tc/f_flower.c         |  7 ++-----
 14 files changed, 37 insertions(+), 82 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 84083b0dbba71..bc2cbce0cc303 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -125,8 +125,9 @@ int af_byte_len(int af);
 const char *format_host_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
 const char *format_host(int af, int lne, const void *addr);
-const char *rt_addr_n2a(int af, int len, const void *addr,
+const char *rt_addr_n2a_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
+const char *rt_addr_n2a(int af, int len, const void *addr);
 
 int read_family(const char *name);
 const char *family_name(int family);
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index d588645eb942a..c02fa0746ab69 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -78,7 +78,7 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 	       p->name,
 	       tnl_strproto(p->proto),
 	       format_host_r(AF_INET6, 16, &p->raddr, s1, sizeof(s1)),
-	       rt_addr_n2a(AF_INET6, 16, &p->laddr, s2, sizeof(s2)));
+	       rt_addr_n2a_r(AF_INET6, 16, &p->laddr, s2, sizeof(s2)));
 	if (p->link) {
 		const char *n = ll_index_to_name(p->link);
 
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 45473f66da065..7da58e4556c07 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -411,7 +411,6 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_BOND_ARP_IP_TARGET]) {
 		struct rtattr *iptb[BOND_MAX_ARP_TARGETS + 1];
-		char buf[INET_ADDRSTRLEN];
 		int i;
 
 		parse_rtattr_nested(iptb, BOND_MAX_ARP_TARGETS,
@@ -425,9 +424,7 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				fprintf(f, "%s",
 					rt_addr_n2a(AF_INET,
 						    RTA_PAYLOAD(iptb[i]),
-						    RTA_DATA(iptb[i]),
-						    buf,
-						    INET_ADDRSTRLEN));
+						    RTA_DATA(iptb[i])));
 			if (i < BOND_MAX_ARP_TARGETS-1 && iptb[i+1])
 				fprintf(f, ",");
 		}
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 34543c00ecb75..2b9f892a62630 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -58,7 +58,6 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[RTA_MAX+1];
-	char abuf[256];
 	char obuf[256];
 
 	SPRINT_BUF(b1);
@@ -126,16 +125,14 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		len = snprintf(obuf, sizeof(obuf),
 			       "(%s, ", rt_addr_n2a(family,
 						    RTA_PAYLOAD(tb[RTA_SRC]),
-						    RTA_DATA(tb[RTA_SRC]),
-						    abuf, sizeof(abuf)));
+						    RTA_DATA(tb[RTA_SRC])));
 	else
 		len = sprintf(obuf, "(unknown, ");
 	if (tb[RTA_DST])
 		snprintf(obuf + len, sizeof(obuf) - len,
 			 "%s)", rt_addr_n2a(family,
 					    RTA_PAYLOAD(tb[RTA_DST]),
-					    RTA_DATA(tb[RTA_DST]),
-					    abuf, sizeof(abuf)));
+					    RTA_DATA(tb[RTA_DST])));
 	else
 		snprintf(obuf + len, sizeof(obuf) - len, "unknown) ");
 
diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index 2524f784965b5..4d986dbc1a5d1 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -75,15 +75,12 @@ int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[PREFIX_ADDRESS]) {
 		struct in6_addr *pfx;
-		char abuf[256];
 
 		pfx = (struct in6_addr *)RTA_DATA(tb[PREFIX_ADDRESS]);
 
-		memset(abuf, '\0', sizeof(abuf));
 		fprintf(fp, "%s", rt_addr_n2a(family,
 					      RTA_PAYLOAD(tb[PREFIX_ADDRESS]),
-					      pfx,
-					      abuf, sizeof(abuf)));
+					      pfx));
 	}
 	fprintf(fp, "/%u ", prefix->prefix_len);
 
diff --git a/ip/iproute.c b/ip/iproute.c
index 8315ad3e6c6ac..1ec9294290b2a 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -318,7 +318,6 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct rtmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[RTA_MAX+1];
-	char abuf[256];
 	int host_len;
 	__u32 table;
 
@@ -373,8 +372,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "%s/%u ", rt_addr_n2a(r->rtm_family,
 						       RTA_PAYLOAD(tb[RTA_DST]),
-						       RTA_DATA(tb[RTA_DST]),
-						       abuf, sizeof(abuf)),
+						       RTA_DATA(tb[RTA_DST])),
 				r->rtm_dst_len
 				);
 		} else {
@@ -392,8 +390,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
 						       RTA_PAYLOAD(tb[RTA_SRC]),
-						       RTA_DATA(tb[RTA_SRC]),
-						       abuf, sizeof(abuf)),
+						       RTA_DATA(tb[RTA_SRC])),
 				r->rtm_src_len
 				);
 		} else {
@@ -452,8 +449,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, " src %s ",
 			rt_addr_n2a(r->rtm_family,
 				    RTA_PAYLOAD(tb[RTA_PREFSRC]),
-				    RTA_DATA(tb[RTA_PREFSRC]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[RTA_PREFSRC])));
 	}
 	if (tb[RTA_PRIORITY])
 		fprintf(fp, " metric %u ", rta_getattr_u32(tb[RTA_PRIORITY]));
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 42abe3753ac6a..53d3ad4e6ea8e 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -70,7 +70,6 @@ static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 static void print_encap_ip(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[LWTUNNEL_IP_MAX+1];
-	char abuf[256];
 
 	parse_rtattr_nested(tb, LWTUNNEL_IP_MAX, encap);
 
@@ -81,15 +80,13 @@ static void print_encap_ip(FILE *fp, struct rtattr *encap)
 		fprintf(fp, "src %s ",
 			rt_addr_n2a(AF_INET,
 				    RTA_PAYLOAD(tb[LWTUNNEL_IP_SRC]),
-				    RTA_DATA(tb[LWTUNNEL_IP_SRC]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[LWTUNNEL_IP_SRC])));
 
 	if (tb[LWTUNNEL_IP_DST])
 		fprintf(fp, "dst %s ",
 			rt_addr_n2a(AF_INET,
 				    RTA_PAYLOAD(tb[LWTUNNEL_IP_DST]),
-				    RTA_DATA(tb[LWTUNNEL_IP_DST]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[LWTUNNEL_IP_DST])));
 
 	if (tb[LWTUNNEL_IP_TTL])
 		fprintf(fp, "ttl %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TTL]));
diff --git a/ip/iprule.c b/ip/iprule.c
index 345b3b042307d..3fd510efe5e1b 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -57,8 +57,6 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int host_len = -1;
 	__u32 table;
 	struct rtattr *tb[FRA_MAX+1];
-	char abuf[256];
-
 	SPRINT_BUF(b1);
 
 	if (n->nlmsg_type != RTM_NEWRULE && n->nlmsg_type != RTM_DELRULE)
@@ -87,8 +85,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
 						       RTA_PAYLOAD(tb[FRA_SRC]),
-						       RTA_DATA(tb[FRA_SRC]),
-						       abuf, sizeof(abuf)),
+						       RTA_DATA(tb[FRA_SRC])),
 				r->rtm_src_len
 				);
 		} else {
@@ -107,8 +104,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "to %s/%u ", rt_addr_n2a(r->rtm_family,
 						       RTA_PAYLOAD(tb[FRA_DST]),
-						       RTA_DATA(tb[FRA_DST]),
-						       abuf, sizeof(abuf)),
+						       RTA_DATA(tb[FRA_DST])),
 				r->rtm_dst_len
 				);
 		} else {
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index bfee99561615a..e3161d81beded 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -309,7 +309,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	       p->name,
 	       tnl_strproto(p->iph.protocol),
 	       p->iph.daddr ? format_host_r(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1)) : "any",
-	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
+	       p->iph.saddr ? rt_addr_n2a_r(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
 		struct ip_tunnel_prl prl[16];
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 860414d377b47..8741ff3b302a9 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -285,17 +285,11 @@ void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 			__u8 mode, __u32 reqid, __u16 family, int force_spi,
 			FILE *fp, const char *prefix, const char *title)
 {
-	char abuf[256];
-
 	if (title)
 		fputs(title, fp);
 
-	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "src %s ", rt_addr_n2a(family, sizeof(*saddr),
-					   saddr, abuf, sizeof(abuf)));
-	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s", rt_addr_n2a(family, sizeof(id->daddr),
-					  &id->daddr, abuf, sizeof(abuf)));
+	fprintf(fp, "src %s ", rt_addr_n2a(family, sizeof(*saddr), saddr));
+	fprintf(fp, "dst %s", rt_addr_n2a(family, sizeof(id->daddr), &id->daddr));
 	fprintf(fp, "%s", _SL_);
 
 	if (prefix)
@@ -447,7 +441,6 @@ void xfrm_lifetime_print(struct xfrm_lifetime_cfg *cfg,
 void xfrm_selector_print(struct xfrm_selector *sel, __u16 family,
 			 FILE *fp, const char *prefix)
 {
-	char abuf[256];
 	__u16 f;
 
 	f = sel->family;
@@ -459,16 +452,12 @@ void xfrm_selector_print(struct xfrm_selector *sel, __u16 family,
 	if (prefix)
 		fputs(prefix, fp);
 
-	memset(abuf, '\0', sizeof(abuf));
 	fprintf(fp, "src %s/%u ",
-		rt_addr_n2a(f, sizeof(sel->saddr), &sel->saddr,
-			    abuf, sizeof(abuf)),
+		rt_addr_n2a(f, sizeof(sel->saddr), &sel->saddr),
 		sel->prefixlen_s);
 
-	memset(abuf, '\0', sizeof(abuf));
 	fprintf(fp, "dst %s/%u ",
-		rt_addr_n2a(f, sizeof(sel->daddr), &sel->daddr,
-			    abuf, sizeof(abuf)),
+		rt_addr_n2a(f, sizeof(sel->daddr), &sel->daddr),
 		sel->prefixlen_d);
 
 	if (sel->proto)
@@ -740,7 +729,6 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 
 	if (tb[XFRMA_ENCAP]) {
 		struct xfrm_encap_tmpl *e;
-		char abuf[256];
 
 		if (prefix)
 			fputs(prefix, fp);
@@ -768,10 +756,8 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 		fprintf(fp, "sport %u ", ntohs(e->encap_sport));
 		fprintf(fp, "dport %u ", ntohs(e->encap_dport));
 
-		memset(abuf, '\0', sizeof(abuf));
 		fprintf(fp, "addr %s",
-			rt_addr_n2a(family, sizeof(e->encap_oa), &e->encap_oa,
-				    abuf, sizeof(abuf)));
+			rt_addr_n2a(family, sizeof(e->encap_oa), &e->encap_oa));
 		fprintf(fp, "%s", _SL_);
 	}
 
@@ -783,7 +769,6 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 	}
 
 	if (tb[XFRMA_COADDR]) {
-		char abuf[256];
 		xfrm_address_t *coa;
 
 		if (prefix)
@@ -798,10 +783,8 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 			return;
 		}
 
-		memset(abuf, '\0', sizeof(abuf));
 		fprintf(fp, "%s",
-			rt_addr_n2a(family, sizeof(*coa), coa,
-				    abuf, sizeof(abuf)));
+			rt_addr_n2a(family, sizeof(*coa), coa));
 		fprintf(fp, "%s", _SL_);
 	}
 
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index ab5e50a205983..4b32fe5aa8088 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -260,7 +260,6 @@ get_failed:
 
 static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
-	char s1[256];
 	char s2[64];
 	int flags = 0;
 	__u32 flowinfo = 0;
@@ -292,16 +291,14 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 		fprintf(f, "remote %s ",
 			rt_addr_n2a(AF_INET6,
 				    RTA_PAYLOAD(tb[IFLA_IPTUN_REMOTE]),
-				    RTA_DATA(tb[IFLA_IPTUN_REMOTE]),
-				    s1, sizeof(s1)));
+				    RTA_DATA(tb[IFLA_IPTUN_REMOTE])));
 	}
 
 	if (tb[IFLA_IPTUN_LOCAL]) {
 		fprintf(f, "local %s ",
 			rt_addr_n2a(AF_INET6,
 				    RTA_PAYLOAD(tb[IFLA_IPTUN_LOCAL]),
-				    RTA_DATA(tb[IFLA_IPTUN_LOCAL]),
-				    s1, sizeof(s1)));
+				    RTA_DATA(tb[IFLA_IPTUN_LOCAL])));
 	}
 
 	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 96b52a44b8a85..9d01a2aab5018 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -227,12 +227,8 @@ static void xfrm_ae_flags_print(__u32 flags, void *arg)
 
 static void xfrm_usersa_print(const struct xfrm_usersa_id *sa_id, __u32 reqid, FILE *fp)
 {
-	char buf[256];
-
-	buf[0] = 0;
 	fprintf(fp, "dst %s ",
-		rt_addr_n2a(sa_id->family, sizeof(sa_id->daddr), &sa_id->daddr,
-			    buf, sizeof(buf)));
+		rt_addr_n2a(sa_id->family, sizeof(sa_id->daddr), &sa_id->daddr));
 
 	fprintf(fp, " reqid 0x%x", reqid);
 
@@ -245,15 +241,12 @@ static int xfrm_ae_print(const struct sockaddr_nl *who,
 {
 	FILE *fp = (FILE *)arg;
 	struct xfrm_aevent_id *id = NLMSG_DATA(n);
-	char abuf[256];
 
 	fprintf(fp, "Async event ");
 	xfrm_ae_flags_print(id->flags, arg);
 	fprintf(fp, "\n\t");
-	memset(abuf, '\0', sizeof(abuf));
 	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family,
-					   sizeof(id->saddr), &id->saddr,
-					   abuf, sizeof(abuf)));
+					   sizeof(id->saddr), &id->saddr));
 
 	xfrm_usersa_print(&id->sa_id, id->reqid, fp);
 
@@ -265,10 +258,7 @@ static int xfrm_ae_print(const struct sockaddr_nl *who,
 
 static void xfrm_print_addr(FILE *fp, int family, xfrm_address_t *a)
 {
-	char buf[256];
-
-	buf[0] = 0;
-	fprintf(fp, "%s", rt_addr_n2a(family, sizeof(*a), a, buf, sizeof(buf)));
+	fprintf(fp, "%s", rt_addr_n2a(family, sizeof(*a), a));
 }
 
 static int xfrm_mapping_print(const struct sockaddr_nl *who,
diff --git a/lib/utils.c b/lib/utils.c
index 22a5ef8fa8213..9b303a6b096bc 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -702,7 +702,7 @@ int __get_user_hz(void)
 	return sysconf(_SC_CLK_TCK);
 }
 
-const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen)
+const char *rt_addr_n2a_r(int af, int len, const void *addr, char *buf, int buflen)
 {
 	switch (af) {
 	case AF_INET:
@@ -725,6 +725,13 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
 	}
 }
 
+const char *rt_addr_n2a(int af, int len, const void *addr)
+{
+	static char buf[256];
+
+	return rt_addr_n2a_r(af, len, addr, buf, 256);
+}
+
 int read_family(const char *name)
 {
 	int family = AF_UNSPEC;
@@ -832,7 +839,7 @@ const char *format_host_r(int af, int len, const void *addr,
 			return n;
 	}
 #endif
-	return rt_addr_n2a(af, len, addr, buf, buflen);
+	return rt_addr_n2a_r(af, len, addr, buf, buflen);
 }
 
 const char *format_host(int af, int len, const void *addr)
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 6139fe08651a4..40f8c595b2eec 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -394,7 +394,6 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 				 struct rtattr *addr6_attr,
 				 struct rtattr *mask6_attr)
 {
-	SPRINT_BUF(b1);
 	struct rtattr *addr_attr;
 	struct rtattr *mask_attr;
 	int family;
@@ -418,16 +417,14 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 		return;
 	fprintf(f, "\n  %s %s", name, rt_addr_n2a(family,
 						  RTA_PAYLOAD(addr_attr),
-						  RTA_DATA(addr_attr),
-						  b1, sizeof(b1)));
+						  RTA_DATA(addr_attr)));
 	if (!mask_attr || RTA_PAYLOAD(mask_attr) != len)
 		return;
 	bits = __mask_bits(RTA_DATA(mask_attr), len);
 	if (bits < 0)
 		fprintf(f, "/%s", rt_addr_n2a(family,
 					      RTA_PAYLOAD(mask_attr),
-					      RTA_DATA(mask_attr),
-					      b1, sizeof(b1)));
+					      RTA_DATA(mask_attr)));
 	else if (bits < len * 8)
 		fprintf(f, "/%d", bits);
 }
-- 
2.7.2
