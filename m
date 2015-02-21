From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 1e918876 breaks r8169 (linux-3.18+)
Date: Sat, 21 Feb 2015 08:22:26 -0800
Message-ID: <1424535746.5565.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150203100816.GA5807@louise.pinerecords.com>
	 <20150203104214.GG24751@breakpoint.cc>
	 <20150210154536.GB16264@breakpoint.cc>
	 <20150221101512.GB17223@louise.pinerecords.com>
	 <20150221103104.GA26574@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tomas Szepe <szepe@pinerecords.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marco Berizzi <pupilla@hotmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150221103104.GA26574@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-02-21 at 11:31 +0100, Florian Westphal wrote:
> Tomas Szepe <szepe@pinerecords.com> wrote:
> > > I tried to reproduce this without success so far on my RTL8168d/8111d device.
> > > I've been running 40 parallel netperf TCP_STREAM tests (1gbit) for the
> > > last 5 hours and so far I saw no watchdog tx timeouts.
> > > 
> > > I'll keep this running for a day or so to see if it just takes more time
> > > to trigger.
> > 
> > So, how's this coming along?  Don't you think the patch should be reverted
> > until the problem is diagnosed/understood/fixed?
> 
> Sorry.
> 
> David, please consider reverting
> 
> 1e918876853aa85435e0f17fd8b4a92dcfff53d6
> (r8169: add support for Byte Queue Limits)
> 
> 	and
> 
> 0bec3b700d106a8b0a34227b2976d1a582f1aab7
> (r8169: add support for xmit_more)
> 
> I cannot reproduce any hangs (tried for 2days with 40 parallel
> netperfs using both 100mbit and 1gbit receiver).
> 
> And I don't see anything wrong with the change either.
> Seems like some revisions of the HW are just dodgy?
> 
> I hate giving up, but I have no means to diagnose this any further.
> Even reporter says it doesn't affect all of his r8169 nics.
> 
> So I think the change is correct per se, but might be revealing some
> HW/firmware bug.

Hold on.

I believe there is one race in the way you access skb->xmit_more _after_

txd->opts1 = cpu_to_le32(status);

After this point, TX might have completed and TX completion already have
freed skb

Could Tomas try following fix ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ad0020af2193..f2764366a36c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7050,6 +7050,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;
 	bool stop_queue;
+	bool xmit_more;
 
 	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
@@ -7091,7 +7092,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	txd->opts2 = cpu_to_le32(opts[1]);
 
 	netdev_sent_queue(dev, skb->len);
-
+	xmit_more = skb->xmit_more;
 	skb_tx_timestamp(skb);
 
 	/* Force memory writes to complete before releasing descriptor */
@@ -7108,7 +7109,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	stop_queue = !TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS);
 
-	if (!skb->xmit_more || stop_queue ||
+	if (!xmit_more || stop_queue ||
 	    netif_xmit_stopped(netdev_get_tx_queue(dev, 0))) {
 		RTL_W8(TxPoll, NPQ);
 
