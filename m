From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set
Date: Mon, 28 Sep 2015 10:12:13 -0700
Message-ID: <1443460333-23302-1-git-send-email-dsa@cumulusnetworks.com>
Cc: netdev@linux-dude.de, yoshfuji@linux-ipv6.org,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33251 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933063AbbI1RMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:12:21 -0400
Received: by pacex6 with SMTP id ex6so179623729pac.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:12:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang reported that IPv6 stack is ignoring oif in output route lookups:

    With ipv6, ip -6 route get always returns the specific route.

    $ ip -6 r
    2001:db8:e2::1 dev enp2s0  proto kernel  metric 256
    2001:db8:e2::/64 dev enp2s0  metric 1024
    2001:db8:e3::1 dev enp3s0  proto kernel  metric 256
    2001:db8:e3::/64 dev enp3s0  metric 1024
    fe80::/64 dev enp3s0  proto kernel  metric 256
    default via 2001:db8:e3::255 dev enp3s0  metric 1024

    $ ip -6 r get 2001:db8:e2::100
    2001:db8:e2::100 from :: dev enp2s0  src 2001:db8:e3::1  metric 0
        cache

    $ ip -6 r get 2001:db8:e2::100 oif enp3s0
    2001:db8:e2::100 from :: dev enp2s0  src 2001:db8:e3::1  metric 0
        cache

The stack does consider the oif but a mismatch in rt6_device_match is not
considered fatal because RT6_LOOKUP_F_IFACE is not set in the flags.

Cc: Wolfgang Nothdurft <netdev@linux-dude.de>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f204089e854c..cb32ce250db0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1193,7 +1193,8 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
-	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr))
+	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr) ||
+	    fl6->flowi6_oif)
 		flags |= RT6_LOOKUP_F_IFACE;
 
 	if (!ipv6_addr_any(&fl6->saddr))
-- 
2.3.8 (Apple Git-58)
