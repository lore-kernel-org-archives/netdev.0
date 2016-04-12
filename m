From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Tue, 12 Apr 2016 20:31:24 +0800
Message-ID: <570CEA9C.1070803@huawei.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FB6AA7.1080004@huawei.com>
 <1459345637.6473.205.camel@edumazet-glaptop3.roam.corp.google.com>
 <5705F759.9020003@huawei.com>
 <1460024518.6473.389.camel@edumazet-glaptop3.roam.corp.google.com>
 <1460040665.6473.398.camel@edumazet-glaptop3.roam.corp.google.com>
 <5707939B.2030907@huawei.com>
 <1460126665.6473.437.camel@edumazet-glaptop3.roam.corp.google.com>
 <570B9126.9080806@huawei.com>
 <1460376828.6473.538.camel@edumazet-glaptop3.roam.corp.google.com>
 <570C6483.5020502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([58.251.152.179]:63002 "EHLO
	szxga05-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756815AbcDLMne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 08:43:34 -0400
In-Reply-To: <570C6483.5020502@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/4/12 10:59, Yang Yingliang wrote:
>
>
> On 2016/4/11 20:13, Eric Dumazet wrote:
>> On Mon, 2016-04-11 at 19:57 +0800, Yang Yingliang wrote:
>>>
>>> On 2016/4/8 22:44, Eric Dumazet wrote:
>>>> On Fri, 2016-04-08 at 19:18 +0800, Yang Yingliang wrote:
>>>>
>>>>> I expand  tcp_adv_win_scale and tcp_rmem. It has no effect.
>>>>
>>>> Try :
>>>>
>>>> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
>>>>
>>>> And restart your flows.
>>>>
>>> cat /proc/sys/net/ipv4/tcp_rmem
>>> 10240 2097152 10485760
>>
>> What about leaving the default values ?
> I tried, it did not work.
>
>>
>> $ cat /proc/sys/net/ipv4/tcp_rmem
>> 4096    87380    6291456
>>
>>>
>>> echo 102400 20971520 104857600 > /proc/sys/net/ipv4/tcp_rmem
>>> echo -2 >/proc/sys/net/ipv4/tcp_adv_win_scale
>>>
>>> It seems has not effect.
>>>
>>
>> I have no idea what you did on the sender side to allow it to send more
>> than 1.5 MB then.
>
> We are doing performance test. The sender send 256KB per-block with 128
> threads to one socket. And the receiver uses 10Gb NIC to handle the
> data on ARM64. The data flow is driver->ip layer->tcp layer->iscsi.
>
> I added some debug messages and found handling backlog packets in
> __release_sock() cost about 11ms at most. This can cause backlog queue
> overflow. The sk_data_ready is re-assigned, it may cost time in our
> program. I will check it out.
>
I traced the cost cycles of handling backlog packets in
__release_sock().
16.97 ms to handling about 12MB backlog packets, of which 13.66ms to do
sk_data_ready.
The speed of handling packets in TCP is 5.65Gb/s which is smaller than
the NIC's bandwidth. So the packets will be dropped.

If the cost of sk_data_read cannot be reduced, do we have other choice
exclude dropping packets ?
