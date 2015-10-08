From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 1/4] net: SO_INCOMING_CPU setsockopt() support
Date: Thu, 8 Oct 2015 09:44:38 -0700
Message-ID: <CALx6S34ctcycnjTR4gon7oSRMdh3Xod2yi_B_TtTvrxt6MW4gg@mail.gmail.com>
References: <1444318627-27883-1-git-send-email-edumazet@google.com>
	<1444318627-27883-2-git-send-email-edumazet@google.com>
	<CALx6S35jNA8sQ_yibFK-eL-asbNP9BieRvTcKkM3-CNarKJMDA@mail.gmail.com>
	<1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34814 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933164AbbJHQoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 12:44:39 -0400
Received: by iow1 with SMTP id 1so64719796iow.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 09:44:38 -0700 (PDT)
In-Reply-To: <1444321775.27760.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 9:29 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-10-08 at 09:03 -0700, Tom Herbert wrote:
>> On Thu, Oct 8, 2015 at 8:37 AM, Eric Dumazet <edumazet@google.com> wrote:
>> > SO_INCOMING_CPU as added in commit 2c8c56e15df3 was a getsockopt() command
>> > to fetch incoming cpu handling a particular TCP flow after accept()
>> >
>> > This commits adds setsockopt() support and extends SO_REUSEPORT selection
>> > logic : If a TCP listener or UDP socket has this option set, a packet is
>> > delivered to this socket only if CPU handling the packet matches the specified one.
>> >
>> > This allows to build very efficient TCP servers, using one thread per cpu,
>> > as the associated TCP listener should only accept flows handled in softirq
>> > by the same cpu. This provides optimal NUMA/SMP behavior and keep cpu caches hot.
>> >
>> Please look again at my SO_INCOMING_CPU_MASK patches to see it these
>> will work. I believe SO_INCOMING_CPU setsockopt is probably a subset
>> of that functionality. A single CPU assigned to socket forces an
>> application design to have one thread per CPU-- this may be overkill.
>> It's probably be sufficient in many cases to have just one listener
>> thread per NUMA node.
>
>
> I think you misunderstood my patch.
>
> For optimal behavior against DDOS, you need one TCP _listener_ per RX
> queue on the NIC.
>
I see. We are not using SO_INCOMING_CPU_MASK as a defense against
DDOS. It's used ensure affinity in application connection processing
between CPUs. For instance, if we have two NUMA nodes we can start two
instances of the application bound to each node and then use
SO_REUSEPORT and SO_INCOMING_CPU_MASK to ensure connections are
processed on the the same NUMA node. Packets crossing NUMA boundaries
even with RFS is painful.

Tom
