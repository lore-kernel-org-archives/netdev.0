From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [next-queue PATCH v6 2/5] mqprio: Implement
 select_queue class_ops
Date: Thu, 12 Oct 2017 08:21:29 -0700
Message-ID: <CAKgT0Ufo1tG4GpSkGaWuUxqhzEUOT7wcBLuaZx_mZmEL+9SnXw@mail.gmail.com>
References: <20171012005449.26533-1-vinicius.gomes@intel.com> <20171012005449.26533-3-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        rodney.cummings@ni.com, andre.guedes@intel.com,
        Jiri Pirko <jiri@resnulli.us>, ivan.briano@intel.com,
        Richard Cochran <richardcochran@gmail.com>, henrik@austad.us,
        Jamal Hadi Salim <jhs@mojatatu.com>, levipearson@gmail.com,
        boon.leong.ong@intel.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:56187 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdJLPVb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 11:21:31 -0400
Received: by mail-qk0-f194.google.com with SMTP id x82so1629127qkb.12
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 08:21:31 -0700 (PDT)
In-Reply-To: <20171012005449.26533-3-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 5:54 PM, Vinicius Costa Gomes
<vinicius.gomes@intel.com> wrote:
> From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>
> When replacing a child qdisc from mqprio, tc_modify_qdisc() must fetch
> the netdev_queue pointer that the current child qdisc is associated
> with before creating the new qdisc.
>
> Currently, when using mqprio as root qdisc, the kernel will end up
> getting the queue #0 pointer from the mqprio (root qdisc), which leaves
> any new child qdisc with a possibly wrong netdev_queue pointer.
>
> Implementing the Qdisc_class_ops select_queue() on mqprio fixes this
> issue and avoid an inconsistent state when child qdiscs are replaced.
>
> Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> ---
>  net/sched/sch_mqprio.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> index 6bcdfe6e7b63..8c042ae323e3 100644
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -396,6 +396,12 @@ static void mqprio_walk(struct Qdisc *sch, struct qdisc_walker *arg)
>         }
>  }
>
> +static struct netdev_queue *mqprio_select_queue(struct Qdisc *sch,
> +                                               struct tcmsg *tcm)
> +{
> +       return mqprio_queue_get(sch, TC_H_MIN(tcm->tcm_parent));
> +}
> +

So I was just comparing this against mq_selet_queue, and I was
wondering why we are willing to return NULL here instead of just
returning a pointer to the first Tx queue? I realize there is the fix
in the first patch but it seems like if we are going to go that route
then maybe we should update mq as well so that both of these qdiscs
behave the same way. Either this should work like mq, or mq should
work like this, but we shouldn't have them exposing different
behaviors.

>  static const struct Qdisc_class_ops mqprio_class_ops = {
>         .graft          = mqprio_graft,
>         .leaf           = mqprio_leaf,
> @@ -403,6 +409,7 @@ static const struct Qdisc_class_ops mqprio_class_ops = {
>         .walk           = mqprio_walk,
>         .dump           = mqprio_dump_class,
>         .dump_stats     = mqprio_dump_class_stats,
> +       .select_queue   = mqprio_select_queue,
>  };
>
>  static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
> --
> 2.14.2
>
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
