From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Sat, 23 Jul 2016 17:09:12 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607231625130.2032@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg> <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn> <alpine.LFD.2.11.1607230654070.2032@ja.home.ssi.bg> <20160723.112447.1086885115572685589.hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53177 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750882AbcGWOKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 10:10:31 -0400
In-Reply-To: <20160723.112447.1086885115572685589.hchunhui@mail.ustc.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 23 Jul 2016, Chunhui He wrote:

> On Sat, 23 Jul 2016 09:17:59 +0300 (EEST), Julian Anastasov <ja@ssi.bg> wrote:
> > 
> > 	What kind of problem is this? Remote host wants to
> > see a recent probe from us, otherwise it refuses to resolve
> > our address before its traffic to us and it is not sent?
> > Can you explain this in more detail because after looking
> > again I have some doubts what actually happens, see below.
> >
> 
> The remote host is configured to refuse to send any packets to a host it doesn't
> "know" (but broadcast is allowed), and it can only "learn" from ARP packets.

	Can it learn from our unicast ARP replies that we
should sent in response to its broadcast probes? Or it
expects only ARP requests?

> When I send packets, if broadcast ARP requests from the remote host are received
> and set the state to NUD_STALE, then I stuck.

	So, this is a special case. Is it possible to
solve it from user space?:

1.1. echo 0 > delay_first_probe_time. This can help if
remote hosts sends broadcast ARP probes every second and
if we send IP packets too.

1.2. reduce base_reachable_time if needed to send ARP probes
more often

2. Send ARP probe by using the arping tool, eg. from cron

	Note that solution 1 is not good. If we do not
have traffic to send there will be no ARP probe and the
remote host can not send to us.

> > 	To summarize: currently the change to NUD_STALE serves the
> > purpose to avoid/delay our hwaddr refreshing probes. They are
> > avoided if protocols indicate progress with the current hwaddr.
> > Outgoing IP traffic that does not trigger confirmation
> > from replies (for example TCP ACK calling dst_confirm) or
> > from applications (MSG_CONFIRM) surely will cause a
> > switch to NUD_PROBE.
> >
> 
> Yes, I agree.
> But now it is possible to delay the probes *forever*, and at the same time we
> get no positive response from the remote host.

	What happens if we do not send traffic and the
neigh entry is removed? How the remote host will learn
our address? If remote host sends ARP broadcasts even
arp_accept=1 will create NUD_STALE entry and without any
traffic we can stay in this state, no chance for NUD_DELAY.

> > 	So, the question is, to avoid probes or to refresh
> > frequently? Is there a good reason to ignore this NUD_STALE
> > event in NUD_DELAY | NUD_PROBE state?
> >
> 
> So reaching a NUD_REACHABLE state in not our goal. It's to ensure correctness.
> Cycle between NUD_STALE and NUD_DELAY is not correct.

	The main goal looks to be the reduced ARP traffic. If
we learned the neigh address recently (even if from remote ARP
broadcast probes or from TCP ACKs) we do not need to send
probes. Looks like the goal "always stay present in remote
ARP caches" is not listed as our goal. Even "always update
remote ARP cache" is not implemented, no outgoing traffic =>
no ARP probes.

> Maybe it is enough to ignore NUD_STALE?

	But you in this case rely on traffic to enter
NUD_DELAY state. Note that looking at neigh_timer_handler
NUD_DELAY state is not guaranteed: if there is no
recent outgoing traffic the NUD_REACHABLE state can be changed
to NUD_STALE, not to NUD_DELAY, so no chance for probes
that will keep the entry refreshed forever.

Regards
