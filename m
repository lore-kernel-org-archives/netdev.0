From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RCU PATCH 00/14] Remove qdisc lock around ingress Qdisc
Date: Wed, 12 Mar 2014 11:25:29 -0700
Message-ID: <CAM_iQpUd=KDVG-6hxQCeHKp+LRx6Yi5jSUo2MEivJiar+QETGg@mail.gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:60699 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbaCLSZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 14:25:29 -0400
Received: by mail-ob0-f177.google.com with SMTP id wo20so10071437obc.36
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 11:25:29 -0700 (PDT)
In-Reply-To: <20140310170008.3011.73599.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 10:03 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> This series drops the qdisc lock that is currently protecting the
> ingress qdisc. This can be done after the tcf filters are made
> lockless and the statistic accounting is safe to run without locks.
>
> To do this the classifiers are converted to use RCU. This requires
> updating each classifier individually to handle the new copy/update
> requirement and also to update the core list traversals. This is
> done in patches 2-11. This also makes the assumption that updates
> to the tables are infrequent in comparison to the packet per second
> being classified. On a 10Gbps running near line rate we can easily
> produce 12+ million packets per second so IMO this is a reasonable
> assumption. And the updates are serialized by RTNL.
>
> In order to have working statistics patch 13 converts the bstats,
> which do accounting for bytes and packets, into percpu variables
> and the u64_stats_update_{begin|end} infrastructure is used to
> maintain consistent statistics. Because these statistics are also
> used by the estimators those function calls had to be udpated as
> well. So that I didn't have to modify all qdiscs at this time many
> of which don't have an easy path to make lockless the percpu
> statistics are only used when the TCQ_F_LLQDISC flag is set. Its
> worth noting that in the mq and mqprio case sub-qdisc's are already
> mapped 1:1 with TX queues which tend to be equal to the number
> of CPUs in the system so its not clear that removing locking in
> these cases would provide any benefit. Most likely a new qdisc
> written from scratch would be needed to implement a mq-htb or
> mq-tbf qdisc.
>
> As for some history I wrote what was basically these patches some
> time ago and then got stalled working on other things. Cong Wang
> made a proposal to remove the locking around the ingress qdisc
> which then kicked me to get these patches working again.
>
> I have started to test this series and do no see any immediate
> splats or issues. I will continue doing some more testing for the
> rest of the week before submitting without the RCU tag but any
> feedback would be good. If someone has a better idea for the
> percpu union of gnet_stats_basic_* in struct Qdisc or finds it
> paticularly ugly that would be good to know.

I assume you mean RFC, otherwise RCU tag doesn't make
any sense to me.

And what about sch->qstats? You seem still don't touch it
in this patchset, and it is you who pointed out qstats.drop++
is not atomic on all architecture to me. :)
