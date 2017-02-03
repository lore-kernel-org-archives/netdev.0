From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/9] sunvnet: add memory barrier before check
 for tx enable
Date: Fri, 03 Feb 2017 14:11:59 -0800
Message-ID: <1486159919.21871.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486143755-192532-1-git-send-email-shannon.nelson@oracle.com>
         <1486143755-192532-6-git-send-email-shannon.nelson@oracle.com>
         <1486144585.21871.92.camel@edumazet-glaptop3.roam.corp.google.com>
         <d9d5ba0c-35dc-d10b-6eef-4d056732b8cf@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d9d5ba0c-35dc-d10b-6eef-4d056732b8cf@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-02-03 at 13:20 -0800, Shannon Nelson wrote:
> On 2/3/2017 9:56 AM, Eric Dumazet wrote:
> > On Fri, 2017-02-03 at 09:42 -0800, Shannon Nelson wrote:
> >> In order to allow the underlying LDC and outstanding memory operations
> >> to potentially catch up with the driver's Tx requests, add a memory
> >> barrier before checking again for available tx descriptors.
> >>
> >> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> >> ---
> >>  drivers/net/ethernet/sun/sunvnet_common.c |    1 +
> >>  1 files changed, 1 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
> >> index 5d0d386..98e758e 100644
> >> --- a/drivers/net/ethernet/sun/sunvnet_common.c
> >> +++ b/drivers/net/ethernet/sun/sunvnet_common.c
> >> @@ -1467,6 +1467,7 @@ ldc_start_done:
> >>  	dr->prod = (dr->prod + 1) & (VNET_TX_RING_SIZE - 1);
> >>  	if (unlikely(vnet_tx_dring_avail(dr) < 1)) {
> >>  		netif_tx_stop_queue(txq);
> >> +		dma_wmb();
> >
> > This does not look right.
> >
> > I believe you need smp_rmb() here.
> 
> Well, it probably should be dma_rmb(), since regardless of the number of 
> cores we think we have, we're communicating with a peer ldom that has 
> its own core(s).  Either way, on sparc they all seem to boil down to the 
> same bit of asm, but using the "rmb" part makes more logical sense. 
> I'll respin with dma_rmb().
> 

Transmit completion might happen on another cpu, regardless of ldom.

Therefore you need smp_rmb() here ( like mellanox/mlx4/en_tx.c) , or
even smp_mb() as bnx2x does.

dma_rmb() is never used in this context.
