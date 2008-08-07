From: Rick Jones <rick.jones2@hp.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 07 Aug 2008 16:28:32 -0700
Message-ID: <489B8520.3010002@hp.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>	<200808072009.34891.rdenis@simphalempin.com>	<65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>	<489B3C53.1000202@hp.com> <20080807120359.2d62880a@extreme>	<65634d660808071243yd7de635i7e780f526161b445@mail.gmail.com>	<489B578A.9030505@hp.com> <65634d660808071605k6301cc1aubea542595763d4e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:16857 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbYHGX2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 19:28:35 -0400
In-Reply-To: <65634d660808071605k6301cc1aubea542595763d4e3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
>>Well, if you _really_ want the load spread, you may need to use a multiqueue
>>(at least inbound if not also later outbound) interface, "know" how the NIC
>>will hash and then have N distinct port numbers each assigned to a LISTEN
>>endpoint.  The old song and dance about making an N CPU system look as much
>>like N single-CPU systems and all that...
>>
> 
> 
> Yep that's what I really want, except for the fact that I can only use
> a single port for the server--  all flows could be nicely distributed
> by the NIC multiqueue, but I still have the problem of how to ensure
> that the accepting thread for a connection is run on the same CPU as
> the interrupt and SYN processing were.

That is where needing to know/control the NIC's hashing comes into play.

> NICs are already doing steering based on tuple hash (RSS), and I think
> some will allow specifying the CPU for interrupt based on RX flow.
> Maybe this would address the issues of Inbound Packet Scheduling?

All IPS in HP-UX 10.20 was was hash the IP/port numbers and queue based 
on that - this at the handoff between driver and netisr.  The problem 
was if you had a thread of execution servicing more than one connection, 
you would start whipsawing across the processors based on the remote 
addressing.

There are IIRC indeed some NICs where you can give them a finite number 
of tuples and say where each tuple should go.  I'm sure those vendors if 
watching can speak-up :)  That sort of functionality can be useful and 
would address the limitations of ISS/plain NIC header address hashing. 
At least for long-lived connections.  Or perhaps even long-lived LISTEN 
endpoints :)

While you say you are constrained to a single port number, are you 
similarly constrained to a single IP address?

> Thanks for the pointers on IPS and TOPS.  Out of curiosity has there
> been an effort to do TOPS on Linux?  We are doing something very
> similar in software RSS with a fair amount of success (I posted
> patches for this a while back).

I'm not sure.  Anything is possible.  The nice thing about TOPS in UX 
11.X was/is the lookup was essentially free and didn't involve things 
going across I/O busses.  Start to have to update those tuple mappings 
on the NIC with any frequency and that's the end of that.

rick
