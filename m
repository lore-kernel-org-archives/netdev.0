From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH iproute2 v3 3/5] utils: add get_be{16,32,64}, use them where possible
Date: Wed, 18 May 2016 17:35:11 +0200
Message-ID: <e27a849fd0c95c662771ce3ad42fab6517df5631.1463585050.git.sd@queasysnail.net>
References: <cover.1463585050.git.sd@queasysnail.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932563AbcERPgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 May 2016 11:36:16 -0400
In-Reply-To: <cover.1463585050.git.sd@queasysnail.net>
In-Reply-To: <cover.1463585050.git.sd@queasysnail.net>
References: <cover.1463585050.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h       |  3 +++
 ip/ipfou.c            |  3 +--
 ip/iplink_vxlan.c     |  8 ++------
 ip/iproute_lwtunnel.c |  8 ++++----
 ip/ipxfrm.c           | 13 +++----------
 ip/xfrm_state.c       | 10 +++-------
 lib/ll_proto.c        |  3 +--
 lib/utils.c           | 33 +++++++++++++++++++++++++++++++++
 tc/f_flower.c         |  4 ++--
 tc/f_u32.c            | 10 ++--------
 10 files changed, 54 insertions(+), 41 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index aef28ce732ab..a9aa89162950 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -112,6 +112,9 @@ int get_u16(__u16 *val, const char *arg, int base);
 int get_s16(__s16 *val, const char *arg, int base);
 int get_u8(__u8 *val, const char *arg, int base);
 int get_s8(__s8 *val, const char *arg, int base);
+int get_be64(__be64 *val, const char *arg, int base);
+int get_be32(__be32 *val, const char *arg, int base);
+int get_be16(__be16 *val, const char *arg, int base);
 int get_addr64(__u64 *ap, const char *cp);
 
 char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
