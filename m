From: "Tom Herbert" <therbert@google.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 7 Aug 2008 12:43:02 -0700
Message-ID: <65634d660808071243yd7de635i7e780f526161b445@mail.gmail.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
	 <200808072009.34891.rdenis@simphalempin.com>
	 <65634d660808071058k7eb33330tcf3c7a877b7a64d@mail.gmail.com>
	 <489B3C53.1000202@hp.com> <20080807120359.2d62880a@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>, netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:60602 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbYHGTnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 15:43:13 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id m77Jh4sT015323
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 20:43:05 +0100
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by wpaz17.hot.corp.google.com with ESMTP id m77Jh3H3012759
	for <netdev@vger.kernel.org>; Thu, 7 Aug 2008 12:43:03 -0700
Received: by rv-out-0708.google.com with SMTP id b17so599482rvf.42
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 12:43:03 -0700 (PDT)
In-Reply-To: <20080807120359.2d62880a@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 7, 2008 at 12:03 PM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> On Thu, 07 Aug 2008 11:17:55 -0700
> Rick Jones <rick.jones2@hp.com> wrote:
>
>> Tom Herbert wrote:
>> >>>We are looking at ways to scale TCP listeners.  I think we like is the
>> >>>ability to listen on a port from multiple threads (sockets bound to
>> >>>same port,  INADDR_ANY, and no interface binding) , which is what
>> >>>SO_REUSEPORT would seem to allow.  Has this ever been implemented for
>> >>>Linux or is there a good reason not to have it?
>> >>
>> >>On Linux, SO_REUSEADDR provide most of what SO_REUSEPORT provides on BSD.
>> >>
>> >>In any case, there is absolutely no point in creating multiple TCP listeners.
>> >>Multiple threads can accept() on the same listener - at the same time.
>> >>
>> >
>> >
>> > We've been doing that, but then on wakeup it would seem that we're at
>> > the mercy of scheduling-- basically which ever threads wakes up first
>> > will get to process accept queue first.  This seems to bias towards
>> > threads running on the same CPU as the wakeup is called, and   so this
>> > method doesn't give us an even distribution of new connections across
>> > the threads that we'd like.
>>
>> How would the presence of multiple TCP LISTEN endpoints change that?
>> You'd then be at the mercy of whatever "scheduling" there was inside the
>> stack.
>>
>> If you want to balance the threads, perhaps a dispatch thread, or a
>> virtual one - each thread knows how many connections it is servicing,
>> let them know how many the other threads are servicing, and if a thread
>> has N more connections than the other threads have it not go into
>> accept() that time around.  Might need some tweaking to handle
>> pathological starvation cases like all the other threads are hung I
>> suppose but the basic idea is there.
>>
>> rick jones
>
> I suspect thread balancing would actually hurt performance!
> You would be better off to have a couple of "hot" threads that are doing
> all the work and stay in cache. If you push the work around to all the
> threads, you have worst case cache behaviour.
>

I'm not sure that's applicable for us since the server application and
networking will max out all the CPUs on host anyway; one way or
another we need to dispatch the work of incoming connections to
threads on different CPUs.  If we do this in user space and do all
accepts in one thread, the CPU of that  thread becomes the bottleneck
(we're accepting about 40,000 connections per second).  If we have
multiple accept threads running on different CPUs, this helps some,
but the load is spread unevenly across the CPUs and we still can't get
the highest connection rate.  So it seems we're looking for a method
that distributes the incoming connection load across CPUs pretty
evenly.

Tom




But we need to spread the load across multiple threads on different CPUs
