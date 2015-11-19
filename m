From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 regression: UDP packets dropped intermittantly
Date: Thu, 19 Nov 2015 04:22:34 -0800
Message-ID: <1447935754.22599.194.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20130309064647.GC4984@marvin.atrad.com.au>
	 <20130311000216.GA31808@zoreil.com>
	 <20130405001526.GC19253@marvin.atrad.com.au>
	 <20151117015605.GI22941@marvin.atrad.com.au>
	 <20151117232108.GC3362@electric-eye.fr.zoreil.com>
	 <20151118050919.GR25216@marvin.atrad.com.au>
	 <20151119005608.GB4882@electric-eye.fr.zoreil.com>
	 <20151119065718.GT8170@marvin.atrad.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Jonathan Woithe <jwoithe@atrad.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34078 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbKSMWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 07:22:36 -0500
Received: by padhx2 with SMTP id hx2so79973823pad.1
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 04:22:36 -0800 (PST)
In-Reply-To: <20151119065718.GT8170@marvin.atrad.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-19 at 17:27 +1030, Jonathan Woithe wrote:
> On Thu, Nov 19, 2015 at 01:56:08AM +0100, Francois Romieu wrote:
> > Jonathan Woithe <jwoithe@atrad.com.au> :
> > [...]
> > > I could try.  What's the most reliable way to determine this?  Use regular
> > > ethtool queries about the time of the failures?
> > 
> > If you are neither space nor cpu constrained:
> > 
> > while : ; do
> > 	echo $(date +%s.%N):$(ethtool -d eth0 raw on | base64 -w 0):$(ethtool -S eth0 | base64 -w 0)
> > 	sleep 1
> > done > gloubi
> > 
> > Expect 2.5~3Mo per hour.
> 
> We're certainly not disc constrained.  The high speed acquisition takes a
> fair bit of CPU but there should still be sufficient free to at least give
> the above a go.  I'll run some tests tomorrow and see what transpires.

This looks like a race when/if RX happens very shortly after one
transmit.

Francois, are we really saving lot of cpu cycles testing status ?

Following patch would probably reduce the window.
(And doing TX completions before RX might help as well)


diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 79ef799f88ab1fc2518736163c5674aec360c065..ed3d0322643600c8c3521aa0ac7b935c929527aa 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7541,17 +7541,14 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	struct rtl8169_private *tp = container_of(napi, struct rtl8169_private, napi);
 	struct net_device *dev = tp->dev;
 	u16 enable_mask = RTL_EVENT_NAPI | tp->event_slow;
-	int work_done= 0;
+	int work_done;
 	u16 status;
 
 	status = rtl_get_events(tp);
 	rtl_ack_events(tp, status & ~tp->event_slow);
 
-	if (status & RTL_EVENT_NAPI_RX)
-		work_done = rtl_rx(dev, tp, (u32) budget);
-
-	if (status & RTL_EVENT_NAPI_TX)
-		rtl_tx(dev, tp);
+	rtl_tx(dev, tp);
+	work_done = rtl_rx(dev, tp, (u32) budget);
 
 	if (status & tp->event_slow) {
 		enable_mask &= ~tp->event_slow;
