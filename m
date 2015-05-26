From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 1/3] net: Add cache alignment in sock_common
 for socket lookup fields
Date: Tue, 26 May 2015 10:19:18 -0700
Message-ID: <1432660758.4060.276.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	 <1432658049-3400132-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:33767 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbbEZRTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 13:19:20 -0400
Received: by pdbqa5 with SMTP id qa5so95332291pdb.0
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 10:19:20 -0700 (PDT)
In-Reply-To: <1432658049-3400132-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 09:34 -0700, Tom Herbert wrote:
> Use ____cacheline_aligned_in_smp to keep the fields used on socket
> lookup in their own cachelines. These are read only fields and will
> be often accessed on accross CPUs (would be very common with
> SO_REUSEPORT for instance).
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/net/sock.h | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 26c1c31..bcf6114 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -211,7 +211,13 @@ struct sock_common {
>  		struct hlist_node	skc_node;
>  		struct hlist_nulls_node skc_nulls_node;
>  	};
> -	int			skc_tx_queue_mapping;
> +
> +	/* Cachelines above this point are read mostly and are used in socket
> +	 * lookup.
> +	 */
> +	int			skc_tx_queue_mapping
> +				____cacheline_aligned_in_smp;
> +
>  	atomic_t		skc_refcnt;
>  	/* private: */
>  	int                     skc_dontcopy_end[0];

No, we do not want to increase the size of sock_common with such a
hammer.

I am pretty sure you never tested this patch, since you placed the
attribute at the wrong place anyway.
