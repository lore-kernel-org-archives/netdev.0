From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 0/3] tcp: receive-side per route dctcp handling
Date: Fri, 28 Aug 2015 14:11:06 +0200
Message-ID: <1440763869-23067-1-git-send-email-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:57665 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751759AbbH1MLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 08:11:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the following case doesn't use DCTCP, even if it should:

- responder has f.e. cubic as system wide default
- 'ip route congctl dctcp $src' was set

Then, DCTCP is NOT used if a DCTCP sender attempts to connect from a
host in the $src range: ECT(0) is set, but listen_sk is not dctcp, so we
fail the INET_ECN_is_not_ect sanity check.

We also have to examine the dst used for the SYN/ACK reply to make this
case work.

In order to minimize additional cost, store the 'ecn is must have'
information is the dst_features field.

The set targets -next instead of -net since this doesn't seem to be a
serious bug and to give the change more soak time until it hits linus tree.

Daniel Borkmann (2):
      net: fib6: reduce identation in ip6_convert_metrics
      tcp: use dctcp if enabled on the route to the initiator

Florian Westphal (1):
      net: fib: move metrics parsing to a helper

 include/net/tcp.h              |  2 +-
 include/uapi/linux/rtnetlink.h | 11 +++---
 net/core/rtnetlink.c           |  4 +++
 net/ipv4/fib_semantics.c       | 78 ++++++++++++++++++++++++++----------------
 net/ipv4/tcp_cong.c            |  9 +++--
 net/ipv4/tcp_input.c           |  7 ++--
 net/ipv6/route.c               | 39 ++++++++++++---------
 7 files changed, 94 insertions(+), 56 deletions(-)
