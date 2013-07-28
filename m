From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 09:15:54 -0700
Message-ID: <1375028154.3669.30.camel@edumazet-glaptop>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34125 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3G1QP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 12:15:56 -0400
In-Reply-To: <20130728104446.GB9876@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-07-28 at 06:44 -0400, Neil Horman wrote:
> On Sat, Jul 27, 2013 at 08:02:05PM -0700, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Sat, 27 Jul 2013 16:59:43 -0700
> > 
> > > If a hardware needs frame being in a single 4K page, its driver must do
> > > its own allocation, or add appropriate aligning logic.
> > 
> > Whatever the cause the original patch in this thread is not the
> > correct fix and I've thus reverted it.
> > 
> 
> So what exactly is the consensus here?  We can certainly modify the patch to
> ensure allocation on a 4k boundary, and within a unique 4k page, but thats just
> a guess at the problem, and the Qualcomm people have been silent on the issue
> for weeks now.
> 

Thats the guess yes, but since MTU can be more than 4096 bytes, it could
be something else, some kind of DMA problem.

I wonder why rx_buffer_len includes VLAN_HLEN as this nic provides
accelerated vlan.

drivers/net/ethernet/atheros/atl1c/atl1c_main.c uses :
 hw->dmar_block = atl1c_dma_req_1024;

while drivers/net/ethernet/atheros/atlx/atl1.c uses :
 hw->dmar_block = atl1_dma_req_256;

drivers/net/ethernet/atheros/atlx/atl1.c also has this code around line
1962 :

                        /* rrd seems to be bad */
                        if (unlikely(i-- > 0)) {
                                /* rrd may not be DMAed completely */
                                udelay(1);
                                goto chk_rrd;
                        }


I would add the following debugging aid just to make sure...

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 786a874..4c794f9 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1794,6 +1794,7 @@ rrs_checked:
 				buffer_info->length, PCI_DMA_FROMDEVICE);
 			skb = buffer_info->skb;
 		} else {
+			WARN_ON_ONCE(1);
 			/* TODO */
 			if (netif_msg_rx_err(adapter))
 				dev_warn(&pdev->dev,
