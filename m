From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next] ipv6: allow routes to be configured with expire values
Date: Thu, 10 Dec 2015 00:27:53 +0800
Message-ID: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449678473.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34165 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612AbbLIQ15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 11:27:57 -0500
Received: by pacwq6 with SMTP id wq6so31953999pac.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 08:27:56 -0800 (PST)
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
index c83b6a5..7815bc0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2709,6 +2709,7 @@ static const struct nla_policy rtm_ipv6_policy[RTA_MAX+1] = {
 	[RTA_PREF]              = { .type = NLA_U8 },
 	[RTA_ENCAP_TYPE]	= { .type = NLA_U16 },
 	[RTA_ENCAP]		= { .type = NLA_NESTED },
+	[RTA_CACHEINFO]		= { .len = sizeof(struct rta_cacheinfo) },
 };
 
 static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
@@ -2809,6 +2810,16 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
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
