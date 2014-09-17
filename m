From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: bisected regression: 3c59x corrupts packets in 3.17-rc5
Date: Wed, 17 Sep 2014 06:27:01 -0400
Message-ID: <20140917102701.GA5699@hmsreliant.think-freely.org>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
 <20140916101704.GA3792@hmsreliant.think-freely.org>
 <20140916.162923.605101746131407931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mroos@linux.ee, klassert@mathematik.tu-chemnitz.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46716 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbaIQK1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 06:27:18 -0400
Content-Disposition: inline
In-Reply-To: <20140916.162923.605101746131407931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 04:29:23PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 16 Sep 2014 06:17:04 -0400
> 
> > I'm guessing the above change has uncovered another bug,
> 
> Neil, read your patch carefully, I think it added the bug.
> 
> The ->page_offset of the frag gets applied two times.
> 
> skb_dma_map_frag() already takes frag->page_offset into consideration,
> you then pass it in as the 'offset' argument and it then gets added to
> itself to compute th final offset.
> 
Shit, you're right, sorry about that.  Its odd, I'm running it here, and its not 
causing problems, but thats obviously wrong.  Meelis, please add the above fix
to your test and confirm that it sovles the problem.  If you could keep the
previous patch in place too that would be great, as we should probably add the
dma error checking anyway.


[PATCH] 3c59x: Fix bad offset spec in skb_frag_dma_map

Recently aded the use of skb_frag_dma_map to 3c59x, but didn't realize it
automatically included the frag_offset internally, as well as provided an option
to specify an extra offset in the parameter list.  We need to specify an offset
of 0 in the parameter list to avoid skb corruption that results in lost
connections.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/ethernet/3com/3c59x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 5621dab..0f59d68 100644
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
-- 
1.9.3
