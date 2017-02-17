From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: check duplicate node before inserting a new
 transport
Date: Fri, 17 Feb 2017 06:19:02 -0500
Message-ID: <20170217111902.GA4256@hmswarspite.think-freely.org>
References: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36181 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755308AbdBQLUI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 06:20:08 -0500
Content-Disposition: inline
In-Reply-To: <ba2afff1b2cf9e0026a23dde02d207583efa3d83.1487320524.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 04:35:24PM +0800, Xin Long wrote:
> sctp has changed to use rhlist for transport rhashtable since commit
> 7fda702f9315 ("sctp: use new rhlist interface on sctp transport
> rhashtable").
> 
> But rhltable_insert_key doesn't check the duplicate node when inserting
> a node, unlike rhashtable_lookup_insert_key. It may cause duplicate
> assoc/transport in rhashtable. like:
> 
>  client (addr A, B)                 server (addr X, Y)
>     connect to X           INIT (1)
>                         ------------>
>     connect to Y           INIT (2)
>                         ------------>
>                          INIT_ACK (1)
>                         <------------
>                          INIT_ACK (2)
>                         <------------
> 
> After sending INIT (2), one transport will be created and hashed into
> rhashtable. But when receiving INIT_ACK (1) and processing the address
> params, another transport will be created and hashed into rhashtable
> with the same addr Y and EP as the last transport. This will confuse
> the assoc/transport's lookup.
> 
> This patch is to fix it by returning err if any duplicate node exists
> before inserting it.
> 
> Fixes: 7fda702f9315 ("sctp: use new rhlist interface on sctp transport rhashtable")
> Reported-by: Fabio M. Di Nitto <fdinitto@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/input.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 458e506..f65245b 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -872,6 +872,8 @@ void sctp_transport_hashtable_destroy(void)
>  
>  int sctp_hash_transport(struct sctp_transport *t)
>  {
> +	struct sctp_transport *transport;
> +	struct rhlist_head *tmp, *list;
>  	struct sctp_hash_cmp_arg arg;
>  	int err;
>  
> @@ -882,8 +884,19 @@ int sctp_hash_transport(struct sctp_transport *t)
>  	arg.paddr = &t->ipaddr;
>  	arg.lport = htons(t->asoc->base.bind_addr.port);
>  
> +	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
> +			       sctp_hash_params);
> +
> +	rhl_for_each_entry_rcu(transport, tmp, list, node)
> +		if (transport->asoc->ep == t->asoc->ep) {
> +			err = -EEXIST;
> +			goto out;
> +		}
> +
Maybe its just a little early, but I'm rather lost as to how this works.  When
you insert a key to the rhltable, its a sctp_hash_cmp_arg that gets inserted,
which is a struct that consists of a sctp_addr union, a struct net, and a u16,
but when you traverse the list for lookup, you treat the returned list as a list
of sctp_transport structs that you compare.  That seems very wrong.

Neil

>  	err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
>  				  &t->node, sctp_hash_params);
> +
> +out:
>  	if (err)
>  		pr_err_once("insert transport fail, errno %d\n", err);
>  
> -- 
> 2.1.0
> 
> 
