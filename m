From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Help: major pppoe regression since 2.6.35 (panic on first ppp
 conection)?
Date: Sat, 25 Dec 2010 13:10:44 +0100
Message-ID: <20101225121044.GA1841@del.dom.local>
References: <20101222110021.GA8985@ff.dom.local>
 <4D122093.6060900@scarlet.be>
 <1293035100.3027.247.camel@edumazet-laptop>
 <4D132C5F.8090404@scarlet.be>
 <1293106348.7789.5.camel@edumazet-laptop>
 <20101223202523.GA1913@del.dom.local>
 <4D148271.8030509@scarlet.be>
 <20101224151325.GA1895@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Joel Soete <soete.joel@scarlet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101224151325.GA1895@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 24, 2010 at 04:13:25PM +0100, Jarek Poplawski wrote:
> On Fri, Dec 24, 2010 at 11:22:25AM +0000, Joel Soete wrote:
> > Hello Jarek,
> Hi Joel,
> 
> > Ok I get a clean 2.6.37-rc7 vanilla src and apply your debugging
> > patch and grab the attached syslog-2.6.37-rc7-t2.gz with obviously a
> > lot of "warning" (but as well as with Eric's patch, kernel survived
> > to a lynx connection to ftp.eu.kernel.org to download of a snapshot
> > patch ;<) )
> 
> Yes, even more than I expected... I hope the list will forgive us ;-)

Alas the list rejected your message (try to limit it to ~200kb next
time).

Anyway, it looks like the sundance driver is the main guilty. The
patch below removes one obvious bug but there could be something more.
Please, apply this one and my previous debugging patch to the clean
2.6.37-rc7. (If there're still warnings the first ~20kb should do.)

Thanks,
Jarek P.
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
