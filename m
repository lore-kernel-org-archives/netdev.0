From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2] be2net: log link status
Date: Wed, 22 Apr 2015 07:07:54 -0700
Message-ID: <1429711674.32612.8.camel@perches.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0179.hostedemail.com ([216.40.44.179]:33907 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932942AbbDVOH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 10:07:57 -0400
In-Reply-To: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-22 at 15:43 +0200, Ivan Vecera wrote:
> The driver unlike other drivers does not log link state changes.

Why add all the speed stuff, why not add a query instead?

I think it'd be simpler to add a line like:
	status = be_cmd_link_status_query(adapter, &speed, &status, 0);
before emitting speed/link_status

Question for the emulex folk:

Is the dom argument to link_status_query necessary?
It's currently always 0.

and trivially:

> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
[]
> @@ -649,7 +649,8 @@ static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
>  	return stats;
>  }
>  
> -void be_link_status_update(struct be_adapter *adapter, u8 link_status)
> +void be_link_status_update(struct be_adapter *adapter, u8 link_status,
> +			   u16 speed)
>  {
>  	struct net_device *netdev = adapter->netdev;
>  
> @@ -658,10 +659,18 @@ void be_link_status_update(struct be_adapter *adapter, u8 link_status)
>  		adapter->flags |= BE_FLAGS_LINK_STATUS_INIT;
>  	}
>  
> -	if (link_status)
> +	if (link_status) {
> +		if (speed)
> +			/* Print speed only when it is known */
> +			netdev_info(netdev, "Link is Up at %d Mbps\n", speed);

signed/unsigned mismatch. %u, speed
