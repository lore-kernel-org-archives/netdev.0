From: "David S. Miller" <davem@davemloft.net>
Subject: [PATCH 29/51] decnet: Stop using NLA_PUT*().
Date: Sun,  1 Apr 2012 22:58:19 -0400
Message-ID: <1333335521-1348-30-git-send-email-davem@davemloft.net>
References: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754418Ab2DBDAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:00:01 -0400
In-Reply-To: <1333335521-1348-1-git-send-email-davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David S. Miller" <davem@davemloft.net>

These macros contain a hidden goto, and are thus extremely error
prone and make code hard to audit.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/dn_dev.c   |   14 +++++++-------
 net/decnet/dn_rules.c |   10 +++++-----
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 74d321a..16efcda 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -695,13 +695,13 @@ static int dn_nl_fill_ifaddr(struct sk_buff *skb, struct dn_ifaddr *ifa,
 	ifm->ifa_scope = ifa->ifa_scope;
 	ifm->ifa_index = ifa->ifa_dev->dev->ifindex;
 
-	if (ifa->ifa_address)
-		NLA_PUT_LE16(skb, IFA_ADDRESS, ifa->ifa_address);
-	if (ifa->ifa_local)
-		NLA_PUT_LE16(skb, IFA_LOCAL, ifa->ifa_local);
-	if (ifa->ifa_label[0])
-		NLA_PUT_STRING(skb, IFA_LABEL, ifa->ifa_label);
-
+	if ((ifa->ifa_address &&
+	     nla_put_le16(skb, IFA_ADDRESS, ifa->ifa_address)) ||
+	    (ifa->ifa_local &&
+	     nla_put_le16(skb, IFA_LOCAL, ifa->ifa_local)) ||
+	    (ifa->ifa_label[0] &&
+	     nla_put_string(skb, IFA_LABEL, ifa->ifa_label)))
+		goto nla_put_failure;
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index f65c9dd..7399e3d 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -204,11 +204,11 @@ static int dn_fib_rule_fill(struct fib_rule *rule, struct sk_buff *skb,
 	frh->src_len = r->src_len;
 	frh->tos = 0;
 
-	if (r->dst_len)
-		NLA_PUT_LE16(skb, FRA_DST, r->dst);
-	if (r->src_len)
-		NLA_PUT_LE16(skb, FRA_SRC, r->src);
-
+	if ((r->dst_len &&
+	     nla_put_le16(skb, FRA_DST, r->dst)) ||
+	    (r->src_len &&
+	     nla_put_le16(skb, FRA_SRC, r->src)))
+		goto nla_put_failure;
 	return 0;
 
 nla_put_failure:
-- 
1.7.7.6
