From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 00/21] remove dst garbage collector logic
Date: Fri, 16 Jun 2017 10:47:23 -0700
Message-ID: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36683 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750886AbdFPRsH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:07 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so7562955pfd.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

The current mechanism of dst release is a bit complicated. It is because
the users of dst get divided into 2 situations:
  1. Most users take the reference count when using a dst and release the
     reference count when done.
  2. Exceptional users like IPv4/IPv6/decnet/xfrm routing code do not take
     reference count when referencing to a dst due to some histotic reasons.

Due to those exceptional use cases in 2, reference count being 0 is not an
adequate evidence to indicate that no user is using this dst. So users in 1
can't free the dst simply based on reference count being 0 because users in
2 might still hold reference to it.
Instead, a dst garbage list is needed to hold the dst entries that already
get removed by the users in 2 but are still held by users in 1. And a periodic
garbage collector task is run to check all the dst entries in the list to see
if the users in 1 have released the reference to those dst entries.
If so, the dst is now ready to be freed.

This logic introduces unnecessary complications in the dst code which makes it
hard to understand and to debug.

In order to get rid of the whole dst garbage collector (gc) and make the dst
code more unified and simplified, we can make the users in 2 also take reference
count on the dst and release it properly when done.
This way, dst can be safely freed once the refcount drops to 0 and no gc
thread is needed anymore.

This patch series' target is to completely get rid of dst gc logic and free
dst based on reference count only.
Patch 1-3 are preparation patches to do some cleanup/improvement on the existing
code to make later work easier.
Patch 4-21 are real implementations.
In these patches, a temporary flag DST_NOGC is used to help transition
those exceptional users one by one. Once every component is transitioned,
this temporary flag is removed.
By the end of this patch series, all dst are refcounted when being used
and released when done. And dst will be freed when its refcount drops to 0.
No dst gc task is running anymore.

Note: This patch series depends on the decnet fix that was sent right before:
      "decnet: always not take dst->__refcnt when inserting dst into hash table"

Wei Wang (21):
  ipv6: remove unnecessary dst_hold() in ip6_fragment()
  udp: call dst_hold_safe() in udp_sk_rx_set_dst()
  net: use loopback dev when generating blackhole route
  net: introduce DST_NOGC in dst_release() to destroy dst based on
    refcnt
  net: introduce a new function dst_dev_put()
  ipv4: take dst->__refcnt when caching dst in fib
  ipv4: call dst_dev_put() properly
  ipv4: call dst_hold_safe() properly
  ipv4: mark DST_NOGC and remove the operation of dst_free()
  ipv6: take dst->__refcnt for insertion into fib6 tree
  ipv6: call dst_dev_put() properly
  ipv6: call dst_hold_safe() properly
  ipv6: mark DST_NOGC and remove the operation of dst_free()
  ipv6: get rid of icmp6 dst garbage collector
  xfrm: take refcnt of dst when creating struct xfrm_dst bundle
  decnet: take dst->__refcnt when struct dn_route is created
  net: remove dst gc related code
  net: remove DST_NOGC flag
  net: remove DST_NOCACHE flag
  net: reorder all the dst flags
  net: add debug atomic_inc_not_zero() in dst_hold()

 drivers/net/vrf.c        |   6 +-
 include/net/dst.h        |  43 ++------
 include/net/ip6_fib.h    |   2 +-
 include/net/ip6_route.h  |   1 -
 include/net/route.h      |   4 +-
 net/core/dev.c           |   1 -
 net/core/dst.c           | 275 ++++++++---------------------------------------
 net/decnet/dn_route.c    |  34 +++---
 net/ipv4/fib_semantics.c |   9 +-
 net/ipv4/route.c         |  62 ++++++-----
 net/ipv4/udp.c           |  22 ++--
 net/ipv6/addrconf.c      |   4 +-
 net/ipv6/ip6_fib.c       |  32 +++---
 net/ipv6/ip6_output.c    |   4 -
 net/ipv6/route.c         | 127 ++++++++--------------
 net/ipv6/udp.c           |  14 ++-
 net/xfrm/xfrm_policy.c   |  49 +++++----
 17 files changed, 219 insertions(+), 470 deletions(-)

-- 
2.13.1.518.g3df882009-goog
