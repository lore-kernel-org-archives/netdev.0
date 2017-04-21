From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use
 napi_complete_done()")
Date: Fri, 21 Apr 2017 08:09:26 -0700
Message-ID: <1492787366.6453.9.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170407181754.GL30290@intel.com>
         <20170421114001.GJ30290@intel.com>
         <1492781375.6453.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ville =?ISO-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492781375.6453.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-21 at 06:29 -0700, Eric Dumazet wrote:

> Thanks for this report.
> 
> Interesting to see how many drivers got the netpoll stuff wrong :/
> 
> Can you try :
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 81f18a8335276495a59fa93219c4607c2b8a47aa..74e4c72c331d5a6cc5b653970ef4133c8ddf9999 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7668,7 +7668,7 @@ static void rtl8169_netpoll(struct net_device *dev)
>  {
>  	struct rtl8169_private *tp = netdev_priv(dev);
>  
> -	rtl8169_interrupt(tp->pci_dev->irq, dev);
> +	napi_schedule(&tp->napi);

The problem is more likely that netconsole handling can call rtl_tx()
from hard irq context, while standard NAPI poll calls it from BH

Meaning that the following sequence triggers a lockdep warning.

	u64_stats_update_begin(&tp->tx_stats.syncp);
	tp->tx_stats.packets++;
	tp->tx_stats.bytes += tx_skb->skb->len;
	u64_stats_update_end(&tp->tx_stats.syncp);

Lockdep does not know that poll_napi() ( called from netpoll_poll_dev())
uses an cmpxchg() to make sure that there is no race.

I am not sure how we can teach lockdep to not splat in this case.
