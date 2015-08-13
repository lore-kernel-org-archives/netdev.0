From: Prashant Upadhyaya <praupadhyaya@gmail.com>
Subject: Re: Problem with fragmented packets on tun/tap interface
Date: Thu, 13 Aug 2015 12:52:05 +0530
Message-ID: <CAPBAu3VHtt5TDpvVNUkkQey2fjEYaDDSX8fwzwomyANtUhGQEg@mail.gmail.com>
References: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
	<1438329395.2748.1.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAPBAu3V2Y56wnfgh1Y9gJ8XxVGEjZYaCXBNfg-uUOeYLy9NTrw@mail.gmail.com>
	<1438341695.2748.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:34075 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbHMHWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 03:22:07 -0400
Received: by iodb91 with SMTP id b91so43729756iod.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 00:22:05 -0700 (PDT)
In-Reply-To: <1438341695.2748.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 31, 2015 at 4:51 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-07-31 at 16:42 +0530, Prashant Upadhyaya wrote:
>> On Fri, Jul 31, 2015 at 1:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Fri, 2015-07-31 at 12:30 +0530, Prashant Upadhyaya wrote:
>> >
>> >> The delays work for me but is clearly not good for the performance of
>> >> the slow path. And more importantly, I was looking for a fundamental
>> >> reason regarding why it works with delays and why not without it. The
>> >> issue is reproducible with a big ping (3.11.10-301.fc20.x86_64)
>> >
>> > How big ping needs to be to reproduce the problem ?
>> >
>> >
>>
>> If the MTU is 1500, I start getting problems anywhere starting from
>> 2900 bytes and surely comes when further big pings are used eg. 10 K.
>> (ping <IP> -s <Size> eg. ping 10.3.10.244 -s 10000)
>> And the big pings do work, as I said, with the delay hack.
>
> It might help trying this while you receive such frags :
>
> perf record -a -g skb:kfree_skb sleep 10
>
> ...
>
> perf report
>
>
>

Hi,

I think I have a clue to the root cause of my issue, but I do not know
a solution.
Let me describe what I think is the problem.

Fragmented packets enter into the kernel through eth0 and the kernel
starts assembling them.
Simultaneously, my packet socket implementation also injects the very
same packets into the kernel via the tap. The kernel sees them as
overlapped packets during assembly and drops the packets injected via
the tap.
Eventually when the assembly gets complete inside kernel for all the
packets which entered via eth0, the whole packet gets dropped due to
the iptables rules that I have set on eth0.
So naturally there is no response to the bigger ping, because
everything got dropped one way or the other.

When I do introduce the delays (and it turns out that the delay that
matters is when injecting via tap), the kernel has already completed
the assembly of the packets via eth0 (during the delay I introduce for
submission on tap), and then the submission via tap works well because
it undergoes a fresh assembly (and ofcourse it does not get dropped
because iptables drop rule is only on eth0)

Now then, the question is -- how do I prevent the kernel from trying
to assemble the packets arriving on eth0 and drop them right away even
before assembly is attempted. This way the same packet injected via
the tap would be the only one undergoing assembly and hopefully it
would work.

Regards
-Prashant
