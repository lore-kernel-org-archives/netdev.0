From: David Miller <davem@davemloft.net>
Subject: Re: Corrupt Network Packets -- 3.17-rc5/rc6
Date: Mon, 22 Sep 2014 13:38:31 -0400 (EDT)
Message-ID: <20140922.133831.220769383344675250.davem@davemloft.net>
References: <CAM_iQpXQcM2E2oez+nNbbecd25fXqOKNqAfoOgCfQ72-VfBOUA@mail.gmail.com>
	<201409221724.s8MHOxe5002845@clem.clem-digital.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: clem@clem.clem-digital.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201409221724.s8MHOxe5002845@clem.clem-digital.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pete Clements <clem@clem.clem-digital.net>
Date: Mon, 22 Sep 2014 13:24:59 -0400 (EDT)

> Quoting Cong Wang
>   > <clem@clem.clem-digital.net> wrote:
>   > > Heads up fyi: system is i386 UP.
>   > >
>   > > Started getting some pop3 reception errors from the above system.
>   > > Investigating the problem discovered scp of the mailbox failed
>   > > with "Corrupted MAC on input"
>   > >
>   > > Problem started with rc5, still in rc6. Running rc4 with no
>   > > problem.
>   > >
>   > > Sorry for lack of better definition.
>   > 
>   > 
>   > Which driver are you using?
>   > 
> Here's the output from boot log:
> 
>  PCI: setting IRQ 11 as level-triggered
>  3c59x 0000:00:0d.0: found PCI INT A -> IRQ 11
>  3c59x: Donald Becker and others.
>  0000:00:0d.0: 3Com PCI 3c900 Cyclone 10Mbps TPC at d8812000.

Should be fixed by:

commit 8400dd029e764e30361a51a7ae35900ae0032b43
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Wed Sep 17 09:04:45 2014 -0400

    3c59x: Fix bad offset spec in skb_frag_dma_map
    
    Recently aded the use of skb_frag_dma_map to 3c59x, but didn't realize it
    automatically included the frag_offset internally, as well as provided an option
    to specify an extra offset in the parameter list.  We need to specify an offset
    of 0 in the parameter list to avoid skb corruption that results in lost
    connections.
    
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
    CC: Linux Kernel list <linux-kernel@vger.kernel.org>
    CC: "David S. Miller" <davem@davemloft.net>
    CC: Meelis Roos <mroos@linux.ee>
    Tested-by: Meelis Roos <mroos@linux.ee>

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8ab87ff..8ca49f04 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2186,7 +2186,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 			dma_addr = skb_frag_dma_map(&VORTEX_PCI(vp)->dev, frag,
-						    frag->page_offset,
+						    0,
 						    frag->size,
 						    DMA_TO_DEVICE);
 			if (dma_mapping_error(&VORTEX_PCI(vp)->dev, dma_addr)) {
