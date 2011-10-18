From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Fix guest memory leak and panic
Date: Tue, 18 Oct 2011 10:47:11 +0100
Message-ID: <1318931232.16132.65.camel@zakaz.uk.xensource.com>
References: <20111018080523.16861.55402.sendpatchset@krkumar2.in.ibm.com>
	 <1318927016.16132.49.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318927016.16132.49.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-18 at 09:36 +0100, Ian Campbell wrote:
> I think the best thing might be to remove the additional ref taking from
> the setter function and audit the previous changes to ensure they
> conform. I'll do that right away and post a fixup patch ASAP.

Sigh, only one out of the ten callers of (__)skb_frag_set_page expects
skb_frag_set_page to take a new reference. I think that's pretty
comprehensive evidence that the current behaviour is unexpected and
wrong. 

Sorry about this.

Ian.

8<---------------------------------------------------------

>From 42c26b7ca640bd5cb6f9c3bc76db96c92ed8ff82 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 18 Oct 2011 09:59:37 +0100
Subject: [PATCH] net: do not take an additional reference in skb_frag_set_page

I audited all of the callers in the tree and only one of them (pktgen) expects
it to do so. Taking this reference is pretty obviously confusing and error
prone.

In particular I looked at the following commits which switched callers of
(__)skb_frag_set_page to the skb paged fragment api:

6a930b9f163d7e6d9ef692e05616c4ede65038ec cxgb3: convert to SKB paged frag API.
5dc3e196ea21e833128d51eb5b788a070fea1f28 myri10ge: convert to SKB paged frag API.
0e0634d20dd670a89af19af2a686a6cce943ac14 vmxnet3: convert to SKB paged frag API.
86ee8130a46769f73f8f423f99dbf782a09f9233 virtionet: convert to SKB paged frag API.
4a22c4c919c201c2a7f4ee09e672435a3072d875 sfc: convert to SKB paged frag API.
18324d690d6a5028e3c174fc1921447aedead2b8 cassini: convert to SKB paged frag API.
b061b39e3ae18ad75466258cf2116e18fa5bbd80 benet: convert to SKB paged frag API.
b7b6a688d217936459ff5cf1087b2361db952509 bnx2: convert to SKB paged frag API.
804cf14ea5ceca46554d5801e2817bba8116b7e5 net: xfrm: convert to SKB frag APIs
ea2ab69379a941c6f8884e290fdd28c93936a778 net: convert core to skb paged frag APIs

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
---
 include/linux/skbuff.h |    1 -
 net/core/pktgen.c      |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 64f8695..78741da 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1765,7 +1765,6 @@ static inline void *skb_frag_address_safe(const skb_frag_t *frag)
 static inline void __skb_frag_set_page(skb_frag_t *frag, struct page *page)
 {
 	frag->page = page;
-	__skb_frag_ref(frag);
 }
 
 /**
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 796044a..c4effd4 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2603,6 +2603,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 					break;
 			}
 			skb_frag_set_page(skb, i, pkt_dev->page);
+			skb_frag_ref(skb, i);
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			/*last fragment, fill rest of data*/
 			if (i == (frags - 1))
-- 
1.7.2.5
