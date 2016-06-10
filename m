From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next,v2] openvswitch: Add packet truncation support.
Date: Fri, 10 Jun 2016 10:17:24 -0700
Message-ID: <CAOrHB_BpTWscsvRYqUjG7vT4Q=exn41o2yvL59wF+d2h8yNNkg@mail.gmail.com>
References: <1465516649-44725-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:34726 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbcFJRRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 13:17:31 -0400
Received: from mfilter37-d.gandi.net (mfilter37-d.gandi.net [217.70.178.168])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id C31E2C5A56
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:17:28 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter37-d.gandi.net (mfilter37-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id qYYQGT1WvsMk for <netdev@vger.kernel.org>;
	Fri, 10 Jun 2016 19:17:26 +0200 (CEST)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 6457FC5A55
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 19:17:26 +0200 (CEST)
Received: by mail-io0-f177.google.com with SMTP id n127so71238870iof.3
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 10:17:26 -0700 (PDT)
In-Reply-To: <1465516649-44725-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 9, 2016 at 4:57 PM, William Tu <u9012063@gmail.com> wrote:
> The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
> truncate packets. A 'max_len' is added for setting up the maximum
> packet size, and a 'cutlen' field is to record the number of bytes
> to trim the packet when the packet is outputting to a port, or when
> the packet is sent to userspace.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> ---
> v1 -> v2:
> - Use 32 bits cutlen and fix unnecessary cutlen initilization.
> - Fix cutlen leaks to remaining actions under sample action.
> - In queue_userspace_packet, don't extract hlen when using skb_zerocopy.
> ---
>  include/uapi/linux/openvswitch.h |  7 +++++++
>  net/openvswitch/actions.c        | 34 ++++++++++++++++++++++++++++++----
>  net/openvswitch/datapath.c       | 27 ++++++++++++++++-----------
>  net/openvswitch/datapath.h       |  5 ++++-
>  net/openvswitch/flow_netlink.c   |  9 +++++++++
>  net/openvswitch/vport.c          |  1 +
>  6 files changed, 67 insertions(+), 16 deletions(-)

...
...
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 9a3eb7a..64dbc80 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -750,6 +750,10 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>
>         if (likely(vport)) {
>                 u16 mru = OVS_CB(skb)->mru;
> +               u32 cutlen = OVS_CB(skb)->cutlen;
> +
> +               if (cutlen > 0)
> +                       pskb_trim(skb, skb->len - cutlen);
>
Lets add check min packet length. also add unlikely annotation  to the
condition.

>                 if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
>                         ovs_vport_send(vport, skb);
...
...
> @@ -1059,8 +1077,16 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         prev_port = nla_get_u32(a);
>                         break;
>
> +               case OVS_ACTION_ATTR_TRUNC: {
> +                       struct ovs_action_trunc *trunc = nla_data(a);
> +
> +                       if (skb->len > trunc->max_len)
> +                               OVS_CB(skb)->cutlen = skb->len - trunc->max_len;
> +                       break;
> +               }
> +
>                 case OVS_ACTION_ATTR_USERSPACE:
> -                       output_userspace(dp, skb, key, a, attr, len);
> +                       output_userspace(dp, skb, key, a, attr, len, 0);
Need to pass cutlen here to truncate packet for userspace action. Also
reset cutlen to zero for the skb after this action is executed.

>                         break;
>
>                 case OVS_ACTION_ATTR_HASH:
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 856bd8d..26f947e 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
...
...
>
>  static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                                   const struct sw_flow_key *key,
> -                                 const struct dp_upcall_info *upcall_info)
> +                                 const struct dp_upcall_info *upcall_info,
> +                                 uint32_t cutlen)
>  {
>         struct ovs_header *upcall;
>         struct sk_buff *nskb = NULL;
> @@ -515,9 +520,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>                 err = -ENOBUFS;
>                 goto out;
>         }
> -       nla->nla_len = nla_attr_size(skb->len);
> +       nla->nla_len = nla_attr_size(skb->len - cutlen);
>
> -       err = skb_zerocopy(user_skb, skb, skb->len, hlen);
> +       err = skb_zerocopy(user_skb, skb, skb->len - cutlen, hlen);
>         if (err)
>                 goto out;

If packet is truncated there is no need to allocate buffer according
to full packet packet length.
