From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: Add packet truncation support.
Date: Wed, 8 Jun 2016 21:30:05 -0700
Message-ID: <CAOrHB_CNZ2_JCt7RCaMQehZvYxZO-3wL00krbPX-iT1z3iAu=w@mail.gmail.com>
References: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:41044 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbcFIEaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:30:12 -0400
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
	by relay3-d.mail.gandi.net (Postfix) with ESMTP id 6F062A80CB
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 06:30:09 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
	by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id tKcyRTWouWm5 for <netdev@vger.kernel.org>;
	Thu,  9 Jun 2016 06:30:07 +0200 (CEST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
	(Authenticated sender: pshelar@ovn.org)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id E802DA80C8
	for <netdev@vger.kernel.org>; Thu,  9 Jun 2016 06:30:06 +0200 (CEST)
Received: by mail-it0-f43.google.com with SMTP id i6so516635ith.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:30:06 -0700 (PDT)
In-Reply-To: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 6:18 PM, William Tu <u9012063@gmail.com> wrote:
> The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
> truncate packets. A 'max_len' is added for setting up the maximum
> packet size, and a 'cutlen' field is to record the number of bytes
> to trim the packet when the packet is outputting to a port, or when
> the packet is sent to userspace.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> ---
>  include/uapi/linux/openvswitch.h |  7 +++++++
>  net/openvswitch/actions.c        | 28 +++++++++++++++++++++++++++-
>  net/openvswitch/datapath.c       |  9 +++++++--
>  net/openvswitch/datapath.h       |  2 ++
>  net/openvswitch/flow_netlink.c   |  9 +++++++++
>  net/openvswitch/vport.c          |  1 +
>  6 files changed, 53 insertions(+), 3 deletions(-)
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index bb0d515..6d7ac5b 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -580,6 +580,11 @@ enum ovs_userspace_attr {
>
>  #define OVS_USERSPACE_ATTR_MAX (__OVS_USERSPACE_ATTR_MAX - 1)
>
> +struct ovs_action_trunc {
> +       uint32_t max_len; /* Max packet size in bytes. */
This could uint16_t. as it is related to packet len.

> +};
> +#define ETH_MIN_FRAME_LEN 60
> +

There is already symbol defined, ETH_ZLEN can used here.

...

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 9a3eb7a..889b78b 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -750,6 +750,10 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>
>         if (likely(vport)) {
>                 u16 mru = OVS_CB(skb)->mru;
> +               u16 cutlen = OVS_CB(skb)->cutlen;
> +
> +               if (cutlen > 0)
> +                       pskb_trim(skb, skb->len - cutlen);
>
>                 if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
>                         ovs_vport_send(vport, skb);
> @@ -858,10 +862,19 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
>                 return 0;
>
>         /* The only known usage of sample action is having a single user-space
> +        * action, or having a truncate action followed by a single user-space
>          * action. Treat this usage as a special case.
>          * The output_userspace() should clone the skb to be sent to the
>          * user space. This skb will be consumed by its caller.
>          */
> +       if (unlikely(nla_type(a) == OVS_ACTION_ATTR_TRUNC)) {
> +               struct ovs_action_trunc *trunc = nla_data(a);
> +
> +               OVS_CB(skb)->cutlen = skb->len > trunc->max_len ?
> +                                               skb->len - trunc->max_len : 0;

There is no need to initialize the cutlen to zero if max-len is
greater then skb len. it should be already zero.

> +               a = nla_next(a, &rem);
> +       }
> +
There cutlen is set in skb cb, but next action could be other than
userspace, in that case cutlen is leaked to remain action list.

>         if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
>                    nla_is_last(a, rem)))
>                 return output_userspace(dp, skb, key, a, actions, actions_len);
> @@ -1044,13 +1057,18 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         for (a = attr, rem = len; rem > 0;
>              a = nla_next(a, &rem)) {
>                 int err = 0;
> +               int cutlen = OVS_CB(skb)->cutlen;
>
>                 if (unlikely(prev_port != -1)) {
>                         struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
>
> -                       if (out_skb)
> +                       if (out_skb) {
> +                               /* skb_clone does not clone the CB. */
Are you sure about this? __copy_skb_header() seem to be doing the copy.

> +                               OVS_CB(out_skb)->cutlen = cutlen;
>                                 do_output(dp, out_skb, prev_port, key);
> +                       }
>
> +                       OVS_CB(skb)->cutlen = 0;
You also need to set cutlen local variable. otherwise next output
could pickup the value.

>                         prev_port = -1;
>                 }
>
> @@ -1059,6 +1077,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         prev_port = nla_get_u32(a);
>                         break;
>
> +               case OVS_ACTION_ATTR_TRUNC: {
> +                       struct ovs_action_trunc *trunc = nla_data(a);
> +
> +                       OVS_CB(skb)->cutlen = skb->len > trunc->max_len ?
> +                                               skb->len - trunc->max_len : 0;
similar to sample() function comment, no need to set OVS_CB cutlen to zero.

> +                       break;
> +               }
> +
>                 case OVS_ACTION_ATTR_USERSPACE:
>                         output_userspace(dp, skb, key, a, attr, len);
>                         break;
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 856bd8d..fb3e5a3 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -425,6 +425,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>         size_t len;
>         unsigned int hlen;
>         int err, dp_ifindex;
> +       int cutlen = OVS_CB(skb)->cutlen;
>
>         dp_ifindex = get_dpifindex(dp);
>         if (!dp_ifindex)
> @@ -461,6 +462,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>         else
>                 hlen = skb->len;
>
> +       if (cutlen > 0)
> +               hlen -= cutlen;
> +
I do not think headline should be changed in case of sib-zero copy.
This is size of linear data in skb, changing this value could result
in wrong data copy in skb-zerocpy.
Also no need to compare cut-lea to zero, it can be directly subtracted.
