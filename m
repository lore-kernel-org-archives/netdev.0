From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v10 3/5] openvswitch: add support to push and pop
 mpls for layer3 packets
Date: Thu, 2 Jun 2016 15:02:00 -0700
Message-ID: <CAOrHB_D0XoGUjSXztNMdektGgTMPxeVfbNF0WcTZuTbR4VYz5g@mail.gmail.com>
References: <1464848686-7656-1-git-send-email-simon.horman@netronome.com>
	<1464848686-7656-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:48284 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbcFBWCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:02:05 -0400
Received: from mfilter23-d.gandi.net (mfilter23-d.gandi.net [217.70.178.151])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 0294741C080
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2016 00:02:03 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter23-d.gandi.net (mfilter23-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id LrdGnSHOPJoH for <netdev@vger.kernel.org>;
	Fri,  3 Jun 2016 00:02:01 +0200 (CEST)
Received: from mail-it0-f49.google.com (mail-it0-f49.google.com [209.85.214.49])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 7740141C08B
	for <netdev@vger.kernel.org>; Fri,  3 Jun 2016 00:02:01 +0200 (CEST)
Received: by mail-it0-f49.google.com with SMTP id z123so63801288itg.0
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 15:02:01 -0700 (PDT)
In-Reply-To: <1464848686-7656-4-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 11:24 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Allow push and pop mpls actions to act on layer 3 packets by teaching
> them not to access non-existent L2 headers of such packets.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
> v10
> * Limit scope of hdr in {push,pop}_mpls()
>
> v9
> * New Patch
> ---
>  net/openvswitch/actions.c | 19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 9a3eb7a0ebf4..15f130e4c22b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -172,7 +172,8 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>
>         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
>
> -       update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
> +       if (skb->mac_len)
> +               update_ethertype(skb, eth_hdr(skb), mpls->mpls_ethertype);
We can move all ethernet related code in this if block. for example memmove().

>         if (!skb->inner_protocol)
>                 skb_set_inner_protocol(skb, skb->protocol);
>         skb->protocol = mpls->mpls_ethertype;
> @@ -184,7 +185,6 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>  static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>                     const __be16 ethertype)
>  {
> -       struct ethhdr *hdr;
>         int err;
>
>         err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
> @@ -199,11 +199,16 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         __skb_pull(skb, MPLS_HLEN);
>         skb_reset_mac_header(skb);
>
> -       /* skb_mpls_header() is used to locate the ethertype
> -        * field correctly in the presence of VLAN tags.
> -        */
> -       hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
> -       update_ethertype(skb, hdr, ethertype);
> +       if (skb->mac_len) {
> +               struct ethhdr *hdr;
> +
> +               /* skb_mpls_header() is used to locate the ethertype
> +                * field correctly in the presence of VLAN tags.
> +                */
> +               hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
> +               update_ethertype(skb, hdr, ethertype);
> +       }
same here.
