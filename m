From: Tom Herbert <tom@herbertland.com>
Subject: Re: [patch net-next v4 RFC 00/15] introduce programable flow
 dissector and cls_flower
Date: Sun, 26 Apr 2015 16:33:20 -0700
Message-ID: <CALx6S34mN5rh3oU6qU27=5vBDUPgDLssywN8F+K=tx51mMyazw@mail.gmail.com>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Thomas Graf <tgraf@suug.ch>, jesse@nicira.com,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	alexander.h.duyck@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	ast@plumgrid.com, daniel@iogearbox.net,
	Herbert Xu <herbert@gondor.apana.org.au>,
	cwang@twopensource.com, john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:38365 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbDZXdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 19:33:21 -0400
Received: by igbhj9 with SMTP id hj9so49727150igb.1
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2015 16:33:20 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 8:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Per Davem's request, I prepared this patchset which introduces programmable
> flow dissector. For current users of flow_keys, there is a wrapper
> skb_flow_dissect_flow_keys which maintains the previous behaviour.
> For purposes of cls_flower, couple of new dissection keys were introduced.
>
> Note that this dissector can be also eventually used by openvswitch code.
>
> Also, I plan to get rid of *skb_flow_get_ports(export) and *__skb_get_poff as
> their functionality can be now implemented by skb_flow_dissect as well.
>
> Ideas, comments?
>
HI Jiri,

Looking a little more closely at your patches I'm not convinced this
complexity is justified; it seems like this is moving flow_dissector
to be more of a general packet parser rather than adhering to its
original prinicples which was to extract just enough information from
packet to create a good hash for the packet's flow. For improving
packet hashing, I would rather judiciously extend the flow_keys
structure to include full IPv6 address, add a *few* other fields such
as VLAN and flow label, and then hash over the the whole structure
especially eliminating use of xor which doesn't do squat in making a
DOS resilient hash. We are potentially calling flow_dissector on every
RX packets, and many TX packets via skb_hash-- this needs to be simple
and efficient. Also, making something like IP address and ports
optional to return doesn't seem like a lot of value to me-- why not
just always return it to the caller in flow_keys and they can ignore
any fields they want-- adding conditionals for IP address and ports
inclusion will only slow down the common critical path use case.

I imagine programmatic packet parser might have some interesting use
cases, but maybe this should be spun off as a separate function. If we
did that then the output wouldn't need to be limited to just the
restricted flow identification fields, but could include whatever else
in a packet might be interesting-- TOS, TTL, TCP flags, both inner and
outer addresses, etc.

btw, can you please split the cosmetic changes and material changes
into two patch sets, this will make reviewing them a lot easier!

Thanks,
Tom

> Jiri Pirko (15):
>   net: change name of flow_dissector header to match the .c file name
>   flow_dissector: remove unused function flow_get_hlen declaration
>   net: move *skb_get_poff declarations into correct header
>   flow_dissector: fix doc for __skb_get_hash and remove couple of empty
>     lines
>   net: move __skb_get_hash function declaration to flow_dissector.h
>   net: move __skb_tx_hash to skbuff.c
>   net: move netdev_pick_tx and dependencies to net/core/dev.c
>   flow_dissector: fix doc for skb_get_poff
>   flow_dissector: introduce programable flow_dissector
>   flow_dissect: use programable dissector in skb_flow_dissect and
>     friends
>   flow_dissector: add missing header includes
>   flow_dissector: introduce support for ipv6 addressses
>   flow_dissector: introduce support for Ethernet addresses
>   flow_dissector: change port array into src,dst tuple
>   tc: introduce Flower classifier
>
>  drivers/net/bonding/bond_main.c                |  20 +-
>  drivers/net/ethernet/cisco/enic/enic_clsf.c    |  29 +-
>  drivers/net/ethernet/cisco/enic/enic_ethtool.c |  10 +-
>  drivers/net/hyperv/netvsc_drv.c                |   8 +-
>  include/linux/skbuff.h                         |  11 +-
>  include/net/flow_dissector.h                   | 152 ++++++
>  include/net/flow_keys.h                        |  45 --
>  include/net/ip.h                               |  10 +-
>  include/net/ipv6.h                             |  10 +-
>  include/uapi/linux/pkt_cls.h                   |  31 ++
>  net/core/dev.c                                 |  78 +++
>  net/core/filter.c                              |   1 +
>  net/core/flow_dissector.c                      | 376 ++++++++------
>  net/core/skbuff.c                              |  28 +
>  net/ethernet/eth.c                             |   7 +-
>  net/sched/Kconfig                              |  10 +
>  net/sched/Makefile                             |   1 +
>  net/sched/cls_flow.c                           |  22 +-
>  net/sched/cls_flower.c                         | 688 +++++++++++++++++++++++++
>  net/sched/sch_choke.c                          |   6 +-
>  net/sched/sch_fq_codel.c                       |  10 +-
>  net/sched/sch_hhf.c                            |  10 +-
>  net/sched/sch_sfb.c                            |  22 +-
>  net/sched/sch_sfq.c                            |  10 +-
>  24 files changed, 1292 insertions(+), 303 deletions(-)
>  create mode 100644 include/net/flow_dissector.h
>  delete mode 100644 include/net/flow_keys.h
>  create mode 100644 net/sched/cls_flower.c
>
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
