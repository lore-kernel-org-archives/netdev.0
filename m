From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH RFC]: soreuseport: Bind multiple sockets to same port
Date: Mon, 19 Apr 2010 08:31:41 -0400
Message-ID: <1271680301.32453.23.camel@bigi>
References: <alpine.DEB.1.00.1004182321480.1822@pokey.mtv.corp.google.com>
	 <1271662103.16881.7300.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f182.google.com ([209.85.221.182]:63259 "EHLO
	mail-qy0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab0DSMbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 08:31:50 -0400
Received: by qyk12 with SMTP id 12so5193172qyk.21
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 05:31:49 -0700 (PDT)
In-Reply-To: <1271662103.16881.7300.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-19 at 09:28 +0200, Eric Dumazet wrote:

> High perf DNS server on such machine would have 16 threads, and probably
> 64 threads in two years.

if you dont care about x86, 64 SMT threads is already there
yesterday ;->

> I understand you want 16 UDP sockets to avoid lock contention, but
> __udp4_lib_lookup() becomes a nightmare (It may already be ...)
> 
> My idea was to add a cpu lookup key.

I like this idea better. 
Staring at data i collected over the weekend, I am scratching my head
trying to find some correlation. I see socket flows  bouncing around
CPUs other than what RPS directs to. The scheduler seems to have a mind
of its own. What is clear is if i can localize a flow/socket to a single
cpu i get best performance. RPS, when there is enough load, does better
because of this localization (DaveM made this statement earlier
actually).

I was hoping i could do a connect() + sched_setaffinity() and have RPS
direct that flow to me - but alas even RFS still depends on hashing.
Unless there is an easier way to do this, I was planning to look
at the RPS hashing and manually cook flows which end up on a cpu where 
I do sched_setaffinity()...

> thread0 would use a new setsockopt() option to bind a socket to a
> virtual cpu0. Then do its normal bind( port=53)

So question: Why not tie to sched_setaffinity? i.e at bind time you
lookup what cpu this socket is affined to?

cheers,
jamal

