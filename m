From: Wedson Almeida Filho <wedsonaf@gmail.com>
Subject: [PATCH] [NET]: Unmap fragment page once iterator is done
Date: Fri, 14 Jun 2013 17:54:29 -0700
Message-ID: <1371257669-21115-1-git-send-email-wedsonaf@gmail.com>
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Wedson Almeida Filho <wedsonaf@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:62400 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3FOAzC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 20:55:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Callers of skb_seq_read() are currently forced to call skb_abort_seq_read()
even when consuming all the data because the last call to skb_seq_read (the
one that returns 0 to indicate the end) fails to unmap the last fragment page.

With this patch callers will be allowed to traverse the SKB data by calling
skb_prepare_seq_read() once and repeatedly calling skb_seq_read() as originally
intended (and documented in the original commit 677e90eda), that is, only call
skb_abort_seq_read() if the sequential read is actually aborted.

Signed-off-by: Wedson Almeida Filho <wedsonaf@gmail.com>
---
 net/core/skbuff.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cfd777b..26ea1cf 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2554,8 +2554,13 @@ unsigned int skb_seq_read(unsigned int consumed, const u8 **data,
 	unsigned int block_limit, abs_offset = consumed + st->lower_offset;
 	skb_frag_t *frag;
 
-	if (unlikely(abs_offset >= st->upper_offset))
+	if (unlikely(abs_offset >= st->upper_offset)) {
+		if (st->frag_data) {
+			kunmap_atomic(st->frag_data);
+			st->frag_data = NULL;
+		}
 		return 0;
+	}
 
 next_skb:
 	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
-- 
1.7.9.5
