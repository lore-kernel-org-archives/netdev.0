From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 13:49:37 -0800
Message-ID: <CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
	<20151123.145433.1554000376541433305.davem@davemloft.net>
	<20151124152744.GB20972@breakpoint.cc>
	<20151124.105537.185897620062606312.davem@davemloft.net>
	<20151124162515.GA22266@breakpoint.cc>
	<CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
	<20151124171650.GA23215@breakpoint.cc>
	<CALx6S36qHkUhz5VN+xvsMhszTQnCUUhQ+Doja86wLGWJEe_u_A@mail.gmail.com>
	<20151124205537.GC23215@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davejwatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35245 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091AbbKXVti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:49:38 -0500
Received: by ioc74 with SMTP id 74so34822887ioc.2
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 13:49:37 -0800 (PST)
In-Reply-To: <20151124205537.GC23215@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 12:55 PM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <tom@herbertland.com> wrote:
>> Message size limits can be enforced in BPF or we could add a limit
>> enforced by KCM. For instance, the message size limit in http/2 is
>> 16M. If it's needed, it wouldn't be much trouble to add a streaming
>> interface for large messages.
>
> That still won't change the fact that KCM allows eating large
> amount of kernel memory (you could just open a lot of sockets...).
>
> For tcp we cannot exceed the total rmem limits, even if I can open
> 4k sockets.
>
> Why anyone would invest such a huge amount of work in making this
> kernel-based framing for single-stream tcp record (de)mux rather than
> improving the userspace protocol to use UDP or SCTP or at least
> one tcp connection per worker is beyond me.
>
>From the /0 patch:

Q: Why not use an existing message-oriented protocol such as RUDP,
   DCCP, SCTP, RDS, and others?

A: Because that would entail using a completely new transport protocol.
   Deploying a new protocol at scale is either a huge undertaking or
   fundamentally infeasible. This is true in either the Internet and in
   the data center due in a large part to protocol ossification.
   Besides, KCM we want KCM to work existing, well deployed application
   protocols that we couldn't change even if we wanted to (e.g. http/2).

   KCM simply defines a new interface method, it does not redefine any
   aspect of the transport protocol nor application protocol, nor set
   any new requirements on these. Neither does KCM attempt to implement
   any application protocol logic other than message deliniation in the
   stream. These are fundamental requirement of KCM.


> For TX side, why is writev not good enough?

writev on a TCP stream does not guarantee atomicity of the operation.

> Is KCM tx just so that userspace doesn't need to handle partial writes?

It writes atomic without user space needing to implement locking when
a socket is shared amongst threads..
