From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 17:17:50 +0900
Message-ID: <20080402171104.9591.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <47F32789.2070703@redhat.com> <20080402005646.f8df1c1b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754402AbYDBISb@vger.kernel.org>
In-Reply-To: <20080402005646.f8df1c1b.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

CC'ed  netdev

> The appropriate thing to do here is to convert known-good drivers (such as
> e1000[e]) to use __GFP_NOWARN.
> 
> Unfortunately netdev_alloc_skb() went and assumed GFP_ATOMIC, but I guess
> we can dive below the covers and use __netdev_alloc_skb():

if network guys hope known-good driver should call 
__netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN) instead netdev_alloc_skb,
I think we should make netdev_alloc_skb_nowarn.

static inline void *netdev_alloc_skb_nowarn(struct net_device *dev, unsigned int length)
{
	return __netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN);
}


if not, we make unnecessary various alloc_skb
(e.g. e1000_alloc_skb, tg3_alloc_skb, 3com_alloc_skb etc..)


> From: Andrew Morton <akpm@linux-foundation.org>
> 
> We get rather a lot of reports of page allocation warnings coming out of
> e1000.  But this driver is know to handle them properly so let's suppress
> them.
> 
> Cc: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e1000/e1000.h      |    4 ++++
>  drivers/net/e1000/e1000_main.c |   10 +++++-----
>  2 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff -puN drivers/net/e1000/e1000_main.c~e1000-suppress-page-allocation-failure-warnings drivers/net/e1000/e1000_main.c
> --- a/drivers/net/e1000/e1000_main.c~e1000-suppress-page-allocation-failure-warnings
> +++ a/drivers/net/e1000/e1000_main.c
> @@ -4296,7 +4296,7 @@ e1000_clean_rx_irq(struct e1000_adapter 
>  		 * of reassembly being done in the stack */
>  		if (length < copybreak) {
>  			struct sk_buff *new_skb =
> -			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
> +			    e1000_alloc_skb(netdev, length + NET_IP_ALIGN);
>  			if (new_skb) {
>  				skb_reserve(new_skb, NET_IP_ALIGN);
>  				skb_copy_to_linear_data_offset(new_skb,
> @@ -4585,7 +4585,7 @@ e1000_alloc_rx_buffers(struct e1000_adap
>  			goto map_skb;
>  		}
>  
> -		skb = netdev_alloc_skb(netdev, bufsz);
> +		skb = e1000_alloc_skb(netdev, bufsz);
>  		if (unlikely(!skb)) {
>  			/* Better luck next round */
>  			adapter->alloc_rx_buff_failed++;
> @@ -4598,7 +4598,7 @@ e1000_alloc_rx_buffers(struct e1000_adap
>  			DPRINTK(RX_ERR, ERR, "skb align check failed: %u bytes "
>  					     "at %p\n", bufsz, skb->data);
>  			/* Try again, without freeing the previous */
> -			skb = netdev_alloc_skb(netdev, bufsz);
> +			skb = e1000_alloc_skb(netdev, bufsz);
>  			/* Failed allocation, critical failure */
>  			if (!skb) {
>  				dev_kfree_skb(oldskb);
> @@ -4720,8 +4720,8 @@ e1000_alloc_rx_buffers_ps(struct e1000_a
>  				rx_desc->read.buffer_addr[j+1] = ~cpu_to_le64(0);
>  		}
>  
> -		skb = netdev_alloc_skb(netdev,
> -		                       adapter->rx_ps_bsize0 + NET_IP_ALIGN);
> +		skb = e1000_alloc_skb(netdev,
> +					adapter->rx_ps_bsize0 + NET_IP_ALIGN);
>  
>  		if (unlikely(!skb)) {
>  			adapter->alloc_rx_buff_failed++;
> diff -puN drivers/net/e1000/e1000.h~e1000-suppress-page-allocation-failure-warnings drivers/net/e1000/e1000.h
> --- a/drivers/net/e1000/e1000.h~e1000-suppress-page-allocation-failure-warnings
> +++ a/drivers/net/e1000/e1000.h
> @@ -358,5 +358,9 @@ extern void e1000_power_up_phy(struct e1
>  extern void e1000_set_ethtool_ops(struct net_device *netdev);
>  extern void e1000_check_options(struct e1000_adapter *adapter);
>  
> +static inline void *e1000_alloc_skb(struct net_device *dev, unsigned int length)
> +{
> +	return __netdev_alloc_skb(dev, length, GFP_ATOMIC|__GFP_NOWARN);
> +}
>  
>  #endif /* _E1000_H_ */
> _
