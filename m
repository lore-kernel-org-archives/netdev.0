From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Mon, 8 Apr 2013 18:46:29 -0700
Message-ID: <CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au> <1365403431-18102-2-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:34327 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S936434Ab3DIBqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 21:46:50 -0400
Received: by mail-ia0-f198.google.com with SMTP id l29so1833828iag.1
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 18:46:49 -0700 (PDT)
In-Reply-To: <1365403431-18102-2-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index e9634fe..7b0f022 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> @@ -617,6 +617,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                 case OVS_ACTION_ATTR_SAMPLE:
>                         err = sample(dp, skb, a);
>                         break;
> +
> +               case OVS_ACTION_ATTR_RECIRCULATE:
> +                       return 1;

I think that if we've had a previous output action with the port
stored in prev_port then this will cause the packet to not actually be
output.

> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index e8be795..ab39dd7 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c
>  void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
[...]
> +               if (IS_ERR_OR_NULL(skb)) {
> +                       break;
> +               } else if (unlikely(!limit--)) {

Should this be a predecrement?

> +                       kfree_skb(skb);

Should we log some kind of rate limited warning here?

> +                       return;

In the first case we use break to exit the loop and here we use
return.  Both should have the same effect so it might be nice to make
them the same.

> @@ -901,6 +913,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
>                         skip_copy = true;
>                         break;
>
> +               case OVS_ACTION_ATTR_RECIRCULATE:
> +                       break;

I think we might want to jump out the loop here to better model how
the actions are actually executed.

> diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
> index e4a2f75..31255f6 100644
> --- a/lib/dpif-netdev.c
> +++ b/lib/dpif-netdev.c
>  dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
>                       struct ofpbuf *packet)
[...]
> +        } else {
> +            dp->n_missed++;
> +            dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
> +            recirculate = false;
> +        }
> +    } while (recirculate && limit--);

I have the same question about predecrement here.

> @@ -1163,6 +1190,7 @@ dp_netdev_sample(struct dp_netdev *dp,
>      const struct nlattr *subactions = NULL;
>      const struct nlattr *a;
>      size_t left;
> +    uint32_t skb_mark;

I don't think it's right to have a new (and uninitialized) copy of
skb_mark here.  We should have the same one all the way through, like
we do in the kernel.

> diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
> index 47830c1..5129da1 100644
> --- a/ofproto/ofproto-dpif.c
> +++ b/ofproto/ofproto-dpif.c

I'm still working on more detailed comments for this.  However, I'm
concerned about whether the behavior for revalidation and stats is
correct.
