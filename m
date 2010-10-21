From: kaber@trash.net
Subject: [PATCH 16/72] netfilter: nf_conntrack_sip: Add callid parser
Date: Thu, 21 Oct 2010 17:19:03 +0200
Message-ID: <1287674399-31455-17-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab0JUPUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:05 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/netfilter/nf_conntrack_sip.h |    1 +
 net/netfilter/nf_conntrack_sip.c           |   39 ++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_sip.h b/include/linux/netfilter/nf_conntrack_sip.h
index ff8cfbc..0ce91d5 100644
--- a/include/linux/netfilter/nf_conntrack_sip.h
+++ b/include/linux/netfilter/nf_conntrack_sip.h
@@ -89,6 +89,7 @@ enum sip_header_types {
 	SIP_HDR_VIA_TCP,
 	SIP_HDR_EXPIRES,
 	SIP_HDR_CONTENT_LENGTH,
+	SIP_HDR_CALL_ID,
 };
 
 enum sdp_header_types {
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 2fd1ea2..715ce54 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -130,6 +130,44 @@ static int digits_len(const struct nf_conn *ct, const char *dptr,
 	return len;
 }
 
+static int iswordc(const char c)
+{
+	if (isalnum(c) || c == '!' || c == '"' || c == '%' ||
+	    (c >= '(' && c <= '/') || c == ':' || c == '<' || c == '>' ||
+	    c == '?' || (c >= '[' && c <= ']') || c == '_' || c == '`' ||
+	    c == '{' || c == '}' || c == '~')
+		return 1;
+	return 0;
+}
+
+static int word_len(const char *dptr, const char *limit)
+{
+	int len = 0;
+	while (dptr < limit && iswordc(*dptr)) {
+		dptr++;
+		len++;
+	}
+	return len;
+}
+
+static int callid_len(const struct nf_conn *ct, const char *dptr,
+		      const char *limit, int *shift)
+{
+	int len, domain_len;
+
+	len = word_len(dptr, limit);
+	dptr += len;
+	if (!len || dptr == limit || *dptr != '@')
+		return len;
+	dptr++;
+	len++;
+
+	domain_len = word_len(dptr, limit);
+	if (!domain_len)
+		return 0;
+	return len + domain_len;
+}
+
 /* get media type + port length */
 static int media_len(const struct nf_conn *ct, const char *dptr,
 		     const char *limit, int *shift)
@@ -299,6 +337,7 @@ static const struct sip_header ct_sip_hdrs[] = {
 	[SIP_HDR_VIA_TCP]		= SIP_HDR("Via", "v", "TCP ", epaddr_len),
 	[SIP_HDR_EXPIRES]		= SIP_HDR("Expires", NULL, NULL, digits_len),
 	[SIP_HDR_CONTENT_LENGTH]	= SIP_HDR("Content-Length", "l", NULL, digits_len),
+	[SIP_HDR_CALL_ID]		= SIP_HDR("Call-Id", "i", NULL, callid_len),
 };
 
 static const char *sip_follow_continuation(const char *dptr, const char *limit)
-- 
1.7.1

