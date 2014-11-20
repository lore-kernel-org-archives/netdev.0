From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC] net: Pass full skb hash to ndo_rx_flow_steer
Date: Wed, 19 Nov 2014 16:21:02 -0800
Message-ID: <CALCETrU9QXUy5EK5JjmqXo50ZqdHRRbsz3eJzLuCJgadN2jPHw@mail.gmail.com>
References: <1416370137-2512-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Network Development <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:57141 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756201AbaKTAVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 19:21:24 -0500
Received: by mail-la0-f53.google.com with SMTP id pn19so1462001lab.26
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 16:21:22 -0800 (PST)
In-Reply-To: <1416370137-2512-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 8:08 PM, Tom Herbert <therbert@google.com> wrote:
> Currently, for aRFS the index into the flow table is passed to
> ndo_rx_flow_steer as the flow ID of a connection. This is the skb->hash
> & the table mask. It looks like the backend can accept the full
> skb->hash as the flow ID which should reduce the number of collisions
> in the hardware tables.
>
> This patch provides the skb->hash to the driver for flow steering.
> Expiration of HW steered flows was also updated.
>
> With a hash collision in RFS, ndo_rx_flow_steer will continue to be
> called with different CPUs, but now with different flow_ids. If this
> is still too much device interaction, then it might make sense for the
> driver to do its own lookup in its structure to see if a matching
> filter is already installed for a given flow_id, an if it is just
> refresh a timestamp to avoid expiration (based on looking at sfc
> driver).
>
> I don't currently have any HW to test this, if someone could try this
> on hardware with aRFS and provide feedback that would be appreciated.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  net/core/dev.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 1ab168e..cb1e06d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3057,7 +3057,8 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
>                         goto out;
>                 flow_id = skb_get_hash(skb) & flow_table->mask;
>                 rc = dev->netdev_ops->ndo_rx_flow_steer(dev, skb,
> -                                                       rxq_index, flow_id);
> +                                                       rxq_index,
> +                                                       skb_get_hash(skb));

Can gcc CSE this?  Not that it matters that much.

>                 if (rc < 0)
>                         goto out;
>                 old_rflow = rflow;
> @@ -3195,8 +3196,8 @@ bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
>
>         rcu_read_lock();
>         flow_table = rcu_dereference(rxqueue->rps_flow_table);
> -       if (flow_table && flow_id <= flow_table->mask) {
> -               rflow = &flow_table->flows[flow_id];
> +       if (flow_table) {
> +               rflow = &flow_table->flows[flow_id & flow_table->mask];

I think this is nicer, but why will it help?  If there's a collision
in the low bits of the hash, we'll still think that the flow is
expired.

Is there a real LRU-ish hash table that could be subbed in easily?
There ought to be a data structure that's barely more complicated than
this kind of hash table but that gives much better behavior when the
number of flows is smaller than the table size.

--Andy

>                 cpu = ACCESS_ONCE(rflow->cpu);
>                 if (rflow->filter == filter_id && cpu != RPS_NO_CPU &&
>                     ((int)(per_cpu(softnet_data, cpu).input_queue_head -
> --
> 2.1.0.rc2.206.gedb03e5
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
