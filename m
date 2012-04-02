From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 11/51] nfnetlink_cttimeout: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:01 -0400
Message-ID: <1333335521-1348-12-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46674 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab2DBC7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 22:59:21 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netfilter/nfnetlink_cttimeout.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 2b9e79f..3e65528 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -170,11 +170,12 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 	nfmsg->version = NFNETLINK_V0;
 	nfmsg->res_id = 0;
 
-	NLA_PUT_STRING(skb, CTA_TIMEOUT_NAME, timeout->name);
-	NLA_PUT_BE16(skb, CTA_TIMEOUT_L3PROTO, htons(timeout->l3num));
-	NLA_PUT_U8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4proto->l4proto);
-	NLA_PUT_BE32(skb, CTA_TIMEOUT_USE,
-			htonl(atomic_read(&timeout->refcnt)));
+	if (nla_put_string(skb, CTA_TIMEOUT_NAME, timeout->name) ||
+	    nla_put_be16(skb, CTA_TIMEOUT_L3PROTO, htons(timeout->l3num)) ||
+	    nla_put_u8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4proto->l4proto) ||
+	    nla_put_be32(skb, CTA_TIMEOUT_USE,
+			 htonl(atomic_read(&timeout->refcnt))))
+		goto nla_put_failure;
 
 	if (likely(l4proto->ctnl_timeout.obj_to_nlattr)) {
 		struct nlattr *nest_parms;
-- 
1.7.7.6
