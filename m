From: Chunhui He <hchunhui@mail.ustc.edu.cn>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in
 neigh_update()
Date: Mon, 25 Jul 2016 07:52:29 +0000 (UTC)
Message-ID: <20160725.075229.794245205936957321.hchunhui@mail.ustc.edu.cn>
References: <alpine.LFD.2.11.1607231625130.2032@ja.home.ssi.bg>
	<20160723.165218.688680379367395677.hchunhui@mail.ustc.edu.cn>
	<alpine.LFD.2.11.1607232039400.2032@ja.home.ssi.bg>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.11.1607232039400.2032@ja.home.ssi.bg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello,

On Sat, 23 Jul 2016 22:09:43 +0300 (EEST), Julian Anastasov <ja@ssi.bg> wrote:
> 
> 	May be that is the problem: we receive such packet,
> ip_route_input_noref detects that we allow such packet
> from NEIGH_IP on this interface, tip is not RTN_LOCAL (no
> ARP reply from us), tip is RTN_UNICAST but proxy_arp is not
> allowed, so we continue and reach __neigh_lookup which finds
> the existing cache entry because we talked to GW before that.
> As this is an ARP request, neigh_update is called with NUD_STALE.
> No reply is sent because request was not for us but we
> just learned that NEIGH_IP is alive because it lookups
> for someone else. This is common to observe with broadcasts,
> GW lookups for other hosts and has to expose its IP+hwaddr.
> More difficult to happen with unicast packets, you need hub,
> not switch, to detect such packets.
> 
> 	It is possible that you miss the packet that tries
> to set NUD_STALE. May be you can add some printk's to catch
> what kind of packet causes this. This can help too:
> 
> tcpdump -lnnn -s0 arp and host GW_IP
> 
> 	If you see such packet, that is it. Our cache is
> updated with NUD_STALE.
> 
>> So I'm not sure if it can learn from ARP reply.
> 
> 	See above, received broadcast GARP reply can set
> NUD_STALE. But the most trivial case of GW exposing its
> IP while looking for other hosts should be the culprit.
> It probably happens often, that is why we have no chance
> to send ARP requests, GW is more ARP-active than us and
> updates our cache and we are happy.
>

Thank you for your analysis.
I think the same, except that I don't think GW can update
our cache via broadcast ARP.

Please the comment in arp_process():
>                int state = NUD_REACHABLE;
...
>                /* Broadcast replies and request packets
>                   do not assert neighbour reachability.
>                 */
>                if (arp->ar_op != htons(ARPOP_REPLY) ||
>                    skb->pkt_type != PACKET_HOST)
>                        state = NUD_STALE;
>                neigh_update(n, sha, state,
...

Broadcast packets do not assert reachability, so they
should not interference our state machine. They are
just a hint.

Regards,
Chunhui
