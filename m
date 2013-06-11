From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH 3/5] netfilter: xt_TCPMSS: Fix violation of RFC879 in
 absence of MSS option
Date: Tue, 11 Jun 2013 14:36:30 -0400
Message-ID: <CABrhC0nmF=KqmrhbTNonV6bcC4PEXkfZUmiHofRxA30p0VmrVg@mail.gmail.com>
References: <1370880461-4265-1-git-send-email-pablo@netfilter.org>
	<1370880461-4265-4-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f51.google.com ([209.85.212.51]:60267 "EHLO
	mail-vb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756131Ab3FKSgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 14:36:31 -0400
In-Reply-To: <1370880461-4265-4-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While it's not likely to harm anything, this isn't quite right for
IPv6, with a lower bound MTU of 1280.

Thanks,
  -John

(Sorry, re-sending as gmail silently turned on HTML formatting.)



On Mon, Jun 10, 2013 at 12:07 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>
> From: Phil Oester <kernel@linuxace.com>
>
> The clamp-mss-to-pmtu option of the xt_TCPMSS target can cause issues
> connecting to websites if there was no MSS option present in the
> original SYN packet from the client. In these cases, it may add a
> MSS higher than the default specified in RFC879. Fix this by never
> setting a value > 536 if no MSS option was specified by the client.
>
> This closes netfilter's bugzilla #662.
>
> Signed-off-by: Phil Oester <kernel@linuxace.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/netfilter/xt_TCPMSS.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
> index a75240f..afaebc7 100644
> --- a/net/netfilter/xt_TCPMSS.c
> +++ b/net/netfilter/xt_TCPMSS.c
> @@ -125,6 +125,12 @@ tcpmss_mangle_packet(struct sk_buff *skb,
>
>         skb_put(skb, TCPOLEN_MSS);
>
> +       /* RFC 879 states that the default MSS is 536 without specific
> +        * knowledge that the destination host is prepared to accept larger.
> +        * Since no MSS was provided, we MUST NOT set a value > 536.
> +        */
> +       newmss = min(newmss, (u16)536);
> +
>         opt = (u_int8_t *)tcph + sizeof(struct tcphdr);
>         memmove(opt + TCPOLEN_MSS, opt, tcplen - sizeof(struct tcphdr));
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
