From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [next-queue PATCH v5 3/5] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Wed, 11 Oct 2017 08:58:09 +0200
Message-ID: <20171011065809.GB2039@nanopsycho>
References: <20171011004400.14946-1-vinicius.gomes@intel.com>
 <20171011004400.14946-4-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:49693 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdJKG6L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 02:58:11 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so2353411wmd.4
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 23:58:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171011004400.14946-4-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 11, 2017 at 02:43:58AM CEST, vinicius.gomes@intel.com wrote:
>This queueing discipline implements the shaper algorithm defined by
>the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>
>It's primary usage is to apply some bandwidth reservation to user
>defined traffic classes, which are mapped to different queues via the
>mqprio qdisc.
>
>Only a simple software implementation is added for now.
>
>Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
>Signed-off-by: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
>---
> include/linux/netdevice.h      |   1 +
> include/net/pkt_sched.h        |   9 ++
> include/uapi/linux/pkt_sched.h |  18 +++
> net/sched/Kconfig              |  11 ++
> net/sched/Makefile             |   1 +
> net/sched/sch_cbs.c            | 305 +++++++++++++++++++++++++++++++++++++++++
> 6 files changed, 345 insertions(+)
> create mode 100644 net/sched/sch_cbs.c
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index 31bb3010c69b..1f6c44ef5b21 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -775,6 +775,7 @@ enum tc_setup_type {
> 	TC_SETUP_CLSFLOWER,
> 	TC_SETUP_CLSMATCHALL,
> 	TC_SETUP_CLSBPF,
>+	TC_SETUP_CBS,
> };
> 
> /* These structures hold the attributes of xdp state that are being passed
>diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
>index 259bc191ba59..7c597b050b36 100644
>--- a/include/net/pkt_sched.h
>+++ b/include/net/pkt_sched.h
>@@ -146,4 +146,13 @@ static inline bool is_classid_clsact_egress(u32 classid)
> 	       TC_H_MIN(classid) == TC_H_MIN(TC_H_MIN_EGRESS);
> }
> 
>+struct tc_cbs_qopt_offload {
>+	u8 enable;
>+	s32 queue;
>+	s32 hicredit;
>+	s32 locredit;
>+	s32 idleslope;
>+	s32 sendslope;

Please introduce the qdisc in one patch, then offload it in second. That
is what I requested already. 2 patches please.

[...]


>+static struct Qdisc_ops cbs_qdisc_ops __read_mostly = {
>+	.next		=	NULL,

It is already 0, no need to re-init.


>+	.id		=	"cbs",
>+	.priv_size	=	sizeof(struct cbs_sched_data),
>+	.enqueue	=	cbs_enqueue,
>+	.dequeue	=	cbs_dequeue,
>+	.peek		=	qdisc_peek_dequeued,
>+	.init		=	cbs_init,
>+	.reset		=	qdisc_reset_queue,
>+	.destroy	=	cbs_destroy,
>+	.change		=	cbs_change,
>+	.dump		=	cbs_dump,
>+	.owner		=	THIS_MODULE,
>+};
