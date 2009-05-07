From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] iproute2/tc caching proposal
Date: Thu, 7 May 2009 22:41:14 +0300
Message-ID: <200905072241.14646.denys@visp.net.lb>
References: <200905070103.37956.denys@visp.net.lb> <4A032C24.7060709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41059 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZEGTl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 15:41:27 -0400
In-Reply-To: <4A032C24.7060709@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 May 2009 21:44:52 Jarek Poplawski wrote:
> Denys Fedoryschenko wrote, On 05/07/2009 12:03 AM:
> > Since already someone did caching in iproute2, my changes is very
> > trivial, but giving huge improvement in batch performance (30k rules
> > 10minutes vs 30 seconds).
> >
> > ll_init_map is called in many places in tc, but since tc not changing
> > anything, that can change this map, i think it is enough to call it only
> > at the beginning, after rtnl_open().
> >
> > Only one exclusion - tc monitor, because it is running long time, and
> > things can change over this time, so we call ll_init_map on each received
> > rtnetlink event.
>
> Do you mean 30 sec. is to short for a change? I don't know these things
> enough; your idea looks very nice, but I wonder if you tested how it
> behaves if e.g. after 15k rules some dev goes away which is used in the
> next 15k?
Well, i think if this point are criticial - not good idea to use batching at 
all. 
Bad condition can happen on 1k interface, and "old style", just each line 
takes hundreds of milliseconds, and there is chance that when root qdisc 
created, in batch, interface doesn't exist, and when you will start creating 
classes it will appear.

In my case even if device disappeared and id is not valid , it will just not 
add shaper(error, in case of flag -force - not critical), because id of 
interface will be different, even if device with same name appeared, because 
device id is incremental as i understand.

For example:
ppp100 assigned to john, who have 100Mbit unlimited. Let's say ppp100 have 
assigned id 12345.
Batch started, and before it is reached john, he disconnected and another user 
connected let's say willy (32Kbit/s) and catch ppp100, but id will be 
different, it will just give error. I use flag "-force" for that.
If i will refresh "interface-id" map on each batch line, first, on system with 
1k+ interface it will take around 10 minutes instead of 30 seconds, to load 
20-40k lines batch file. Second, willy can get 100Mbits because of mistake.



>
> > Also please check "[RFC] [IPROUTE2] Filter class output by classid", if
> > it is ok. Many people told it is useful patch.
>
> I agree it's useful and quite natural option.
>
> Thanks,
> Jarek P.


