From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix tcp_md5_hash_skb_data()
Date: Tue, 14 May 2013 00:25:52 -0700
Message-ID: <1368516352.32106.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Schnall <mischnal@google.com>,
	Bernhard Beck <bbeck@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:48651 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3ENHZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 03:25:56 -0400
Received: by mail-pa0-f41.google.com with SMTP id rl6so269162pac.0
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 00:25:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP md5 communications fail [1] for some devices, because sg/crypto code
assume page offsets are below PAGE_SIZE.

This was discovered using mlx4 driver [2], but I suspect loopback
might trigger the same bug now we use order-3 pages in tcp_sendmsg()

[1] Failure is giving following messages.

huh, entered softirq 3 NET_RX ffffffff806ad230 preempt_count 00000100,
exited with 00000101?

[2] mlx4 driver uses order-2 pages to allocate RX frags

Reported-by: Matt Schnall <mischnal@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Bernhard Beck <bbeck@google.com>
---
 net/ipv4/tcp.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dcb116d..10c9393 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3269,8 +3269,11 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 
 	for (i = 0; i < shi->nr_frags; ++i) {
 		const struct skb_frag_struct *f = &shi->frags[i];
-		struct page *page = skb_frag_page(f);
-		sg_set_page(&sg, page, skb_frag_size(f), f->page_offset);
+		unsigned int offset = f->page_offset;
+		struct page *page = skb_frag_page(f) + (offset >> PAGE_SHIFT);
+
+		sg_set_page(&sg, page, skb_frag_size(f),
+			    offset_in_page(offset));
 		if (crypto_hash_update(desc, &sg, skb_frag_size(f)))
 			return 1;
 	}
