From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v15] openvswitch: enable NSH support
Date: Wed, 1 Nov 2017 17:52:40 -0700
Message-ID: <CAOrHB_DfrpQF_W9CL5q-=0aKSh5sBmcMqTvs9HeupeYQFoVJ6g@mail.gmail.com>
References: <1509508981-66202-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, Jiri Benc <jbenc@redhat.com>,
        Eric Garver <e@erig.me>,
        "David S. Miller" <davem@davemloft.net>
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:48962 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932169AbdKBAwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 20:52:43 -0400
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 282ABFB887
        for <netdev@vger.kernel.org>; Thu,  2 Nov 2017 01:52:41 +0100 (CET)
Received: by mail-wm0-f43.google.com with SMTP id r68so7974629wmr.3
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 17:52:41 -0700 (PDT)
In-Reply-To: <1509508981-66202-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 9:03 PM, Yi Yang <yi.y.yang@intel.com> wrote:
> v14->v15
>  - Check size in nsh_hdr_from_nlattr
>  - Fixed four small issues pointed out By Jiri and Eric
>
> v13->v14
>  - Rename skb_push_nsh to nsh_push per Dave's comment
>  - Rename skb_pop_nsh to nsh_pop per Dave's comment
>
> v12->v13
>  - Fix NSH header length check in set_nsh
>
> v11->v12
>  - Fix missing changes old comments pointed out
>  - Fix new comments for v11
>
> v10->v11
>  - Fix the left three disputable comments for v9
>    but not fixed in v10.
>
> v9->v10
>  - Change struct ovs_key_nsh to
>        struct ovs_nsh_key_base base;
>        __be32 context[NSH_MD1_CONTEXT_SIZE];
>  - Fix new comments for v9
>
> v8->v9
>  - Fix build error reported by daily intel build
>    because nsh module isn't selected by openvswitch
>
> v7->v8
>  - Rework nested value and mask for OVS_KEY_ATTR_NSH
>  - Change pop_nsh to adapt to nsh kernel module
>  - Fix many issues per comments from Jiri Benc
>
> v6->v7
>  - Remove NSH GSO patches in v6 because Jiri Benc
>    reworked it as another patch series and they have
>    been merged.
>  - Change it to adapt to nsh kernel module added by NSH
>    GSO patch series
>
> v5->v6
>  - Fix the rest comments for v4.
>  - Add NSH GSO support for VxLAN-gpe + NSH and
>    Eth + NSH.
>
> v4->v5
>  - Fix many comments by Jiri Benc and Eric Garver
>    for v4.
>
> v3->v4
>  - Add new NSH match field ttl
>  - Update NSH header to the latest format
>    which will be final format and won't change
>    per its author's confirmation.
>  - Fix comments for v3.
>
> v2->v3
>  - Change OVS_KEY_ATTR_NSH to nested key to handle
>    length-fixed attributes and length-variable
>    attriubte more flexibly.
>  - Remove struct ovs_action_push_nsh completely
>  - Add code to handle nested attribute for SET_MASKED
>  - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
>    to transfer NSH header data.
>  - Fix comments and coding style issues by Jiri and Eric
>
> v1->v2
>  - Change encap_nsh and decap_nsh to push_nsh and pop_nsh
>  - Dynamically allocate struct ovs_action_push_nsh for
>    length-variable metadata.
>
> OVS master and 2.8 branch has merged NSH userspace
> patch series, this patch is to enable NSH support
> in kernel data path in order that OVS can support
> NSH in compat mode by porting this.
>
> Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> ---
I have comment related to checksum, otherwise patch looks good to me.

>  include/net/nsh.h                |   3 +
>  include/uapi/linux/openvswitch.h |  29 ++++
>  net/nsh/nsh.c                    |  59 ++++++++
>  net/openvswitch/Kconfig          |   1 +
>  net/openvswitch/actions.c        | 119 +++++++++++++++
>  net/openvswitch/flow.c           |  51 +++++++
>  net/openvswitch/flow.h           |   7 +
>  net/openvswitch/flow_netlink.c   | 315 ++++++++++++++++++++++++++++++++++++++-
>  net/openvswitch/flow_netlink.h   |   5 +
>  9 files changed, 588 insertions(+), 1 deletion(-)
>

