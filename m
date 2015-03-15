From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/8] iproute2: Add a source addres length parameter to rt_addr_n2a
Date: Sun, 15 Mar 2015 14:48:32 -0500
Message-ID: <8761a2oxdb.fsf_-_@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
	<87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45376 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751477AbbCOTwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:52:16 -0400
In-Reply-To: <87bnjuoxe8.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Sun, 15 Mar 2015 14:47:59 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For some address families (like AF_PACKET) it is helpful to have the
length when prenting the address.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/utils.h   |  2 +-
 ip/iplink_bond.c  |  1 +
 ip/ipmroute.c     |  2 ++
 ip/ipprefix.c     |  4 +++-
 ip/iproute.c      | 11 +++++++----
 ip/iprule.c       | 10 ++++++----
 ip/iptunnel.c     |  2 +-
 ip/ipxfrm.c       | 17 +++++++++++------
 ip/link_ip6tnl.c  |  2 ++
 ip/xfrm_monitor.c |  8 +++++---
 lib/utils.c       |  4 ++--
 11 files changed, 41 insertions(+), 22 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 9151c4f103e3..1b39e2c5cbfc 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -106,7 +106,7 @@ extern int af_byte_len(int af);
 
 extern const char *format_host(int af, int len, const void *addr,
 			       char *buf, int buflen);
-extern const char *rt_addr_n2a(int af, const void *addr,
+extern const char *rt_addr_n2a(int af, int len, const void *addr,
 			       char *buf, int buflen);
 
 void missarg(const char *) __attribute__((noreturn));
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 3009ec912e23..a573f92b03a0 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -415,6 +415,7 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			if (iptb[i])
 				fprintf(f, "%s",
 					rt_addr_n2a(AF_INET,
+						    RTA_PAYLOAD(iptb[i]),
 						    RTA_DATA(iptb[i]),
 						    buf,
 						    INET_ADDRSTRLEN));
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index b4ed9f15fda5..13ac892512d0 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -116,6 +116,7 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_SRC])
 		len = snprintf(obuf, sizeof(obuf),
 			       "(%s, ", rt_addr_n2a(family,
+						    RTA_PAYLOAD(tb[RTA_SRC]),
 						    RTA_DATA(tb[RTA_SRC]),
 						    abuf, sizeof(abuf)));
 	else
@@ -123,6 +124,7 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_DST])
 		snprintf(obuf + len, sizeof(obuf) - len,
 			 "%s)", rt_addr_n2a(family,
+					    RTA_PAYLOAD(tb[RTA_DST]),
 					    RTA_DATA(tb[RTA_DST]),
 					    abuf, sizeof(abuf)));
 	else
diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index 02c0efce6836..26b596151217 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -80,7 +80,9 @@ int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		pfx = (struct in6_addr *)RTA_DATA(tb[PREFIX_ADDRESS]);
 
 		memset(abuf, '\0', sizeof(abuf));
-		fprintf(fp, "%s", rt_addr_n2a(family, pfx,
+		fprintf(fp, "%s", rt_addr_n2a(family,
+					      RTA_PAYLOAD(tb[PREFIX_ADDRESS]),
+					      pfx,
 					      abuf, sizeof(abuf)));
 	}
 	fprintf(fp, "/%u ", prefix->prefix_len);
diff --git a/ip/iproute.c b/ip/iproute.c
index b32025ff0da5..79d0760a34f6 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -339,8 +339,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_DST]) {
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "%s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_DATA(tb[RTA_DST]),
-							 abuf, sizeof(abuf)),
+						       RTA_PAYLOAD(tb[RTA_DST]),
+						       RTA_DATA(tb[RTA_DST]),
+						       abuf, sizeof(abuf)),
 				r->rtm_dst_len
 				);
 		} else {
@@ -358,8 +359,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_SRC]) {
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_DATA(tb[RTA_SRC]),
-							 abuf, sizeof(abuf)),
+						       RTA_PAYLOAD(tb[RTA_SRC]),
+						       RTA_DATA(tb[RTA_SRC]),
+						       abuf, sizeof(abuf)),
 				r->rtm_src_len
 				);
 		} else {
@@ -401,6 +403,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		 */
 		fprintf(fp, " src %s ",
 			rt_addr_n2a(r->rtm_family,
+				    RTA_PAYLOAD(tb[RTA_PREFSRC]),
 				    RTA_DATA(tb[RTA_PREFSRC]),
 				    abuf, sizeof(abuf)));
 	}
diff --git a/ip/iprule.c b/ip/iprule.c
index 54ed7536e064..967969c0e60e 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -82,8 +82,9 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[FRA_SRC]) {
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_DATA(tb[FRA_SRC]),
-							 abuf, sizeof(abuf)),
+						       RTA_PAYLOAD(tb[FRA_SRC]),
+						       RTA_DATA(tb[FRA_SRC]),
+						       abuf, sizeof(abuf)),
 				r->rtm_src_len
 				);
 		} else {
@@ -102,8 +103,9 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[FRA_DST]) {
 		if (r->rtm_dst_len != host_len) {
 			fprintf(fp, "to %s/%u ", rt_addr_n2a(r->rtm_family,
-							 RTA_DATA(tb[FRA_DST]),
-							 abuf, sizeof(abuf)),
+						       RTA_PAYLOAD(tb[FRA_DST]),
+						       RTA_DATA(tb[FRA_DST]),
+						       abuf, sizeof(abuf)),
 				r->rtm_dst_len
 				);
 		} else {
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index caf8a28e62e8..29188c450370 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -343,7 +343,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	       p->name,
 	       tnl_strproto(p->iph.protocol),
 	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1))  : "any",
