From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix sk_buff page offsets and lengths.
Date: Mon, 30 Jul 2007 18:50:28 -0700 (PDT)
Message-ID: <20070730.185028.26532012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34897
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S940396AbXGaBu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 21:50:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stephen Rothwell pointed out to me that the skb_frag_struct
is broken on platforms using 64K or larger page sizes, it
even generates warnings when (for example) the myri10ge driver
tries to assign PAGE_SIZE into frag->size.

I've thus increased page offset and size to __u32 in the patch below.

I made this change much to even my own chagrin, but this is the
most direct fix and the ifdefs we could put here are both ugly
and also not something that we do with struct scatterlist so
no reason to do it in a place like this.

Actually, the cost on 64-bit is zero because there existed 4 bytes of
alignment padding for skb_frag_struct because of the page pointer.
On 32-bit the cost is up to 64-bytes :-/

Stephen, this opens up the doors a bit for the scatterlist work
you wanted to do in sk_buff.

commit 051c14dbc588590e0a165dda0305c7c1b9ce7fb0
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Jul 30 18:47:03 2007 -0700

    [NET]: Page offsets and lengths need to be __u32.
    
    Based upon a report from Stephen Rothwell.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ce25643..93c27f7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -134,8 +134,8 @@ typedef struct skb_frag_struct skb_frag_t;
 
 struct skb_frag_struct {
 	struct page *page;
-	__u16 page_offset;
-	__u16 size;
+	__u32 page_offset;
+	__u32 size;
 };
 
 /* This data is invariant across clones and lives at