...
> diff --git a/net/nsh/nsh.c b/net/nsh/nsh.c
> index 58fb827..2764682 100644
> --- a/net/nsh/nsh.c
> +++ b/net/nsh/nsh.c
> @@ -14,6 +14,65 @@
>  #include <net/nsh.h>
>  #include <net/tun_proto.h>
>
> +int nsh_push(struct sk_buff *skb, const struct nshhdr *pushed_nh)
> +{
> +       struct nshhdr *nh;
> +       size_t length = nsh_hdr_len(pushed_nh);
> +       u8 next_proto;
> +
> +       if (skb->mac_len) {
> +               next_proto = TUN_P_ETHERNET;
> +       } else {
> +               next_proto = tun_p_from_eth_p(skb->protocol);
> +               if (!next_proto)
> +                       return -EAFNOSUPPORT;
> +       }
> +
> +       /* Add the NSH header */
> +       if (skb_cow_head(skb, length) < 0)
> +               return -ENOMEM;
> +
> +       skb_push(skb, length);
> +       nh = (struct nshhdr *)(skb->data);
> +       memcpy(nh, pushed_nh, length);
> +       nh->np = next_proto;
dont you need to update checksum for CHECKSUM_COMPLETE case?

> +
> +       skb->protocol = htons(ETH_P_NSH);
> +       skb_reset_mac_header(skb);
> +       skb_reset_network_header(skb);
> +       skb_reset_mac_len(skb);
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL_GPL(nsh_push);
> +
> +int nsh_pop(struct sk_buff *skb)
> +{
> +       struct nshhdr *nh;
> +       size_t length;
> +       __be16 inner_proto;
> +
> +       if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
> +               return -ENOMEM;
> +       nh = (struct nshhdr *)(skb->data);
> +       length = nsh_hdr_len(nh);
> +       inner_proto = tun_p_to_eth_p(nh->np);
> +       if (!pskb_may_pull(skb, length))
> +               return -ENOMEM;
> +
> +       if (!inner_proto)
> +               return -EAFNOSUPPORT;
> +
> +       skb_pull(skb, length);
same as above, we need to update the checksum.

> +       skb_reset_mac_header(skb);
> +       skb_reset_network_header(skb);
> +       skb_reset_mac_len(skb);
> +       skb->protocol = inner_proto;
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL_GPL(nsh_pop);
> +
>  static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
>                                        netdev_features_t features)
>  {
...

> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index a551232..dd1449d 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
...
> @@ -602,6 +640,67 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
>         return 0;
>  }
>
> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +                  const struct nlattr *a)
> +{
> +       struct nshhdr *nh;
> +       size_t length;
> +       int err;
> +       u8 flags;
> +       u8 ttl;
> +       int i;
> +
> +       struct ovs_key_nsh key;
> +       struct ovs_key_nsh mask;
> +
> +       err = nsh_key_from_nlattr(a, &key, &mask);
> +       if (err)
> +               return err;
> +
> +       /* Make sure the NSH base header is there */
> +       if (!pskb_may_pull(skb, skb_network_offset(skb) + NSH_BASE_HDR_LEN))
> +               return -ENOMEM;
> +
> +       nh = nsh_hdr(skb);
> +       length = nsh_hdr_len(nh);
> +
> +       /* Make sure the whole NSH header is there */
> +       err = skb_ensure_writable(skb, skb_network_offset(skb) +
> +                                      length);
> +       if (unlikely(err))
> +               return err;
> +
> +       nh = nsh_hdr(skb);
> +       flags = nsh_get_flags(nh);
> +       flags = OVS_MASKED(flags, key.base.flags, mask.base.flags);
> +       flow_key->nsh.base.flags = flags;
> +       ttl = nsh_get_ttl(nh);
> +       ttl = OVS_MASKED(ttl, key.base.ttl, mask.base.ttl);
> +       flow_key->nsh.base.ttl = ttl;
> +       nsh_set_flags_and_ttl(nh, flags, ttl);
> +       nh->path_hdr = OVS_MASKED(nh->path_hdr, key.base.path_hdr,
> +                                 mask.base.path_hdr);
> +       flow_key->nsh.base.path_hdr = nh->path_hdr;
> +       switch (nh->mdtype) {
> +       case NSH_M_TYPE1:
> +               for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++) {
> +                       nh->md1.context[i] =
> +                           OVS_MASKED(nh->md1.context[i], key.context[i],
> +                                      mask.context[i]);
> +               }
> +               memcpy(flow_key->nsh.context, nh->md1.context,
> +                      sizeof(nh->md1.context));
> +               break;
> +       case NSH_M_TYPE2:
> +               memset(flow_key->nsh.context, 0,
> +                      sizeof(flow_key->nsh.context));
> +               break;
> +       default:
> +               return -EINVAL;
> +       }
same as above need to fix checksum for CHECKSUM_COMPLETE case.

> +       return 0;
> +}
> +
