From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Tue, 02 Sep 2014 15:37:23 +0800
Message-ID: <540573B3.2010904@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com> <1408608310-13579-2-git-send-email-jasowang@redhat.com> <1408683665.5648.69.camel@marge.simpson.net> <53F6F14B.1030609@redhat.com> <20140822074224.GB7372@gmail.com> <53FFEEC0.4000304@redhat.com> <540414AB.9000004@linux.intel.com> <54053998.4040604@redhat.com> <54056076.2030603@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbaIBHiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 03:38:00 -0400
In-Reply-To: <54056076.2030603@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 02:15 PM, Eliezer Tamir wrote:
> On 02/09/2014 06:29, Jason Wang wrote:
>> On 09/01/2014 02:39 PM, Eliezer Tamir wrote:
>>> On 29/08/2014 06:08, Jason Wang wrote:
>>>>> Yes, but rx busy polling only works in process context and does not
>>>>> disable bh, so it may be not an issue.
>>> sk_busy_loop() uses rcu_read_lock_bh(), so it does run with bh disabled.
>> True, so we need probably also exit the loop when there are pending bhs.
> I'm not so sure, in the typical busy poll scenario, the incoming
> traffic is the most time-critical thing in the system.
> It's so important that you are willing to trade lots of CPU power
> for better latency. The user has decided that he wants to dedicate
> this CPU mostly for that. 

But user should increase the process priority or cgroup in this case.
> This is not something that plays nice with
> other apps, but this is what the user wants.

So the busy polling looks have a higher priority somehow than other
processes.
> So, you definitely don't want to starve any bh, and you should
> regularly re-enable bh's, but you also don't want to stop everything
> at any time a bh is scheduled.

If I get your meaning, you may want call to rcu_read_lock_bh() and get
socket napi id inside the do{} loop? This seems can prevent bhs from
being starved and can also handle the case that the packets were from
different NAPIs.
>
> You also want network processing on the queues that are busy polled
> to come through busy polling and not through NAPI, which is run in bh
> context.
>
> -Eliezer
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
