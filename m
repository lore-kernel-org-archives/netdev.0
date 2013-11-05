From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] vti: fix spd lookup: match plaintext pkt, not ipsec
 pkt
Date: Tue, 05 Nov 2013 17:05:48 +0400
Message-ID: <5278ED2C.8070604@cogentembedded.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>,
	netdev@vger.kernel.org
To: Christophe Gouault <christophe.gouault@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:41716 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754112Ab3KENFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 08:05:55 -0500
Received: by mail-la0-f47.google.com with SMTP id er20so2013817lab.6
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 05:05:52 -0800 (PST)
In-Reply-To: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-11-2013 14:16, Christophe Gouault wrote:

> The vti interface inbound and outbound SPD lookups are based on the
> ipsec packet instead of the plaintext packet.

> Not only is it counterintuitive, it also restricts vti interfaces
> to a single policy (whose selector must match the tunnel local and
> remote addresses).

> The policy selector is supposed to match the plaintext packet, before
> encryption or after decryption.

> This patch performs the SPD lookup based on the plaintext packet. It
> enables to create several polices bound to the vti interface (via a
> mark equal to the vti interface okey).

> It remains possible to apply the same policy to all packets entering
> the vti interface, by setting an any-to-any selector (src 0.0.0.0/0
> dst 0.0.0.0/0 proto any mark OKEY).

> Signed-off-by: Christophe Gouault <christophe.gouault@6wind.com>
> ---
>   net/ipv4/ip_vti.c |   28 +++++++++++++++++++++++++++-
>   1 file changed, 27 insertions(+), 1 deletion(-)

> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 6e87f85..a7e03c0 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
[...]
> @@ -133,7 +134,12 @@ static int vti_rcv(struct sk_buff *skb)
>   		 * only match policies with this mark.
>   		 */
>   		skb->mark = be32_to_cpu(tunnel->parms.o_key);
> +		/* the packet is decrypted, but not yet decapsulated.
> +		 * Temporarily make network_header point to the inner header
> +		 * for policy check */

    Multi-line comment style in the networking code is:

/* bla
  * bla
  */

[...]
> @@ -173,17 +181,35 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
>
>   	tos = old_iph->tos;
>
> +	/* SPD lookup: we must provide a dst_entry to xfrm_lookup, normally the
> +	 * route to the final destination. However this route is a route via
> +	 * the vti interface. Now vti interfaces typically have the NOXFRM
> +	 * flag, hence xfrm_lookup would bypass IPsec.
> +	 *
> +	 * Therefore, we feed xfrm_lookup with a route to the vti tunnel remote
> +	 * endpoint instead.
> +	 */

    Hm, you got it right the second and third time.

WBR, Sergei
