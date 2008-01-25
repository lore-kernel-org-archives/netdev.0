From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: Slow OOM in netif_RX function
Date: Fri, 25 Jan 2008 12:12:04 -0200
Message-ID: <20080125141204.GA25510@ghostprotocols.net>
References: <4798CAA9.1080005@obs.bg> <4798E32E.6080003@cosmosbay.com> <20080124211810.3E24A46E9A@smtp.obs.bg> <p73tzl282ij.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Ivan H. Dichev" <idichev@obs.bg>, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50094 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbYAYOMM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 09:12:12 -0500
Content-Disposition: inline
In-Reply-To: <p73tzl282ij.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Jan 25, 2008 at 02:21:08PM +0100, Andi Kleen escreveu:
> "Ivan H. Dichev" <idichev@obs.bg> writes:
> >
> > What could happen if I put different Lan card in every slot?
> > In ex. to-private -> 3com
> >       to-inet    -> VIA
> >       to-dmz     -> rtl8139
> > And then to look which RX function is consuming the memory.
> > (boomerang_rx, rtl8139_rx, ... etc) 
> 
> The problem is unlikely to be in the driver (these are both
> well tested ones) but more likely your complicated iptables setup somehow
> triggers a skb leak.
> 
> There are unfortunately no shrink wrapped debug mechanisms in the kernel
> for leaks like this (ok you could enable CONFIG_NETFILTER_DEBUG 
> and see if it prints something interesting, but that's a long shot).
> 
> If you wanted to write a custom debugging patch I would do something like this:
> 
> - Add two new integer fields to struct sk_buff: a time stamp and a integer field
> - Fill the time stamp with jiffies in alloc_skb and clear the integer field
> - In __kfree_skb clear the time stamp
> - For all the ipt target modules in net/ipv4/netfilter/*.c you use change their 
> ->target functions to put an unique value into the integer field you added.
> - Do the same for the pkt_to_tuple functions for all conntrack modules
> 
> Then when you observe the leak take a crash dump using kdump on the router 
> and then use crash to dump all the slab objects for the sk_head_cache.
> Then look for any that have an old time stamp and check what value they
> have in the integer field. Then the netfilter function who set that unique value 
> likely triggered the leak somehow.

I wrote some systemtap scripts that do parts of what you suggest, and at
least for the timestamp there was no need to add a new field to struct
sk_buff, I just reuse skb->timestamp, as it is only used when we use a
packet sniffer. Here it is for reference, but it needs some tapsets I
wrote, so I'll publish this git repo in git.kernel.org, perhaps it can
be useful in this case as a starting point. Find another unused field
(hint: I know that at least 4 bytes on 64 bits is present as a hole) and
you're done, no need to rebuild the kernel :)

http://git.kernel.org/?p=linux/kernel/git/acme/nettaps.git

- Arnaldo

#!/usr/bin/stap

global stats_latency
global stats_bufsize

probe new_packet = kernel.function("__alloc_skb").return
{
	skb = $return
}

probe tcp_in = kernel.function("tcp_v4_rcv")
{
	skb = $skb
	sport = skb_tcphdr_sport(skb)
	dport = skb_tcphdr_dport(skb)
	saddr = skb_iphdr_saddr(skb)
	daddr = skb_iphdr_daddr(skb)
	len = $skb->len
	timestamp = skb_tstamp(skb)
}

probe tcp_out = kernel.function("tcp_transmit_skb")
{
	sk = $sk
	len = $skb->len
	timestamp = skb_tstamp($skb)
	sport = inet_sk_sport(sk)
	dport = inet_sk_dport(sk)
	saddr = inet_sk_saddr(sk)
	daddr = inet_sk_daddr(sk)
}

probe ip_in = kernel.function("ip_rcv")
{
	skb = $skb
	saddr = skb_iphdr_saddr(skb)
	daddr = skb_iphdr_daddr(skb)
	protocol = skb_iphdr_protocol(skb)
	len = $skb->len
	timestamp = skb_tstamp(skb)
}

probe ip_out = kernel.function("ip_queue_xmit")
{
	sk = $skb->sk
	len = $skb->len
	protocol = sk_protocol(sk)
	timestamp = skb_tstamp($skb)
	sport = inet_sk_sport(sk)
	dport = inet_sk_dport(sk)
	saddr = inet_sk_saddr(sk)
	daddr = inet_sk_daddr(sk)
}

probe dev_out = kernel.function("dev_hard_start_xmit")
{
	skb = $skb
	sk = $skb->sk
	len = $skb->len
	timestamp = skb_tstamp(skb)
	if (sk) {
		protocol = sk_protocol(sk)
		sport = inet_sk_sport(sk)
		dport = inet_sk_dport(sk)
		saddr = inet_sk_saddr(sk)
		daddr = inet_sk_daddr(sk)
	}
}

probe dev_in = kernel.function("netif_rx"), kernel.function("netif_receive_skb")
{
	skb = $skb
}

probe user_in = kernel.function("skb_copy_datagram_iovec"),
		kernel.function("skb_copy_and_csum_datagram")
{
	skb = $skb
	sk = $skb->sk
	len = len
	timestamp = skb_tstamp(skb)
	protocol = 0
	if (sk) {
		protocol = sk_protocol(sk)
		dport = inet_sk_dport(sk)
		sport = inet_sk_sport(sk)
		saddr = inet_sk_saddr(sk)
		daddr = inet_sk_daddr(sk)
	}
}

probe new_packet
{
	if (skb)
		skb_take_tstamp(skb)
}

probe dev_in
{
	if (skb)
		skb_take_tstamp(skb)
}

function add_sample(table_id, saddr, sport, daddr, dport, timestamp, len)
{
	/* We're only interested in loopback 
	if (daddr != 0x100007f)
		return 0 */
	delay = gettimeofday_ns() - timestamp
	if (delay < 0) {
		printf("delay < 0! timestamp=%d\n", timestamp)
		return 0
	}

	stats_latency[table_id, saddr, sport, daddr, dport] <<< delay
	stats_bufsize[table_id, saddr, sport, daddr, dport] <<< len
}

