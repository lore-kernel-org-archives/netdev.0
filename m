From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 2/2] ila: Precompute checksum difference for translations
Date: Mon, 24 Aug 2015 09:45:42 -0700
Message-ID: <1440434742-4112603-3-git-send-email-tom@herbertland.com>
References: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36465 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753979AbbHXQpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 12:45:54 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7OGifjc021677
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:54 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wg4mu0q9w-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 09:45:54 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 94e8be5e4a7f11e5bf480002c9521c9e-7aff2240 for <netdev@vger.kernel.org>;	Mon,
 24 Aug 2015 09:45:52 -0700
In-Reply-To: <1440434742-4112603-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ILA build state for LWT compute the checksum difference to apply
to transport checksums that include the IPv6 pseudo header. The
difference is between the route destination (from fib6_config) and the
locator to write.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index ffe4dca..678d2df 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -14,6 +14,8 @@
 
 struct ila_params {
 	__be64 locator;
+	__be64 locator_match;
+	__wsum csum_diff;
 };
 
 static inline struct ila_params *ila_params_lwtunnel(
@@ -33,6 +35,9 @@ static inline __wsum compute_csum_diff8(const __be32 *from, const __be32 *to)
 
 static inline __wsum get_csum_diff(struct ipv6hdr *ip6h, struct ila_params *p)
 {
+	if (*(__be64 *)&ip6h->daddr == p->locator_match)
+		return p->csum_diff;
+	else
 		return compute_csum_diff8((__be32 *)&ip6h->daddr,
 					  (__be32 *)&p->locator);
 }
@@ -130,8 +135,12 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 	struct nlattr *tb[ILA_ATTR_MAX + 1];
 	size_t encap_len = sizeof(*p);
 	struct lwtunnel_state *newts;
+	const struct fib6_config *cfg6 = cfg;
 	int ret;
 
+	if (family != AF_INET6)
+		return -EINVAL;
+
 	ret = nla_parse_nested(tb, ILA_ATTR_MAX, nla,
 			       ila_nl_policy);
 	if (ret < 0)
@@ -149,6 +158,15 @@ static int ila_build_state(struct net_device *dev, struct nlattr *nla,
 
 	p->locator = (__force __be64)nla_get_u64(tb[ILA_ATTR_LOCATOR]);
 
+	if (cfg6->fc_dst_len > sizeof(__be64)) {
+		/* Precompute checksum difference for translation since we
+		 * know both the old locator and the new one.
+		 */
+		p->locator_match = *(__be64 *)&cfg6->fc_dst;
+		p->csum_diff = compute_csum_diff8(
+			(__be32 *)&p->locator_match, (__be32 *)&p->locator);
+	}
+
 	newts->type = LWTUNNEL_ENCAP_ILA;
 	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT |
 			LWTUNNEL_STATE_INPUT_REDIRECT;
-- 
1.8.1
