From: jamal <hadi@cyberus.ca>
Subject: Re: Problem with redirecting traffic via ifb device
Date: Tue, 27 Jun 2006 09:21:25 -0400
Message-ID: <1151414485.6516.70.camel@jzny2>
References: <449FBB60.2000600@corpit.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:18867 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932240AbWF0NV1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 09:21:27 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FvDVQ-0002om-O0
	for netdev@vger.kernel.org; Tue, 27 Jun 2006 09:21:28 -0400
To: Egor Duda <deo@corpit.ru>
In-Reply-To: <449FBB60.2000600@corpit.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-26-06 at 14:48 +0400, Egor Duda wrote:
> I have a linux router which is connected via pppoe to my ISP. My
> provider limits aggregate upload+download rate to some fixed amount of
> kbps, so to perform shaping on my router i'm trying to do the same on my
> router (to "own the queue", so to say). Since standard tbf accounts to
> the packets going only one way, i wanted to create virtual ifb
> interface, which will gather all incoming and outgoing packets, and then
> perform appropriate shaping on it.
> 
> I'm doing it roughly in the following way:
> 
> -------------------------------------------------------------------------
> tc qdisc add dev $iface ingress
> tc qdisc add dev $iface parent ffff: handle 1: prio
> 

The above line doesnt seem to make a lot of sense and maybe the cause of
your problems. You cant have queues on ingress.

You probably want:
tc qdisc add dev $iface root handle 1: prio
?
> tc filter add dev $iface parent 1: protocol ip prio 10 \
> u32   match u32 0 0 flowid 1:1 \
> action ipt -j MARK --set-mark 1  \
> action mirred egress redirect dev ifb0
> 

Above will mark all packets arriving on 1:0 (egress??) and mark them
with fwmark 1 and then redirect to ifb0.
If you are trying to do ingress do "parent ffff:"

> tc qdisc add dev $iface root handle 2: prio
> 

wtf? is this the egress?

> tc filter add dev $iface parent 2: protocol ip prio 10 \
> u32   match u32 0 0 flowid 2:1 \
> action ipt -j MARK --set-mark 1 \
> action mirred egress redirect dev ifb0
> -------------------------------------------------------------------------
> 

I think you need to get you scripts intent correct first. I am sorry, my
limited time would be more valuable if you narrow things down a little.
Ask questions in the user list and then come back if you have found a
bug. You definitely have bugs in the script and if you can help reducing
the variables i can help.
Some other ideas to try in narrowing down the issue:
--> Just do ingress alone first and see if that works
--> Just do egress alone and see if that works
---> do both.
--> dont use ipt - i dont trust it; the netfilter folks changed things
on me again. Pablo is helping me out resolving things. 

cheers,
jamal

