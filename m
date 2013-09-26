From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] moxa: drop free_irq of devm_request_irq allocated irq
Date: Thu, 26 Sep 2013 15:02:51 +0100
Message-ID: <1380204171.1571.5.camel@bwh-desktop.uk.level5networks.com>
References: <CAPgLHd8YRP7kL_jNHi3J9jFn86f=Fv-AWWUY_aRGZQOgVTNPgg@mail.gmail.com>
	 <000001ceba51$f8b45c10$ea1d1430$%han@samsung.com>
	 <CAPgLHd9VXaPx18ujDKbUik6XjOsnARcK-C-orCOynyJaWFREjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <jg1.han@samsung.com>, <jonas.jensen@gmail.com>,
	<davem@davemloft.net>, <grant.likely@linaro.org>,
	<rob.herring@calxeda.com>, <yongjun_wei@trendmicro.com.cn>,
	<netdev@vger.kernel.org>, <sachin.kamat@linaro.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51581 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744Ab3IZODA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 10:03:00 -0400
In-Reply-To: <CAPgLHd9VXaPx18ujDKbUik6XjOsnARcK-C-orCOynyJaWFREjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-26 at 10:12 +0800, Wei Yongjun wrote:
> On 09/26/2013 08:47 AM, Jingoo Han wrote:
> > On Wednesday, September 25, 2013 4:33 PM, Wei Yongjun wrote:
> >> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >>
> >> irq allocated with devm_request_irq should not be freed using
> >> free_irq, because doing so causes a dangling pointer, and a
> >> subsequent double free.
> >>
> >> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> >> ---
> >>  drivers/net/ethernet/moxa/moxart_ether.c | 1 -
> >>  1 file changed, 1 deletion(-)
> >>
> >> diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
> >> index 83c2091..9a7fcb5 100644
> >> --- a/drivers/net/ethernet/moxa/moxart_ether.c
> >> +++ b/drivers/net/ethernet/moxa/moxart_ether.c
> >> @@ -531,7 +531,6 @@ static int moxart_remove(struct platform_device *pdev)
> >>  	struct net_device *ndev = platform_get_drvdata(pdev);
> >>
> >>  	unregister_netdev(ndev);
> >> -	free_irq(ndev->irq, ndev);
> >>  	moxart_mac_free_memory(ndev);
> >>  	free_netdev(ndev);
> > CC'ed Sachin Kamat,
> >
> > In this case, the free_irq() will be called, after calling
> > free_netdev(). 'ndev' is freed by free_netdev(). Then, 'ndev->irq'
> > is used by free_irq(). Is it right?
> >
> > In my humble opinion, it seems to make the problem.
> >
> 
> devm_request_irq() has recorded the irq and dev_id, so free_irq() by devm_*
> will not touch 'ndev' which has been freed by free_netdev().
> So, if we not need to call free_irq() before free_netdev(), there will be
> no problem.

What if this is a shared IRQ?  Then if free_irq() is not called here:

- The IRQ handler might still be called after free_netdev()
- The memory containing ndev could also be reallocated to another device
sharing the IRQ, so that it it uses the same dev_id for its IRQ handler

Maybe you can be sure that this device will never share an IRQ.  But it
still doesn't look like good practice to rely on this.  Perhaps there
should be devm functions for netdevs too, so it wouldn't be necessary to
free either IRQ or netdev explicitly.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
