From: "john ye" <johny@asimco.com.cn>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently runsoftirqnetwork code on SMP
Date: Sun, 23 Sep 2007 23:45:33 +0800
Message-ID: <000501c7fdf8$c7f7c8d0$d6ddfea9@JOHNYE1>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1> <1190551422.4256.36.camel@localhost>
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <jmorris@namei.org>,
	<kaber@coreworks.de>, <iceburgue@gmail.com>
To: <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asimco-na.com ([207.138.153.195]:20911 "EHLO
	mail.asimco-na.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbXIWPoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 11:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Jamal,

Yes. you are right. I do "need some real fast traffic generator; possibly 
one that can do
thousands of tcp sessions." to get some kind of convincing result.

Also, the packet reordering is also my big concern. round-robin doesn't have 
much help.

"The INPUT speed is doubled by using 2 CPUs" is shown by these steps:
1) without intables, ftp get a 50M file from another machine, ftp can show 
speed 10M/s.
2) run iptables and add many intpalbes rules, ftp get the same file, the 
speed is down to 3M/s, top shows CPU0 busy in softirq. CPU1 idle.
3) insmod my module BS, then ftp get the same file, the speed can reach 
6M/s, top shows both CPU0 and CPU1 are busy in keventd/0/1

I will try my best to do further test. the best test should be done on a 4 
CPU GATEWAY machine. In China, there are many companies who use linux box 
running iptables as a gateway to serve 1000 around clients, for example. On 
those machines, a lot conntracking, and they have the "idle CPUs while net 
is too busy" problem.

In my BS module (If you got it), only 2 functions are needed to see: 
REP_ip_rcv(), and bs_func(). Others have nothing to do with the BS patch ---  
they are there only for accessing non-EXPORT_SYMBOLed kernel variables.

Thanks a lot for your thought.

John Ye


----- Original Message ----- 
From: "jamal" <hadi@cyberus.ca>
To: "john ye" <johny@asimco.com.cn>
Cc: "David Miller" <davem@davemloft.net>; <netdev@vger.kernel.org>; 
<kuznet@ms2.inr.ac.ru>; <pekkas@netcore.fi>; <jmorris@namei.org>; 
<kaber@coreworks.de>
Sent: Sunday, September 23, 2007 8:43 PM
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently 
runsoftirqnetwork code on SMP


> On Sun, 2007-23-09 at 12:45 +0800, john ye wrote:
>
>>  I do randomly select a CPU to dispatch the skb to. Previously, I
>> dispatch
>>  skb evenly to all CPUs( round robin, one by one). but I didn't find a
>> quick
>>  coding. for_each_online_cpu is not quick enough.
>
> for_each_online_cpu doenst look that expensive - but even round robin
> wont fix the reordering problem. What you need to do is make sure that a
> flow always goes to the same cpu over some period of time.
>
>>  According to my test result, it did make packet INPUT speed doubled
>> because
>>  another CPU is used concurrently.
>
> How did you measure "speed" - was it throughput? Did you measure how
> much cpu was being utilized?
>
>>  It seems the packets still keep "roughly ordering" after turning on
>> BS patch.
>
> Linux TCP is very resilient to reordering compared to other OSes, but
> even then if you hit it with enough packets it is going to start
> sweating it.
>
>>  The test is simple: use an 2400 lines of iptables -t filter -A INPUT
>> -p
>>  tcp -s x.x.x.x --dport yy -j XXXX.
>>  these rules make the current softirq be very busy on one CPU and make
>> the
>>  incoming net very slow. after turning on BS, the speed doubled.
>>
> Ok, but how do you observe "doubled"?
> Do you have conntrack on? It maybe that what you have just found is
> netfilter needs to have its work defered from packet rcv.
> You need some real fast traffic generator; possibly one that can do
> thousands of tcp sessions.
>
>>  For NAT test, I didn't get a good result like INPUT because real
>> environment limitation.
>>  The test is very basic and is far from "full".
>
> What happens when you totally compile out netfilter and you just use
> this machine as a server?
>
>>  It seems to me that the cross-cpu spinlock_xxxx for the queue doesn't
>> have
>>  big cost and is allowable in terms of CPU time consumption, compared
>> with
>>  the gains by making other CPUs joint in the work.
>>
>>  I have made BS patch into a loadable module.
>>  http://linux.chinaunix.net/bbs/thread-909725-2-1.html and let others
>> help with testing.
>
> It is still very hard to read; and i am not sure how you are going to
> get the performance you claim eventually - you are registering as a tap
> for ip packets, which means you will process two of each incoming
> packets.
>
> cheers,
> jamal
>
> 


