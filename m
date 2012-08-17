From: pablo@netfilter.org
Subject: [PATCH 2/5] netfilter: nf_ct_sip: fix IPv6 address parsing
Date: Fri, 17 Aug 2012 16:09:30 +0200
Message-ID: <1345212573-3076-3-git-send-email-pablo@netfilter.org>
References: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345212573-3076-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Within SIP messages IPv6 addresses are enclosed in square brackets in most
cases, with the exception of the "received=" header parameter. Currently
the helper fails to parse enclosed addresses.

This patch:

- changes the SIP address parsing function to enforce square brackets
  when required, and accept them when not required but present, as
  recommended by RFC 5118.

- adds a new SDP address parsing function that never accepts square
  brackets since SDP doesn't use them.

With these changes, the SIP helper correctly parses all test messages
from RFC 5118 (Session Initiation Protocol (SIP) Torture Test Messages
for Internet Protocol Version 6 (IPv6)).

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_sip.h |    2 +-
 net/ipv4/netfilter/nf_nat_sip.c            |    4 +-
 net/netfilter/nf_conntrack_sip.c           |   87 ++++++++++++++++++++++------
 3 files changed, 73 insertions(+), 20 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index 0dfc8b7..89f2a62 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -164,7 +164,7 @@ extern int ct_sip_parse_address_param(const struct nf_conn *ct, const char *dptr
 				      unsigned int dataoff, unsigned int datalen,
 				      const char *name,
 				      unsigned int *matchoff, unsigned int *matchlen,
-				      union nf_inet_addr *addr);
+				      union nf_inet_addr *addr, bool delim);
 extern int ct_sip_parse_numerical_param(const struct nf_conn *ct, const char *dptr,
 					unsigned int off, unsigned int datalen,
 					const char *name,
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index ea4a238..eef8f29 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -173,7 +173,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		 * the reply. */
 		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
 					       "maddr=", &poff, &plen,
-					       &addr) > 0 &&
+					       &addr, true) > 0 &&
 		    addr.ip == ct->tuplehash[dir].tuple.src.u3.ip &&
 		    addr.ip != ct->tuplehash[!dir].tuple.dst.u3.ip) {
 			buflen = sprintf(buffer, "%pI4",
@@ -187,7 +187,7 @@ static unsigned int ip_nat_sip(struct sk_buff *skb, unsigned int dataoff,
 		 * from which the server received the request. */
 		if (ct_sip_parse_address_param(ct, *dptr, matchend, *datalen,
 					       "received=", &poff, &plen,
-					       &addr) > 0 &&
+					       &addr, false) > 0 &&
 		    addr.ip == ct->tuplehash[dir].tuple.dst.u3.ip &&
 		    addr.ip != ct->tuplehash[!dir].tuple.src.u3.ip) {
 			buflen = sprintf(buffer, "%pI4",
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 2fb6669..5c0a112 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -183,12 +183,12 @@ static int media_len(const struct nf_conn *ct, const char *dptr,
 	return len + digits_len(ct, dptr, limit, shift);
 }
 
-static int parse_addr(const struct nf_conn *ct, const char *cp,
-                      const char **endp, union nf_inet_addr *addr,
-                      const char *limit)
+static int sip_parse_addr(const struct nf_conn *ct, const char *cp,
+			  const char **endp, union nf_inet_addr *addr,
+			  const char *limit, bool delim)
 {
 	const char *end;
-	int ret = 0;
+	int ret;
 
 	if (!ct)
 		return 0;
@@ -197,16 +197,28 @@ static int parse_addr(const struct nf_conn *ct, const char *cp,
 	switch (nf_ct_l3num(ct)) {
 	case AF_INET:
 		ret = in4_pton(cp, limit - cp, (u8 *)&addr->ip, -1, &end);
+		if (ret == 0)
+			return 0;
 		break;
 	case AF_INET6:
+		if (cp < limit && *cp == '[')
+			cp++;
+		else if (delim)
+			return 0;
+
 		ret = in6_pton(cp, limit - cp, (u8 *)&addr->ip6, -1, &end);
+		if (ret == 0)
+			return 0;
+
+		if (end < limit && *end == ']')
+			end++;
+		else if (delim)
+			return 0;
 		break;
 	default:
 		BUG();
 	}
 
-	if (ret == 0 || end == cp)
-		return 0;
 	if (endp)
 		*endp = end;
 	return 1;
@@ -219,7 +231,7 @@ static int epaddr_len(const struct nf_conn *ct, const char *dptr,
 	union nf_inet_addr addr;
 	const char *aux = dptr;
 
-	if (!parse_addr(ct, dptr, &dptr, &addr, limit)) {
+	if (!sip_parse_addr(ct, dptr, &dptr, &addr, limit, true)) {
 		pr_debug("ip: %s parse failed.!\n", dptr);
 		return 0;
 	}
@@ -296,7 +308,7 @@ int ct_sip_parse_request(const struct nf_conn *ct,
 		return 0;
 	dptr += shift;
 
-	if (!parse_addr(ct, dptr, &end, addr, limit))
+	if (!sip_parse_addr(ct, dptr, &end, addr, limit, true))
 		return -1;
 	if (end < limit && *end == ':') {
 		end++;
@@ -550,7 +562,7 @@ int ct_sip_parse_header_uri(const struct nf_conn *ct, const char *dptr,
 	if (ret == 0)
 		return ret;
 
-	if (!parse_addr(ct, dptr + *matchoff, &c, addr, limit))
+	if (!sip_parse_addr(ct, dptr + *matchoff, &c, addr, limit, true))
 		return -1;
 	if (*c == ':') {
 		c++;
@@ -599,7 +611,7 @@ int ct_sip_parse_address_param(const struct nf_conn *ct, const char *dptr,
 			       unsigned int dataoff, unsigned int datalen,
 			       const char *name,
 			       unsigned int *matchoff, unsigned int *matchlen,
-			       union nf_inet_addr *addr)
+			       union nf_inet_addr *addr, bool delim)
 {
 	const char *limit = dptr + datalen;
 	const char *start, *end;
@@ -613,7 +625,7 @@ int ct_sip_parse_address_param(const struct nf_conn *ct, const char *dptr,
 		return 0;
 
 	start += strlen(name);
-	if (!parse_addr(ct, start, &end, addr, limit))
+	if (!sip_parse_addr(ct, start, &end, addr, limit, delim))
 		return 0;
 	*matchoff = start - dptr;
 	*matchlen = end - start;
@@ -675,6 +687,47 @@ static int ct_sip_parse_transport(struct nf_conn *ct, const char *dptr,
 	return 1;
 }
 
+static int sdp_parse_addr(const struct nf_conn *ct, const char *cp,
+			  const char **endp, union nf_inet_addr *addr,
+			  const char *limit)
+{
+	const char *end;
+	int ret;
+
+	memset(addr, 0, sizeof(*addr));
+	switch (nf_ct_l3num(ct)) {
+	case AF_INET:
+		ret = in4_pton(cp, limit - cp, (u8 *)&addr->ip, -1, &end);
+		break;
+	case AF_INET6:
+		ret = in6_pton(cp, limit - cp, (u8 *)&addr->ip6, -1, &end);
+		break;
+	default:
+		BUG();
+	}
+
+	if (ret == 0)
+		return 0;
+	if (endp)
+		*endp = end;
+	return 1;
+}
+
+/* skip ip address. returns its length. */
+static int sdp_addr_len(const struct nf_conn *ct, const char *dptr,
+			const char *limit, int *shift)
+{
+	union nf_inet_addr addr;
+	const char *aux = dptr;
+
+	if (!sdp_parse_addr(ct, dptr, &dptr, &addr, limit)) {
+		pr_debug("ip: %s parse failed.!\n", dptr);
+		return 0;
+	}
+
+	return dptr - aux;
+}
+
 /* SDP header parsing: a SDP session description contains an ordered set of
  * headers, starting with a section containing general session parameters,
  * optionally followed by multiple media descriptions.
@@ -686,10 +739,10 @@ static int ct_sip_parse_transport(struct nf_conn *ct, const char *dptr,
  */
 static const struct sip_header ct_sdp_hdrs[] = {
 	[SDP_HDR_VERSION]		= SDP_HDR("v=", NULL, digits_len),
-	[SDP_HDR_OWNER_IP4]		= SDP_HDR("o=", "IN IP4 ", epaddr_len),
-	[SDP_HDR_CONNECTION_IP4]	= SDP_HDR("c=", "IN IP4 ", epaddr_len),
-	[SDP_HDR_OWNER_IP6]		= SDP_HDR("o=", "IN IP6 ", epaddr_len),
-	[SDP_HDR_CONNECTION_IP6]	= SDP_HDR("c=", "IN IP6 ", epaddr_len),
+	[SDP_HDR_OWNER_IP4]		= SDP_HDR("o=", "IN IP4 ", sdp_addr_len),
+	[SDP_HDR_CONNECTION_IP4]	= SDP_HDR("c=", "IN IP4 ", sdp_addr_len),
+	[SDP_HDR_OWNER_IP6]		= SDP_HDR("o=", "IN IP6 ", sdp_addr_len),
+	[SDP_HDR_CONNECTION_IP6]	= SDP_HDR("c=", "IN IP6 ", sdp_addr_len),
 	[SDP_HDR_MEDIA]			= SDP_HDR("m=", NULL, media_len),
 };
 
@@ -775,8 +828,8 @@ static int ct_sip_parse_sdp_addr(const struct nf_conn *ct, const char *dptr,
 	if (ret <= 0)
 		return ret;
 
-	if (!parse_addr(ct, dptr + *matchoff, NULL, addr,
-			dptr + *matchoff + *matchlen))
+	if (!sdp_parse_addr(ct, dptr + *matchoff, NULL, addr,
+			    dptr + *matchoff + *matchlen))
 		return -1;
 	return 1;
 }
-- 
1.7.10.4

