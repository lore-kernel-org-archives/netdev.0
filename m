From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH net-2.6] sundance: Fix oopses with corrupted skb_shared_info
Date: Sat, 25 Dec 2010 16:12:17 +0100
Message-ID: <20101225151217.GA1994@del.dom.local>
References: <20101222110021.GA8985@ff.dom.local>
 <4D122093.6060900@scarlet.be>
 <1293035100.3027.247.camel@edumazet-laptop>
 <4D132C5F.8090404@scarlet.be>
 <1293106348.7789.5.camel@edumazet-laptop>
 <20101223202523.GA1913@del.dom.local>
 <4D148271.8030509@scarlet.be>
 <20101224151325.GA1895@del.dom.local>
 <20101225121044.GA1841@del.dom.local>
 <4D15F6C9.50700@scarlet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joel Soete <soete.joel@scarlet.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D15F6C9.50700@scarlet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Was: Help: major pppoe regression since 2.6.35 (panic on first ppp
conection)?]

On Sat, Dec 25, 2010 at 01:51:05PM +0000, Joel Soete wrote:
> Hello Jarek,
Hello Joel,
...
> I don't have any more warnings :<)
> 
> Awesome job.

Awesome help.

Thanks and Happy New Year to you as well!
Jarek P.
-------------->

[PATCH net-2.6] sundance: Fix oopses with corrupted skb_shared_info

Joel Soete reported oopses at the beginning of pppoe connections since
v2.6.35. After debugging the bug was found in sundance skb allocation
and dma mapping code, where skb_reserve() bytes aren't taken into
account. This is an old bug, only uncovered by some change in 2.6.35.

Initial debugging patch by: Eric Dumazet <eric.dumazet@gmail.com>

Reported-by: Joel Soete <soete.joel@scarlet.be>
Tested-by: Joel Soete <soete.joel@scarlet.be>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 3ed2a67..b409d7e 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1016,7 +1016,7 @@ static void init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + 2);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1407,7 +1407,7 @@ static void refill_rx (struct net_device *dev)
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz);
+			skb = dev_alloc_skb(np->rx_buf_sz + 2);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;		/* Better luck next round. */
