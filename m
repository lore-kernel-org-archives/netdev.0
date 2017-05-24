From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/4] [next-queue]net: mqprio: Introduce
 new hardware offload mode in mqprio for offloading full TC configurations
Date: Wed, 24 May 2017 14:59:59 -0700
Message-ID: <CAKgT0UeKf37YKbw2bgZKXs4Or4aK6p64zRSNk9ZSnc=kp0_JCQ@mail.gmail.com>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
 <149524190301.11022.16999010740843369111.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33429 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033240AbdEXWAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 18:00:01 -0400
Received: by mail-it0-f65.google.com with SMTP id l145so21291377ita.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 15:00:00 -0700 (PDT)
In-Reply-To: <149524190301.11022.16999010740843369111.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 5:58 PM, Amritha Nambiar
<amritha.nambiar@intel.com> wrote:
> This patch introduces a new hardware offload mode in mqprio
> which makes full use of the mqprio options, the TCs, the
> queue configurations and the bandwidth rates for the TCs.
> This is achieved by setting the value 2 for the "hw" option.
> This new offload mode supports new attributes for traffic
> class such as minimum and maximum values for bandwidth rate limits.
>
> Introduces a new datastructure 'tc_mqprio_qopt_offload' for offloading
> mqprio queue options and use this to be shared between the kernel and
> device driver. This contains a copy of the exisiting datastructure
> for mqprio queue options. This new datastructure can be extended when
> adding new attributes for traffic class such as bandwidth rate limits. The
> existing datastructure for mqprio queue options will be shared between the
> kernel and userspace.
>
> This patch enables configuring additional attributes associated
> with a traffic class such as minimum and maximum bandwidth
> rates and can be offloaded to the hardware in the new offload mode.
> The min and max limits for bandwidth rates are provided
> by the user along with the the TCs and the queue configurations
> when creating the mqprio qdisc.
>
> Example:
> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>   queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2
>
> To dump the bandwidth rates:
>
> # tc qdisc show dev eth0
> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>              queues:(0:3) (4:7)
>              min rates:0bit 0bit
>              max rates:55Mbit 60Mbit
>
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> ---
>  include/linux/netdevice.h      |    2
>  include/net/pkt_cls.h          |    7 ++
>  include/uapi/linux/pkt_sched.h |   13 +++
>  net/sched/sch_mqprio.c         |  169 +++++++++++++++++++++++++++++++++++++---
>  4 files changed, 180 insertions(+), 11 deletions(-)
>

[...]

> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> index 0a4cf27..6457ec9 100644
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -18,10 +18,13 @@
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
>  #include <net/sch_generic.h>
> +#include <net/pkt_cls.h>
>
>  struct mqprio_sched {
>         struct Qdisc            **qdiscs;
>         int hw_offload;
> +       u32 flags;
> +       u64 min_rate[TC_QOPT_MAX_QUEUE], max_rate[TC_QOPT_MAX_QUEUE];
>  };
>
>  static void mqprio_destroy(struct Qdisc *sch)
> @@ -39,10 +42,21 @@ static void mqprio_destroy(struct Qdisc *sch)
>         }
>
>         if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc) {
> -               struct tc_mqprio_qopt offload = { 0 };
> -               struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
> -                                          { .mqprio = &offload } };
> +               struct tc_mqprio_qopt_offload offload = { 0 };

So this is currently throwing a warning when I pull these patches and
build this with gcc 6.2. I think the correct setup is "offload = {{ 0
}}" in order to indicate that we are initializing the inner structure
and all other data to 0.

> +               struct tc_to_netdev tc = { 0 };
>
> +               switch (priv->hw_offload) {
> +               case TC_MQPRIO_HW_OFFLOAD_TCS:
> +                       tc.type = TC_SETUP_MQPRIO;
> +                       tc.mqprio = &offload.qopt;
> +                       break;
> +               case TC_MQPRIO_HW_OFFLOAD:
> +                       tc.type = TC_SETUP_MQPRIO_EXT;
> +                       tc.mqprio_qopt = &offload;
> +                       break;
> +               default:
> +                       return;
> +               }
>                 dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
>         } else {
>                 netdev_set_num_tc(dev, 0);
