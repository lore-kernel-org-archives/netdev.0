From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 14:53:18 -0400
Message-ID: <20130728185318.GA10795@neilslaptop.think-freely.org>
References: <87k3kbdcmy.fsf@canonical.com>
 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
 <1374969583.3669.23.camel@edumazet-glaptop>
 <20130727.200205.67471633133830510.davem@davemloft.net>
 <20130728104446.GB9876@neilslaptop.think-freely.org>
 <1375028154.3669.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	luis.henriques@canonical.com, netdev@vger.kernel.org,
	jcliburn@gmail.com, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1375028154.3669.30.camel@edumazet-glaptop>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 28, 2013 at 09:15:54AM -0700, Eric Dumazet wrote:
> On Sun, 2013-07-28 at 06:44 -0400, Neil Horman wrote:
> > On Sat, Jul 27, 2013 at 08:02:05PM -0700, David Miller wrote:
> > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date: Sat, 27 Jul 2013 16:59:43 -0700
> > > 
> > > > If a hardware needs frame being in a single 4K page, its driver must do
> > > > its own allocation, or add appropriate aligning logic.
> > > 
> > > Whatever the cause the original patch in this thread is not the
> > > correct fix and I've thus reverted it.
> > > 
> > 
> > So what exactly is the consensus here?  We can certainly modify the patch to
> > ensure allocation on a 4k boundary, and within a unique 4k page, but thats just
> > a guess at the problem, and the Qualcomm people have been silent on the issue
> > for weeks now.
> > 
> 
> Thats the guess yes, but since MTU can be more than 4096 bytes, it could
> be something else, some kind of DMA problem.
> 
Right, thats exactly my concern, its a guess, one which infers problems of its
own.  I'll certainly code up a patch to test, sure, given what we've discussed
here, but I'm not sure it leaves us in any better position than we were in with
my origional patch.

> I wonder why rx_buffer_len includes VLAN_HLEN as this nic provides
> accelerated vlan.
> 
I expect its an overestimation of sizing requirements in the rx ring.  The
set_features method for the driver doesn't re-allocate the rx ring buffers if
the vlan tag accleration feature is disabled, so I suspect that they keep that
extra space in place in the event that its ever turned off.

> drivers/net/ethernet/atheros/atl1c/atl1c_main.c uses :
>  hw->dmar_block = atl1c_dma_req_1024;
> 
> while drivers/net/ethernet/atheros/atlx/atl1.c uses :
>  hw->dmar_block = atl1_dma_req_256;
> 
Another question for the Atheros people I suppose.  Although, atl1c takes this
value through several other contortions in atl1c_configure_tx, in which it seems
to allow the value to be either 2, or 3 (capped by the min_t call, and floored
by the check against DEVICE_CTRL_MAXRRS_MIN).  By all rights the setting in the
atlx driver would be considered invalid in the atl1c driver (if such
comparisons can be drawn).

> drivers/net/ethernet/atheros/atlx/atl1.c also has this code around line
> 1962 :
> 
>                         /* rrd seems to be bad */
>                         if (unlikely(i-- > 0)) {
>                                 /* rrd may not be DMAed completely */
>                                 udelay(1);
>                                 goto chk_rrd;
>                         }
> 
> 
Hmm, that is interesting, expecially given that atl1c has this code:
rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
                                RRS_RX_RFD_CNT_MASK;
                        if (unlikely(rfd_num != 1))
                                /* TODO support mul rfd*/
                                if (netif_msg_rx_err(adapter))
                                        dev_warn(&pdev->dev,
                                                "Multi rfd not support yet!\n");
                        goto rrs_checked;

It appears that atl1c does a simmilar check to what atlx does, but atl1c just
ignores the possibility that rfd_num may be 0.  I wonder if I shouldn't add a
loop simmilar to what alx does there.

> I would add the following debugging aid just to make sure...
> 
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index 786a874..4c794f9 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> @@ -1794,6 +1794,7 @@ rrs_checked:
>  				buffer_info->length, PCI_DMA_FROMDEVICE);
>  			skb = buffer_info->skb;
>  		} else {
> +			WARN_ON_ONCE(1);
>  			/* TODO */
>  			if (netif_msg_rx_err(adapter))
>  				dev_warn(&pdev->dev,
> 
> 
> 
I agree, I think perhaps a loop higher up prior to the rrs_checked label to
ensure that rfd_num is at least 1 prior to going through the rest of the rx
path.  I'll have something for the reporters to test tomorrow.

Thanks!
Neil

> 
