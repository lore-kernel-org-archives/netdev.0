From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] net: sctp: sctp_v6_get_dst: fix boolean test in dst
 cache
Date: Wed, 13 Feb 2013 07:02:45 -0500
Message-ID: <20130213120245.GA26539@hmsreliant.think-freely.org>
References: <cover.1360709645.git.dborkman@redhat.com>
 <4a07201201d7bac08468d17dea3dbc1ea9a67205.1360709645.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33863 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab3BMMC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 07:02:56 -0500
Content-Disposition: inline
In-Reply-To: <4a07201201d7bac08468d17dea3dbc1ea9a67205.1360709645.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 13, 2013 at 12:30:16AM +0100, Daniel Borkmann wrote:
> We walk through the bind address list and try to get the best source
> address for a given destination. However, currently, we take the
> 'continue' path of the loop when an entry is invalid (!laddr->valid)
> *and* the entry state does not equal SCTP_ADDR_SRC (laddr->state !=
> SCTP_ADDR_SRC).
> 
> Thus, still, invalid entries with SCTP_ADDR_SRC might not 'continue'
> as well as valid entries with SCTP_ADDR_{NEW, SRC, DEL}, with a possible
> false baddr and matchlen as a result, causing in worst case dst route
> to be false or possibly NULL.
> 
> This test should actually be a '||' instead of '&&'. But lets fix it
> and make this a bit easier to read by having the condition the same way
> as similarly done in sctp_v4_get_dst.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/ipv6.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index f3f0f4d..391a245 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -326,9 +326,10 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>  	 */
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -		if (!laddr->valid && laddr->state != SCTP_ADDR_SRC)
> +		if (!laddr->valid)
>  			continue;
> -		if ((laddr->a.sa.sa_family == AF_INET6) &&
> +		if ((laddr->state == SCTP_ADDR_SRC) &&
> +		    (laddr->a.sa.sa_family == AF_INET6) &&
>  		    (scope <= sctp_scope(&laddr->a))) {
>  			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
>  			if (!baddr || (matchlen < bmatchlen)) {
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
