From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 16:25:25 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
 <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: 'Or Gerlitz' <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43359 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759604AbaJ3Q15 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:27:57 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12133-01 for <netdev@vger.kernel.org>;
 Thu, 30 Oct 2014 16:27:44 +0000 (GMT)
In-Reply-To: <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz
> From: Shani Michaeli <shanim@mellanox.com>
> 
> Compute IPV6 pseudo header checksum without folding it to a 16 bit
> return value.
> 
> Signed-off-by: Shani Michaeli <shanim@mellanox.com>
> Signed-off-by: Matan Barak <matanb@mellanox.com>
> ---
>  include/net/ip6_checksum.h |   21 +++++++++++++++++++++
>  1 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
> index 1a49b73..c45d690 100644
> --- a/include/net/ip6_checksum.h
> +++ b/include/net/ip6_checksum.h
> @@ -41,6 +41,27 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
>  			__wsum csum);
>  #endif
> 
> +static inline __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
> +					    const struct in6_addr *daddr,
> +					    __u32 len, unsigned short proto,
> +					    __wsum sum)
> +{
> +	__wsum res = sum;
> +
> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[0]);
> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[1]);
> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[2]);
> +	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[3]);
> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[0]);
> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[1]);
> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[2]);
> +	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[3]);

That probably generates a very long dependency chain.

> +	res = csum_add(res, (__force __wsum)htonl(len));
> +	res = csum_add(res, (__force __wsum)htonl(proto));

htonl() doesn't look right for a 16bit value.
It might not matter (because the final checksum is 16bits).

	David

> +
> +	return res;
> +}
> +
>  static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
>  {
>  	return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> --
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
