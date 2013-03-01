From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: correct dropwatch false positive in
 ip_local_deliver_finish
Date: Fri, 01 Mar 2013 08:37:25 -0800
Message-ID: <1362155845.15793.55.camel@edumazet-glaptop>
References: <1362154680-4331-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	William Reich <reich@ulticom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:49761 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3CAQh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 11:37:28 -0500
Received: by mail-da0-f45.google.com with SMTP id v40so1472648dad.32
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 08:37:28 -0800 (PST)
In-Reply-To: <1362154680-4331-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-01 at 11:18 -0500, Neil Horman wrote:
> I had a report recently of a user trying to use dropwatch to localise some frame
> loss, and they were getting false positives.  Turned out they were using a user
> space SCTP stack that used raw sockets to grab frames.  When we don't have a
> registered protocol for a given packet, we record it as a drop, even if a raw
> socket receieves the frame.  We should only record the drop in the event a raw
> socket doesnt exist to receive the frames
> 
> Tested by the reported successfully
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: William Reich <reich@ulticom.com>
> Tested-by: William Reich <reich@ulticom.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: William Reich <reich@ulticom.com>
> ---
>  net/ipv4/ip_input.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index 87abd3e..2bdf802 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -228,9 +228,11 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
>  					icmp_send(skb, ICMP_DEST_UNREACH,
>  						  ICMP_PROT_UNREACH, 0);
>  				}
> -			} else
> +				kfree_skb(skb);
> +			} else {
>  				IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
> -			kfree_skb(skb);
> +				consume_skb(skb);
> +			}
>  		}
>  	}
>   out:

Acked-by: Eric Dumazet <edumazet@google.com>
