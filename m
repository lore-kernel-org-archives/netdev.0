From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC 8/9] vti: Update the ipv4 side to use it's own receive
 hook.
Date: Thu, 12 Dec 2013 17:26:55 +0100
Message-ID: <52A9E3CF.7040204@6wind.com>
References: <20131205120028.GW31491@secunet.com> <20131205120504.GE31491@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:64509 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554Ab3LLQ07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 11:26:59 -0500
Received: by mail-wi0-f176.google.com with SMTP id hq4so8940654wib.9
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 08:26:58 -0800 (PST)
In-Reply-To: <20131205120504.GE31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/12/2013 13:05, Steffen Klassert a =E9crit :
> With this patch, vti uses the IPsec protocol multiplexer to
> register it's own receive side hooks for ESP and AH.
>
> Vti now does the following on receive side:
>
> 1. Do an input policy check for the IPsec packet we received.
>     This is required because this packet could be already
>     prosecces by IPsec, so an inbuond policy check is needed.
>
> 2. Clean the skb to not leak informations on namespace
>     transitions.
>
> 3. Mark the packet with the i_key. The policy and the state
>     must match this key now. Policy and state belong to the vti
>     namespace and policy enforcement is done at the further layers.
>
> 4. Call the generic xfrm layer to do decryption and decapsulation.
>
> 5. Wait for a callback from the xfrm layer to properly update
>     the device statistics.
>
> On transmit side:
>
> 1. Mark the packet with the o_key. The policy and the state
>     must match this key now.
>
> 2. Do a xfrm_lookup on the original packet with the mark applied.
>
> 3. Check if we got an IPsec route.
>
> 4. Clean the skb to not leak informations on namespace
>     transitions.
>
> 5. Attach the dst_enty we got from the xfrm_lookup to the skb.
>
> 6. Call dst_output to do the IPsec processing.
>
> 7. Do the device statistics.
>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv4/ip_vti.c |  124 +++++++++++++++++++++++++++++++++++++-----=
-----------
>   1 file changed, 88 insertions(+), 36 deletions(-)
>
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index 52b802a..fe3d3ab 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -41,6 +41,8 @@
>   #include <net/ip_tunnels.h>
>   #include <net/inet_ecn.h>
>   #include <net/xfrm.h>
> +#include <net/esp.h>
> +#include <net/ah.h>
>   #include <net/net_namespace.h>
>   #include <net/netns/generic.h>
>
> @@ -49,7 +51,6 @@ static struct rtnl_link_ops vti_link_ops __read_mos=
tly;
>   static int vti_net_id __read_mostly;
>   static int vti_tunnel_init(struct net_device *dev);
>
> -/* We dont digest the packet therefore let the packet pass */
>   static int vti_rcv(struct sk_buff *skb)
>   {
>   	struct ip_tunnel *tunnel;
> @@ -60,48 +61,72 @@ static int vti_rcv(struct sk_buff *skb)
>   	tunnel =3D ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
>   				  iph->saddr, iph->daddr, 0);
>   	if (tunnel !=3D NULL) {
> -		struct pcpu_tstats *tstats;
> -		u32 oldmark =3D skb->mark;
> -		int ret;
> +		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
> +			goto drop;
> +
> +		XFRM_TUNNEL_SKB_CB(skb)->tunnel =3D tunnel;
> +
> +		/* Partially clear the buffer, the rest is done by xfrm_input. */
> +		if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
> +			skb_orphan(skb);
> +		skb->tstamp.tv64 =3D 0;
> +		skb->pkt_type =3D PACKET_HOST;
> +		skb->skb_iif =3D 0;
> +		nf_reset_trace(skb);
> +		secpath_reset(skb);
Is it not better to call skb_scrub_packet() (if necessary adding a new
argument to skip some operations)?
skb_scrub_packet() ensures to perform all needed operations when crossi=
ng
netns/tunnel.
It also eases the maintenance and make the code more consistent: when a=
 bug is
fixed in skb_scrub_packet() all users benefit from it (eg 239c78db9c41 =
net:
clear local_df when passing skb between namespaces), otherwise we will =
always
forget some users.

Nicolas
