From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: do not trigger BUG_ON in
 sctp_cmd_delete_tcb
Date: Thu, 31 Oct 2013 09:42:42 -0400
Message-ID: <20131031134242.GA25894@hmsreliant.think-freely.org>
References: <1383207212-21658-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37488 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab3JaNmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 09:42:51 -0400
Content-Disposition: inline
In-Reply-To: <1383207212-21658-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 31, 2013 at 09:13:32AM +0100, Daniel Borkmann wrote:
> Introduced in f9e42b853523 ("net: sctp: sideeffect: throw BUG if
> primary_path is NULL"), we intended to find a buggy assoc that's
> part of the assoc hash table with a primary_path that is NULL.
> However, we better remove the BUG_ON for now and find a more
> suitable place to assert for these things as Mark reports that
> this also triggers the bug when duplication cookie processing
> happens, and the assoc is not part of the hash table (so all
> good in this case). Such a situation can for example easily be
> reproduced by:
> 
>   tc qdisc add dev eth0 root handle 1: prio bands 2 priomap 1 1 1 1 1 1
>   tc qdisc add dev eth0 parent 1:2 handle 20: netem loss 20%
>   tc filter add dev eth0 protocol ip parent 1: prio 2 u32 match ip \
>             protocol 132 0xff match u8 0x0b 0xff at 32 flowid 1:2
> 
> This drops 20% of COOKIE-ACK packets. After some follow-up
> discussion with Vlad we came to the conclusion that for now we
> should still better remove this BUG_ON() assertion, and come up
> with two follow-ups later on, that is, i) find a more suitable
> place for this assertion, and possibly ii) have a special
> allocator/initializer for such kind of temporary assocs.
> 
> Reported-by: Mark Thomas <Mark.Thomas@metaswitch.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/sm_sideeffect.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 666c668..1a6eef3 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -860,7 +860,6 @@ static void sctp_cmd_delete_tcb(sctp_cmd_seq_t *cmds,
>  	    (!asoc->temp) && (sk->sk_shutdown != SHUTDOWN_MASK))
>  		return;
>  
> -	BUG_ON(asoc->peer.primary_path == NULL);
>  	sctp_unhash_established(asoc);
>  	sctp_association_free(asoc);
>  }
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
