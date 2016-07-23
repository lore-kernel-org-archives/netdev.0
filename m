From: Chunhui He <hchunhui@mail.ustc.edu.cn>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Sat, 23 Jul 2016 16:52:18 +0000 (UTC)
Message-ID: <20160723.165218.688680379367395677.hchunhui@mail.ustc.edu.cn>
References: <alpine.LFD.2.11.1607230654070.2032@ja.home.ssi.bg>
	<20160723.112447.1086885115572685589.hchunhui@mail.ustc.edu.cn>
	<alpine.LFD.2.11.1607231625130.2032@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ustc.edu.cn ([202.38.64.46]:35203 "EHLO ustc.edu.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751083AbcGWQws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 12:52:48 -0400
In-Reply-To: <alpine.LFD.2.11.1607231625130.2032@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, Julian.

My case is special, so I think the detail(provided below, if you are intresting)
is not very important. *It only trigers the real problem*.

The neigh system is to reduce ARP traffic, that is good. The problem is it fails
to handle some coner cases.

The coner case is (let's forget my case above):
In NUD_DELAY, the neigh system is waiting for a proof of reachablity. If there
is no proof, the neigh system must prove by itself, so goes to NUD_PROBE and
sends request. But when some other part of kernel gives a non-proof by
neigh_update()(STALE is a *hint*, not a proof of reachablity), the neigh system
will leave NUD_DELAY, and will *"forget"* to prove by itself. So it's possiable
to send traffic to a non-reachable address. That's definitely wrong, even it
"saves" traffic.

And the fix is to disallow NUD_DELAY -> NUD_STALE.

Regrads,
Chunhui

On Sat, 23 Jul 2016 17:09:12 +0300 (EEST), Julian Anastasov <ja@ssi.bg> wrote:
>> 
>> The remote host is configured to refuse to send any packets to a host it doesn't
>> "know" (but broadcast is allowed), and it can only "learn" from ARP packets.
> 
> 	Can it learn from our unicast ARP replies that we
> should sent in response to its broadcast probes? Or it
> expects only ARP requests?

All the broadcast probes I have seen are not "who has <our ip>". they are about
other hosts, so we are not expected to answer.
So I'm not sure if it can learn from ARP reply.

> 
>> When I send packets, if broadcast ARP requests from the remote host are received
>> and set the state to NUD_STALE, then I stuck.
> 
> 	So, this is a special case. Is it possible to
> solve it from user space?:
> 
> 1.1. echo 0 > delay_first_probe_time. This can help if
> remote hosts sends broadcast ARP probes every second and
> if we send IP packets too.
> 
> 1.2. reduce base_reachable_time if needed to send ARP probes
> more often
>
> 2. Send ARP probe by using the arping tool, eg. from cron
>

Solution 2 works. But I think it is a workaround.

> 	What happens if we do not send traffic and the
> neigh entry is removed? How the remote host will learn
> our address? If remote host sends ARP broadcasts even
> arp_accept=1 will create NUD_STALE entry and without any
> traffic we can stay in this state, no chance for NUD_DELAY.
>

The remote host is a gateway, traffic initiated from outside is forbidden.
So we always initiate traffic.
If we don't send traffic and arp_accept=0, no entry is created.

The entry is created when we send traffic.
Normally the state is set to NUD_STALE immediately, then we enter
the "NUD_STALE -> NUD_DELAY -> NUD_STALE" loop.

> 
> 	The main goal looks to be the reduced ARP traffic. If
> we learned the neigh address recently (even if from remote ARP
> broadcast probes or from TCP ACKs) we do not need to send
> probes. Looks like the goal "always stay present in remote
> ARP caches" is not listed as our goal. Even "always update
> remote ARP cache" is not implemented, no outgoing traffic =>
> no ARP probes.
>

Please see the top.

> 	But you in this case rely on traffic to enter
> NUD_DELAY state. Note that looking at neigh_timer_handler
> NUD_DELAY state is not guaranteed: if there is no
> recent outgoing traffic the NUD_REACHABLE state can be changed
> to NUD_STALE, not to NUD_DELAY, so no chance for probes
> that will keep the entry refreshed forever.
> 

No. When I send traffic, the entry will enter NUD_DELAY agagin.
