From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 1/9] net: ipv4: refactor key and length checks
Date: Sat, 27 May 2017 16:19:25 -0600
Message-ID: <20170527221933.57644-2-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36785 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdE0WTk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:40 -0400
Received: by mail-pf0-f195.google.com with SMTP id n23so8200050pfb.3
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:40 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_table_insert and fib_table_delete have the same checks on the prefix
and length. Refactor into a helper. Avoids duplicate extack messages in
the next patch.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/fib_trie.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6e9df7d9bcc2..9bd46e1e1037 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1099,6 +1099,17 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 	return 0;
 }
 
+static bool fib_valid_key_len(u32 key, u8 plen)
+{
+	if (plen > KEYLENGTH)
+		return false;
+
+	if ((plen < KEYLENGTH) && (key << plen))
+		return false;
+
+	return true;
+}
+
 /* Caller must hold RTNL. */
 int fib_table_insert(struct net *net, struct fib_table *tb,
 		     struct fib_config *cfg, struct netlink_ext_ack *extack)
@@ -1115,16 +1126,13 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 	u32 key;
 	int err;
 
-	if (plen > KEYLENGTH)
-		return -EINVAL;
-
 	key = ntohl(cfg->fc_dst);
 
-	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
-
-	if ((plen < KEYLENGTH) && (key << plen))
+	if (!fib_valid_key_len(key, plen))
 		return -EINVAL;
 
+	pr_debug("Insert table=%u %08x/%d\n", tb->tb_id, key, plen);
+
 	fi = fib_create_info(cfg, extack);
 	if (IS_ERR(fi)) {
 		err = PTR_ERR(fi);
@@ -1518,12 +1526,9 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 	u8 tos = cfg->fc_tos;
 	u32 key;
 
-	if (plen > KEYLENGTH)
-		return -EINVAL;
-
 	key = ntohl(cfg->fc_dst);
 
-	if ((plen < KEYLENGTH) && (key << plen))
+	if (!fib_valid_key_len(key, plen))
 		return -EINVAL;
 
 	l = fib_find_node(t, &tp, key);
-- 
2.11.0 (Apple Git-81)
