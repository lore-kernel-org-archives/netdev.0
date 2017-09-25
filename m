From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net v2] sctp: Fix a big endian bug in sctp_diag_dump()
Date: Mon, 25 Sep 2017 07:23:00 -0400
Message-ID: <20170925112259.GB3425@hmswarspite.think-freely.org>
References: <CADvbK_dCT6Z6JwD+VtjNg6UUkQneU2OLeme9JVqrXjnJJ63cGg@mail.gmail.com>
 <20170925101926.db4f6x4hblh7tcvo@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34141 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933200AbdIYLXP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 07:23:15 -0400
Content-Disposition: inline
In-Reply-To: <20170925101926.db4f6x4hblh7tcvo@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 01:19:26PM +0300, Dan Carpenter wrote:
> The sctp_for_each_transport() function takes an pointer to int.  The
> cb->args[] array holds longs so it's only using the high 32 bits.  It
> works on little endian system but will break on big endian 64 bit
> machines.
> 
> Fixes: d25adbeb0cdb ("sctp: fix an use-after-free issue in sctp_sock_dump")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: The v1 patch changed the function to take a long pointer, but v2
>     just changes the caller.
> 
> diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
> index 22ed01a76b19..a72a7d925d46 100644
> --- a/net/sctp/sctp_diag.c
> +++ b/net/sctp/sctp_diag.c
> @@ -463,6 +463,7 @@ static void sctp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  		.r = r,
>  		.net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN),
>  	};
> +	int pos = cb->args[2];
>  
>  	/* eps hashtable dumps
>  	 * args:
> @@ -493,7 +494,8 @@ static void sctp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
>  		goto done;
>  
>  	sctp_for_each_transport(sctp_sock_filter, sctp_sock_dump,
> -				net, (int *)&cb->args[2], &commp);
> +				net, &pos, &commp);
> +	cb->args[2] = pos;
>  
>  done:
>  	cb->args[1] = cb->args[4];
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
