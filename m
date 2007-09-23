From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH: 2.6.13-15-SMP 3/3] network: concurrently run
	softirqnetwork code on SMP
Date: Sun, 23 Sep 2007 08:43:41 -0400
Message-ID: <1190551422.4256.36.camel@localhost>
References: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de
To: john ye <johny@asimco.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:3384 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbXIWMnq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 08:43:46 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1006089wxd
        for <netdev@vger.kernel.org>; Sun, 23 Sep 2007 05:43:45 -0700 (PDT)
In-Reply-To: <004901c7fd9c$94370df0$d6ddfea9@JOHNYE1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-23-09 at 12:45 +0800, john ye wrote:

>  I do randomly select a CPU to dispatch the skb to. Previously, I
> dispatch
>  skb evenly to all CPUs( round robin, one by one). but I didn't find a
> quick
>  coding. for_each_online_cpu is not quick enough.

for_each_online_cpu doenst look that expensive - but even round robin
wont fix the reordering problem. What you need to do is make sure that a
flow always goes to the same cpu over some period of time.

>  According to my test result, it did make packet INPUT speed doubled
> because
>  another CPU is used concurrently.

How did you measure "speed" - was it throughput? Did you measure how
much cpu was being utilized?

>  It seems the packets still keep "roughly ordering" after turning on
> BS patch.

Linux TCP is very resilient to reordering compared to other OSes, but
even then if you hit it with enough packets it is going to start
sweating it.

>  The test is simple: use an 2400 lines of iptables -t filter -A INPUT
> -p
>  tcp -s x.x.x.x --dport yy -j XXXX.
>  these rules make the current softirq be very busy on one CPU and make
> the
>  incoming net very slow. after turning on BS, the speed doubled.
> 
Ok, but how do you observe "doubled"?
Do you have conntrack on? It maybe that what you have just found is
netfilter needs to have its work defered from packet rcv.
You need some real fast traffic generator; possibly one that can do
thousands of tcp sessions.

>  For NAT test, I didn't get a good result like INPUT because real 
> environment limitation.
>  The test is very basic and is far from "full".

What happens when you totally compile out netfilter and you just use
this machine as a server?

>  It seems to me that the cross-cpu spinlock_xxxx for the queue doesn't
> have
>  big cost and is allowable in terms of CPU time consumption, compared
> with
>  the gains by making other CPUs joint in the work.
> 
>  I have made BS patch into a loadable module.
>  http://linux.chinaunix.net/bbs/thread-909725-2-1.html and let others
> help with testing.

It is still very hard to read; and i am not sure how you are going to
get the performance you claim eventually - you are registering as a tap
for ip packets, which means you will process two of each incoming
packets.

cheers,
jamal

