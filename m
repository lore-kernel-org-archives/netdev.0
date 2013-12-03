From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v4 1/2] net: sched: tbf: fix calculation of max_size
Date: Tue, 3 Dec 2013 17:47:45 +0800
Message-ID: <529DA8C1.4000504@huawei.com>
References: <1386041214-72744-1-git-send-email-yangyingliang@huawei.com>		 <1386041214-72744-2-git-send-email-yangyingliang@huawei.com>	 <1386046793.30495.12.camel@edumazet-glaptop2.roam.corp.google.com>	 <529D8BC7.4050005@huawei.com> <1386058339.30495.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:9890 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007Ab3LCJsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 04:48:16 -0500
In-Reply-To: <1386058339.30495.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/3 16:12, Eric Dumazet wrote:
> On Tue, 2013-12-03 at 15:44 +0800, Yang Yingliang wrote:
>> On 2013/12/3 12:59, Eric Dumazet wrote:
>>> On Tue, 2013-12-03 at 11:26 +0800, Yang Yingliang wrote:
>>>
>>>> +	for (max_size = 0; max_size < MAX_PKT_LEN; max_size++)
>>>> +		if (psched_l2t_ns(&q->rate, max_size) > q->buffer)
>>>> +			break;
>>>> +	if (--max_size <= 0)
>>>> +		goto unlock_done;
>>>> +
>>>
>>> This seems dubious. With your new code, max_size < 65536
>>>
>>> Prior code had :
>>>
>>> for (n = 0; n < 256; n++)
>>>     if (rtab->data[n] > qopt->buffer)
>>>         break;
>>> max_size = (n << qopt->rate.cell_log) - 1;
>>>
>>> So we could have much bigger max_size.
>>>
>>> The reason I ask is that its possible to have qdisc_pkt_len(skb) being
>>> bigger than 65536, for TCP packets with low MSS value.
>>>
>>
>> Hmmm, if qdisc_pkt_len(skb) is bigger than 65536, skb_is_gso(skb) is true,
>> it will go into tbf_segment(). If I am wrong, please point me out, thanks!
>>
>> BTW, 65536 is suggested by Jesper, I'm a little uncertain about it. He is, too.
>> Do you or some other developers have stronger opinions on this?
> 
> We do not want to go to tbf_segment() if we programmed tbf to allow TSO
> packets of 68.000 bytes being sent without being segmented.

I mean a 64KB TSO packet's "qdisc_pkt_len(skb)" is bigger than 65536, but it will go
to tbf_segment(), so the TSO packet of 64KB can be enqueued.

> 
> TSO packet of 64KB -> about 45 frames if MSS=1448, 45*1514 = 68130 bytes
> 
> Have you tried to use TBF on a 10 Gbps link, say with one TCP flow ?

Yes, I had tried it with intel82599 nic.
