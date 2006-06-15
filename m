From: Auke Kok <sofar@foo-projects.org>
Subject: Re: [patch] e100 statistic value "rx_bytes" error
Date: Wed, 14 Jun 2006 21:35:58 -0700
Message-ID: <4490E3AE.5050506@foo-projects.org>
References: <1150345027.3008.10.camel@L-tech>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:45273 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750954AbWFOEgb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 00:36:31 -0400
To: Wei Dong <weid@nanjing-fnst.com>
In-Reply-To: <1150345027.3008.10.camel@L-tech>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Dong wrote:
> Hi All:
>    When I test linux kernel(2.6.9-16), I found that maybe there is a bug
> in e100 driver. See function e100_rx_indicate() at line 1847:
> 	nic->net_stats.rx_bytes += actual_size;
> Here, actual_size is the actual size of an ethernent frame sans FCS.And
> the e100 driver gets it from skb. Because "rx_bytes" is a statistc value
> for a NIC, I think rx_bytes should include the FCS(4 bytes).
> The following is the patch for the function in e100.c

This is definately not an issue, and I'm not for changing this: It always was 
like this in the first place. It's done for many drivers like this anyway, 
mostly those without real hardware counters do it this way anyway (I count 
half a dozen or so on first glance).

On top of that we would be changing statistics numbers after x years of e100 
driver. I'm sure everyone doing real performance work will frown upon this.

Next it's unlikely that every driver (or worse, every nic in hardware) 
accounts for FCS in the rx_bytes count. It really wouldn't surprise me if a 
driver (or chip) got this wrong here or there.

Bottom line is that for e100, it's well known and easily seeable that e100 is 
counting skb sizes. That's consistent and I think we should keep it that way.

Auke


PS please cc the driver maintainers when you post patches to a specific driver.


> diff -ruN old/drivers/net/e100.c new/drivers/net/e100.c
> --- old/drivers/net/e100.c	2006-03-20 13:53:29.000000000 +0800
> +++ new/drivers/net/e100.c	2006-06-15 11:16:04.000000000 +0800
> @@ -1844,7 +1844,8 @@
>  		dev_kfree_skb_any(skb);
>  	} else {
>  		nic->net_stats.rx_packets++;
> -		nic->net_stats.rx_bytes += actual_size;
> +		/* Don't forget FCS */
> +		nic->net_stats.rx_bytes += actual_size + 4;
>  		nic->netdev->last_rx = jiffies;
>  		netif_receive_skb(skb);
>  		if(work_done)
> 
> BR.
>   Weidong
> 
> Signed-off-by: Weidong <weid@nanjing-fnst.com>
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

