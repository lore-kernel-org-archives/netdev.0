From: Yanko Kaneti <yaneti@declera.com>
Subject: Re: PPPOE lockdep report  in dev_queue_xmit+0x8b8/0x900
Date: Tue, 19 Feb 2013 13:10:21 +0200
Message-ID: <1361272221.2282.5.camel@d2>
References: <1361209421.9147.12.camel@d2>
	 <1361217052.19353.101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from indigo.declera.com ([212.116.131.21]:40204 "HELO
	indigo.declera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932354Ab3BSLKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 06:10:38 -0500
In-Reply-To: <1361217052.19353.101.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-18 at 11:50 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Mon, 2013-02-18 at 19:43 +0200, Yanko Kaneti wrote:
> > Hello,
> > 
> > I've had the following lockdep report for the last couple of years of
> > kernels. I don't think I've had a lockup during that time related to
> > pppoe.
> > 
> > The pppoe entry in the MAINTAINERS file lists Michal Ostrowski <mostrows@earthlink.net>
> > which unfortunately bounces.
> > 
> 
> Thanks for the report.
> 
> Could you please test following patch ?

It looks like it has done the job. I am running a kernel with the patch
and workload that otherwise inevitably triggers the splat and so far it
has been quiet.

Thanks

> 
> [PATCH] ppp: set qdisc_tx_busylock to avoid LOCKDEP splat
> 
> If a qdisc is installed on a ppp device, its possible to get
> a lockdep splat under stress, because nested dev_queue_xmit() can
> lock busylock a second time (on a different device, so its a false
> positive)
> 
> Avoid this problem using a distinct lock_class_key for team
> devices.
> 
> Reported-by: Yanko Kaneti <yaneti@declera.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ppp/ppp_generic.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> index 4fd754e..3db9131 100644
> --- a/drivers/net/ppp/ppp_generic.c
> +++ b/drivers/net/ppp/ppp_generic.c
> @@ -1058,7 +1058,15 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
>         return stats64;
>  }
>  
> +static struct lock_class_key ppp_tx_busylock;
> +static int ppp_dev_init(struct net_device *dev)
> +{
> +       dev->qdisc_tx_busylock = &ppp_tx_busylock;
> +       return 0;
> +}
> +
>  static const struct net_device_ops ppp_netdev_ops = {
> +       .ndo_init        = ppp_dev_init,
>         .ndo_start_xmit  = ppp_start_xmit,
>         .ndo_do_ioctl    = ppp_net_ioctl,
>         .ndo_get_stats64 = ppp_get_stats64,
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
