From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: increment UDP_MIB_NOPORTS in mcast receive
Date: Wed, 03 Oct 2012 17:29:13 +0200
Message-ID: <1349278153.12401.2811.camel@edumazet-glaptop>
References: <506955F3.8050304@googlemail.com>
	 <1349082950.12401.669.camel@edumazet-glaptop>
	 <20121001193434.GA14236@redhat.com>
	 <20121001.160115.1816241312626722150.davem@davemloft.net>
	 <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <alpine.LFD.2.00.1210030032430.25856@ja.ssi.bg>
	 <1349249328.12401.1364.camel@edumazet-glaptop>
	 <OFA39D9FC0.CDC6EE41-ON85257A8C.00458030-85257A8C.00461EF4@us.ibm.com>
	 <1349270151.12401.2372.camel@edumazet-glaptop>
	 <OF8CC7A8E7.DA3B059E-ON85257A8C.004C258C-85257A8C.004DCE49@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, Dave Jones <davej@redhat.com>,
	David Miller <davem@davemloft.net>, gpiez@web.de,
	Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35427 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964792Ab2JCP3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 11:29:19 -0400
In-Reply-To: <OF8CC7A8E7.DA3B059E-ON85257A8C.004C258C-85257A8C.004DCE49@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-10-03 at 10:09 -0400, David Stevens wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 10/03/2012 09:15:51 AM:
>  
> > So when a host receives an UDP datagram but there was no application
> > at the destination port we should increment udpNoPorts, and its not
> > an error but just a fact.
> 
>         Of course. I think our difference is on the definition of 
> "receives".

A receive is a packet delivered to this host.
Interface being promiscuous or not doesnt really matter.

> I don't think a packet delivered locally due to promiscuous mode, 
> broadcast
> or an imperfect multicast address filter match is a host UDP datagram 
> receive.
> These packets really shouldn't be delivered to UDP at all; they are not
> addressed to this host (at least the non-broadcast, no-membership ones).

Thats the bug we currently are tracking. If some error is happening and
packet is delivered instead of being forwarded or dropped, we need a
counter being incremented to catch the bug.

>         A unicast UDP packet that doesn't match a local IP address does 
> not
> increment this counter. 

It _does_ increment this counter right now, not sure what you mean.

We currently correctly increment udpNoPorts if we receive an unicast UDP
packet that doesnt find a matching socket (because socket(s) are bound
to specific addresses instead of ANY_ADDR)

This is an extension of the "there was no application at the destination
port" to "there was no application at the destination port and
destination address"

> A promiscuous mode multicast delivery is no 
> different,
> except that the destination alone doesn't tell us if it is for us.
> 
>         I think counting these will primarily lead to administrators 
> seeing
> non-zero drops and wasting their time trying to track them down.

Well, as I said, seeing increments of this counter is perfectly fine and
matches RFC. It permits better diagnostics. Hiding bugs is not very
helpful.

Most of the time I am trying to track a bug in linux network stack, the
very first thing I ask to reporters is to post "netstat -s" before/after
their tests exactly because I want to see _some_ counters be incremented
and catch obvious problems.

And alas, many drops in our stack are not correctly reported because we
forgot to increment a counter at the right place.

I am fine adding a new SNMP McastDrops counter if you feel its better.

# grep Udp: /proc/net/snmp
Udp: InDatagrams NoPorts InErrors OutDatagrams RcvbufErrors SndbufErrors McastDrops
Udp: 11449164 15473 514616 290821178 0 184352 134

"netstat -s -u" would display :

Udp:
    11449164 packets received
    15473 packets to unknown port received.
    514616 packet receive errors
    290821178 packets sent
    SndbufErrors: 184352
    McastDrops: 134


Non official patch since net-next is not open :

 include/linux/snmp.h |    1 +
 net/ipv4/proc.c      |    1 +
 net/ipv4/udp.c       |    2 ++
 net/ipv6/proc.c      |    2 ++
 net/ipv6/udp.c       |    2 ++
 5 files changed, 8 insertions(+)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 00bc189..321d643 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -145,6 +145,7 @@ enum
 	UDP_MIB_OUTDATAGRAMS,			/* OutDatagrams */
 	UDP_MIB_RCVBUFERRORS,			/* RcvbufErrors */
 	UDP_MIB_SNDBUFERRORS,			/* SndbufErrors */
+	UDP_MIB_MCASTDROPS,			/* McastDrops (linux extension) */
 	__UDP_MIB_MAX
 };
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 957acd1..1e932ee 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -172,6 +172,7 @@ static const struct snmp_mib snmp4_udp_list[] = {
 	SNMP_MIB_ITEM("OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("McastDrops", UDP_MIB_MCASTDROPS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 2814f66..4e2a4f7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1591,6 +1591,8 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
+		UDP_INC_STATS_BH(net, UDP_MIB_MCASTDROPS,
+				 udptable != &udp_table);
 	}
 	return 0;
 }
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 745a320..f2c12ea 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -129,6 +129,7 @@ static const struct snmp_mib snmp6_udp6_list[] = {
 	SNMP_MIB_ITEM("Udp6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("Udp6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("Udp6SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("Udp6McastDrops", UDP_MIB_MCASTDROPS),
 	SNMP_MIB_SENTINEL
 };
 
@@ -139,6 +140,7 @@ static const struct snmp_mib snmp6_udplite6_list[] = {
 	SNMP_MIB_ITEM("UdpLite6OutDatagrams", UDP_MIB_OUTDATAGRAMS),
 	SNMP_MIB_ITEM("UdpLite6RcvbufErrors", UDP_MIB_RCVBUFERRORS),
 	SNMP_MIB_ITEM("UdpLite6SndbufErrors", UDP_MIB_SNDBUFERRORS),
+	SNMP_MIB_ITEM("UdpLite6McastDrops", UDP_MIB_MCASTDROPS);
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 07e2bfe..c8caf1b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -748,6 +748,8 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 			sock_put(stack[i]);
 	} else {
 		kfree_skb(skb);
+		UDP6_INC_STATS_BH(net, UDP_MIB_MCASTDROPS,
+				  udptable != &udp_table);
 	}
 	return 0;
 }
