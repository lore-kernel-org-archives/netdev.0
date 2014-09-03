From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next 01/13] openvswitch: split flow structures into
 ovs specific and generic ones
Date: Wed, 3 Sep 2014 11:41:39 -0700
Message-ID: <CALnjE+pscRmfhaWgkWCunJfjvG04RiNUAj6nefSFHrknQTC+xw@mail.gmail.com>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
	<1409736300-12303-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	andy@greyhouse.net, Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	Cong Wang <xiyou.wangcong@gmail.com>,
	john.r.fastabend@intel.com, Eric Dumazet <edumazet@google.com>,
	jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	John Linville <linville@tuxdriver.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>, jasowang@redhat.com,
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.s
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:49319 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754141AbaICSlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 14:41:52 -0400
Received: by mail-ig0-f179.google.com with SMTP id r2so9619529igi.0
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 11:41:39 -0700 (PDT)
In-Reply-To: <1409736300-12303-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 2:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> After this, flow related structures can be used in other code.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/net/sw_flow.h          |  99 ++++++++++++++++++++++++++++++++++
>  net/openvswitch/actions.c      |   3 +-
>  net/openvswitch/datapath.c     |  74 +++++++++++++-------------
>  net/openvswitch/datapath.h     |   4 +-
>  net/openvswitch/flow.c         |   6 +--
>  net/openvswitch/flow.h         | 102 +++++++----------------------------
>  net/openvswitch/flow_netlink.c |  53 +++++++++---------
>  net/openvswitch/flow_netlink.h |  10 ++--
>  net/openvswitch/flow_table.c   | 118 ++++++++++++++++++++++-------------------
>  net/openvswitch/flow_table.h   |  30 +++++------
>  net/openvswitch/vport-gre.c    |   4 +-
>  net/openvswitch/vport-vxlan.c  |   2 +-
>  net/openvswitch/vport.c        |   2 +-
>  net/openvswitch/vport.h        |   2 +-
>  14 files changed, 276 insertions(+), 233 deletions(-)
>  create mode 100644 include/net/sw_flow.h
>
> diff --git a/include/net/sw_flow.h b/include/net/sw_flow.h
> new file mode 100644
> index 0000000..21724f1
> --- /dev/null
> +++ b/include/net/sw_flow.h
> @@ -0,0 +1,99 @@
> +/*
> + * include/net/sw_flow.h - Generic switch flow structures
> + * Copyright (c) 2007-2012 Nicira, Inc.
> + * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef _NET_SW_FLOW_H_
> +#define _NET_SW_FLOW_H_
> +
> +struct sw_flow_key_ipv4_tunnel {
> +       __be64 tun_id;
> +       __be32 ipv4_src;
> +       __be32 ipv4_dst;
> +       __be16 tun_flags;
> +       u8   ipv4_tos;
> +       u8   ipv4_ttl;
> +};
> +
> +struct sw_flow_key {
> +       struct sw_flow_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
> +       struct {
> +               u32     priority;       /* Packet QoS priority. */
> +               u32     skb_mark;       /* SKB mark. */
> +               u16     in_port;        /* Input switch port (or DP_MAX_PORTS). */
> +       } __packed phy; /* Safe when right after 'tun_key'. */
> +       struct {
> +               u8     src[ETH_ALEN];   /* Ethernet source address. */
> +               u8     dst[ETH_ALEN];   /* Ethernet destination address. */
> +               __be16 tci;             /* 0 if no VLAN, VLAN_TAG_PRESENT set otherwise. */
> +               __be16 type;            /* Ethernet frame type. */
> +       } eth;
> +       struct {
> +               u8     proto;           /* IP protocol or lower 8 bits of ARP opcode. */
> +               u8     tos;             /* IP ToS. */
> +               u8     ttl;             /* IP TTL/hop limit. */
> +               u8     frag;            /* One of OVS_FRAG_TYPE_*. */
> +       } ip;
> +       struct {
> +               __be16 src;             /* TCP/UDP/SCTP source port. */
> +               __be16 dst;             /* TCP/UDP/SCTP destination port. */
> +               __be16 flags;           /* TCP flags. */
> +       } tp;
> +       union {
> +               struct {
> +                       struct {
> +                               __be32 src;     /* IP source address. */
> +                               __be32 dst;     /* IP destination address. */
> +                       } addr;
> +                       struct {
> +                               u8 sha[ETH_ALEN];       /* ARP source hardware address. */
> +                               u8 tha[ETH_ALEN];       /* ARP target hardware address. */
> +                       } arp;
> +               } ipv4;
> +               struct {
> +                       struct {
> +                               struct in6_addr src;    /* IPv6 source address. */
> +                               struct in6_addr dst;    /* IPv6 destination address. */
> +                       } addr;
> +                       __be32 label;                   /* IPv6 flow label. */
> +                       struct {
> +                               struct in6_addr target; /* ND target address. */
> +                               u8 sll[ETH_ALEN];       /* ND source link layer address. */
> +                               u8 tll[ETH_ALEN];       /* ND target link layer address. */
> +                       } nd;
> +               } ipv6;
> +       };
> +} __aligned(BITS_PER_LONG/8); /* Ensure that we can do comparisons as longs. */
> +

HW offload API should be separate from OVS module. This has following
advantages.
1. It can be managed by OVS userspace vswitchd process which has much
better context to setup hardware flow table. Once we add capabilities
for swdev, it is much more easier for vswitchd process to choose
correct (hw or sw) flow table for given flow.
2. Other application that wants to use HW offload does not have
dependency on OVS kernel module.
3. Hardware and software datapath remains separate, these two
components has no dependency on each other, both can be developed
independent of each other.

Thanks.
