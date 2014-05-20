From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.57] datapath: Add basic MPLS support to kernel
Date: Mon, 19 May 2014 18:34:05 -0700
Message-ID: <CAEP_g=-X=T2hJoXTV5ptZRvf1WPgYa1xusczwSR1bUYAZ5yaqA@mail.gmail.com>
References: <1400195227-21265-1-git-send-email-horms@verge.net.au> <1400195227-21265-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ben Pfaff <blp@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:45277 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750894AbaETBe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 21:34:28 -0400
Received: by mail-qg0-f41.google.com with SMTP id j5so10215176qga.28
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 18:34:27 -0700 (PDT)
In-Reply-To: <1400195227-21265-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have some miscellaneous comments on things that I noticed, all of
which are pretty small. I will probably have a few more tomorrow but
my hope is that we can get this in soon.

On Thu, May 15, 2014 at 4:07 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 603c7cb..7c3ae0c 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +static int push_mpls(struct sk_buff *skb,
> +                    const struct ovs_action_push_mpls *mpls)
> +{
> +       __be32 *new_mpls_lse;
> +       struct ethhdr *hdr;
> +
> +       if (skb_cow_head(skb, MPLS_HLEN) < 0) {
> +               kfree_skb(skb);
> +               return -ENOMEM;
> +       }

I think it would be better to not free the skb on error here - it
introduces an exception case in the call to push_mpls() that would be
otherwise handled if we didn't free it.

When we set the EtherType at the bottom of the function, I don't think
that it is correct in the presence of VLAN tags because it will set
the outer EtherType.

> +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> +{
> +       struct ethhdr *hdr;
> +       int err;
> +
> +       if (unlikely(skb->len < skb->mac_len + MPLS_HLEN))
> +               return -EINVAL;

I don't think this check is necessary since we would have rejected
such packets at flow validation time.

> +static int set_mpls(struct sk_buff *skb, const __be32 *mpls_lse)
> +{
> +       __be32 *stack = (__be32 *)mac_header_end(skb);
> +       int err;
> +
> +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> +       if (unlikely(err))
> +               return err;
> +
> +       if (skb->ip_summed == CHECKSUM_COMPLETE) {
> +               __be32 diff[] = { ~(*stack), *mpls_lse };
> +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> +                                         ~skb->csum);
> +       }

Is it possible to use csum_replace4() to simplify this?

> @@ -701,6 +815,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb, bool recirc)
>                 goto out_loop;
>         }
>
> +       ovs_skb_init_inner_protocol(skb);

I think we talked about some time ago but it seems like this will get
reset by recirculation (although maybe it's unlikely that
recirculation will get used on output).

Also, maybe I'm missing something but I don't see where we actually
set the inner protocol.
