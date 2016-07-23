From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Sat, 23 Jul 2016 22:09:43 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1607232039400.2032@ja.home.ssi.bg>
References: <alpine.LFD.2.11.1607230654070.2032@ja.home.ssi.bg> <20160723.112447.1086885115572685589.hchunhui@mail.ustc.edu.cn> <alpine.LFD.2.11.1607231625130.2032@ja.home.ssi.bg> <20160723.165218.688680379367395677.hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, dsa@cumulusnetworks.com,
	nicolas.dichtel@6wind.com, roopa@cumulusnetworks.com,
	rshearma@brocade.com, dbarroso@fastly.com, martinbj2008@gmail.com,
	rick.jones2@hp.com, koct9i@gmail.com, edumazet@google.com,
	tgraf@suug.ch, ebiederm@xmission.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chunhui He <hchunhui@mail.ustc.edu.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160723.165218.688680379367395677.hchunhui@mail.ustc.edu.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Sat, 23 Jul 2016, Chunhui He wrote:

> The neigh system is to reduce ARP traffic, that is good. The problem is it fails
> to handle some coner cases.
> 
> The coner case is (let's forget my case above):
> In NUD_DELAY, the neigh system is waiting for a proof of reachablity. If there
> is no proof, the neigh system must prove by itself, so goes to NUD_PROBE and
> sends request. But when some other part of kernel gives a non-proof by
> neigh_update()(STALE is a *hint*, not a proof of reachablity), the neigh system
> will leave NUD_DELAY, and will *"forget"* to prove by itself. So it's possiable
> to send traffic to a non-reachable address. That's definitely wrong, even it
> "saves" traffic.
> 
> And the fix is to disallow NUD_DELAY -> NUD_STALE.

	But NUD_STALE event happens only for received
packet, for the concerned remote IP address, for same or
different hwaddr, for any kind of tip (target IP). Examples:

- Received ARP request who-has LOCAL_IP tell NEIGH_IP:
	neigh_event_ns is called for the RTN_LOCAL case,
	for sip/sha. Reply is sent.

- Received ARP request who-has UNICAST_IP tell NEIGH_IP:
	neigh_event_ns is called for the IN_DEV_FORWARD case,
	for sip/sha, i.e. if we use proxy_arp. Deferred
	or immediate reply is sent.

- Received ARP request who-has UNICAST_IP tell NEIGH_IP:
	neigh_update is called for existing entry when
	proxy_arp=0, i.e. request not catched by above case.
	No reply is sent.

- Received Gratuitous ARP request who-has NEIGH_IP tell NEIGH_IP:
	neigh_update is called for broadcast request when
	arp_accept=1 or when arp_accept=0 while cache entry exists.
	No reply is sent.

- Received Gratuitous ARP reply NEIGH_IP is-at hwaddr:
	neigh_update is called for the received broadcast reply

	This was all for NUD_STALE. There is only one
ARP case where NUD_REACHABLE is set, usually in response
to our request:

- Received unicast reply NEIGH_IP is-at hwaddr

- the second non-ARP case for NUD_REACHABLE is from dst_confirm

> > 	Can it learn from our unicast ARP replies that we
> > should sent in response to its broadcast probes? Or it
> > expects only ARP requests?
> 
> All the broadcast probes I have seen are not "who has <our ip>". they are about
> other hosts, so we are not expected to answer.

	May be that is the problem: we receive such packet,
ip_route_input_noref detects that we allow such packet
from NEIGH_IP on this interface, tip is not RTN_LOCAL (no
ARP reply from us), tip is RTN_UNICAST but proxy_arp is not
allowed, so we continue and reach __neigh_lookup which finds
the existing cache entry because we talked to GW before that.
As this is an ARP request, neigh_update is called with NUD_STALE.
No reply is sent because request was not for us but we
just learned that NEIGH_IP is alive because it lookups
for someone else. This is common to observe with broadcasts,
GW lookups for other hosts and has to expose its IP+hwaddr.
More difficult to happen with unicast packets, you need hub,
not switch, to detect such packets.

	It is possible that you miss the packet that tries
to set NUD_STALE. May be you can add some printk's to catch
what kind of packet causes this. This can help too:

tcpdump -lnnn -s0 arp and host GW_IP

	If you see such packet, that is it. Our cache is
updated with NUD_STALE.

> So I'm not sure if it can learn from ARP reply.

	See above, received broadcast GARP reply can set
NUD_STALE. But the most trivial case of GW exposing its
IP while looking for other hosts should be the culprit.
It probably happens often, that is why we have no chance
to send ARP requests, GW is more ARP-active than us and
updates our cache and we are happy.

Regards

--
Julian Anastasov <ja@ssi.bg>
