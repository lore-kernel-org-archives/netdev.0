From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 0/2] Fix handling of GRO skbs in forwarding path
Date: Sat, 25 Jan 2014 23:48:45 +0100
Message-ID: <1390690127-559-1-git-send-email-fw@strlen.de>
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33735 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752104AbaAYWwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 17:52:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcelo Ricardo Leitner reported problems when the forwarding link
path has a lower mtu than the incoming link if the inbound interface
supports GRO.

Currently GSO/GRO skbs bypass all dst MTU checks, i.e. forwarding of
such skbs fails in case the outgoing link mtu is smaller than the one
of the incoming interface: We neither generate an icmp error nor will
the packet be fragmented if ipv4 would permit it.

The first patch moves part of Eric Dumazets skb_gso_seglen helper from
sch_tbf to skbuff core for re-use in forwarding path.

The 2nd change then alters forwarding path to handle GRO skbs.

It is not 100% correct, since the icmp error will contain the headers
of the GRO skb instead of the original/segmented one, but it seems to
work fine in my (limited) tests.

Software segmentation is done for ipv4 if the DF bit is not set.

If you think this is -next material just set patchwork state to
"deferred", I'll resend then once -next is open again.

 include/linux/skbuff.h |   18 +++++++++++++++
 net/core/skbuff.c      |   26 +++++++++++++++++++++
 net/ipv4/ip_forward.c  |   58 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ip6_output.c  |   18 +++++++++++++--
 net/sched/sch_tbf.c    |   12 ++--------
 5 files changed, 119 insertions(+), 13 deletions(-)
