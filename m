From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 03/22] netfilter: Replace strnicmp with strncasecmp
Date: Tue, 16 Sep 2014 22:51:17 +0200
Message-ID: <1410900696-6481-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1410900696-6481-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410900696-6481-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel used to contain two functions for length-delimited,
case-insensitive string comparison, strnicmp with correct semantics
and a slightly buggy strncasecmp. The latter is the POSIX name, so
strnicmp was renamed to strncasecmp, and strnicmp made into a wrapper
for the new strncasecmp to avoid breaking existing users.

To allow the compat wrapper strnicmp to be removed at some point in
the future, and to avoid the extra indirection cost, do
s/strnicmp/strncasecmp/g.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org
Cc: coreteam@netfilter.org
Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 net/netfilter/ipvs/ip_vs_ftp.c   |  6 +++---
 net/netfilter/nf_conntrack_ftp.c |  4 ++--
 net/netfilter/nf_conntrack_sip.c | 22 +++++++++++-----------
 net/netfilter/nf_log.c           |  2 +-
 net/netfilter/nf_nat_sip.c       |  2 +-
 5 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index 77c1732..cce4a51 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -96,13 +96,13 @@ static int ip_vs_ftp_get_addrport(char *data, char *data_limit,
 
 	if (data_limit - data < plen) {
 		/* check if there is partial match */
-		if (strnicmp(data, pattern, data_limit - data) == 0)
+		if (strncasecmp(data, pattern, data_limit - data) == 0)
 			return -1;
 		else
 			return 0;
 	}
 
-	if (strnicmp(data, pattern, plen) != 0) {
+	if (strncasecmp(data, pattern, plen) != 0) {
 		return 0;
 	}
 	s = data + plen;
@@ -353,7 +353,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 	data_limit = skb_tail_pointer(skb);
 
 	while (data <= data_limit - 6) {
-		if (strnicmp(data, "PASV\r\n", 6) == 0) {
+		if (strncasecmp(data, "PASV\r\n", 6) == 0) {
 			/* Passive mode on */
 			IP_VS_DBG(7, "got PASV at %td of %td\n",
 				  data - data_start,
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index b8a0924..b666959 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -304,12 +304,12 @@ static int find_pattern(const char *data, size_t dlen,
 
 	if (dlen <= plen) {
 		/* Short packet: try for partial? */
-		if (strnicmp(data, pattern, dlen) == 0)
+		if (strncasecmp(data, pattern, dlen) == 0)
 			return -1;
 		else return 0;
 	}
 
-	if (strnicmp(data, pattern, plen) != 0) {
+	if (strncasecmp(data, pattern, plen) != 0) {
 #if 0
 		size_t i;
 
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4c3ba1c..885b4ab 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -247,7 +247,7 @@ int ct_sip_parse_request(const struct nf_conn *ct,
 	for (; dptr < limit - strlen("sip:"); dptr++) {
 		if (*dptr == '\r' || *dptr == '\n')
 			return -1;
-		if (strnicmp(dptr, "sip:", strlen("sip:")) == 0) {
+		if (strncasecmp(dptr, "sip:", strlen("sip:")) == 0) {
 			dptr += strlen("sip:");
 			break;
 		}
@@ -350,7 +350,7 @@ static const char *ct_sip_header_search(const char *dptr, const char *limit,
 			continue;
 		}
 
-		if (strnicmp(dptr, needle, len) == 0)
+		if (strncasecmp(dptr, needle, len) == 0)
 			return dptr;
 	}
 	return NULL;
@@ -383,10 +383,10 @@ int ct_sip_get_header(const struct nf_conn *ct, const char *dptr,
 		/* Find header. Compact headers must be followed by a
 		 * non-alphabetic character to avoid mismatches. */
 		if (limit - dptr >= hdr->len &&
-		    strnicmp(dptr, hdr->name, hdr->len) == 0)
+		    strncasecmp(dptr, hdr->name, hdr->len) == 0)
 			dptr += hdr->len;
 		else if (hdr->cname && limit - dptr >= hdr->clen + 1 &&
-			 strnicmp(dptr, hdr->cname, hdr->clen) == 0 &&
+			 strncasecmp(dptr, hdr->cname, hdr->clen) == 0 &&
 			 !isalpha(*(dptr + hdr->clen)))
 			dptr += hdr->clen;
 		else
@@ -620,9 +620,9 @@ static int ct_sip_parse_transport(struct nf_conn *ct, const char *dptr,
 
 	if (ct_sip_parse_param(ct, dptr, dataoff, datalen, "transport=",
 			       &matchoff, &matchlen)) {
-		if (!strnicmp(dptr + matchoff, "TCP", strlen("TCP")))
+		if (!strncasecmp(dptr + matchoff, "TCP", strlen("TCP")))
 			*proto = IPPROTO_TCP;
-		else if (!strnicmp(dptr + matchoff, "UDP", strlen("UDP")))
+		else if (!strncasecmp(dptr + matchoff, "UDP", strlen("UDP")))
 			*proto = IPPROTO_UDP;
 		else
 			return 0;
@@ -743,10 +743,10 @@ int ct_sip_get_sdp_header(const struct nf_conn *ct, const char *dptr,
 
 		if (term != SDP_HDR_UNSPEC &&
 		    limit - dptr >= thdr->len &&
-		    strnicmp(dptr, thdr->name, thdr->len) == 0)
+		    strncasecmp(dptr, thdr->name, thdr->len) == 0)
 			break;
 		else if (limit - dptr >= hdr->len &&
-			 strnicmp(dptr, hdr->name, hdr->len) == 0)
+			 strncasecmp(dptr, hdr->name, hdr->len) == 0)
 			dptr += hdr->len;
 		else
 			continue;
@@ -1394,7 +1394,7 @@ static int process_sip_response(struct sk_buff *skb, unsigned int protoff,
 		if (handler->response == NULL)
 			continue;
 		if (*datalen < matchend + handler->len ||
-		    strnicmp(*dptr + matchend, handler->method, handler->len))
+		    strncasecmp(*dptr + matchend, handler->method, handler->len))
 			continue;
 		return handler->response(skb, protoff, dataoff, dptr, datalen,
 					 cseq, code);
@@ -1435,7 +1435,7 @@ static int process_sip_request(struct sk_buff *skb, unsigned int protoff,
 		if (handler->request == NULL)
 			continue;
 		if (*datalen < handler->len ||
-		    strnicmp(*dptr, handler->method, handler->len))
+		    strncasecmp(*dptr, handler->method, handler->len))
 			continue;
 
 		if (ct_sip_get_header(ct, *dptr, 0, *datalen, SIP_HDR_CSEQ,
@@ -1462,7 +1462,7 @@ static int process_sip_msg(struct sk_buff *skb, struct nf_conn *ct,
 	const struct nf_nat_sip_hooks *hooks;
 	int ret;
 
-	if (strnicmp(*dptr, "SIP/2.0 ", strlen("SIP/2.0 ")) != 0)
+	if (strncasecmp(*dptr, "SIP/2.0 ", strlen("SIP/2.0 ")) != 0)
 		ret = process_sip_request(skb, protoff, dataoff, dptr, datalen);
 	else
 		ret = process_sip_response(skb, protoff, dataoff, dptr, datalen);
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index daad602..d719764 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -30,7 +30,7 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 
 		log = rcu_dereference_protected(loggers[pf][i],
 						lockdep_is_held(&nf_log_mutex));
-		if (!strnicmp(str_logger, log->name, strlen(log->name)))
+		if (!strncasecmp(str_logger, log->name, strlen(log->name)))
 			return log;
 	}
 
diff --git a/net/netfilter/nf_nat_sip.c b/net/netfilter/nf_nat_sip.c
index b4d691d..791fac4 100644
--- a/net/netfilter/nf_nat_sip.c
+++ b/net/netfilter/nf_nat_sip.c
@@ -155,7 +155,7 @@ static unsigned int nf_nat_sip(struct sk_buff *skb, unsigned int protoff,
 	int request, in_header;
 
 	/* Basic rules: requests and responses. */
-	if (strnicmp(*dptr, "SIP/2.0", strlen("SIP/2.0")) != 0) {
+	if (strncasecmp(*dptr, "SIP/2.0", strlen("SIP/2.0")) != 0) {
 		if (ct_sip_parse_request(ct, *dptr, *datalen,
 					 &matchoff, &matchlen,
 					 &addr, &port) > 0 &&
-- 
2.0.4
