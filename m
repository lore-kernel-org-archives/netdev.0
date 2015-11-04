From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3] netfilter: xt_TEE: fix NULL dereference
Date: Wed,  4 Nov 2015 15:00:36 +0100
Message-ID: <1446645638-3625-2-git-send-email-pablo@netfilter.org>
References: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44228 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754871AbbKDNxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 08:53:45 -0500
In-Reply-To: <1446645638-3625-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

iptables -I INPUT ... -j TEE --gateway 10.1.2.3

<crash> because --oif was not specified

tee_tg_check() sets ->priv pointer to NULL in this case.

Fixes: bbde9fc1824a ("netfilter: factor out packet duplication for IPv4/IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TEE.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index fd980aa..c5fdea1 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -31,8 +31,9 @@ static unsigned int
 tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
+	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, info->priv->oif);
+	nf_dup_ipv4(skb, par->hooknum, &info->gw.in, oif);
 
 	return XT_CONTINUE;
 }
@@ -42,8 +43,9 @@ static unsigned int
 tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
+	int oif = info->priv ? info->priv->oif : 0;
 
-	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, info->priv->oif);
+	nf_dup_ipv6(skb, par->hooknum, &info->gw.in6, oif);
 
 	return XT_CONTINUE;
 }
-- 
2.1.4
