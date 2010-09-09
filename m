From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Alternative PATCH net-next] sctp: fix test for end of loop
Date: Thu, 09 Sep 2010 09:57:31 -0400
Message-ID: <4C88E7CB.7060804@hp.com>
References: <20100906122344.GA2764@bicker>	 <20100908.132420.179918700.davem@davemloft.net> <4C87F366.3070002@hp.com>	 <20100908.133747.232732909.davem@davemloft.net> <1283979861.2479.21.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, error27@gmail.com,
	sri@us.ibm.com, yjwei@cn.fujitsu.com, cascardo@holoscopio.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:30960 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751259Ab0IIN5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 09:57:38 -0400
In-Reply-To: <1283979861.2479.21.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2010 05:04 PM, Joe Perches wrote:
> Perhaps something like this is clearer?
> 
> Add a list_has_sctp_addr function to simplify loop
> 
> Based on a patches by Dan Carpenter and David Miller
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Thanks Joe

I like this.  Nice and clean. :)

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

> ---
>  net/sctp/sm_statefuns.c |   46 +++++++++++++++++++++++-----------------------
>  1 files changed, 23 insertions(+), 23 deletions(-)
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 8b28443..4b4eb7c 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -1232,6 +1232,18 @@ out:
>  	return 0;
>  }
>  
> +static bool list_has_sctp_addr(const struct list_head *list,
> +			       union sctp_addr *ipaddr)
> +{
> +	struct sctp_transport *addr;
> +
> +	list_for_each_entry(addr, list, transports) {
> +		if (sctp_cmp_addr_exact(ipaddr, &addr->ipaddr))
> +			return true;
> +	}
> +
> +	return false;
> +}
>  /* A restart is occurring, check to make sure no new addresses
>   * are being added as we may be under a takeover attack.
>   */
> @@ -1240,10 +1252,10 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  				       struct sctp_chunk *init,
>  				       sctp_cmd_seq_t *commands)
>  {
> -	struct sctp_transport *new_addr, *addr;
> -	int found;
> +	struct sctp_transport *new_addr;
> +	int ret = 1;
>  
> -	/* Implementor's Guide - Sectin 5.2.2
> +	/* Implementor's Guide - Section 5.2.2
>  	 * ...
>  	 * Before responding the endpoint MUST check to see if the
>  	 * unexpected INIT adds new addresses to the association. If new
> @@ -1254,31 +1266,19 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  	/* Search through all current addresses and make sure
>  	 * we aren't adding any new ones.
>  	 */
> -	new_addr = NULL;
> -	found = 0;
> -
>  	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
> -			transports) {
> -		found = 0;
> -		list_for_each_entry(addr, &asoc->peer.transport_addr_list,
> -				transports) {
> -			if (sctp_cmp_addr_exact(&new_addr->ipaddr,
> -						&addr->ipaddr)) {
> -				found = 1;
> -				break;
> -			}
> -		}
> -		if (!found)
> +			    transports) {
> +		if (!list_has_sctp_addr(&asoc->peer.transport_addr_list,
> +					&new_addr->ipaddr)) {
> +			sctp_sf_send_restart_abort(&new_addr->ipaddr, init,
> +						   commands);
> +			ret = 0;
>  			break;
> -	}
> -
> -	/* If a new address was added, ABORT the sender. */
> -	if (!found && new_addr) {
> -		sctp_sf_send_restart_abort(&new_addr->ipaddr, init, commands);
> +		}
>  	}
>  
>  	/* Return success if all addresses were found. */
> -	return found;
> +	return ret;
>  }
>  
>  /* Populate the verification/tie tags based on overlapping INIT
> 
> 

