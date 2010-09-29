From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] bonding: fix to rejoin multicast groups immediately
Date: Wed, 29 Sep 2010 10:16:19 -0300
Message-ID: <20100929131619.GA2857@redhat.com>
References: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755484Ab0I2NQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 09:16:33 -0400
Content-Disposition: inline
In-Reply-To: <1285744327-1194-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


forgot CC to bonding-devel@lists.sourceforge.net

On Wed, Sep 29, 2010 at 04:12:07AM -0300, Flavio Leitner wrote:
> It should rejoin multicast groups immediately when
> the failover happens to restore the multicast traffic.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
> ---
>  net/ipv4/igmp.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 1fdcacd..b81d674 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -1257,14 +1257,14 @@ void ip_mc_rejoin_group(struct ip_mc_list *im)
>  	if (im->multiaddr == IGMP_ALL_HOSTS)
>  		return;
>  
> -	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
> -		igmp_mod_timer(im, IGMP_Initial_Report_Delay);
> -		return;
> -	}
> -	/* else, v3 */
> -	im->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
> -		IGMP_Unsolicited_Report_Count;
> -	igmp_ifc_event(in_dev);
> +	/* a failover is happening and switches
> +	 * must be notified immediately */
> +	if (IGMP_V1_SEEN(in_dev))
> +		igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
> +	else if (IGMP_V2_SEEN(in_dev))
> +		igmp_send_report(in_dev, im, IGMPV2_HOST_MEMBERSHIP_REPORT);
> +	else
> +		igmp_send_report(in_dev, im, IGMPV3_HOST_MEMBERSHIP_REPORT);
>  #endif
>  }
>  EXPORT_SYMBOL(ip_mc_rejoin_group);
> -- 
> 1.7.2.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Flavio
