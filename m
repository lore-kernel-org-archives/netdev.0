From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/4] netfilter: ipt_rpfilter: remove the nh_scope test in rpfilter_lookup_reverse
Date: Mon, 19 Oct 2015 20:22:53 +0200
Message-ID: <1445278975-2412-3-git-send-email-pablo@netfilter.org>
References: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37517 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754644AbbJSSP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 14:15:57 -0400
In-Reply-To: <1445278975-2412-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lucien <lucien.xin@gmail.com>

--accept-local  option works for res.type == RTN_LOCAL, which should be
from the local table, but there, the fib_info's nh->nh_scope =
RT_SCOPE_NOWHERE ( > RT_SCOPE_HOST). in fib_create_info().

	if (cfg->fc_scope == RT_SCOPE_HOST) {
		struct fib_nh *nh = fi->fib_nh;

		/* Local address is added. */
		if (nhs != 1 || nh->nh_gw)
			goto err_inval;
		nh->nh_scope = RT_SCOPE_NOWHERE;   <===
		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
		err = -ENODEV;
		if (!nh->nh_dev)
			goto failure;

but in our rpfilter_lookup_reverse():

	if (dev_match || flags & XT_RPFILTER_LOOSE)
		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;

if nh->nh_scope > RT_SCOPE_HOST, it will fail. --accept-local option
will never be passed.

it seems the test is bogus and can be removed to fix this issue.

	if (dev_match || flags & XT_RPFILTER_LOOSE)
		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;

ipv6 does not have this issue.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ipt_rpfilter.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index 8618fd1..c4ffc9d 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -61,9 +61,7 @@ static bool rpfilter_lookup_reverse(struct flowi4 *fl4,
 	if (FIB_RES_DEV(res) == dev)
 		dev_match = true;
 #endif
-	if (dev_match || flags & XT_RPFILTER_LOOSE)
-		return FIB_RES_NH(res).nh_scope <= RT_SCOPE_HOST;
-	return dev_match;
+	return dev_match || flags & XT_RPFILTER_LOOSE;
 }
 
 static bool rpfilter_is_local(const struct sk_buff *skb)
-- 
2.1.4
