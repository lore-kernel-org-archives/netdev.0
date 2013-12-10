From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC ] net: sched: tbf: fix the calculation of max_size
Date: Tue, 10 Dec 2013 10:29:28 +0800
Message-ID: <52A67C88.8040606@huawei.com>
References: <1386313205-87660-1-git-send-email-yangyingliang@huawei.com>	 <1386313205-87660-2-git-send-email-yangyingliang@huawei.com>	 <AE90C24D6B3A694183C094C60CF0A2F6026B7468@saturn3.aculab.com>	 <52A5384A.8050106@huawei.com>	 <AE90C24D6B3A694183C094C60CF0A2F6026B7471@saturn3.aculab.com>	 <52A5B5D9.7000204@huawei.com> <52A5C12D.8080008@huawei.com> <1386601926.30495.323.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>, <brouer@redhat.com>,
	<jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11441 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab3LJC3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:29:45 -0500
In-Reply-To: <1386601926.30495.323.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/9 23:12, Eric Dumazet wrote:
> On Mon, 2013-12-09 at 21:10 +0800, Yang Yingliang wrote:
>> From: Yang Yingliang <yangyingliang@huawei.com>
>>
>> Current max_size is caluated from rate table. Now, the rate table
>> has been replaced and it's wrong to caculate max_size based on this
>> rate table. It can lead wrong calculation of max_size.
>>
>> The burst in kernel may be lower than user asked, because burst may gets
>> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
>> and it seems we cannot avoid this loss. Burst's value(max_size) based on
>> rate table may be equal user asked. If a packet's length is max_size, this
>> packet will be stalled in tbf_dequeue() because its length is above the
>> burst in kernel so that it cannot get enough tokens. The max_size guards
>> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
>>
>> To make consistent with the calculation of tokens, this patch add a helper
>> psched_ns_t2l() to calculate burst(max_size) directly to fix this problem.
>>
>> After this fix, we can support to using 64bit rates to calculate burst as well.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
>>  net/sched/sch_tbf.c | 203 +++++++++++++++++++++++++++++++++++++++-------------
>>  1 file changed, 155 insertions(+), 48 deletions(-)
> 
> 
> There is no way I am going to study this patch.
> 
> There is no way 32bit * 32bit multiply can overflow 64bit.
> 
> If the user gave a stupid input, like a buffer bigger than 4 sec, just
> say no. Nobody ever did such stupid things in the past, and nobody will
> do in the future because it is so wrong and useless.
> 
> q->mtu = max_t(u64, ~0U, PSCHED_TICKS2NS(qopt->mtu));
> 
> q->buffer = max_t(u64, ~0U, PSCHED_TICKS2NS(qopt->buffer));
> 
> Could we keep this code understandable, please ?

Hmm, I cannot figure out why max_t, did you mean min_t?

> 
> 
> 
> 
> 
