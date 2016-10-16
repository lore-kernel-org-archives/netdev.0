From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next RFC 4/6] Introduce sample tc action
Date: Sun, 16 Oct 2016 13:27:14 +0300
Message-ID: <CAJ3xEMivz1cPutHyyU8_=dvbwmkPCgJYC8xTxF4NHjuSmq8cRw@mail.gmail.com>
References: <1476276069-5315-1-git-send-email-jiri@resnulli.us> <1476276069-5315-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, geert+renesas@glider.be,
        Stephen Hemminger <stephen@networkplumber.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Guenter Roeck <linux@roeck-us.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:32972 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752904AbcJPK1Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2016 06:27:16 -0400
Received: by mail-oi0-f67.google.com with SMTP id i127so10581734oia.0
        for <netdev@vger.kernel.org>; Sun, 16 Oct 2016 03:27:16 -0700 (PDT)
In-Reply-To: <1476276069-5315-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 3:41 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Yotam Gigi <yotam.gi@gmail.com>
>
> This action allow the user to sample traffic matched by tc classifier.
> The sampling consists of choosing packets randomly, truncating them,
> adding some informative metadata regarding the interface and the original
> packet size and mark them with specific mark, to allow further tc rules to
> match and process. The marked sample packets are then injected into the
> device ingress qdisc using netif_receive_skb.
>
> The packets metadata is packed using the ife encapsulation protocol, and
> the outer packet's ethernet dest, source and eth_type, along with the
> rate, mark and the optional truncation size can be configured from
> userspace.
>
> Example:
> To sample ingress traffic from interface eth1, and redirect the sampled
> the sampled packets to interface dummy0, one may use the commands:
>
> tc qdisc add dev eth1 handle ffff: ingress
>
> tc filter add dev eth1 parent ffff: \
>            matchall action sample rate 12 mark 17
>
> tc filter add parent ffff: dev eth1 protocol all \
>            u32 match mark 172 0xff
>            action mirred egress redirect dev dummy0
>
> Where the first command adds an ingress qdisc and the second starts
> sampling every 12'th packet on dev eth0 and marks the sampled packets with
> 17. The command third catches the sampled packets, which are marked with
> 17, and redirects them to dev dummy0.

eth0 --> eth1

command third --> third command

don't we need a re-classify directive for the u32 filter to apply
after the marking done by the matchall rule + sample action
or is that implicit?


> diff --git a/include/net/tc_act/tc_sample.h b/include/net/tc_act/tc_sample.h
> new file mode 100644
> index 0000000..a2b445a
> --- /dev/null
> +++ b/include/net/tc_act/tc_sample.h
> @@ -0,0 +1,88 @@
> +#ifndef __NET_TC_SAMPLE_H
> +#define __NET_TC_SAMPLE_H
> +
> +#include <net/act_api.h>
> +#include <linux/tc_act/tc_sample.h>
> +
> +struct tcf_sample {
> +       struct tc_action        common;
> +       u32                     rate;
> +       u32                     mark;
> +       bool                    truncate;
> +       u32                     trunc_size;
> +       u32                     packet_counter;
> +       u8                      eth_dst[ETH_ALEN];
> +       u8                      eth_src[ETH_ALEN];
> +       u16                     eth_type;
> +       bool                    eth_type_set;
> +       struct list_head        tcfm_list;
> +};

> +++ b/include/uapi/linux/tc_act/tc_sample.h
> @@ -0,0 +1,31 @@
> +#ifndef __LINUX_TC_SAMPLE_H
> +#define __LINUX_TC_SAMPLE_H
> +
> +#include <linux/types.h>
> +#include <linux/pkt_cls.h>
> +#include <linux/if_ether.h>
> +
> +#define TCA_ACT_SAMPLE 26
> +
> +struct tc_sample {
> +       tc_gen;
> +       __u32           rate;           /* sample rate */
> +       __u32           mark;           /* mark to put on the sampled packets */
> +       bool            truncate;       /* whether to truncate the packets */
> +       __u32           trunc_size;     /* truncation size */
> +       __u8            eth_dst[ETH_ALEN]; /* encapsulated mac destination */
> +       __u8            eth_src[ETH_ALEN]; /* encapsulated mac source */
> +       bool            eth_type_set;      /* whether to overrid ethtype */
> +       __u16           eth_type;          /* encapsulated mac ethtype */
> +};

