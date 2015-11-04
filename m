From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: allow routes to be configured with expire values
Date: Wed,  4 Nov 2015 21:08:10 +0800
Message-ID: <351cae1858ad0f91eb8a2ff9c9a1c356e50e0ae8.1446642490.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org, thaller@redhat.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36128 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746AbbKDNIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 08:08:14 -0500
Received: by pacdm15 with SMTP id dm15so28824437pac.3
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 05:08:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the support for adding expire value to routes,  requested by
Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
wants it too.

add it by using the field rta_expires of rta_cacheinfo

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/route.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 946880a..49780bc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2700,6 +2700,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_PREF]              = { .type = NLA_U8 },
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
+	[RTA_CACHEINFO]		= { .len = sizeof(struct rta_cacheinfo) },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2800,6 +2801,16 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (tb[RTA_ENCAP_TYPE])
 		cfg->fc_encap_type = nla_get_u16(tb[RTA_ENCAP_TYPE]);
 
+	if (tb[RTA_CACHEINFO]) {
+		struct rta_cacheinfo *ci = nla_data(tb[RTA_CACHEINFO]);
+		unsigned long timeout = addrconf_timeout_fixup(ci->rta_expires, HZ);
+
+		if (addrconf_finite_timeout(timeout)) {
+			cfg->fc_expires = jiffies_to_clock_t(timeout * HZ);
+			cfg->fc_flags |= RTF_EXPIRES;
+		}
+	}
+
 	err = 0;
 errout:
 	return err;
-- 
2.1.0
