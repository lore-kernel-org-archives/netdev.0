From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-ipv6: on device mtu change do not add mtu to mtu-less routes
Date: Fri,  4 Nov 2016 14:51:54 -0700
Message-ID: <1478296314-32396-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33668 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761750AbcKDVwA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 17:52:00 -0400
Received: by mail-pf0-f193.google.com with SMTP id 144so592885pfv.0
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 14:51:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

Routes can specify an mtu explicitly or inherit the mtu from
the underlying device - this inheritance is implemented in
dst->ops->mtu handlers ip6_mtu() and ip6_blackhole_mtu().

Currently changing the mtu of a device adds mtu explicitly
to routes using that device.

ie.
  # ip link set dev lo mtu 65536
  # ip -6 route add local 2000::1 dev lo
  # ip -6 route get 2000::1
  local 2000::1 dev lo  table local  src ...  metric 1024  pref medium

  # ip link set dev lo mtu 65535
  # ip -6 route get 2000::1
  local 2000::1 dev lo  table local  src ...  metric 1024  mtu 65535 pref medium

  # ip link set dev lo mtu 65536
  # ip -6 route get 2000::1
  local 2000::1 dev lo  table local  src ...  metric 1024  mtu 65536 pref medium

  # ip -6 route del local 2000::1

After this patch the route entry no longer changes unless it already has an mtu.
There is no need: this inheritance is already done in ip6_mtu()

  # ip link set dev lo mtu 65536
  # ip -6 route add local 2000::1 dev lo
  # ip -6 route add local 2000::2 dev lo mtu 2000
  # ip -6 route get 2000::1; ip -6 route get 2000::2
  local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
  local 2000::2 dev lo  table local  src ...  metric 1024  mtu 2000 pref medium

  # ip link set dev lo mtu 65535
  # ip -6 route get 2000::1; ip -6 route get 2000::2
  local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
  local 2000::2 dev lo  table local  src ...  metric 1024  mtu 2000 pref medium

  # ip link set dev lo mtu 1501
  # ip -6 route get 2000::1; ip -6 route get 2000::2
  local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
  local 2000::2 dev lo  table local  src ...  metric 1024  mtu 1501 pref medium

  # ip link set dev lo mtu 65536
  # ip -6 route get 2000::1; ip -6 route get 2000::2
  local 2000::1 dev lo  table local  src ...  metric 1024  pref medium
  local 2000::2 dev lo  table local  src ...  metric 1024  mtu 65536 pref medium

  # ip -6 route del local 2000::1
  # ip -6 route del local 2000::2

This is desirable because changing device mtu and then resetting it
to the previous value shouldn't change the user visible routing table.

Signed-off-by: Maciej Żenczykowski <maze@google.com>
CC: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 947ed1ded026..fa90d14302f7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2758,6 +2758,7 @@ static int rt6_mtu_change_route(struct rt6_info *rt, void *p_arg)
 	   PMTU discouvery.
 	 */
 	if (rt->dst.dev == arg->dev &&
+	    dst_metric_raw(&rt->dst, RTAX_MTU) &&
 	    !dst_metric_locked(&rt->dst, RTAX_MTU)) {
 		if (rt->rt6i_flags & RTF_CACHE) {
 			/* For RTF_CACHE with rt6i_pmtu == 0
-- 
2.8.0.rc3.226.g39d4020
