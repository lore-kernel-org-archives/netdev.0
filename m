From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net] net: Fix page seeking for skb_splice_bits().
Date: Wed, 11 Feb 2009 22:58:06 +0100
Message-ID: <20090211215806.GA2676@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:55733 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756874AbZBKV6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:58:13 -0500
Received: by fxm13 with SMTP id 13so1271152fxm.13
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 13:58:10 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

So, you both were right there is something wrong with splice for
multipage linear regions, at least theoretically. Since I don't know
if this can really matter in practice (could NUMA slab allocate these
pages from different tables?), I've done it against -net, but maybe
-net-next is enough?

Thanks,
Jarek P.
------------->
net: Fix page seeking for skb_splice_bits().

struct page walking should be done with proper accessor functions, not
directly.

With doubts from David S. Miller and Herbert Xu.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/core/skbuff.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index da74b84..7aacd95 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1373,8 +1373,13 @@ static inline int spd_fill_page(struct splice_pipe_desc *spd, struct page *page,
 static inline void __segment_seek(struct page **page, unsigned int *poff,
 				  unsigned int *plen, unsigned int off)
 {
+	unsigned long n;
+
 	*poff += off;
-	*page += *poff / PAGE_SIZE;
+	n = *poff / PAGE_SIZE;
+	if (n)
+		*page = nth_page(*page, n);
+
 	*poff = *poff % PAGE_SIZE;
 	*plen -= off;
 }

