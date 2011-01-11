From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] xen: netfront: Drop GSO SKBs which do not have
 csum_blank.
Date: Tue, 11 Jan 2011 11:46:08 +0000
Message-ID: <1294746368.3831.5817.camel@zakaz.uk.xensource.com>
References: <1294233811-28123-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:13641 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534Ab1AKLrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 06:47:07 -0500
In-Reply-To: <1294233811-28123-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

http://patchwork.ozlabs.org/patch/77593/ tells me this patch is "Not
Applicable". Is this scenario not worth worrying about for some reason?

The error would be due to a buggy peer (i.e. netback) so I guess this
frontend fix is really just a belt-and-braces thing.

However The equivalent netback patch (which is not upstream yet but I'm
working on cleaning it up for a first post soon) is more critical since
it could allow a malicious guest to spam the domain 0 syslog (via the
WARN_ON in skb_gso_segment) so I just wanted to check if I was also
missing some reason why the netback patch would be non-applicable too.

Thanks,
Ian.

On Wed, 2011-01-05 at 13:23 +0000, Ian Campbell wrote:
> The Linux network stack expects all GSO SKBs to have ip_summed ==
> CHECKSUM_PARTIAL (which implies that the frame contains a partial
> checksum) and the Xen network ring protocol similarly expects an SKB
> which has GSO set to also have NETRX_csum_blank (which also implies a
> partial checksum). Therefore drop such frames on receive otherwise
> they will trigger the warning in skb_gso_segment.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: xen-devel@lists.xensource.com
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/xen-netfront.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index cdbeec9..8b8c480 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -836,6 +836,11 @@ static int handle_incoming_queue(struct net_device *dev,
>  				dev->stats.rx_errors++;
>  				continue;
>  			}
> +		} else if (skb_is_gso(skb)) {
> +			kfree_skb(skb);
> +			packets_dropped++;
> +			dev->stats.rx_errors++;
> +			continue;
>  		}
>  
>  		dev->stats.rx_packets++;


