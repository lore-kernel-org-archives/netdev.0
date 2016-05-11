From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 15:13:49 +0200
Message-ID: <de6ef948-65a4-e7e0-718e-6d37474f65d4@stressinduktion.org>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160511065527.GD3193@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Peter Zijlstra <peterz@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:57364 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751816AbcEKNOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:14:04 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 1B50121461
	for <netdev@vger.kernel.org>; Wed, 11 May 2016 09:14:03 -0400 (EDT)
In-Reply-To: <20160511065527.GD3193@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11.05.2016 08:55, Peter Zijlstra wrote:
> On Tue, May 10, 2016 at 03:51:37PM -0700, Eric Dumazet wrote:
>> diff --git a/kernel/softirq.c b/kernel/softirq.c
>> index 17caf4b63342..22463217e3cf 100644
>> --- a/kernel/softirq.c
>> +++ b/kernel/softirq.c
>> @@ -56,6 +56,7 @@ EXPORT_SYMBOL(irq_stat);
>>  static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
>>  
>>  DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
>> +DEFINE_PER_CPU(bool, ksoftirqd_scheduled);
>>  
>>  const char * const softirq_to_name[NR_SOFTIRQS] = {
>>  	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
>> @@ -73,8 +74,10 @@ static void wakeup_softirqd(void)
>>  	/* Interrupts are disabled: no need to stop preemption */
>>  	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
>>  
>> -	if (tsk && tsk->state != TASK_RUNNING)
>> +	if (tsk && tsk->state != TASK_RUNNING) {
>> +		__this_cpu_write(ksoftirqd_scheduled, true);
>>  		wake_up_process(tsk);
> 
> Since we're already looking at tsk->state, and the wake_up_process()
> ensures the thing becomes TASK_RUNNING, you could add:
> 
> static inline bool ksoftirqd_running(void)
> {
> 	return __this_cpu_read(ksoftirqd)->state == TASK_RUNNING;
> }

This looks racy to me as the ksoftirqd could be in the progress to stop
and we would miss another softirq invocation.

Thanks,
Hannes
