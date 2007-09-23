From: "john ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run softirqnetwork code on SMP
Date: Sun, 23 Sep 2007 11:45:27 +0800
Message-ID: <003701c7fd94$2ead6090$d6ddfea9@JOHNYE1>
References: <002b01c7fb86$02b27df0$d6ddfea9@JOHNYE1> <20070920.104614.58454013.davem@davemloft.net> <00e601c7fc31$4ed29890$ca8510ac@asimco> <1190375023.4261.34.camel@localhost>
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<kaber@coreworks.de>, "John Ye" <johny@asimco.com.cn>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:17638 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbXIWDo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 23:44:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Jamal,

Sorry, I sent to you all a not-good-formatted mail.
Thanks for instructions and corrections from you all.

I have thought that packet re-ordering for upper TCP protocol will become 
more intensive and this will make the network even slower.

I do randomly select a CPU to dispatch the skb to. Previously, I dispatch 
skb evenly to all CPUs( round robin, one by one). but I didn't find a quick 
coding. for_each_online_cpu is not quick enough.

According to my test result, it did make packet INPUT speed doubled because 
another CPU is used concurrently.
It seems the packets still keep "roughly ordering" after turning on BS 
patch.

The test is simple: use an 2400 lines of iptables -t filter -A INPUT -p 
tcp -s x.x.x.x --dport yy -j XXXX.
these rules make the current softirq be very busy on one CPU and make the 
incoming net very slow. after turning on BS, the speed doubled.

For NAT test, I didn't get a good result like INPUT because real environment 
limitation.
The test is very basic and is far from "full".

It seems to me that the cross-cpu spinlock_xxxx for the queue doesn't have 
big cost and is allowable in terms of CPU time consumption, compared with 
the gains by making other CPUs joint in the work.

I have made BS patch into a loadable module. 
http://linux.chinaunix.net/bbs/thread-909725-2-1.html and let others help 
with testing.

John Ye


----- Original Message ----- 
From: "jamal" <hadi@cyberus.ca>
To: "John Ye" <johny@asimco.com.cn>
Cc: "David Miller" <davem@davemloft.net>; <netdev@vger.kernel.org>; 
<kuznet@ms2.inr.ac.ru>; <pekkas@netcore.fi>; <jmorris@namei.org>; 
<kaber@coreworks.de>
Sent: Friday, September 21, 2007 7:43 PM
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run 
softirqnetwork code on SMP


> On Fri, 2007-21-09 at 17:25 +0800, John Ye wrote:
>> David,
>>
>> Thanks for your reply. I understand it's not worth to do.
>>
>> I have made it a loadable module to fulfill the function. it mainly for 
>> busy
>> NAT gateway server with SMP to speed up.
>>
>
> John,
>
> It was a little hard to read your code; however, it does seems to me
> like will cause a massive amount of packet reordering to the end hosts
> using you as the gateway especially when it is receiving a lot of
> packets/second.
> You have a queue per CPU that connects your bottom and top half and
> several CPUs that may service a single NIC in your bottom half.
> one cpu in either bottom/top half has to be slightly loaded and you
> loose the ordering where incoming doesnt match outgoing packet order.
>
> cheers,
> jamal
>
> 


