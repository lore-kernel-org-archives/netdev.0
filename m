From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: update checksum in {push,pop}_mpls
Date: Sun, 29 May 2016 09:16:09 -0700
Message-ID: <CAOrHB_A+moWsAu4FEkmouXE=Wvy7xr-y4TfLBOp4U=gwGvKORg@mail.gmail.com>
References: <1464332338-12382-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:42133 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932325AbcE2QQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 May 2016 12:16:14 -0400
Received: from mfilter23-d.gandi.net (mfilter23-d.gandi.net [217.70.178.151])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id 860B7A80C8
	for <netdev@vger.kernel.org>; Sun, 29 May 2016 18:16:12 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter23-d.gandi.net (mfilter23-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id osMvtV2rs-tV for <netdev@vger.kernel.org>;
	Sun, 29 May 2016 18:16:10 +0200 (CEST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D4D0EA80C6
	for <netdev@vger.kernel.org>; Sun, 29 May 2016 18:16:10 +0200 (CEST)
Received: by mail-it0-f53.google.com with SMTP id e62so22937175ita.1
        for <netdev@vger.kernel.org>; Sun, 29 May 2016 09:16:10 -0700 (PDT)
In-Reply-To: <1464332338-12382-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 26, 2016 at 11:58 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> In the case of CHECKSUM_COMPLETE the skb checksum should be updated in
> {push,pop}_mpls() as they the type in the ethernet header.
>
> As suggested by Pravin Shelar.
>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Fixes: 25cd9ba0abc0 ("openvswitch: Add basic MPLS support to kernel")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  net/openvswitch/actions.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 879185fe183f..d6010b44d423 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -161,6 +161,12 @@ static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>         skb_postpush_rcsum(skb, new_mpls_lse, MPLS_HLEN);
>
>         hdr = eth_hdr(skb);
> +       if (skb->ip_summed == CHECKSUM_COMPLETE) {
> +               __be16 diff[] = { ~(hdr->h_proto), mpls->mpls_ethertype };
> +
> +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> +                                       ~skb->csum);
> +       }
>         hdr->h_proto = mpls->mpls_ethertype;
>
This looks correct. But same code is now replicated three times in
this file. can you add helper function to update checksum for such
case?

>         if (!skb->inner_protocol)
> @@ -193,6 +199,12 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
>          * field correctly in the presence of VLAN tags.
>          */
>         hdr = (struct ethhdr *)(skb_mpls_header(skb) - ETH_HLEN);
> +       if (skb->ip_summed == CHECKSUM_COMPLETE) {
> +               __be16 diff[] = { ~(hdr->h_proto), ethertype };
> +
> +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> +                                       ~skb->csum);
> +       }
>         hdr->h_proto = ethertype;
>         if (eth_p_mpls(skb->protocol))
>                 skb->protocol = ethertype;
> --
> 2.1.4
>
