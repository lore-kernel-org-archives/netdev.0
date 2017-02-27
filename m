From: Alexander Aring <aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v5 5/6] 6lowpan: Use netdev addr_len to determine lladdr
 len
Date: Mon, 27 Feb 2017 08:13:44 +0100
Message-ID: <39321f06-c013-1e8f-efd1-2e230659535b@pengutronix.de>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
 <20170224121440.32269-6-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
        jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org,
        linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170224121440.32269-6-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On 02/24/2017 01:14 PM, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> This allow technologies such as Bluetooth to use its native lladdr which
> is eui48 instead of eui64 which was expected by functions like
> lowpan_header_decompress and lowpan_header_compress.
> 
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
> ---
>  include/net/6lowpan.h   | 19 +++++++++++++++++++
>  net/6lowpan/iphc.c      | 49 ++++++++++++++++++++++++++++++++++++++-----------
>  net/bluetooth/6lowpan.c | 42 ++++++------------------------------------
>  3 files changed, 63 insertions(+), 47 deletions(-)
> 
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index 5ab4c99..c5792cb 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -198,6 +198,25 @@ static inline void lowpan_iphc_uncompress_eui64_lladdr(struct in6_addr *ipaddr,
>  	ipaddr->s6_addr[8] ^= 0x02;
>  }
>  
> +static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
> +						       const void *lladdr)
> +{
> +	/* fe:80::XXXX:XXff:feXX:XXXX
> +	 *        \_________________/
> +	 *              hwaddr
> +	 */
> +	ipaddr->s6_addr[0] = 0xFE;
> +	ipaddr->s6_addr[1] = 0x80;
> +	memcpy(&ipaddr->s6_addr[8], lladdr, 3);
> +	ipaddr->s6_addr[11] = 0xFF;
> +	ipaddr->s6_addr[12] = 0xFE;
> +	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
> +	/* second bit-flip (Universe/Local)
> +	 * is done according RFC2464
> +	 */
> +	ipaddr->s6_addr[8] ^= 0x02;
> +}
> +

same thing here. I think you don't need u/l bitflip here, you argumented
already that IID is without it in another patch, or?

btw: making static inline function -> then remove link-local setting
here before. Then we can use this function for ipv6/sateful/stateless
IPHC compression/decompression to generate IID.
And better with a function before that evaluates lltype (or dev->addr_len,
see below why not).

another thing is:
__ipv6_addr_set_half(&addr.s6_addr32[0], htonl(0xFE800000), 0);

should be used here, but this need to be cleanuped everywhere in 6lowpan
code. :-)

---

What I mean such function placed in 6lowpan header should only set the
IID according a ipaddr.
Such function can also be used then in IPv6 IID generation.

And DON'T make such handling depending on address size, this is in my
opinion wrong. Because the link-layer 6lowpan adaption RFC describes how
to generate the IID and not depending on a address size.
Means another link-layer e.g. has eui48 but will set a u/l bitflip here.
You should use the lltype of 6lowpan netdev private area for that.

This means also the name "eui48" in the function is also semantic wrong,
at my point of view.
(Okay, I don't care about function names right now).

Anyway, I agree that doesn't matter currently because we have only two
adaptions right now.
... and yes, I know (already more about ~one year) BTLE 6LoWPAN is
broken (races/rfc stuff) and I am happy that somebody fix that now.
So I would also ack patches which makes it depending on dev->addr_len.
Otherwise broken things will never be fixed...

- Alex
