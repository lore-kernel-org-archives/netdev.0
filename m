From: Olaf Kirch <okir@lst.de>
Subject: [PATCH] net: Make skb_seq_read unmap the last fragment
Date: Tue, 19 Jun 2007 09:56:24 +0200
Message-ID: <200706190956.26252.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:38501 "EHLO mail.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188AbXFSH4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 03:56:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <olaf.kirch@oracle.com>

Make skb_seq_read unmap the last fragment

Having walked through the entire skbuff, skb_seq_read would leave the
last fragment mapped.  As a consequence, the unwary caller would leak
kmaps, and proceed with preempt_count off by one. The only (kind of
non-intuitive) workaround is to use skb_seq_read_abort.

This patch makes sure skb_seq_read always unmaps frag_data after having
cycled through the skb's paged part.

Signed-off-by: olaf.kirch@oracle.com
---
 net/core/skbuff.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: build-2.6/net/core/skbuff.c
===================================================================
--- build-2.6.orig/net/core/skbuff.c
+++ build-2.6/net/core/skbuff.c
@@ -1706,6 +1706,11 @@ next_skb:
 		st->stepped_offset += frag->size;
 	}
 
+	if (st->frag_data) {
+		kunmap_skb_frag(st->frag_data);
+		st->frag_data = NULL;
+	}
+
 	if (st->cur_skb->next) {
 		st->cur_skb = st->cur_skb->next;
 		st->frag_idx = 0;

-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
