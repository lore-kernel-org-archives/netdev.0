From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problem with fragmented packets on tun/tap interface
Date: Thu, 13 Aug 2015 07:18:22 -0700
Message-ID: <1439475502.7960.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPBAu3WwLLAYtRuxrA2uDF7J5-1FPfvJ-JVB1_WHNZdf1W_M=A@mail.gmail.com>
	 <1438329395.2748.1.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3V2Y56wnfgh1Y9gJ8XxVGEjZYaCXBNfg-uUOeYLy9NTrw@mail.gmail.com>
	 <1438341695.2748.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAPBAu3VHtt5TDpvVNUkkQey2fjEYaDDSX8fwzwomyANtUhGQEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Prashant Upadhyaya <praupadhyaya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35847 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbbHMOSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 10:18:25 -0400
Received: by pacrr5 with SMTP id rr5so38371760pac.3
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 07:18:24 -0700 (PDT)
In-Reply-To: <CAPBAu3VHtt5TDpvVNUkkQey2fjEYaDDSX8fwzwomyANtUhGQEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-08-13 at 12:52 +0530, Prashant Upadhyaya wrote:

> 
> Hi,
> 
> I think I have a clue to the root cause of my issue, but I do not know
> a solution.
> Let me describe what I think is the problem.
> 
> Fragmented packets enter into the kernel through eth0 and the kernel
> starts assembling them.
> Simultaneously, my packet socket implementation also injects the very
> same packets into the kernel via the tap. The kernel sees them as
> overlapped packets during assembly and drops the packets injected via
> the tap.
> Eventually when the assembly gets complete inside kernel for all the
> packets which entered via eth0, the whole packet gets dropped due to
> the iptables rules that I have set on eth0.
> So naturally there is no response to the bigger ping, because
> everything got dropped one way or the other.
> 
> When I do introduce the delays (and it turns out that the delay that
> matters is when injecting via tap), the kernel has already completed
> the assembly of the packets via eth0 (during the delay I introduce for
> submission on tap), and then the submission via tap works well because
> it undergoes a fresh assembly (and ofcourse it does not get dropped
> because iptables drop rule is only on eth0)
> 
> Now then, the question is -- how do I prevent the kernel from trying
> to assemble the packets arriving on eth0 and drop them right away even
> before assembly is attempted. This way the same packet injected via
> the tap would be the only one undergoing assembly and hopefully it
> would work.
> 

Nice theory ! 

What kind of iptables rule do you have to drop packets coming on eth0 ?

Have you tried to install this rule in raw table, PREROUTING hook ?

This should work, because the defrag is attempted from
ip_local_deliver() [ after raw table has given its verdict] , not from
ip_rcv().

iptables -t raw -I PREROUTING -i eth0 -j DROP
