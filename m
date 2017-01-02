From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next rfc 0/6] convert tc_verd to integer bitfields
Date: Mon, 2 Jan 2017 11:09:57 -0500
Message-ID: <c32d7b7c-3dd3-2d75-5f9a-e356f1fc7732@mojatatu.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>,
        Roman Mashak <mrv@mojatatu.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35624 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751797AbdABQKA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 11:10:00 -0500
Received: by mail-it0-f67.google.com with SMTP id b123so48436867itb.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 08:10:00 -0800 (PST)
In-Reply-To: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And a happy new year netdev.
No objections to new year resolution of slimming the skb.
But: i am still concerned about the recursion that getting rid of
some of these bits could embolden. i.e my suggestion was infact to
restore some of those bits taken away by Florian after the ingress
redirect patches from Shmulik.

The possibilities are: egress->egress, egress->ingress,
ingress->egress, ingress->ingress. The suggestion was
xmit_recursion with some skb magic would suffice.
Hannes promised around last netdevconf that he has a scheme to solve
it without using any extra skb state.

cheers,
jamal

On 16-12-28 02:13 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> The skb tc_verd field takes up two bytes but uses far fewer bits.
> Convert the remaining use cases to bitfields that fit in existing
> holes (depending on config options) and potentially save the two
> bytes in struct sk_buff.
>
> This patchset is based on an earlier set by Florian Westphal and its
> discussion (http://www.spinics.net/lists/netdev/msg329181.html).
>
> Patches 1 and 2 are low hanging fruit: removing the last traces of
>   data that are no longer stored in tc_verd.
>
> Patches 3 and 4 convert tc_verd to individual bitfields (5 bits).
>
> Patch 5 reduces TC_AT to a single bitfield,
>   as AT_STACK is not valid here (unlike in the case of TC_FROM).
>
> Patch 6 changes TC_FROM to two bitfields with clearly defined purpose.
>
> It may be possible to reduce storage further after this initial round.
> If tc_skip_classify is set only by IFB, testing skb_iif may suffice.
> The L2 header pushing/popping logic can perhaps be shared with
> AF_PACKET, which currently not pkt_type for the same purpose.
>
> Tested ingress mirred + netem + ifb:
>
>   ip link set dev ifb0 up
>   tc qdisc add dev eth0 ingress
>   tc filter add dev eth0 parent ffff: \
>     u32 match ip dport 8000 0xffff \
>     action mirred egress redirect dev ifb0
>   tc qdisc add dev ifb0 root netem delay 1000ms
>   nc -u -l 8000 &
>   ssh $otherhost nc -u $host 8000
>
> Tested egress mirred:
>
>   ip link add veth1 type veth peer name veth2
>   ip link set dev veth1 up
>   ip link set dev veth2 up
>   tcpdump -n -i veth2 udp and dst port 8000 &
>
>   tc qdisc add dev eth0 root handle 1: prio
>   tc filter add dev eth0 parent 1:0 \
>     u32 match ip dport 8000 0xffff \
>     action mirred egress redirect dev veth1
>   tc qdisc add dev veth1 root netem delay 1000ms
>   nc -u $otherhost 8000
>
> Willem de Bruijn (6):
>   net-tc: remove unused tc_verd fields
>   net-tc: make MAX_RECLASSIFY_LOOP local
>   net-tc: extract skip classify bit from tc_verd
>   net-tc: convert tc_verd to integer bitfields
>   net-tc: convert tc_at to tc_at_ingress
>   net-tc: convert tc_from to tc_from_ingress and tc_redirected
>
>  drivers/net/ifb.c                    | 16 ++++-------
>  drivers/staging/octeon/ethernet-tx.c |  5 ++--
>  include/linux/skbuff.h               | 15 ++++++----
>  include/net/sch_generic.h            | 20 ++++++++++++-
>  include/uapi/linux/pkt_cls.h         | 55 ------------------------------------
>  net/core/dev.c                       | 20 ++++---------
>  net/core/pktgen.c                    |  4 +--
>  net/core/skbuff.c                    |  3 --
>  net/sched/act_api.c                  |  8 ++----
>  net/sched/act_ife.c                  |  7 ++---
>  net/sched/act_mirred.c               | 21 +++++++-------
>  net/sched/sch_api.c                  |  4 ++-
>  net/sched/sch_netem.c                |  2 +-
>  13 files changed, 64 insertions(+), 116 deletions(-)
>
