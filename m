From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: ctnetlink: don't add null bindings if no nat requested
Date: Fri,  9 May 2014 12:56:02 +0200
Message-ID: <1399632967-4423-2-git-send-email-pablo@netfilter.org>
References: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40270 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610AbaEIK4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 06:56:17 -0400
In-Reply-To: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

commit 0eba801b64cc8284d9024c7ece30415a2b981a72 tried to fix a race
where nat initialisation can happen after ctnetlink-created conntrack
has been created.

However, it causes the nat module(s) to be loaded needlessly on
systems that are not using NAT.

Fortunately, we do not have to create null bindings in that case.

conntracks injected via ctnetlink always have the CONFIRMED bit set,
which prevents addition of the nat extension in nf_nat_ipv4/6_fn().

We only need to make sure that either no nat extension is added
or that we've created both src and dst manips.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ccc46fa..5857963 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1336,6 +1336,9 @@ ctnetlink_setup_nat(struct nf_conn *ct, const struct nlattr * const cda[])
 #ifdef CONFIG_NF_NAT_NEEDED
 	int ret;
 
+	if (!cda[CTA_NAT_DST] && !cda[CTA_NAT_SRC])
+		return 0;
+
 	ret = ctnetlink_parse_nat_setup(ct, NF_NAT_MANIP_DST,
 					cda[CTA_NAT_DST]);
 	if (ret < 0)
-- 
1.7.10.4
