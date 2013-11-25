From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Mon, 25 Nov 2013 11:43:42 +0800
Message-ID: <5292C76E.1070701@huawei.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>		 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>	 <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>	 <5291AA8D.6060108@gmail.com> <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<brouer@redhat.com>, <jpirko@redhat.com>, <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:2294 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3KYDn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 22:43:58 -0500
In-Reply-To: <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/25 2:40, Eric Dumazet wrote:
> On Sun, 2013-11-24 at 15:28 +0800, Yang Yingliang wrote:
>> O>
>>>> With the follow command:
>>>> tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k
>>>>
>>>
>> Ideally burst should be 10KB in kernel space.
>> But at hight rates, when burst is converted to
>> time in tick in userland, it gets much more loss
>> than low rates. So the burst can't actually
>> reach 10KB in kernel.
> 
> If you think tc can help to fix user choices, please provide an
> iproute2 patch.

Unfortunately, it can't. It always has some loss when burst in bytes
is converted to buffer in ticks, we cannot avoid it, except we send burst
to kernel directly, this need to modify the code both in iproute2 and kernel.

> 
> Quite frankly, using a burst of 10KB and a rate of 30gbit is simply a
> user error. It cannot possibly work. At all.

Yep, I agree it's a user error. But the error may cause network down, and
we have a way to avoid it, I think we should fix it. :)

> 
> As stated in many tbf docs, burst must be larger than device mtu (1514)
> 
> By extension, with GRO/GSO, burst should be larger than 68130, otherwise
> we need to segment the packets, and this is horribly expensive for high
> rates.
> 
> I personally tc/tbf needs some changes, because the logical way would be
> to use the 1514 value for low rates, but if we use this value, the
> kernel gets a value of 1511, which doesn't work.

Yep, I agree with your logical way. But I think current logic in kernel
cannot support to only do some changes in tc/tbf. We need changes both
in tc and kernel. I'll post a patch which uses TCA_TBF_BURST to get burst
from tc directly and this patch also need to keep backward compatible with
old tc.

Regards,
Yang
