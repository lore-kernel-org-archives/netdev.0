From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] fib_trie: Only display main table in
 /proc/net/route
Date: Wed, 11 Mar 2015 16:36:08 -0700
Message-ID: <20150311233536.1696.1657.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751204AbbCKXgK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 19:36:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we merged the tries for local and main I had overlooked the iterator
for /proc/net/route.  As a result it was outputting both local and main
when the two tries were merged.

This patch resolves that by only providing output for aliases that are
actually in the main trie.  As a result we should go back to the original
behavior which I assume will be necessary to maintain legacy support.

Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7b2badd..dd488c1 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2539,6 +2539,8 @@ static unsigned int fib_flag_trans(int type, __be32 mask, const struct fib_info
  */
 static int fib_route_seq_show(struct seq_file *seq, void *v)
 {
+	struct fib_route_iter *iter = seq->private;
+	struct fib_table *tb = iter->main_tb;
 	struct fib_alias *fa;
 	struct key_vector *l = v;
 	__be32 prefix;
@@ -2561,6 +2563,9 @@ static int fib_route_seq_show(struct seq_file *seq, void *v)
 		    (fa->fa_type == RTN_MULTICAST))
 			continue;
 
+		if (fa->tb_id != tb->tb_id)
+			continue;
+
 		seq_setwidth(seq, 127);
 
 		if (fi)