probe dev_out
{
	if (protocol == IPPROTO_TCP)
		add_sample("dev_out", saddr, sport, daddr, dport, timestamp, len)
}

probe tcp_out
{
	add_sample("tcp_out", saddr, sport, daddr, dport, timestamp, len)
}

probe ip_in
{
	if (protocol == IPPROTO_TCP) {
		sport = skb_iphdr_tcp_sport(skb)
		dport = skb_iphdr_tcp_dport(skb)

		add_sample("ip_in", daddr, dport, saddr, sport, timestamp, len)
	}
}

probe ip_out
{
	if (protocol == IPPROTO_TCP)
		add_sample("ip_out", daddr, dport, saddr, sport, timestamp, len)
}

probe tcp_in
{
	add_sample("tcp_in", daddr, dport, saddr, sport, timestamp, len)
}

probe user_in
{
	if (protocol == IPPROTO_TCP)
		add_sample("user_in", saddr, sport, daddr, dport, timestamp, len)
}

probe end
{
	printf("%8s %15.15s %5s %15s %5s %23s %18s\n",
	       "", "", "", "", "", "latency(ns)", "buffer size")
	printf("%8.8s %15.15s %5s %15.15s %5s %8s %7s %9s %5s %5s %5s\n",
	       "entry", "local address", "port", "remote address", "port",
	       "avg", "min", "max", "avg", "min", "max")

	foreach ([table_id-, saddr, sport, daddr, dport] in stats_latency) {
		printf("%-8.8s %15.15s %5d %15.15s %5d %8d %7d %9d %5d %5d %5d\n",
		       table_id, inet_sk_ntop(saddr), sport, inet_sk_ntop(daddr), dport,
		       @avg(stats_latency[table_id, saddr, sport, daddr, dport]),
		       @min(stats_latency[table_id, saddr, sport, daddr, dport]),
		       @max(stats_latency[table_id, saddr, sport, daddr, dport]),
		       @avg(stats_bufsize[table_id, saddr, sport, daddr, dport]),
		       @min(stats_bufsize[table_id, saddr, sport, daddr, dport]),
		       @max(stats_bufsize[table_id, saddr, sport, daddr, dport]))
	}
}
