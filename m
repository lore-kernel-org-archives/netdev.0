From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Thu, 11 Dec 2008 16:03:07 -0800
Message-ID: <20081211160307.20709435@s6510>
References: <20081209210644.GC3785@hmsreliant.think-freely.org>
	<20081211130728.GB5910@ff.dom.local>
	<20081211090104.02cab3d4@s6510>
	<20081211181528.GB10558@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43077 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212AbYLLADU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 19:03:20 -0500
In-Reply-To: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2008 13:15:28 -0500
Neil Horman <nhorman@tuxdriver.com> wrote:

> On Thu, Dec 11, 2008 at 09:01:04AM -0800, Stephen Hemminger wrote:
> > On Thu, 11 Dec 2008 13:07:28 +0000
> > Jarek Poplawski <jarkao2@gmail.com> wrote:
> > 
> > > On 09-12-2008 22:06, Neil Horman wrote:
> > > ...
> > > > When executing napi->poll from the netpoll_path, this bit will
> > > > be set. When a driver calls netif_rx_complete, if that bit is set, it will not
> > > > remove the napi_struct from the poll_list.  That work will be saved for the next
> > > > iteration of net_rx_action.
> > > 
> > > This could be not enough: some drivers, e.g. sky2, call napi_complete()
> > > directly.
> > > 
> > 
> > There is good reason for this. Although most drivers only have one NAPI
> > instance per device, and multiqueue drivers have several NAPI structures
> > per device, a few devices like sky2 need to support multiple devices
> > running off one NAPI receive. The Marvell hardware has a common receive
> > interrupt for both ports on a dual port card.
> > 
> > This kind of hardware limits usage of netpoll. Only one port can be
> > used with netpoll because netpoll makes assumptions about NAPI
> > association.
> > 
> 
> There was previously good cause to use __netif_rx_complete instead of
> netif_rx_complete some time ago when multiqueue rx was implemented using a set
> of dummy netdevices.  But with the separation of the napi code, there is no
> longer any reason for this to be done.
> 
> I just took a quick look, and it appears that sky2 is the last remaining driver
> to use the underlying napi routines.
> 
> This patch maintains exactly the same functionality that it previously had, but
> allows for the netpoll patch to be safe with respect to the per-cpu poll_lists
> used by net_rx_action.
> 
> Regards
> Neil
> 
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> 
>  sky2.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 3813d15..84bdc3c 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -2694,7 +2694,7 @@ static int sky2_poll(struct napi_struct *napi, int work_limit)
>  		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_STOP);
>  		sky2_write8(hw, STAT_TX_TIMER_CTRL, TIM_START);
>  	}
> -	napi_complete(napi);
> +	netif_rx_complete(napi->dev, napi);
>  	sky2_read32(hw, B0_Y2_SP_LISR);
>  done:

I would ask it the other way. Why is interface an argument to netif_rx_complete
if it is never used?  
