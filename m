From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH RFC] net: decrease the length of backlog queue immediately
 after it's detached from sk
Date: Wed, 30 Mar 2016 13:56:55 +0800
Message-ID: <56FB6AA7.1080004@huawei.com>
References: <1459315001-3448-1-git-send-email-yangyingliang@huawei.com>
 <1459315520.6473.187.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([119.145.14.52]:36632 "EHLO
	szxga04-in.huawei.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752720AbcC3F6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 01:58:08 -0400
In-Reply-To: <1459316043.6473.188.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/3/30 13:34, Eric Dumazet wrote:
> On Tue, 2016-03-29 at 22:25 -0700, Eric Dumazet wrote:
>> On Wed, 2016-03-30 at 13:16 +0800, Yang Yingliang wrote:
>>> When task A hold the sk owned in tcp_sendmsg, if lots of packets
>>> arrive and the packets will be added to backlog queue. The packets
>>> will be handled in release_sock called from tcp_sendmsg. When the
>>> sk_backlog is removed from sk, the length will not decrease until
>>> all the packets in backlog queue are handled. This may leads to the
>>> new packets be dropped because the lenth is too big. So set the
>>> lenth to 0 immediately after it's detached from sk.
>>>
>>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>>> ---
>>>   net/core/sock.c | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/core/sock.c b/net/core/sock.c
>>> index 47fc8bb..108be05 100644
>>> --- a/net/core/sock.c
>>> +++ b/net/core/sock.c
>>> @@ -1933,6 +1933,7 @@ static void __release_sock(struct sock *sk)
>>>
>>>   	do {
>>>   		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
>>> +		sk->sk_backlog.len = 0;
>>>   		bh_unlock_sock(sk);
>>>
>>>   		do {
>>
>> Certainly not.
>>
>> Have you really missed the comment ?
>>
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8eae939f1400326b06d0c9afe53d2a484a326871
>>
>>
>> I do not believe the case you describe can happen, unless a misbehaving
>> driver cooks fat skb (with skb->truesize being far more bigger than
>> skb->len)
>>
>
> And also make sure you backported
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=da882c1f2ecadb0ed582628ec1585e36b137c0f0

Sorry, I made a mistake. I am very sure my kernel has these two patches.
And I can get some dropping of the packets in 10Gb eth.

# netstat -s | grep -i backlog
     TCPBacklogDrop: 4135
# netstat -s | grep -i backlog
     TCPBacklogDrop: 4167


>
>
>
>
>
>
