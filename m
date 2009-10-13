From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Tue, 13 Oct 2009 15:45:36 +0300
Message-ID: <200910131545.36946.denys@visp.net.lb>
References: <200910121143.39924.denys@visp.net.lb> <200910130144.04910.denys@visp.net.lb> <1255436477.6305.2.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34296 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbZJMMrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 08:47:41 -0400
In-Reply-To: <1255436477.6305.2.camel@dogo.mojatatu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I bet pppd in user space is probably your biggest problem in terms of
> performance.
No. :-)
First problem, on restart and massive users login i am getting some weird 
locking problem with modprobe,probably related to busybox/mdev.
When interface come up, maybe it is problem of mdev, it is trying to do 
modprobe with ip address as attribute. Probably they must not modprobe on 
virtual interface. It is not easy to track who is reason of such call.

As result:
[  174.564503] request_module: runaway loop modprobe 172.16.3.1
[  174.564702] request_module: runaway loop modprobe 172.16.3.1
[  174.801355] request_module: runaway loop modprobe 172.16.106.1
[  174.801487] request_module: runaway loop modprobe 172.16.106.1
[  175.011415] request_module: runaway loop modprobe 172.16.106.1
load average (even it doesn't mean anything in terms of CPU load) jumps to 
72-80.

Another bottleneck is u32 (i can optimize but) and some strange locks 
appearing at top of perf, maybe same as logon case.
And yes, pppd also appearing, but seems just registering new sysctls (for new 
interface?) takes a lot of resources.

I can post perf -a -f g if you are interested for "logging in" case and 
regular operation.

>
> > After switching to skbedit things improve a lot (before 1k users was near
> > max)
>
> Not using netfilter will improve your numbers. So can skbedit do fwmark
> as well?
I dont need it, i am using skb->priority as a key for flow classifier.
It looks weird, a lot of obsolete code there, but it is very nice, i dont need 
to touch almost anything on ifb, and i can predefine even on startup required 
amount of classes and just change rate when required.

Here is key part of shaper code:

$TC filter add dev ifb0 protocol ip pref 32 parent 1: handle 1 flow map key 
priority baseclass 1:64

Then i create classes for id's i need (at my case id related to ppp interface 
number).

and when ppp interface come up also:
(lowid is related to ppp interface or user id)

filter add dev $2 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action skbedit priority 0x${lowid} pipe \
action mirred egress redirect dev ifb0

>
> yes, something like that.
> It may be easier to tcpdump -x on both pppoe and ifb and see how the
> packets look like at what offset. If that doesnt work well, I will work
> on a patch...
Well another way is just to use  as you suggest - egress on output 
interface(s).
>
> cheers,
> jamal


