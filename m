From: Deng-Cheng Zhu <dczhu@mips.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Tue, 8 May 2012 14:43:45 +0800
Message-ID: <4FA8C0A1.1060607@mips.com>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>	 <4FA35A3D.8000205@mips.com>	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>	 <4FA77051.20804@mips.com> <1336376282.3752.2252.camel@edumazet-glaptop>	 <4FA7815F.8030101@mips.com> <1336379153.3752.2273.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns0.mips.com ([12.201.5.70]:49365 "EHLO dns0.mips.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab2EHGny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 02:43:54 -0400
In-Reply-To: <1336379153.3752.2273.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2012 04:25 PM, Eric Dumazet wrote:
> On Mon, 2012-05-07 at 16:01 +0800, Deng-Cheng Zhu wrote:
>
>> Did you really read my patch and understand what I commented? When I was
>> talking about using rps_sparse_flow (initially cpu_flow), neither
>> rps_sock_flow_table nor rps_dev_flow_table is activated (number of
>> entries: 0).
>
> I read your patch and am concerned of performance issues when handling
> typical workload. Say between 0.1 and 20 Mpps on current hardware.

Thanks for reading. For the performance concern, that's why I posted
the test data in the patch description.

>
> The argument "oh its only selected when
> CONFIG_RPS_SPARSE_FLOW_OPTIMIZATION is set" is wrong.

Certainly, as stated before, I admit (in fact, it's obvious) that this
patch is nothing more than a tradeoff between the throughput of sparse
flows and that of many. In the tests, less than 4% performance loss was
observed as the number of connections went higher. If people (in most
cases I understand) don't care about the sparse flow case, then leave
this feature not selected (the default). In the real world, there are
many tradeoffs, right?

>
> CONFIG_NR_RPS_MAP_LOOPS is wrong.

To balance the overhead and the sparse flow throughput.

>
> Your HZ timeout is yet another dark side of your patch.

Certainly it can be changed to something more reasonable.

>
> Your (flow->dev == skb->dev) test is wrong.

Please let me know why, thanks. The tests showed it's possible that 2
correlated flows could have the same hash value but from different
devices.

>
> Your : flow->ts = now; is wrong (dirtying memory for each packet)

It doesn't touch the packet, does it? It only records the last time when
the flow is active. And the flow entries are only managed by this
feature.

>
> Really I dont like your patch.

Regretfully.

>
> You are kindly asked to find another way to solve your problem, a
> generic mechanism that can help others, not only you.

This is the meat of the problem. And it's why I'm still saying something
about this patch. We do have the platform where SMP irq affinity is not
available to NICs and, according to tests, RPS does take effect with a
bit imperfection: relatively low and inconsistent throughput in the case
of sparse connections. What you are saying is not the linux way, IMHO:
Provided the incoming code doesn't do harm to the kernel, we should
offer options to users. My case can be a rare one, but it would be good
to have the kernel support.

>
> We do think activating RFS is the way to go. Its the standard layer we
> added below RPS, its configurable and scales. It can be expanded at will
> with configurable plugins.
>
> For example, using single queue NICS, it makes sense to select cpu on
> the output device only, not on the rxhash by itself (a modulo or
> something), to reduce false sharing and qdisc/device lock on tx path.
>
> If your machine has 4 cpus, and 4 nics, you can instruct RFS table to
> prefer cpu on the NIC that packet will use for output.

I understand what you say above, but it does not apply in my case.


Thanks,

Deng-Cheng
