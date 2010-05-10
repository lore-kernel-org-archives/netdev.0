From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4  0/4] net: relax dst refcnt for net-next-2.6
Date: Mon, 10 May 2010 23:08:36 +0200
Message-ID: <1273525716.2590.313.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39997 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab0EJV1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:27:54 -0400
Received: by wyb32 with SMTP id 32so460462wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 14:27:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is V4 of a patch previously sent last year

One serious point of contention in network stack is the IP route cache
refcounts in input path, on SMP setups.

On stress situation, one cpu (say A) handles network softirq RX processing.
When a packet is received, we need to find a dst_entry, take
a reference on this dst_entry and associate skb to this dst_entry.
skb is queued on a socket receive queue.

When application (running from another CPU B) dequeues this packet,
it has to release the dst_entry, which refcount is hot and dirty on
another CPU A cache, involving an expensive cache line ping-pong.

Back in November 2008, we tried to keep this cache line only
in CPU A (commit 703556028792)
(net: release skb->dst in sock_queue_rcv_skb()), but we had
to revert this commit because it broke IP_PKTINFO handling,
as noticed by Mark McLoughlin

Then David suggested not taking the reference at the first place,
which this patch does when possible.

We prepared this work with commit adf30907 (net: skb->dst accessors),
introducing accessors to work on skb->dst

We now can use the low order bit of skb->_skb_dst to tell
if a reference was _not_ taken on dst for this skb

We make sure a dst leaving rcu protected region has a refcount.
This is done on enqueueing on any kind of queue (backlog, qdisc,
nf_queue, ...)

Net effect of this patch is avoiding two atomic ops per
incoming packet, and two atomic ops per outgoing TCP packet.

Same for outgoing path, if device has IFF_XMIT_DST_RELEASE,
or qdisc is work-conserving (or no queue)

V2: Forwarding is taken into account by changes in dev_queue_xmit(),
forcing a dst refcount on !IFF_XMIT_DST_RELEASE devices.

V3: As pointed by Patrick, we must force a dst refcount in
__nf_queue(), before queueing a packet.

V4: 
- output path (ip_queue_xmit()) handled as well.

- commit f84af32cbca70 (net: ip_queue_rcv_skb() helper) already in tree.

- Some interim checks make sure a dst does not escape unrefcounted
from a RCU section (thanks to lockdep)

- Better handling of queueing (backlog, qdisc)

Patch split into 4 parts :

1/4 : add a noref bit on skb dst (dstref infrastructure)

2/4 : ip_route_input_noref() introduction

3/4 : Use ip_route_input_noref() in three input paths

4/4 : norefcounting in ip_queue_xmit()


 include/linux/skbuff.h   |   58 ++++++++++++++++++++++++++++++++++---
 include/net/dst.h        |   48 ++++++++++++++++++++++++++++--
 include/net/route.h      |   17 ++++++++++
 include/net/sock.h       |   13 +++++---
 net/core/dev.c           |    3 +
 net/core/skbuff.c        |    2 -
 net/core/sock.c          |    6 +++
 net/ipv4/arp.c           |    2 -
 net/ipv4/icmp.c          |    6 +--
 net/ipv4/ip_input.c      |    4 +-
 net/ipv4/ip_options.c    |    9 +++--
 net/ipv4/ip_output.c     |    9 ++++-
 net/ipv4/netfilter.c     |    6 +--
 net/ipv4/route.c         |   17 +++++++---
 net/ipv4/xfrm4_input.c   |    4 +-
 net/netfilter/nf_queue.c |    2 +
 net/sched/sch_generic.c  |    2 -
 17 files changed, 170 insertions(+), 38 deletions(-)


