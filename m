From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH v2 net-next 0/9] ipv6: fib6: socket dst_entry improvments and cleanups
Date: Sun, 21 Sep 2014 16:11:44 +0200
Message-ID: <cover.1411308211.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:35420 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097AbaIUOMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 10:12:05 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2232D206F1
	for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 10:12:04 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet noticed that rt6_nodes wich are neither RTF_NONEXTHOP nor
RTF_GATEWAY but DST_HOST ones cause major routing lookup churn because
their rt6_genid is never renewed, thus ip6_dst_check always considers
them outdated. This is a major problem, because these kind of routes
are normally used to in input handling.

Thus it does not make sense to use rt6i_genid anymore. This series
removes it.

The address deletion path is already covered and does not depend on
rt6i_genid. When we add a new address, we update the fn_sernums while
traversing the tree.

Because inet6_connect_socket depend on dst_check returning NULL also
for source address invalidation, we currently have to walk the whole
tree and update the fn_sernums manually when an address gets deleted.
This is a fairly expensive operation we currenlty have to do for
address deletion and xfrm policy changes. We currently do that for
interface mtu changes already.

I dropped the patch for updating the fn_sernum on deletion as it
showed some side effects with /proc/net/ipv6_route and we currently
don't need it. I stashed it away.

Thanks to Eric Dumazet for noticing the problem with rt6i_genid!

v2 (addressed YOSHIFUJI Hideaki's feedback, thanks!):
* fixed changelog in patch #2
* added patch to rename rt_genid_bump_ipv6 etc.

Regarding the __u32 to u32 conversion, I didn't see anything
problematic or left over, if I missed something there I am happy to
fix it up in a next version.


Hannes Frederic Sowa (9):
  ipv6: support for fib6_clean_* to update fn_sernum
  ipv6: a bit more typesafety
  ipv6: only generate one new serial number during fib6_add()
  ipv6: if no function for cleaner is specified only visit fib6_nodes
  ipv6: new function fib6_flush_trees and use it instead of bumping
    removed rt6_genid
  ipv6: no need to bump rt_genid_ipv6 on address addition
  ipv6: keep rt_sernum per namespace to reduce number of flushes
  ipv6: switch rt_sernum to atomic_t and clean up types
  ipv6: rename rt_genid_bump_ipv6 to rt6_inval_dst_caches

 include/net/ip6_fib.h           | 16 ++++++--
 include/net/net_namespace.h     | 22 ++++------
 include/net/netns/ipv6.h        |  2 +-
 net/ipv6/addrconf.c             |  3 +-
 net/ipv6/addrconf_core.c        |  6 +++
 net/ipv6/af_inet6.c             |  2 +-
 net/ipv6/ip6_fib.c              | 90 +++++++++++++++++++++++++----------------
 net/ipv6/route.c                |  4 --
 net/xfrm/xfrm_policy.c          |  2 +-
 security/selinux/include/xfrm.h |  2 +-
 10 files changed, 87 insertions(+), 62 deletions(-)

-- 
1.9.3
