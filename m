From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv6: Use inbound ifaddr as source addresses for ICMPv6
 errors
Date: Sat, 27 Aug 2016 18:17:26 +0300
Message-ID: <3064a340-1c6b-f293-eb0d-f099c3b214fd@cogentembedded.com>
References: <20160827130536.10660-1-elicooper@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>
To: Eli Cooper <elicooper@gmx.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33133 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753403AbcH0PRw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 11:17:52 -0400
Received: by mail-lf0-f47.google.com with SMTP id b199so74936862lfe.0
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 08:17:27 -0700 (PDT)
In-Reply-To: <20160827130536.10660-1-elicooper@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/27/2016 4:05 PM, Eli Cooper wrote:

> According to RFC 1885 2.2(c), the source address of ICMPv6
> errors in response to forwarded packets should be set to the
> unicast address of the forwarding interface in order to be helpful
> in diagnosis. Currently the selection of source address is based
> on the default route, without respect to the inbound interface.
>
> This patch sets the source address of ICMPv6 error messages to
> the address of inbound interface, with the exception of
> 'time exceeded' and 'packet to big' messages sent in ip6_forward(),
> where the address of OUTPUT device is forced as source address
> (however, it is NOT enforced as claimed without this patch).
>
> Signed-off-by: Eli Cooper <elicooper@gmx.com>
> ---
>  net/ipv6/icmp.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index bd59c34..0e52f3b 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
[...]
> @@ -421,6 +422,12 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
>  	 */
>  	addr_type = ipv6_addr_type(&hdr->daddr);
>
> +	if (type == ICMPV6_DEST_UNREACH || type == ICMPV6_PKT_TOOBIG ||
> +	    type == ICMPV6_TIME_EXCEED || type == ICMPV6_PARAMPROB)

    This is asking to be a *switch* statement instead.

> +		if (!ipv6_dev_get_saddr(net, skb->dev, &hdr->saddr, 0,
> +					&tmp_saddr))
> +			saddr = &tmp_saddr;
> +
>  	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0) ||
>  	    ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr))
>  		saddr = &hdr->daddr;

MBR, Sergei
