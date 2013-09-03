From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue, 03 Sep 2013 14:26:43 +0200
Message-ID: <5225D583.9090404@redhat.com>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>  <1378204010-27050-2-git-send-email-dborkman@redhat.com>  <1378206045.2048.9.camel@joe-AO722> <5225CAB1.7080402@redhat.com> <1378210546.2048.20.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Theodore Ts'o" <tytso@mit.edu>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752612Ab3ICM0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 08:26:50 -0400
In-Reply-To: <1378210546.2048.20.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2013 02:15 PM, Joe Perches wrote:
> On Tue, 2013-09-03 at 13:40 +0200, Daniel Borkmann wrote:
>> On 09/03/2013 01:00 PM, Joe Perches wrote:
>>> On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
>>>> We have implemented the same function over and over, so introduce a
>>>> generic helper net_random_N() that unifies these implementations.
>>>> It internally used net_random() which eventually resolves to
>>>> prandom_u32(). Explicit include of reciprocal_div.h is not necessary.
>>>
>>> Perhaps adding a generic helper to random.h like
>>> 	u32 prandom_u32_between(u32 low, u32 high);
>>> or
>>> 	u32 prandom_u32_range(u32 bound1, u32 bound2)
>>> would be better.
>>
>> Sure, this could be done as a follow-up. Once, we've migrated users to
>> the new API, follow-ups could go ahead to do the rest, and migration
>> will be easy. Note that the lower bound is 0 here.
>
> Part of the reason I suggested this it to make the
> API more readable/intelligible.
>
> At first glance, I have no idea what net_random_N does.
>
> I think #define net_random() prandom_u32()
> should be removed eventually as well.

Why? Assume there could be different PRNGs in future that have different properties
(e.g. speed vs. period, etc). Then, changing net_random() to something else is way
easier and less error-prone than searching through the whole subtree of net and
replacing every occurrence of prandom_u32().

> If gcc doesn't already do this optimization,
> perhaps there are also some use of
> 	net_random() % non_const
> that could be optimized a bit using this API.

I agree with you, needs to be evaluated on a case by case basis for future work.

> $ git grep -E "(prandom_u32|net_random)\s*\(\s*\)\s*\%" net
> net/batman-adv/bat_iv_ogm.c:	msecs += prandom_u32() % (2 * BATADV_JITTER);
> net/batman-adv/bat_iv_ogm.c:	return jiffies + msecs_to_jiffies(prandom_u32() % (BATADV_JITTER / 2));
> net/core/neighbour.c:	return base ? (net_random() % base) + (base >> 1) : 0;
> net/core/neighbour.c:	unsigned long sched_next = now + (net_random() % p->proxy_delay);
> net/core/pktgen.c:		flow = prandom_u32() % pkt_dev->cflows;
> net/core/pktgen.c:			t = prandom_u32() %
> net/core/pktgen.c:			mc = prandom_u32() % pkt_dev->src_mac_count;
> net/core/pktgen.c:			mc = prandom_u32() % pkt_dev->dst_mac_count;
> net/core/pktgen.c:			pkt_dev->cur_udp_src = prandom_u32() %
> net/core/pktgen.c:			pkt_dev->cur_udp_dst = prandom_u32() %
> net/core/pktgen.c:				t = prandom_u32() % (imx - imn) + imn;
> net/core/pktgen.c:						t = prandom_u32() %
> net/core/pktgen.c:			t = prandom_u32() %
> net/core/stream.c:		current_timeo = vm_wait = (net_random() % (HZ / 5)) + 2;
> net/ipv4/igmp.c:	int tv = net_random() % max_delay;
> net/ipv4/igmp.c:	int tv = net_random() % in_dev->mr_maxdelay;
> net/ipv4/igmp.c:	int tv = net_random() % delay;
> net/ipv4/inet_connection_sock.c:		smallest_rover = rover = net_random() % remaining + low;
> net/ipv6/addrconf.c:		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
> net/ipv6/mcast.c:	unsigned long tv = net_random() % idev->mc_maxdelay;
> net/ipv6/mcast.c:	unsigned long tv = net_random() % delay;
> net/ipv6/mcast.c:	unsigned long tv = net_random() % delay;
> net/ipv6/mcast.c:			delay = net_random() % resptime;
> net/ipv6/mcast.c:	delay = net_random() % unsolicited_report_interval(ma->idev);
> net/netfilter/nf_conntrack_core.c:			(prandom_u32() % net->ct.sysctl_events_retry_timeout);
> net/netfilter/nf_conntrack_core.c:		(prandom_u32() % net->ct.sysctl_events_retry_timeout);
> net/sched/act_gact.c:	if (!gact->tcfg_pval || net_random() % gact->tcfg_pval)
> net/sched/sch_netem.c:		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
> net/sctp/socket.c:		rover = net_random() % remaining + low;
> net/sunrpc/xprtsock.c:	unsigned short rand = (unsigned short) net_random() % range;
> net/xfrm/xfrm_state.c:			spi = low + net_random()%(high-low+1);
>
>
