From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Wed, 08 Sep 2010 16:34:46 -0400
Message-ID: <4C87F366.3070002@hp.com>
References: <20100906122344.GA2764@bicker> <20100908.132420.179918700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, sri@us.ibm.com, yjwei@cn.fujitsu.com,
	cascardo@holoscopio.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:43055 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754979Ab0IHUex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:34:53 -0400
In-Reply-To: <20100908.132420.179918700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2010 04:24 PM, David Miller wrote:
> From: Dan Carpenter <error27@gmail.com>
> Date: Mon, 6 Sep 2010 14:26:39 +0200
> 
>> "new_addr" is the list cursor here and it's always non-NULL.
>>
>> We're trying to test if we exited because the loop ended or we hit the
>> break statement.  Really testing !found is enough so long as 
>> "new_asoc->peer.transport_addr_list" is not empty and I believe it never
>> is empty at this point.  So this is never really a bug with the current
>> code.
>>
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> If you don't mind, I still think the code is confusing after your
> patch even if the result is correct.
> 
> What do you think about the following kind of approach instead?
> 
> Thanks!
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 8b28443..3d5bbae7 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -1241,7 +1241,7 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  				       sctp_cmd_seq_t *commands)
>  {
>  	struct sctp_transport *new_addr, *addr;
> -	int found;
> +	int ret = 1;
>  
>  	/* Implementor's Guide - Sectin 5.2.2
>  	 * ...
> @@ -1254,31 +1254,28 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  	/* Search through all current addresses and make sure
>  	 * we aren't adding any new ones.
>  	 */
> -	new_addr = NULL;
> -	found = 0;
> -
>  	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
>  			transports) {
> -		found = 0;
>  		list_for_each_entry(addr, &asoc->peer.transport_addr_list,
>  				transports) {
>  			if (sctp_cmp_addr_exact(&new_addr->ipaddr,
> -						&addr->ipaddr)) {
> -				found = 1;
> -				break;
> -			}
> +						&addr->ipaddr))
> +				goto next;
>  		}
> -		if (!found)
> -			break;
> -	}
>  
> -	/* If a new address was added, ABORT the sender. */
> -	if (!found && new_addr) {
> +		/* 'new_addr' could not be found in the transport address
> +		 * list of 'asoc', abort.
> +		 */
>  		sctp_sf_send_restart_abort(&new_addr->ipaddr, init, commands);
> +		ret = 0;
> +		break;
> +
> +	next:
> +		;
>  	}
>  

This would certainly make things clearer as well.  It essentially does what I suggested
(moving the abort into the loop once we know we have a new address) and clean up all
the 'found' mess at the same time.

The empty goto tag would give my old profs an apoplexy though. :)

I would ack this.

-vlad
>  	/* Return success if all addresses were found. */
> -	return found;
> +	return ret;
>  }
>  
>  /* Populate the verification/tie tags based on overlapping INIT
> 

