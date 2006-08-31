From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Subject: Re: [BUG] in skge.c on 2.6.18-rc5
Date: Thu, 31 Aug 2006 10:48:28 +0200
Message-ID: <20060831084828.GD12754@edgar.underground.se.axis.com>
References: <7d01f9f00608300830j74871672o31b9ce126ee8c07d@mail.gmail.com> <7d01f9f00608301021v5d02b18dg8b0d993ee3dd1977@mail.gmail.com> <20060830102916.0e64e3b5@localhost.localdomain> <7d01f9f00608301036m621149bt82b4c007a6432a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from miranda.se.axis.com ([193.13.178.8]:24754 "EHLO
	miranda.se.axis.com") by vger.kernel.org with ESMTP
	id S1750986AbWHaIsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 04:48:30 -0400
Received: from axis.com (edgar.se.axis.com [10.92.151.1])
	by miranda.se.axis.com (8.12.9/8.12.9/Debian-5local0.1) with ESMTP id k7V8mSP0006519
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 10:48:28 +0200
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00608301036m621149bt82b4c007a6432a6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 07:36:56PM +0200, Thibaut VARENE wrote:
> On 8/30/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> >On Wed, 30 Aug 2006 19:21:20 +0200
> >"Thibaut VARENE" <T-Bone@parisc-linux.org> wrote:
> >
> >> Replying to myself as I've been pointed at Stephen's reply (please CC
> >> me, i'm not subscribed):
> >>
> >> I'm bringing the interface up with 'dhclient eth0', and yes it's using 
> >autoneg.
> >>
> >
> >Any chance of getting a backtrace; serial port, digital camera, 
> >handwritten note?
> 
> If you can deal with this extremely blurry shot:
> http://www.pateam.org/archive/tmp/IMGP0825.JPG
> 
> begins with "mod_timer" / "neigh_update" / "read_lock" and so on.
> 
> Worst case I'll reproduce the bug again and dump a better bt, but I'd
> rather avoid as much as possible as I use that machine a lot right now
> ;P

Hi,

It may be safer to disable pollers for the entire down procedure. I think
we might also have races where xmitters are active while we are in
skge_down. Taking the txlock around netif_stop_queue probably doens't help
as a txirq can hit just after and wakeup the queue. Dont know if the 
xmitters while in skge_down will cause problems though.

I have no skge hw so I am pretty much in the dark, cannot test anything,
sorry.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946

Subject: [PATCH] disable pollers while stopping hw, not just around rx_clean.
Signed-off-by: Edgar E. Iglesias <edgar.iglesias@axis.com>

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index ad878df..cd8c1e4 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2236,6 +2236,7 @@ static int skge_down(struct net_device *
 	if (netif_msg_ifdown(skge))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
 
+	netif_poll_disable(dev);
 	netif_stop_queue(dev);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
@@ -2280,7 +2281,6 @@ static int skge_down(struct net_device *
 
 	skge_led(skge, LED_MODE_OFF);
 
-	netif_poll_disable(dev);
 	skge_tx_clean(skge);
 	skge_rx_clean(skge);
 