diff --git a/ip/ipfou.c b/ip/ipfou.c
index 8a86b18fc284..2a6ae1755d3e 100644
--- a/ip/ipfou.c
+++ b/ip/ipfou.c
@@ -55,9 +55,8 @@ static int fou_parse_opt(int argc, char **argv, struct nlmsghdr *n,
 		if (!matches(*argv, "port")) {
 			NEXT_ARG();
 
-			if (get_u16(&port, *argv, 0) || port == 0)
+			if (get_be16(&port, *argv, 0) || port == 0)
 				invarg("invalid port", *argv);
-			port = htons(port);
 			port_set = 1;
 		} else if (!matches(*argv, "ipproto")) {
 			struct protoent *servptr;
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index e3bbea0031df..b3ef487b083f 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -171,16 +171,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("max addresses", *argv);
 		} else if (!matches(*argv, "port") ||
 			   !matches(*argv, "srcport")) {
-			__u16 minport, maxport;
-
 			NEXT_ARG();
-			if (get_u16(&minport, *argv, 0))
+			if (get_be16(&range.low, *argv, 0))
 				invarg("min port", *argv);
 			NEXT_ARG();
-			if (get_u16(&maxport, *argv, 0))
+			if (get_be16(&range.high, *argv, 0))
 				invarg("max port", *argv);
-			range.low = htons(minport);
-			range.high = htons(maxport);
 		} else if (!matches(*argv, "dstport")) {
 			NEXT_ARG();
 			if (get_u16(&dstport, *argv, 0))
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 3baac7720816..bdbb15d2b746 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -190,9 +190,9 @@ static int parse_encap_ip(struct rtattr *rta, size_t len, int *argcp, char ***ar
 			NEXT_ARG();
 			if (id_ok++)
 				duparg2("id", *argv);
-			if (get_u64(&id, *argv, 0))
+			if (get_be64(&id, *argv, 0))
 				invarg("\"id\" value is invalid\n", *argv);
-			rta_addattr64(rta, len, LWTUNNEL_IP_ID, htonll(id));
+			rta_addattr64(rta, len, LWTUNNEL_IP_ID, id);
 		} else if (strcmp(*argv, "dst") == 0) {
 			inet_prefix addr;
 
@@ -267,9 +267,9 @@ static int parse_encap_ip6(struct rtattr *rta, size_t len, int *argcp, char ***a
 			NEXT_ARG();
 			if (id_ok++)
 				duparg2("id", *argv);
-			if (get_u64(&id, *argv, 0))
+			if (get_be64(&id, *argv, 0))
 				invarg("\"id\" value is invalid\n", *argv);
-			rta_addattr64(rta, len, LWTUNNEL_IP6_ID, htonll(id));
+			rta_addattr64(rta, len, LWTUNNEL_IP6_ID, id);
 		} else if (strcmp(*argv, "dst") == 0) {
 			inet_prefix addr;
 
diff --git a/ip/ipxfrm.c b/ip/ipxfrm.c
index 8741ff3b302a..8d786d1334df 100644
--- a/ip/ipxfrm.c
+++ b/ip/ipxfrm.c
@@ -1109,15 +1109,10 @@ int xfrm_id_parse(xfrm_address_t *saddr, struct xfrm_id *id, __u16 *family,
 			filter.id_proto_mask = XFRM_FILTER_MASK_FULL;
 
 		} else if (strcmp(*argv, "spi") == 0) {
-			__u32 spi;
-
 			NEXT_ARG();
-			if (get_u32(&spi, *argv, 0))
+			if (get_be32(&id->spi, *argv, 0))
 				invarg("SPI value is invalid", *argv);
 
-			spi = htonl(spi);
-			id->spi = spi;
-
 			filter.id_spi_mask = XFRM_FILTER_MASK_FULL;
 
 		} else {
@@ -1252,9 +1247,8 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 
 			NEXT_ARG();
 
-			if (get_u16(&sel->sport, *argv, 0))
+			if (get_be16(&sel->sport, *argv, 0))
 				invarg("value after \"sport\" is invalid", *argv);
-			sel->sport = htons(sel->sport);
 			if (sel->sport)
 				sel->sport_mask = ~((__u16)0);
 
@@ -1265,9 +1259,8 @@ static int xfrm_selector_upspec_parse(struct xfrm_selector *sel,
 
 			NEXT_ARG();
 
-			if (get_u16(&sel->dport, *argv, 0))
+			if (get_be16(&sel->dport, *argv, 0))
 				invarg("value after \"dport\" is invalid", *argv);
-			sel->dport = htons(sel->dport);
 			if (sel->dport)
 				sel->dport_mask = ~((__u16)0);
 
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 5e2b641959bf..21ada3647ba4 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -175,11 +175,9 @@ static int xfrm_seq_parse(__u32 *seq, int *argcp, char ***argvp)
 	int argc = *argcp;
 	char **argv = *argvp;
 
-	if (get_u32(seq, *argv, 0))
+	if (get_be32(seq, *argv, 0))
 		invarg("SEQ value is invalid", *argv);
 
-	*seq = htonl(*seq);
-
 	*argcp = argc;
 	*argvp = argv;
 
@@ -359,13 +357,11 @@ static int xfrm_state_modify(int cmd, unsigned int flags, int argc, char **argv)
 			NEXT_ARG();
 			xfrm_encap_type_parse(&encap.encap_type, &argc, &argv);
 			NEXT_ARG();
-			if (get_u16(&encap.encap_sport, *argv, 0))
+			if (get_be16(&encap.encap_sport, *argv, 0))
 				invarg("SPORT value after \"encap\" is invalid", *argv);
-			encap.encap_sport = htons(encap.encap_sport);
 			NEXT_ARG();
-			if (get_u16(&encap.encap_dport, *argv, 0))
+			if (get_be16(&encap.encap_dport, *argv, 0))
 				invarg("DPORT value after \"encap\" is invalid", *argv);
-			encap.encap_dport = htons(encap.encap_dport);
 			NEXT_ARG();
 			get_addr(&oa, *argv, AF_UNSPEC);
 			memcpy(&encap.encap_oa, &oa.data, sizeof(encap.encap_oa));
diff --git a/lib/ll_proto.c b/lib/ll_proto.c
index d8df68c110b0..e094d9f81ccc 100644
--- a/lib/ll_proto.c
+++ b/lib/ll_proto.c
@@ -111,8 +111,7 @@ int ll_proto_a2n(unsigned short *id, const char *buf)
 			 return 0;
 		 }
 	}
-	if (get_u16(id, buf, 0))
+	if (get_be16(id, buf, 0))
 		return -1;
-	*id = htons(*id);
 	return 0;
 }
diff --git a/lib/utils.c b/lib/utils.c
index bd10c0d71718..e0cee5e9dc56 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -353,6 +353,39 @@ int get_s8(__s8 *val, const char *arg, int base)
 	return 0;
 }
 
+int get_be64(__be64 *val, const char *arg, int base)
+{
+	__u64 v;
+	int ret = get_u64(&v, arg, base);
+
+	if (!ret)
+		*val = htonll(v);
+
+	return ret;
+}
+
+int get_be32(__be32 *val, const char *arg, int base)
+{
+	__u32 v;
+	int ret = get_u32(&v, arg, base);
+
+	if (!ret)
+		*val = htonl(v);
+
+	return ret;
+}
+
+int get_be16(__be16 *val, const char *arg, int base)
+{
+	__u16 v;
+	int ret = get_u16(&v, arg, base);
+
+	if (!ret)
+		*val = htons(v);
+
+	return ret;
+}
+
 /* This uses a non-standard parsing (ie not inet_aton, or inet_pton)
  * because of legacy choice to parse 10.8 as 10.8.0.0 not 10.0.0.8
  */
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 306f056c1b66..fd2014b374a1 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -150,11 +150,11 @@ static int flower_parse_port(char *str, __u8 ip_port,
 		return -1;
 	}
 
-	ret = get_u16(&port, str, 10);
+	ret = get_be16(&port, str, 10);
 	if (ret)
 		return -1;
 
-	addattr16(n, MAX_MSG, type, htons(port));
+	addattr16(n, MAX_MSG, type, port);
 
 	return 0;
 }
diff --git a/tc/f_u32.c b/tc/f_u32.c
index 62995153923a..e2d39b3d52fe 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -766,12 +766,9 @@ static int parse_offset(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 			}
 			sel->flags |= TC_U32_VAROFFSET;
 		} else if (matches(*argv, "mask") == 0) {
-			__u16 mask;
-
 			NEXT_ARG();
-			if (get_u16(&mask, *argv, 16))
+			if (get_be16(&sel->offmask, *argv, 16))
 				return -1;
-			sel->offmask = htons(mask);
 			sel->flags |= TC_U32_VAROFFSET;
 		} else if (matches(*argv, "shift") == 0) {
 			int shift;
@@ -801,12 +798,9 @@ static int parse_hashkey(int *argc_p, char ***argv_p, struct tc_u32_sel *sel)
 
 	while (argc > 0) {
 		if (matches(*argv, "mask") == 0) {
-			__u32 mask;
-
 			NEXT_ARG();
-			if (get_u32(&mask, *argv, 16))
+			if (get_be32(&sel->hmask, *argv, 16))
 				return -1;
-			sel->hmask = htonl(mask);
 		} else if (matches(*argv, "at") == 0) {
 			int num;
 
-- 
2.8.2
