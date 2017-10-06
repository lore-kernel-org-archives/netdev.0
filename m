From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 00/16] ipv6: replace rwlock with rcu and spinlock in fib6 table
Date: Fri,  6 Oct 2017 12:05:55 -0700
Message-ID: <20171006190611.110633-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:46630 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbdJFTGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:32 -0400
Received: by mail-pg0-f45.google.com with SMTP id k7so5429641pga.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Currently, fib6 table is protected by rwlock. During route lookup,
reader lock is taken and during route insertion, deletion or
modification, writer lock is taken. This is a very inefficient
implementation because the fastpath always has to do the operation
to grab the reader lock.
According to my latest syn flood test on an iota ivybridage machine
with 2 10G mlx nics bonded together, each with 8 rx queues on 2 NUMA
nodes, and with the upstream net-next kernel:
ipv4 stack can handle around 4.2Mpps
ipv6 stack can handle around 1.3Mpps

In order to close the gap of the performance number between ipv4
and ipv6 stack, this patch series tries to get rid of the usage of
the rwlock and replace it with rcu and spinlock protection. This will
greatly speed up the fastpath performance as it only needs to hold
rcu which is much less expensive than grabbing the reader lock. It
also makes ipv6 fib implementation more consistent with ipv4.

In order to be able to replace the current rwlock with rcu and
spinlock, some preparation work is needed:
Patch 1-8 introduces a per-route hash table (protected by rcu and a
different spinlock) to store all cached routes created by pmtu and ip
redirect under its main route. This makes the main fib6 tree only
contain static routes.
Patch 9-14 prepares all the reader path to be ready to tolerate
concurrent writer.
Patch 15 finally does the rwlock to rcu and spinlock conversion.
Patch 16 takes care of rt6_stats.

After this patch series, in the same syn flood test,
ipv6 stack can now handle around 3.5Mpps compared to previous 1.3Mpps
in my test setup.

After this patch series, there are still some improvements that should
be done in ipv6 stack:
1. During route lookup, dst_use() is called everytime on the selected
route to update dst->__use and dst->lastuse. This dirties the cacheline 
and causes extra cacheline miss and should be avoided.
2. when no route is found in the current table, net->ip6.ipv6_null_entry
is used and refcnt is taken on it. As there is no pcpu cache for this
specific route, frequent change on the refcnt for this route causes
quite some cacheline misses.
And to make things worse, if CONFIG_IPV6_MULTIPLE_TABLES is defined,
output path route lookup always starts with local table first and
guarantees to hit net->ipv6.ip6_null_entry before continuing to do
lookup in the main table.
These operations on net->ipv6.ip6_null_entry could potentially be
avoided.
3. ipv6 input path route lookup grabs refcnt on dst. This is different
from ipv4. We could potentially change this behavior to let ipv6 input
path route lookup not to grab refcnt on dst. However, it does not give
us much performance boost as we currently have pcpu route cache for
input path as well in ipv6. But this work probably is still worth doing
to unify ipv6 and ipv4 route lookup behavior.

The above issues will be addressed separately after this patch series
has been accepted.

This is a joint work with Martin KaFai Lau and Eric Dumazet. And many
many thanks to them for their inspiring ideas and big big code review
efforts.

Wei Wang (16):
  ipv6: introduce a new function fib6_update_sernum()
  ipv6: introduce a hash table to store dst cache
  ipv6: prepare fib6_remove_prefsrc() for exception table
  ipv6: prepare rt6_mtu_change() for exception table
  ipv6: prepare rt6_clean_tohost() for exception table
  ipv6: prepare fib6_age() for exception table
  ipv6: prepare fib6_locate() for exception table
  ipv6: hook up exception table to store dst cache
  ipv6: grab rt->rt6i_ref before allocating pcpu rt
  ipv6: don't release rt->rt6i_pcpu memory during rt6_release()
  ipv6: replace dst_hold() with dst_hold_safe() in routing code
  ipv6: update fn_sernum after route is inserted to tree
  ipv6: check fn->leaf before it is used
  ipv6: add key length check into rt6_select()
  ipv6: replace rwlock with rcu and spinlock in fib6_table
  ipv6: take care of rt6_stats

 include/net/dst.h       |   2 +-
 include/net/ip6_fib.h   |  79 ++++-
 include/net/ip6_route.h |   5 +
 net/ipv6/addrconf.c     |  17 +-
 net/ipv6/ip6_fib.c      | 645 ++++++++++++++++++----------------
 net/ipv6/route.c        | 901 ++++++++++++++++++++++++++++++++++++++++--------
 6 files changed, 1179 insertions(+), 470 deletions(-)

-- 
2.14.2.920.gcf0c67979c-goog
