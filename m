From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] skb: Propagate pfmemalloc on skb from head page only
Date: Thu, 14 Mar 2013 17:29:40 +0400
Message-ID: <5141D0C4.70409@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: David Miller <davem@davemloft.net>, Mel Gorman <mgorman@suse.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4272 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757807Ab3CNNbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 09:31:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

I'm trying to send big chunks of memory from application address space via
TCP socket using vmsplice + splice like this

   mem = mmap(128Mb);
   vmsplice(pipe[1], mem); /* splice memory into pipe */
   splice(pipe[0], tcp_socket); /* send it into network */

When I'm lucky and a huge page splices into the pipe and then into the socket
_and_ client and server ends of the TCP connection are on the same host,
communicating via lo, the whole connection gets stuck! The sending queue
becomes full and app stops writing/splicing more into it, but the receiving
queue remains empty, and that's why.

The __skb_fill_page_desc observes a tail page of a huge page and erroneously
propagates its page->pfmemalloc value onto socket (the pfmemalloc on tail pages
contain garbage). Then this skb->pfmemalloc leaks through lo and due to the

    tcp_v4_rcv
    sk_filter
        if (skb->pfmemalloc && !sock_flag(sk, SOCK_MEMALLOC)) /* true */
            return -ENOMEM
        goto release_and_discard;

no packets reach the socket. Even TCP re-transmits are dropped by this, as skb
cloning clones the pfmemalloc flag as well.

That said, here's the proper page->pfmemalloc propagation onto socket: we
must check the huge-page's head page only, other pages' pfmemalloc and mapping
values do not contain what is expected in this place. However, I'm not sure
whether this fix is _complete_, since pfmemalloc propagation via lo also 
oesn't look great.

Both, bit propagation from page to skb and this check in sk_filter, were 
introduced by c48a11c7 (netvm: propagate page->pfmemalloc to skb), in v3.5 so
Mel and stable@ are in Cc.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eb2106f..4e525eb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1292,11 +1292,13 @@ static inline void __skb_fill_page_desc(struct sk_buff *skb, int i,
 	 * do not lose pfmemalloc information as the pages would not be
 	 * allocated using __GFP_MEMALLOC.
 	 */
-	if (page->pfmemalloc && !page->mapping)
-		skb->pfmemalloc	= true;
 	frag->page.p		  = page;
 	frag->page_offset	  = off;
 	skb_frag_size_set(frag, size);
+
+	page = compound_head(page);
+	if (page->pfmemalloc && !page->mapping)
+		skb->pfmemalloc	= true;
 }
 
 /**
