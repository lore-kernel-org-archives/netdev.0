From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: avoid list_del_init if it's freeing the
 memory right away
Date: Tue, 07 Feb 2017 14:21:21 -0500 (EST)
Message-ID: <20170207.142121.1027174926882132252.davem@davemloft.net>
References: <e1b3b9b24f39ee82a3131a39a0413231ba54bc7c.1486494022.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        vyasevich@gmail.com, nhorman@tuxdriver.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754912AbdBGTWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:22:13 -0500
In-Reply-To: <e1b3b9b24f39ee82a3131a39a0413231ba54bc7c.1486494022.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Tue,  7 Feb 2017 17:03:21 -0200

> There is no reason to use list_del_init() in these places as we are
> going to free/destroy the memory in a few lines below.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
>  net/sctp/associola.c     | 14 ++++----------
>  net/sctp/auth.c          |  8 ++------
>  net/sctp/chunk.c         |  4 ++--
>  net/sctp/outqueue.c      | 14 +++++++-------
>  net/sctp/sm_make_chunk.c |  3 +--
>  5 files changed, 16 insertions(+), 27 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index e50dc6d7543fd6acfa7442f3a9ee575203c7718d..7eb9dacfa53a438b20a34319cf01c6c9a591f0c3 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1638,25 +1638,19 @@ int sctp_assoc_set_id(struct sctp_association *asoc, gfp_t gfp)
>  static void sctp_assoc_free_asconf_queue(struct sctp_association *asoc)
>  {
>  	struct sctp_chunk *asconf;
> -	struct sctp_chunk *tmp;
>  
> -	list_for_each_entry_safe(asconf, tmp, &asoc->addip_chunk_list, list) {
> -		list_del_init(&asconf->list);
> +	list_for_each_entry(asconf, &asoc->addip_chunk_list, list)
>  		sctp_chunk_free(asconf);
> -	}
>  }

This leave freed memory on the asoc->addip_chunk_list, in fact why aren't you seeing
the BUG_ON() in sctp_chunk_destroy() get triggered?  If you elide the list_del() here
then the "list_empty(&chunk->list)" check there will not be true.

I don't think this transformation here is legal at all.
