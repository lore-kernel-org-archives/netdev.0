From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/7] ipv4: fib: Only flush FIB aliases belonging to currently flushed table
Date: Thu,  9 Feb 2017 10:28:38 +0100
Message-ID: <1486632524-5588-2-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, Alexander Duyck <alexander.h.duyck@intel.com>,
        Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35263 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752279AbdBIJ2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:28:48 -0500
Received: by mail-wm0-f48.google.com with SMTP id v186so74450393wmd.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:28:47 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In case the MAIN table is flushed and its trie is shared with the LOCAL
table, then we might be flushing FIB aliases belonging to the latter.
This can lead to FIB_ENTRY_DEL notifications sent with the wrong table
ID.

The above doesn't affect current listeners, as the table ID is ignored
during entry deletion, but this will change later in the patchset.

When flushing a particular table, skip any aliases belonging to a
different one.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/fib_trie.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2919d1a..5ef4596 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1963,7 +1963,8 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 		hlist_for_each_entry_safe(fa, tmp, &n->leaf, fa_list) {
 			struct fib_info *fi = fa->fa_info;
 
-			if (!fi || !(fi->fib_flags & RTNH_F_DEAD)) {
+			if (!fi || !(fi->fib_flags & RTNH_F_DEAD) ||
+			    tb->tb_id != fa->tb_id) {
 				slen = fa->fa_slen;
 				continue;
 			}
-- 
2.7.4
