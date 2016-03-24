From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 19:21:15 +0100
Message-ID: <20160324182115.GA7678@1wt.eu>
References: <CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
 <20160324061222.GA6807@1wt.eu>
 <1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324142222.GB7237@1wt.eu>
 <1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324153053.GA7569@1wt.eu>
 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324165047.GA7585@1wt.eu>
 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160324180011.GB7585@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tolga Ceylan <tolga.ceylan@gmail.com>,
	Tom Herbert <tom@herbertland.com>, cgallek@google.com,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:32139 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbcCXSVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2016 14:21:25 -0400
Content-Disposition: inline
In-Reply-To: <20160324180011.GB7585@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 07:00:11PM +0100, Willy Tarreau wrote:
> Since it's not about
> load distribution and that processes are totally independant, I don't see
> well how to (ab)use BPF to achieve this.
> 
> The pattern is :
> 
>   t0 : unprivileged processes 1 and 2 are listening to the same port
>        (sock1@pid1) (sock2@pid2)
>        <------ listening ------>
> 
>   t1 : new processes are started to replace the old ones
>        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>        <------ listening ------> <------ listening ------>
> 
>   t2 : new processes signal the old ones they must stop
>        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>        <------- draining ------> <------ listening ------>
> 
>   t3 : pids 1 and 2 have finished, they go away
>                                  (sock3@pid3) (sock4@pid4)
>         <------ gone ----->      <------ listening ------>
> 

Thinking a bit more about it, would it make sense to consider that in order
to address such a scenario, the only the new (still privileged) process
reconfigures the BPF to deliver traffic only to its own sockets and that
by doing so it will result in the old one not to receive any of it anymore ?
If so that could possibly be reasonably doable then. Ie: the old processes
don't have to do anything to stop receiving traffic.

Thanks,
Willy
