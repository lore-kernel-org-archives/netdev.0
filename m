From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: call rcu_read_lock before checking for
 duplicate transport nodes
Date: Tue, 28 Feb 2017 09:23:23 -0500
Message-ID: <20170228142323.GA17171@hmswarspite.think-freely.org>
References: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51280 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751452AbdB1OY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 09:24:28 -0500
Content-Disposition: inline
In-Reply-To: <d239fb1c1f86e3421de4a891f8a704d37b236cbf.1488256889.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2017 at 12:41:29PM +0800, Xin Long wrote:
> Commit cd2b70875058 ("sctp: check duplicate node before inserting a
> new transport") called rhltable_lookup() to check for the duplicate
> transport node in transport rhashtable.
> 
> But rhltable_lookup() doesn't call rcu_read_lock inside, it could cause
> a use-after-free issue if it tries to dereference the node that another
> cpu has freed it. Note that sock lock can not avoid this as it is per
> sock.
> 
> This patch is to fix it by calling rcu_read_lock before checking for
> duplicate transport nodes.
> 
> Fixes: cd2b70875058 ("sctp: check duplicate node before inserting a new transport")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/input.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index fc45896..2a28ab2 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -884,14 +884,17 @@ int sctp_hash_transport(struct sctp_transport *t)
>  	arg.paddr = &t->ipaddr;
>  	arg.lport = htons(t->asoc->base.bind_addr.port);
>  
> +	rcu_read_lock();
>  	list = rhltable_lookup(&sctp_transport_hashtable, &arg,
>  			       sctp_hash_params);
>  
>  	rhl_for_each_entry_rcu(transport, tmp, list, node)
>  		if (transport->asoc->ep == t->asoc->ep) {
> +			rcu_read_unlock();
>  			err = -EEXIST;
>  			goto out;
>  		}
> +	rcu_read_unlock();
>  
>  	err = rhltable_insert_key(&sctp_transport_hashtable, &arg,
>  				  &t->node, sctp_hash_params);
> -- 
> 2.1.0
> 
> 

Hmm, rhltable_insert_key I think returns a pointer to the existing object in the
hash table if there is a collision (according to the _rhashtable_insert_fast
description).  Wouldn't it be better to eliminate the rhl_for_each_entry_rcu
entirely, and just check the returned pointer from rhltable_insert_key?

Neil
