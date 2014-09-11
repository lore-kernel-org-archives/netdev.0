From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 0/6] ipv6: dst_entry socket caching improvments
Date: Fri, 12 Sep 2014 01:21:47 +0200
Message-ID: <cover.1410477596.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:51526 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066AbaIKXV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 19:21:59 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id C0D8E20A56
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:21:58 -0400 (EDT)
Received: from k64.localdomain (unknown [213.55.184.147])
	by mail.messagingengine.com (Postfix) with ESMTPA id 3C267C00915
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 19:21:58 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet noticed that rt6_nodes wich are neither RTF_NONEXTHOP nor
RTF_GATEWAY but DST_HOST ones cause major routing lookup churn because
their rt6_genid is never renewed, thus ip6_dst_check always considers
them outdated. This is a major problem, because these kind of routes
are normally used to in input handling.

This patchset tries to improve the situation by also updating the
fn_sernum in the routing tables during address deletion. The only
expensive operation left, which needs a walk over all routing tables,
are xfrm policy modifications.

I didn't annotate the patches with fixes-tags as it only solves a
performance issue. Please review carefully, thanks! I'll do some more
tests and will do a propoer submission if the xfrm slow paths looks ok
to everyone.

Hannes Frederic Sowa (6):
  ipv6: also increase fib6_node sernum on deletion events
  ipv6: no need to bump rt_genid_ipv6 on address change anymore
  ipv6: if no function for cleaner is specified only visit nodes
  ipv6: new function fib6_flush_trees and use it instead of bumping
    removed rt6_genid
  ipv6: keep rt_sernum per namespace to reduce number of flushes
  ipv6: switch rt_sernum to atomic_t and clean up types

 include/net/ip6_fib.h       |  2 +-
 include/net/net_namespace.h | 14 ++------
 include/net/netns/ipv6.h    |  2 +-
 net/ipv6/addrconf.c         |  1 -
 net/ipv6/addrconf_core.c    |  6 ++++
 net/ipv6/af_inet6.c         |  2 +-
 net/ipv6/ip6_fib.c          | 81 ++++++++++++++++++++++++++++++++-------------
 net/ipv6/route.c            |  4 ---
 8 files changed, 70 insertions(+), 42 deletions(-)

-- 
1.9.3