overrid --> override

what do you mean by override here, to encapsulate?

consider using 0 as special value, e.g no truncation and no encapsulation

best if you just define the netlink attributes (document on the RHS
the type, see the uapi
for the new tunnel key action) and let the tc action in-kernel code to
decode them directly
into the non UAPI structure. This way you are extendable and also
avoid having two
structs which is sort of confusing.

> +
> +enum {
> +       TCA_SAMPLE_UNSPEC,
> +       TCA_SAMPLE_TM,
> +       TCA_SAMPLE_PARMS,
> +       TCA_SAMPLE_PAD,
> +       __TCA_SAMPLE_MAX
> +};
> +#define TCA_SAMPLE_MAX (__TCA_SAMPLE_MAX - 1)
> +
> +#endif


> +static bool dev_ok_push(struct net_device *dev)
> +{
> +       switch (dev->type) {
> +       case ARPHRD_TUNNEL:
> +       case ARPHRD_TUNNEL6:
> +       case ARPHRD_SIT:
> +       case ARPHRD_IPGRE:
> +       case ARPHRD_VOID:
> +       case ARPHRD_NONE:
> +               return false;
> +       default:
> +               return true;
> +       }
> +}
> +

> +static int tcf_sample(struct sk_buff *skb, const struct tc_action *a,
> +                     struct tcf_result *res)
> +{
> +       struct tcf_sample *s = to_sample(a);
> +       struct sample_packet_metadata metadata;
> +       static struct ethhdr *ethhdr;
> +       struct sk_buff *skb2;
> +       int retval;
> +       u32 at;
> +
> +       tcf_lastuse_update(&s->tcf_tm);
> +       bstats_cpu_update(this_cpu_ptr(s->common.cpu_bstats), skb);
> +
> +       rcu_read_lock();
> +       retval = READ_ONCE(s->tcf_action);
> +
> +       if (++s->packet_counter % s->rate == 0) {
> +               skb2 = skb_copy(skb, GFP_ATOMIC);
> +               if (!skb2)
> +                       goto out;
> +
> +               if (s->truncate)
> +                       skb_trim(skb2, s->trunc_size);
> +
> +               at = G_TC_AT(skb->tc_verd);
> +               skb2->mac_len = skb->mac_len;
> +
> +               /* on ingress, the mac header gets poped, so push it back */
> +               if (!(at & AT_EGRESS) && dev_ok_push(skb->dev))
> +                       skb_push(skb2, skb2->mac_len);
> +

what's the exact role of the !(at & AT_EGRESS) check?

and if !dev_ok_push(.) - are we just fine to continue here without
that push? maybe
worth documenting that corner a bit



> +               metadata.ifindex = skb->dev->ifindex;
> +               metadata.orig_size = skb->len + skb->dev->hard_header_len;
> +               metadata.sample_size = skb2->len;
> +               ethhdr = sample_packet_pack(skb2, (void *)&metadata);
> +               if (!ethhdr)
> +                       goto out;
> +
> +               if (!is_zero_ether_addr(s->eth_src))
> +                       ether_addr_copy(ethhdr->h_source, s->eth_src);
> +               if (!is_zero_ether_addr(s->eth_dst))
> +                       ether_addr_copy(ethhdr->h_dest, s->eth_dst);
> +               if (s->eth_type_set)
> +                       ethhdr->h_proto = htons(s->eth_type);
> +
> +               skb2->mark = s->mark;
> +               netif_receive_skb(skb2);
> +
> +               /* mirror is always swallowed */
> +               skb2->tc_verd = SET_TC_FROM(skb2->tc_verd, at);
> +       }
> +out:
> +       rcu_read_unlock();
> +
> +       return retval;
> +}
