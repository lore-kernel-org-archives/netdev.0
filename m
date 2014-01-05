From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: ctnetlink: honor CTA_MARK_MASK when setting ctmark
Date: Mon,  6 Jan 2014 00:12:56 +0100
Message-ID: <1388963586-5049-3-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56225 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbaAEXNV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:21 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Useful to only set a particular range of the conntrack mark while
leaving exisiting parts of the value alone, e.g. when setting
conntrack marks via NFQUEUE.

Follows same scheme as MARK/CONNMARK targets, i.e. the mask defines
those bits that should be altered.  No mask is equal to '~0', ie.
the old value is replaced by new one.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 08870b8..bb322d0 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2118,8 +2118,16 @@ ctnetlink_nfqueue_parse_ct(const struct nlattr *cda[], struct nf_conn *ct)
 			return err;
 	}
 #if defined(CONFIG_NF_CONNTRACK_MARK)
-	if (cda[CTA_MARK])
-		ct->mark = ntohl(nla_get_be32(cda[CTA_MARK]));
+	if (cda[CTA_MARK]) {
+		u32 mask = 0, mark, newmark;
+		if (cda[CTA_MARK_MASK])
+			mask = ~ntohl(nla_get_be32(cda[CTA_MARK_MASK]));
+
+		mark = ntohl(nla_get_be32(cda[CTA_MARK]));
+		newmark = (ct->mark & mask) ^ mark;
+		if (newmark != ct->mark)
+			ct->mark = newmark;
+	}
 #endif
 	return 0;
 }
-- 
1.7.10.4
