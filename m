From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Mon, 3 Oct 2011 11:37:21 -0300
Message-ID: <20111003143721.GA3596@oc1711230544.ibm.com>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:58678 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496Ab1JCOhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 10:37:40 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p93BbL2b023971
	for <netdev@vger.kernel.org>; Mon, 3 Oct 2011 08:37:21 -0300
Received: from d24av03.br.ibm.com (d24av03.br.ibm.com [9.8.31.95])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p93Eeok0631070
	for <netdev@vger.kernel.org>; Mon, 3 Oct 2011 11:40:53 -0300
Received: from d24av03.br.ibm.com (loopback [127.0.0.1])
	by d24av03.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p93EbYla026160
	for <netdev@vger.kernel.org>; Mon, 3 Oct 2011 11:37:34 -0300
Content-Disposition: inline
In-Reply-To: <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 02, 2011 at 08:58:21AM +0000, Yevgeny Petrilin wrote:
> 
> > With the addition of Blue Frame support in the network driver for mlx4, the doorbell is not written in the path where blue frame is enabled and the package follows some characteristics.
> > 
> > The consequence of that is that ICMP ECHO requests, for example, were not transmitted by the device. A ping flood, for example, would make the
> > watchdog dispatch, because the ring was full and transmissions have timed out.
> > 
> > After this fix, I could ping two systems using mlx4_en (both with the fix).
> > 
> > Signed-off-by: Thadeu Lima de Souza Cascardo
> > <cascardo@linux.vnet.ibm.com>
> > Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    5 +++--
> >  1 files changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > index 6e03de0..270da80 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > @@ -811,10 +811,11 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb,
> > struct net_device *dev)
> >  		* before setting ownership of this descriptor to HW */
> >  		wmb();
> >  		tx_desc->ctrl.owner_opcode = op_own;
> > -		wmb();
> > -		writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
> >  	}
> > 
> > +	wmb();
> > +	writel(ring->doorbell_qpn, ring->bf.uar->map + MLX4_SEND_DOORBELL);
> > +
> >  	/* Poll CQ here */
> >  	mlx4_en_xmit_poll(priv, tx_ind);
> > 
> > --
> > 1.7.4.4
> 
> What this patch does is ringing the doorbell unconditionally, whether blue flame is used or not.
> The whole idea, is to copy the data to the blueflame register and have the HW take the data from there and save the memory access to the work queue entry.
> In this patch you do both, copy the data to the register, and then still the HW accesses the memory to take it.
> For some reason Blue flame is not working on your system and we need to understand why, I'll be glad to work with you to debug it.
> Anyway, this patch is not the solution (even that it works on your systems) for the problem.
> 
> Yevgeny

Hello, Yevgeny.

We use a MT26448 (lspci -v output bellow) on a POWER7. Any other
information, tests or debug patches you want me to try, just tell me.

I expected this was really not the proper fix, but thought it would be
better to send it than just guess. Any clues what the problem might be?
Perhaps, we would have to disable blue frame for this particular device?

Regards,
Cascardo.

---
lspci output
0006:01:00.0 Ethernet controller: Mellanox Technologies MT26448 [ConnectX EN 10GigE, PCIe 2.0 5GT/s] (rev b0)
---
lspci -v output
0006:01:00.0 0200: 15b3:6750 (rev b0)
        Subsystem: 1014:0416
        Flags: bus master, fast devsel, latency 0, IRQ 31
        Memory at 3da47be00000 (64-bit, non-prefetchable) [size=1M]
        Memory at 3da47c000000 (64-bit, prefetchable) [size=32M]
        Expansion ROM at 3da47bf00000 [disabled] [size=1M]
        Capabilities: [40] Power Management version 3
        Capabilities: [48] Vital Product Data
        Capabilities: [9c] MSI-X: Enable+ Count=128 Masked-
        Capabilities: [60] Express Endpoint, MSI 00
        Capabilities: [100] Alternative Routing-ID Interpretation (ARI)
        Capabilities: [148] Device Serial Number 00-02-c9-03-00-0f-50-be
        Kernel driver in use: mlx4_core
        Kernel modules: mlx4_en, mlx4_core
---
