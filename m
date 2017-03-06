From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] udp: avoid ufo handling on IP payload compression packets
Date: Mon, 6 Mar 2017 07:16:57 +0100
Message-ID: <20170306061657.GY694@gauss.secunet.com>
References: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>,
        "David Miller" <davem@davemloft.net>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34820 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750982AbdCFG1R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 01:27:17 -0500
Content-Disposition: inline
In-Reply-To: <1488544652-28475-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 03, 2017 at 03:37:32PM +0300, Alexey Kodanev wrote:
> commit c146066ab802 ("ipv4: Don't use ufo handling on later transformed
> packets") and commit f89c56ce710a ("ipv6: Don't use ufo handling on
> later transformed packets") added a check that 'rt->dst.header_len' isn't
> zero in order to skip UFO, but it doesn't include IPcomp in transport mode
> where it equals zero.

IPcomp has an additional header and should better set rt->dst.header_len
instead of hacking around that internally.

> 
> Packets, after payload compression, may not require further fragmentation,
> and if original length exceeds MTU, later compressed packets will be
> transmitted incorrectly. This can be reproduced with LTP udp_ipsec.sh test
> on veth device with enabled UFO, MTU is 1500 and UDP payload is 2000:
> 
> * IPv4 case, offset is wrong + unnecessary fragmentation
>     udp_ipsec.sh -p comp -m transport -s 2000 &
>     tcpdump -ni ltp_ns_veth2
>     ...
>     IP (tos 0x0, ttl 64, id 45203, offset 0, flags [+],
>       proto Compressed IP (108), length 49)
>       10.0.0.2 > 10.0.0.1: IPComp(cpi=0x1000)
>     IP (tos 0x0, ttl 64, id 45203, offset 1480, flags [none],
>       proto UDP (17), length 21) 10.0.0.2 > 10.0.0.1: ip-proto-17
> 
> * IPv6 case, sending small fragments
>     udp_ipsec.sh -6 -p comp -m transport -s 2000 &
>     tcpdump -ni ltp_ns_veth2
>     ...
>     IP6 (flowlabel 0x6b9ba, hlim 64, next-header Compressed IP (108)
>       payload length: 37) fd00::2 > fd00::1: IPComp(cpi=0x1000)
>     IP6 (flowlabel 0x6b9ba, hlim 64, next-header Compressed IP (108)
>       payload length: 21) fd00::2 > fd00::1: IPComp(cpi=0x1000)
> 
> Fix it by checking 'rt->dst.xfrm' pointer to 'xfrm_state' struct, skip UFO
> if xfrm is set. So the new check will include both cases: IPcomp and IPsec.
> 
> Fixes: c146066ab802 ("ipv4: Don't use ufo handling on later transformed packets")
> Fixes: f89c56ce710a ("ipv6: Don't use ufo handling on later transformed packets")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
>  net/ipv4/ip_output.c  |    5 ++++-
>  net/ipv6/ip6_output.c |    5 ++++-
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index b67719f..18383ef 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -960,7 +960,10 @@ static int __ip_append_data(struct sock *sk,
>  	cork->length += length;
>  	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
> -	    (rt->dst.dev->features & NETIF_F_UFO) && !rt->dst.header_len &&
> +	    (rt->dst.dev->features & NETIF_F_UFO) &&
> +#ifdef CONFIG_XFRM
> +	    !rt->dst.xfrm &&
> +#endif

Please fix IPcomp to use rt->dst.header_len instead off adding
this ifdef to the generic networking code.