-	       p->iph.saddr ? rt_addr_n2a(AF_INET, &p->iph.saddr, s2, sizeof(s2)) : "any");
+	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
 		struct ip_tunnel_prl prl[16];
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 659fa6b64579..eacefd907f46 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -288,10 +288,10 @@ void xfrm_id_info_print(xfrm_address_t *saddr, struct xfrm_id *id,
 		fputs(title, fp);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "src %s ", rt_addr_n2a(family,
+	fprintf(fp, "src %s ", rt_addr_n2a(family, sizeof(*saddr),
 					   saddr, abuf, sizeof(abuf)));
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s", rt_addr_n2a(family,
+	fprintf(fp, "dst %s", rt_addr_n2a(family, sizeof(id->daddr),
 					  &id->daddr, abuf, sizeof(abuf)));
 	fprintf(fp, "%s", _SL_);
 
@@ -455,11 +455,15 @@ void xfrm_selector_print(struct xfrm_selector *sel, __u16 family,
 		fputs(prefix, fp);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "src %s/%u ", rt_addr_n2a(f, &sel->saddr, abuf, sizeof(abuf)),
+	fprintf(fp, "src %s/%u ",
+		rt_addr_n2a(f, sizeof(sel->saddr), &sel->saddr,
+			    abuf, sizeof(abuf)),
 		sel->prefixlen_s);
 
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s/%u ", rt_addr_n2a(f, &sel->daddr, abuf, sizeof(abuf)),
+	fprintf(fp, "dst %s/%u ",
+		rt_addr_n2a(f, sizeof(sel->daddr), &sel->daddr,
+			    abuf, sizeof(abuf)),
 		sel->prefixlen_d);
 
 	if (sel->proto)
@@ -754,7 +758,8 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 
 		memset(abuf, '\0', sizeof(abuf));
 		fprintf(fp, "addr %s",
-			rt_addr_n2a(family, &e->encap_oa, abuf, sizeof(abuf)));
+			rt_addr_n2a(family, sizeof(e->encap_oa), &e->encap_oa,
+				    abuf, sizeof(abuf)));
 		fprintf(fp, "%s", _SL_);
 	}
 
@@ -782,7 +787,7 @@ void xfrm_xfrma_print(struct rtattr *tb[], __u16 family,
 
 		memset(abuf, '\0', sizeof(abuf));
 		fprintf(fp, "%s",
-			rt_addr_n2a(family, coa,
+			rt_addr_n2a(family, sizeof(*coa), coa,
 				    abuf, sizeof(abuf)));
 		fprintf(fp, "%s", _SL_);
 	}
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 5ed3d5a23fb5..cf59a9338f57 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -285,6 +285,7 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 	if (tb[IFLA_IPTUN_REMOTE]) {
 		fprintf(f, "remote %s ",
 			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[IFLA_IPTUN_REMOTE]),
 				    RTA_DATA(tb[IFLA_IPTUN_REMOTE]),
 				    s1, sizeof(s1)));
 	}
@@ -292,6 +293,7 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 	if (tb[IFLA_IPTUN_LOCAL]) {
 		fprintf(f, "local %s ",
 			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[IFLA_IPTUN_LOCAL]),
 				    RTA_DATA(tb[IFLA_IPTUN_LOCAL]),
 				    s1, sizeof(s1)));
 	}
diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 50116a7b5433..b2b2d6e27a45 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -227,7 +227,8 @@ static void xfrm_usersa_print(const struct xfrm_usersa_id *sa_id, __u32 reqid, F
 
 	buf[0] = 0;
 	fprintf(fp, "dst %s ",
-		rt_addr_n2a(sa_id->family, &sa_id->daddr, buf, sizeof(buf)));
+		rt_addr_n2a(sa_id->family, sizeof(sa_id->daddr), &sa_id->daddr,
+			    buf, sizeof(buf)));
 
 	fprintf(fp, " reqid 0x%x", reqid);
 
@@ -246,7 +247,8 @@ static int xfrm_ae_print(const struct sockaddr_nl *who,
 	xfrm_ae_flags_print(id->flags, arg);
 	fprintf(fp,"\n\t");
 	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family, &id->saddr,
+	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family,
+					   sizeof(id->saddr), &id->saddr,
 					   abuf, sizeof(abuf)));
 
 	xfrm_usersa_print(&id->sa_id, id->reqid, fp);
@@ -262,7 +264,7 @@ static void xfrm_print_addr(FILE *fp, int family, xfrm_address_t *a)
 	char buf[256];
 
 	buf[0] = 0;
-	fprintf(fp, "%s", rt_addr_n2a(family, a, buf, sizeof(buf)));
+	fprintf(fp, "%s", rt_addr_n2a(family, sizeof(*a), a, buf, sizeof(buf)));
 }
 
 static int xfrm_mapping_print(const struct sockaddr_nl *who,
diff --git a/lib/utils.c b/lib/utils.c
index 9cda26810da1..4b4f20126822 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -636,7 +636,7 @@ int __get_user_hz(void)
 	return sysconf(_SC_CLK_TCK);
 }
 
-const char *rt_addr_n2a(int af, const void *addr, char *buf, int buflen)
+const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen)
 {
 	switch (af) {
 	case AF_INET:
@@ -723,7 +723,7 @@ const char *format_host(int af, int len, const void *addr,
 			return n;
 	}
 #endif
-	return rt_addr_n2a(af, addr, buf, buflen);
+	return rt_addr_n2a(af, len, addr, buf, buflen);
 }
 
 
-- 
2.2.1
