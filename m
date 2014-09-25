From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [RFC PATCH 22/24] net: rbridge: Add rbr_fwd
Date: Thu, 25 Sep 2014 15:43:14 +0400
Message-ID: <5423FFD2.103@cogentembedded.com>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net> <1411573940-14079-23-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:53082 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaIYLnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 07:43:17 -0400
Received: by mail-lb0-f170.google.com with SMTP id n15so709081lbi.15
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 04:43:16 -0700 (PDT)
In-Reply-To: <1411573940-14079-23-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/24/2014 7:52 PM, Ahmed Amamou wrote:

> add rbridge forward function
> packets arriving to rbr_fwd should be already encapsulated and correc=
t egress
> and ingress nickname should be already assigned
> rbr_fwd function will assign correct source and destination outer MAC=
 addresses
> according to which port will send the frame and next hop to reach
> the engress nickname
> Nexthope to reach the egress will be found in node database

> Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
> Signed-off-by: Kamel Haddadou <kamel@gandi.net>
> Signed-off-by: William Dauchy <william@gandi.net>
> Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
> ---
>   net/bridge/rbridge/rbr.c | 49 +++++++++++++++++++++++++++++++++++++=
+++++++++--
>   1 file changed, 47 insertions(+), 2 deletions(-)

> diff --git a/net/bridge/rbridge/rbr.c b/net/bridge/rbridge/rbr.c
> index 8aa5182..39aa816c 100644
> --- a/net/bridge/rbridge/rbr.c
> +++ b/net/bridge/rbridge/rbr.c
> @@ -177,6 +177,51 @@ static bool add_header(struct sk_buff *skb, uint=
16_t ingressnick,
>   	return 0;
>   }
>
> +static void rbr_fwd(struct net_bridge_port *p, struct sk_buff *skb,
> +		    uint16_t adj_nick, u16 vid)
> +{
> +	struct rbr_node *adj;
> +	struct trill_hdr *trh;
> +	struct ethhdr *outerethhdr;
> +	struct net *net =3D dev_net(p->br->dev);
> +	struct net_device *outdev;
> +
> +	adj =3D rbr_find_node(p->br->rbr, adj_nick);
> +    outdev =3D __dev_get_by_index(net, adj->rbr_ni->linkid);

    Indent with a tab please.

> +	if (!outdev) {
> +		pr_warn_ratelimited("rbr_fwd: cannot find source port device for f=
orwrding\n");
> +		goto dest_fwd_fail;
> +    }
> +	if (unlikely(adj =3D=3D NULL)) {
> +		pr_warn_ratelimited
> +		    ("rbr_fwd: unable to find adjacent RBridge\n");
> +		goto dest_fwd_fail;
> +	}
> +
> +	trh =3D (struct trill_hdr *)skb->data;
> +	trillhdr_dec_hopcount(trh);
> +	outerethhdr =3D eth_hdr(skb);
> +
> +	/* change outer ether header */
> +	/* bridge become the source_port address in outeretherhdr */

    Becomes?

> +	memcpy(outerethhdr->h_source, p->br->dev->dev_addr, ETH_ALEN);
> +	/* dist port become dest address in outeretherhdr */
> +	memcpy(outerethhdr->h_dest, adj->rbr_ni->adjsnpa, ETH_ALEN);
> +	rbr_node_put(adj);
> +	/* set Bridge as source device */
> +	skb->dev =3D p->br->dev;
> +	br_forward(br_port_get_rcu(outdev), skb, NULL);
> +
> +	return;
> +
> + dest_fwd_fail:
> +	if (likely(p && p->br))
> +		p->br->dev->stats.tx_dropped++;
> +	kfree_skb(skb);
> +	return;
> +}
> +
> +

    One empty line is enough.

>   static void rbr_encaps(struct sk_buff *skb, uint16_t egressnick, u1=
6 vid)
>   {
>   	uint16_t local_nick;
[...]

WBR, Sergei
