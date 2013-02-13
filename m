From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net] net: sctp: sctp_v6_get_dst: fix boolean test in dst
 cache
Date: Tue, 12 Feb 2013 20:13:08 -0500
Message-ID: <511AE8A4.4060608@gmail.com>
References: <cover.1360709645.git.dborkman@redhat.com> <4a07201201d7bac08468d17dea3dbc1ea9a67205.1360709645.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:43385 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304Ab3BMBNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 20:13:12 -0500
In-Reply-To: <4a07201201d7bac08468d17dea3dbc1ea9a67205.1360709645.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 06:30 PM, Daniel Borkmann wrote:
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

It uses || everywhere else except this one case.  I don't know what I 
was thinking when I wrote that one.... :)

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

> ---
>   net/sctp/ipv6.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index f3f0f4d..391a245 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -326,9 +326,10 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
>   	 */
>   	rcu_read_lock();
>   	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
> -		if (!laddr->valid && laddr->state != SCTP_ADDR_SRC)
> +		if (!laddr->valid)
>   			continue;
> -		if ((laddr->a.sa.sa_family == AF_INET6) &&
> +		if ((laddr->state == SCTP_ADDR_SRC) &&
> +		    (laddr->a.sa.sa_family == AF_INET6) &&
>   		    (scope <= sctp_scope(&laddr->a))) {
>   			bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
>   			if (!baddr || (matchlen < bmatchlen)) {
>
