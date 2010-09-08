From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Wed, 08 Sep 2010 16:26:45 -0400
Message-ID: <4C87F185.3070402@hp.com>
References: <20100906122344.GA2764@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:39013 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab0IHU0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:26:51 -0400
In-Reply-To: <20100906122344.GA2764@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2010 08:26 AM, Dan Carpenter wrote:
> "new_addr" is the list cursor here and it's always non-NULL.
> 
> We're trying to test if we exited because the loop ended or we hit the
> break statement.  Really testing !found is enough so long as 
> "new_asoc->peer.transport_addr_list" is not empty and I believe it never
> is empty at this point.  So this is never really a bug with the current
> code.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> Compile tested only.
> 
> diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> index 24b2cd5..cb76d2e 100644
> --- a/net/sctp/sm_statefuns.c
> +++ b/net/sctp/sm_statefuns.c
> @@ -1254,7 +1254,6 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  	/* Search through all current addresses and make sure
>  	 * we aren't adding any new ones.
>  	 */
> -	new_addr = NULL;
>  	found = 0;
>  
>  	list_for_each_entry(new_addr, &new_asoc->peer.transport_addr_list,
> @@ -1273,7 +1272,8 @@ static int sctp_sf_check_restart_addrs(const struct sctp_association *new_asoc,
>  	}
>  
>  	/* If a new address was added, ABORT the sender. */
> -	if (!found && new_addr) {
> +	if (!found &&
> +	    &new_addr->transports != &new_asoc->peer.transport_addr_list) {

I am really not fond of this code.  I think it would be better to move
this abort code into the loop and break out once things are aborted.

This way we can get rid of the whole found check after the outer loop happens
and it cleans things up nicely.

-vlad

>  		sctp_sf_send_restart_abort(&new_addr->ipaddr, init, commands);
>  	}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

