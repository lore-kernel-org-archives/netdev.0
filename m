From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: potential read out of bounds in
 sctp_ulpevent_type_enabled()
Date: Wed, 13 Sep 2017 10:28:55 -0400
Message-ID: <20170913142855.GA4320@hmswarspite.think-freely.org>
References: <20170913092028.idzvduj7ran4li6b@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58845 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdIMO3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 10:29:16 -0400
Content-Disposition: inline
In-Reply-To: <20170913092028.idzvduj7ran4li6b@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 13, 2017 at 12:20:28PM +0300, Dan Carpenter wrote:
> This code causes a static checker warning because Smatch doesn't trust
> anything that comes from skb->data.  I've reviewed this code and I do
> think skb->data can be controlled by the user here.
> 
> The sctp_event_subscribe struct has 13 __u8 fields and we want to see
> if ours is non-zero.  sn_type can be any value in the 0-USHRT_MAX range.
> We're subtracting SCTP_SN_TYPE_BASE which is 1 << 15 so we could read
> either before the start of the struct or after the end.
> 
> This is a very old bug and it's surprising that it would go undetected
> for so long but my theory is that it just doesn't have a big impact so
> it would be hard to notice.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I'm not terribly familiar with sctp and this is a static checker fix.
> Please review it carefully.
> 
> diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
> index 1060494ac230..e6873176bea7 100644
> --- a/include/net/sctp/ulpevent.h
> +++ b/include/net/sctp/ulpevent.h
> @@ -154,7 +154,11 @@ static inline int sctp_ulpevent_type_enabled(__u16 sn_type,
>  					     struct sctp_event_subscribe *mask)
>  {
>  	char *amask = (char *) mask;
> -	return amask[sn_type - SCTP_SN_TYPE_BASE];
> +	int offset = sn_type - SCTP_SN_TYPE_BASE;
> +
> +	if (offset >= sizeof(struct sctp_event_subscribe))
> +		return 0;
> +	return amask[offset];
>  }
Acked-by: Neil Horman <nhorman@tuxdriver.com>

>  
>  /* Given an event subscription, is this event enabled? */
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
