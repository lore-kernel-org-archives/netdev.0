From: pravin shelar <pshelar@ovn.org>
Subject: Re: [ovs-dev] [PATCH 2/2] openvswitch: use percpu flow stats
Date: Mon, 12 Sep 2016 12:42:02 -0700
Message-ID: <CAOrHB_Cg_ekDr9GSRH4EkmtxyCNc1qx9wbknz4uJ+d-ae0LyMA@mail.gmail.com>
References: <1473453705-18804-1-git-send-email-cascardo@redhat.com> <1473453705-18804-2-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ovs dev <dev@openvswitch.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:55502 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754618AbcILTmH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 15:42:07 -0400
Received: from mfilter30-d.gandi.net (mfilter30-d.gandi.net [217.70.178.161])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id BF9D9A80C8
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 21:42:05 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter30-d.gandi.net (mfilter30-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id R6hi2wpQ8Unl for <netdev@vger.kernel.org>;
        Mon, 12 Sep 2016 21:42:04 +0200 (CEST)
Received: from mail-it0-f44.google.com (mail-it0-f44.google.com [209.85.214.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 3E633A80D1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 21:42:04 +0200 (CEST)
Received: by mail-it0-f44.google.com with SMTP id n143so21508680ita.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 12:42:04 -0700 (PDT)
In-Reply-To: <1473453705-18804-2-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 9, 2016 at 1:41 PM, Thadeu Lima de Souza Cascardo
<cascardo@redhat.com> wrote:
> Instead of using flow stats per NUMA node, use it per CPU. When using
> megaflows, the stats lock can be a bottleneck in scalability.
>
> On a E5-2690 12-core system, usual throughput went from ~4Mpps to
> ~15Mpps when forwarding between two 40GbE ports with a single flow
> configured on the datapath.
>
> This has been tested on a system with possible CPUs 0-7,16-23. After
> module removal, there were no corruption on the slab cache.
>
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> ---
>  net/openvswitch/flow.c       | 43 +++++++++++++++++++++++--------------------
>  net/openvswitch/flow.h       |  4 ++--
>  net/openvswitch/flow_table.c | 23 ++++++++++++-----------
>  3 files changed, 37 insertions(+), 33 deletions(-)
>
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 3609f37..2970a9f 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -29,6 +29,7 @@
>  #include <linux/module.h>
>  #include <linux/in.h>
>  #include <linux/rcupdate.h>
> +#include <linux/cpumask.h>
>  #include <linux/if_arp.h>
>  #include <linux/ip.h>
>  #include <linux/ipv6.h>
> @@ -72,32 +73,33 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
>  {
>         struct flow_stats *stats;
>         int node = numa_node_id();
> +       int cpu = get_cpu();
>         int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
>
This function is always called from BH context. So calling
smp_processor_id() for cpu id is fine. There is no need to handle
pre-emption here.

> -       stats = rcu_dereference(flow->stats[node]);
> +       stats = rcu_dereference(flow->stats[cpu]);
>
...
> diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
> index 957a3c3..60e5ae0 100644
> --- a/net/openvswitch/flow_table.c
> +++ b/net/openvswitch/flow_table.c
...

> @@ -102,9 +103,9 @@ struct sw_flow *ovs_flow_alloc(void)
>
>         RCU_INIT_POINTER(flow->stats[0], stats);
>
> -       for_each_node(node)
> -               if (node != 0)
> -                       RCU_INIT_POINTER(flow->stats[node], NULL);
> +       for_each_possible_cpu(cpu)
> +               if (cpu != 0)
> +                       RCU_INIT_POINTER(flow->stats[cpu], NULL);
>
I think at this point we should just use GFP_ZERO flag for allocating
struct flow.
