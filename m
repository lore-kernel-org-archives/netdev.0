From: John Stultz <john.stultz@linaro.org>
Subject: Re: [PATCH 1/4] [RFC] net: Explicitly initialize u64_stats_sync structures
 for lockdep
Date: Thu, 26 Sep 2013 12:39:04 -0700
Message-ID: <52448D58.9060503@linaro.org>
References: <1380220464-28840-1-git-send-email-john.stultz@linaro.org>	 <1380220464-28840-2-git-send-email-john.stultz@linaro.org> <1380223585.3165.205.camel@edumazet-glaptop> <52448C46.2050107@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Roger Luethi <rl@hellgate.ch>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>, Jesse Gross <jesse@nicira.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:44553 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab3IZTjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 15:39:09 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so1573820pbb.14
        for <netdev@vger.kernel.org>; Thu, 26 Sep 2013 12:39:08 -0700 (PDT)
In-Reply-To: <52448C46.2050107@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2013 12:34 PM, John Stultz wrote:
> On 09/26/2013 12:26 PM, Eric Dumazet wrote:
>> On Thu, 2013-09-26 at 11:34 -0700, John Stultz wrote:
>>> In order to enable lockdep on seqcount/seqlock structures, we
>>> must explicitly initialize any locks.
>>>
>>> diff --git a/include/linux/u64_stats_sync.h b/include/linux/u64_stats_sync.h
>>> index 8da8c4e..c450e11 100644
>>> --- a/include/linux/u64_stats_sync.h
>>> +++ b/include/linux/u64_stats_sync.h
>>> @@ -67,6 +67,13 @@ struct u64_stats_sync {
>>>  #endif
>>>  };
>>>  
>>> +
>>> +#if BITS_PER_LONG == 32 && defined(CONFIG_SMP)
>>> +#define u64_stats_init(syncp)	seqcount_init(syncp.seq)
>>> +#else
>>> +#define u64_stats_init(syncp)
>>> +#endif
>>> +
>> I would prefer a function.
>>
>> static inline void u64_stats_init(struct u64_stats_sync *syncp)
>> {
>> #if BITS_PER_LONG == 32 && defined(CONFIG_SMP)
>> 	seqcount_init(&syncp->seq);
>> #endif
>> }
> No objection, though I worry that will obscure the lockdep key name,
> causing all the u64_stat_sync locks to appear the same.
>
> I'll give it a quick shot to see if the compiler inlines it well enough
> to preserve the name.
Yea, unfortunately this causes the reports to all look like:
[   10.370105]  Possible unsafe locking scenario:
[   10.370105]
[   10.370105]        CPU0
[   10.370105]        ----
[   10.370105]   lock(&syncp->seq#5);
[   10.370105]   <Interrupt>
[   10.370105]     lock(&syncp->seq#5);
[   10.370105]
[   10.370105]  *** DEADLOCK ***


Rather then:
[   12.150105]  Possible unsafe locking scenario:
[   12.150105]
[   12.150105]        CPU0
[   12.150105]        ----
[   12.150105]   lock(&af_inet6_stats->syncp.seq);
[   12.150105]   <Interrupt>
[   12.150105]     lock(&af_inet6_stats->syncp.seq);
[   12.150105]
[   12.150105]  *** DEADLOCK ***


So I suspect using the macro is the best approach here. Is that ok?

thanks
-john
