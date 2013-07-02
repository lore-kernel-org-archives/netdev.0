From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC ] netlink: limit large vmalloc() based skbs to
 NETLINK_NETFILTER
Date: Tue, 02 Jul 2013 15:07:14 -0700
Message-ID: <1372802834.4979.27.camel@edumazet-glaptop>
References: <20130702215015.GA1979@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43616 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930Ab3GBWHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 18:07:16 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp12so6743477pab.21
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 15:07:15 -0700 (PDT)
In-Reply-To: <20130702215015.GA1979@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-02 at 23:50 +0200, Sebastian Andrzej Siewior wrote:
> Since commit c05cdb1b ("netlink: allow large data transfers from
> user-space") the large skbs are allocated via vmalloc(). Trinity
> triggered this in response:
> 
> | BUG: unable to handle kernel paging request at ffffc900001bf001
> | IP: [<ffffffff8135270a>] skb_clone+0x1a/0xa0
> | Call Trace:
> |  [<ffffffff813cb107>] nl_fib_input+0x37/0x230
> |  [<ffffffff8142c9b2>] ? _raw_read_unlock+0x22/0x40
> |  [<ffffffff81380b1a>] netlink_unicast+0x13a/0x1f0
> |  [<ffffffff81380ef7>] netlink_sendmsg+0x327/0x420
> 
> The problem is that the vmalloc() based skb ends exactly at size (where
> ->end is pointing) and skb_shinfo() starts past ->end where we have our
> guard page and hence we BUG().
> The question is should we fix this or forbid the skb_clone(). Fixing this
> behaviour is tricky because even after we add space for struct
> skb_shared_info we release the memory from the destructor so once the
> first skbs is gone, the memory in the clone is invalid.
> The other case where skb_clone() is used is when we have mutltiple
> destinations.
> Since I assume the initial target was to extend the size for
> NETLINK_NETFILTER this patch limits to this target only and with single
> destination.
> Is this okay?
> 
> Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
> ---
>  net/netlink/af_netlink.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 68c1673..9926453 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -2129,7 +2129,11 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
>  	if (len > sk->sk_sndbuf - 32)
>  		goto out;
>  	err = -ENOBUFS;
> -	skb = netlink_alloc_large_skb(len);
> +	if (netlink_is_kernel(sk) && sk->sk_protocol == NETLINK_NETFILTER &&
> +			!dst_group)
> +		skb = netlink_alloc_large_skb(len);
> +	else
> +		skb = alloc_skb(len, GFP_KERNEL);
>  	if (skb == NULL)
>  		goto out;
>  


I believe you came too late, this was hopefully fixed here after some
discussion last week : 

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=3a36515f729458c8efa0c124c7262d5843ad5c37
