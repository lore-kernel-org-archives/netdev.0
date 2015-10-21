From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr set
Date: Wed, 21 Oct 2015 08:42:22 -0700
Message-ID: <1445442142-19881-1-git-send-email-dsa@cumulusnetworks.com>
Cc: thehajime@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36535 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbbJUPm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:42:29 -0400
Received: by pacfv9 with SMTP id fv9so60489110pac.3
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 08:42:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
adds the RT6_LOOKUP_F_IFACE flag to make device index mismatch fatal if
oif is given. Hajime reported that this change breaks the Mobile IPv6
use case that wants to force the message through one interface yet use
the source address from another interface. Handle this case by only
adding the flag if oif is set and saddr is not set.

Fixes: 741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
Cc: Hajime Tazaki <thehajime@gmail.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
This is needed for 4.3.

 net/ipv6/route.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d0619632723a..2701cb3d88e9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1171,6 +1171,7 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 {
 	struct dst_entry *dst;
 	int flags = 0;
+	bool any_src;
 
 	dst = l3mdev_rt6_dst_by_oif(net, fl6);
 	if (dst)
@@ -1178,11 +1179,12 @@ struct dst_entry *ip6_route_output(struct net *net, const struct sock *sk,
 
 	fl6->flowi6_iif = LOOPBACK_IFINDEX;
 
+	any_src = ipv6_addr_any(&fl6->saddr);
 	if ((sk && sk->sk_bound_dev_if) || rt6_need_strict(&fl6->daddr) ||
-	    fl6->flowi6_oif)
+	    (fl6->flowi6_oif && any_src))
 		flags |= RT6_LOOKUP_F_IFACE;
 
-	if (!ipv6_addr_any(&fl6->saddr))
+	if (!any_src)
 		flags |= RT6_LOOKUP_F_HAS_SADDR;
 	else if (sk)
 		flags |= rt6_srcprefs2flags(inet6_sk(sk)->srcprefs);
-- 
1.9.1
