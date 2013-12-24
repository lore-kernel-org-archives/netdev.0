From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Mon, 23 Dec 2013 22:08:49 -0800
Message-ID: <52B924F1.9020201@gmail.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com> <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com> <52B4FDD1.10608@intel.com> <52B61222.8080000@mojatatu.com> <52B61FA3.9050904@gmail.com> <CAM_iQpWAdsT=HX6AdK8oqPOFwzpBvPN__335Fuv3zEeS4HEWHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:51497 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914Ab3LXGJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Dec 2013 01:09:13 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so6450039oah.8
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 22:09:13 -0800 (PST)
In-Reply-To: <CAM_iQpWAdsT=HX6AdK8oqPOFwzpBvPN__335Fuv3zEeS4HEWHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/23/2013 04:56 PM, Cong Wang wrote:
> On Sat, Dec 21, 2013 at 3:09 PM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>>
>> I solved this by making them per CPU and synchronizing when I hit
>> an operation that required sync'ing them. Going forward if folks
>> have the time to write SMP aware qdisc's that work with eventually
>> consistent counters that would be great.
>>
>
> Interesting, then you have to copy the same filters and actions
> to all per-cpu-ingress-qdisc, right? Also you need to handle
> CPU online/offline event.
>
> The number of CPU's grows fast today, so the total size
> of such ingress qdisc would be huge if I install lots
> of filters and action.
>

In this case I was specifically talking about statistics so the
bstats and qstats.

As long as the qdisc's do not require global state this works well
enough. However as Jamal keeps pointing out the problem is any qdisc
which requires global state requires locking (I paraphrase but I think
replicate the spirit correctly) and this doesn't work well with many
CPUs. So you either replicate the qdiscs one per queue like we do in
the mq and mqprio case effectively removing any global state or you
develop qdiscs that don't require global state or at least work with
eventually consistent data to avoid the constant syncing of data.

I think though a qdisc per nic queue is really not as bad as you think.
For example we do this on the tx side and it works OK. Note its per
RX queue and not per CPU.

.John



-- 
John Fastabend         Intel Corporation
