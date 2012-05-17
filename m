From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 2/4] e1000: remove workaround for Errata 23 from
 jumbo alloc
Date: Thu, 17 May 2012 15:40:30 +0100
Message-ID: <1337265630.2496.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337254070-32500-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1337254070-32500-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9291 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751782Ab2EQOkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 10:40:37 -0400
In-Reply-To: <1337254070-32500-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 04:27 -0700, Jeff Kirsher wrote:
> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> According to the comment, errata 23 says that the memory we allocate
> can't cross a 64KiB boundary. In case of jumbo frames we allocate
> complete pages which can never cross the 64KiB boundary because
> PAGE_SIZE should be a multiple of 64KiB so we stop either before the

Should be a factor, not multiple.

[...]
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -4391,30 +4391,6 @@ e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
>  			break;
>  		}
>  
> -		/* Fix for errata 23, can't cross 64kB boundary */
> -		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
> -			struct sk_buff *oldskb = skb;
> -			e_err(rx_err, "skb align check failed: %u bytes at "
> -			      "%p\n", bufsz, skb->data);
> -			/* Try again, without freeing the previous */
> -			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
> -			/* Failed allocation, critical failure */
> -			if (!skb) {
> -				dev_kfree_skb(oldskb);
> -				adapter->alloc_rx_buff_failed++;
> -				break;
> -			}
> -
> -			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
> -				/* give up */
> -				dev_kfree_skb(skb);
> -				dev_kfree_skb(oldskb);
> -				break; /* while (cleaned_count--) */
> -			}
> -
> -			/* Use new allocation */
> -			dev_kfree_skb(oldskb);
> -		}
[...]

I don't believe PAGE_SIZE is >64K on any architecture, but perhaps you
should replace the run-time check with:

		BUILD_BUG_ON(PAGE_SIZE > 0x10000);

in case that changes in future.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
