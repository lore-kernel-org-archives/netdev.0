From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [RFT] 2.6.4 - epic100 napi
Date: Sun, 21 Mar 2004 13:24:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405DDDC6.7030007@pobox.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040320152109.A31118@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> People are welcome to report how the following patch behaves on their
> hardware. It does not seem too bad here but it probably is still a bit rough.
> A split version of the patch will follow tomorrow. This one definitely aims
> at brave and/or bored testers.

Looks pretty good, but includes a standard NAPI race...

When you split up the patches, I'll throw it into my -netdev tree, which 
means it will be automatically included in -mm for testing (as is r8169 
now).

FWIW Andrew Morton has made me lazy...  I don't bother publishing 
separate -netdev patches anymore, since he automatically downloads my 
netdev-2.6 BK tree before doing each -mm release.


> +	if (work_done < orig_budget) {
> +		unsigned long flags;
> +		int status;
> +
> +		spin_lock_irqsave(&ep->napi_lock, flags);
> +		epic_napi_irq_on(dev, ep);
> +		__netif_rx_complete(dev);
> +		spin_unlock_irqrestore(&ep->napi_lock, flags);
> +
> +		status = inl(ioaddr + INTSTAT);
> +		if (status & EpicNapiEvent) {
> +			epic_napi_irq_off(dev, ep);
> +			goto rx_action;
> +		}

Need to add a netif_running() check to the 'if' test at the top of the 
quote.

Are you (or somebody else?) interested in reviewing all the in-tree NAPI 
drivers, and seeing if other drivers have this bug?  I think 8139cp.c 
does at least, maybe e100 too...  Such a fix would need to go into 2.4.x 
as well.

	Jeff
