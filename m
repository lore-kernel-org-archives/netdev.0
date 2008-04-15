From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Mon, 14 Apr 2008 17:12:07 -0700
Message-ID: <20080415001207.GA11852@localdomain>
References: <47BA0984.2070306@cybernetics.com>
 <1203381120.13495.78.camel@dell>
 <20080218.163554.74130592.davem@davemloft.net>
 <1203383046.13495.87.camel@dell> <47BB00EC.3010607@cybernetics.com>
 <1203448265.13495.95.camel@dell> <47BB54C2.6090501@cybernetics.com>
 <20080220034515.GC22703@gondor.apana.org.au>
 <47BC44E2.9060301@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Michael Chan" <mchan@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, gregkh@suse.de,
	linux-kernel@vger.kernel.org
To: "Tony Battersby" <tonyb@cybernetics.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762521AbYDOAKs@vger.kernel.org>
In-Reply-To: <47BC44E2.9060301@cybernetics.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tony.  Sorry for the radio silence.

Michael and I have discussed this problem a bit.  Another possibility is
that the chip may be having difficulty with non-dword aligned TX buffers.
Since we already know the RX side has the same problem, it isn't so
far-fetched to think that perhaps it can affect the TX side too.  Can
you give the following patch a try and see if the corruption still
happens?


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 96043c5..810c711 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4135,11 +4135,20 @@ static int tigon3_dma_hwbug_workaround(struct tg3 *tp, struct sk_buff *skb,
 				       u32 last_plus_one, u32 *start,
 				       u32 base_flags, u32 mss)
 {
-	struct sk_buff *new_skb = skb_copy(skb, GFP_ATOMIC);
+	struct sk_buff *new_skb;
 	dma_addr_t new_addr = 0;
 	u32 entry = *start;
 	int i, ret = 0;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701)
+		new_skb = skb_copy(skb, GFP_ATOMIC);
+	else {
+		int more_headroom = 4 - (skb->mac_header & 3);
+
+		new_skb = skb_copy_expand(skb, skb_headroom(skb) + more_headroom,
+					  skb_tailroom(skb), GFP_ATOMIC);
+	}
+
 	if (!new_skb) {
 		ret = -1;
 	} else {
@@ -4465,6 +4474,10 @@ static int tg3_start_xmit_dma_bug(struct sk_buff *skb, struct net_device *dev)
 	if (tg3_4g_overflow_test(mapping, len))
 		would_hit_hwbug = 1;
 
+	/* Force the 5701 into the double copy path. */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701)
+		would_hit_hwbug = 1;
+
 	tg3_set_txd(tp, entry, mapping, len, base_flags,
 		    (skb_shinfo(skb)->nr_frags == 0) | (mss << 1));
 


On Wed, Feb 20, 2008 at 10:18:58AM -0500, Tony Battersby wrote:
> Herbert Xu wrote:
> > On Tue, Feb 19, 2008 at 05:14:26PM -0500, Tony Battersby wrote:
> >   
> >> Update: when I revert Herbert's patch in addition to applying your
> >> patch, the iSCSI performance goes back up to 115 MB/s again in both
> >> directions.  So it looks like turning off SG for TX didn't itself cause
> >> the performance drop, but rather that the performance drop is just
> >> another manifestation of whatever bug is causing the data corruption.
> >>     
> >
> > Interesting.  So the workload that regressed is mostly RX with a
> > little TX traffic? Can you try to reproduce this with something
> > like netperf to eliminate other variables?
> >
> > This is all very puzzling since the patch in question shouldn't
> > change an RX load at all.
> >
> > Thanks,
> >   
> We have established that the slowdown was caused by TCP checksum errors
> and retransmits.  I assume that the slowdown in my test was due to the
> light TX rather than the heavy RX.  I am no TCP protocol expert, but
> perhaps heavy TX (such as iperf) might not be affected as much because
> the wire stays busy while waiting for the retransmit, whereas with my
> light TX iSCSI load, the wire goes idle while waiting for the retransmit
> because the iSCSI state machine is stalled.
> 
> Tony
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
