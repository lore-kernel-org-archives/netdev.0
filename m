From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Mon, 08 Dec 2014 17:56:20 +0100
Message-ID: <1418057780.29477.12.camel@localhost>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38993 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751520AbaLHQ4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:56:22 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 4C99B20B8D
	for <netdev@vger.kernel.org>; Mon,  8 Dec 2014 11:56:22 -0500 (EST)
In-Reply-To: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2014-12-08 at 17:30 +0100, Daniel Borkmann wrote:
> For netlink, we shouldn't be using arch_fast_hash() as a hashing
> discipline, but rather jhash() instead.
> 
> Since netlink sockets can be opened by any user, a local attacker
> would be able to easily create collisions with the DPDK-derived
> arch_fast_hash(), which trades off performance for security by
> using crc32 CPU instructions on x86_64.
> 
> While it might have a legimite use case in other places, it should
> be avoided in netlink context, though. As rhashtable's API is very
> flexible, we could later on still decide on other hashing disciplines,
> if legitimate.
> 
> Reference: http://thread.gmane.org/gmane.linux.kernel/1844123
> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/netlink/af_netlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 0007b81..b6bf8e8 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -3130,7 +3130,7 @@ static int __init netlink_proto_init(void)
>  		.head_offset = offsetof(struct netlink_sock, node),
>  		.key_offset = offsetof(struct netlink_sock, portid),
>  		.key_len = sizeof(u32), /* portid */
> -		.hashfn = arch_fast_hash,
> +		.hashfn = jhash,
>  		.max_shift = 16, /* 64K */
>  		.grow_decision = rht_grow_above_75,
>  		.shrink_decision = rht_shrink_below_30,

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

In net-next, some time soon, we should try to let all function pointers
to jhash() use one non-inline version. The other arch_fast_hash patch
adds __jhash for x86-only, we can move it over to lib/.

Thanks,
Hannes
