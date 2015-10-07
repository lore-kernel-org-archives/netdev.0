From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Do not drop to make_route if oif is l3mdev
Date: Wed,  7 Oct 2015 08:40:13 -0700
Message-ID: <1444232413-8435-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34277 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbJGPkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 11:40:20 -0400
Received: by padhy16 with SMTP id hy16so24766196pad.1
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 08:40:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit deaa0a6a930 ("net: Lookup actual route when oif is VRF device")
exposed a bug in __ip_route_output_key_hash for VRF devices: on FIB lookup
failure if the oif is specified the current logic drops to make_route on
the assumption that the route tables are wrong. For VRF/L3 master devices
this leads to wrong dst entries and route lookups. For example:
    $ ip route ls table vrf-red
    unreachable default
    broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
    10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
    local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
    broadcast 10.2.1.255 dev eth1  proto kernel  scope link  src 10.2.1.2

    $ ip route get oif vrf-red 1.1.1.1
    1.1.1.1 dev vrf-red  src 10.0.0.2
        cache

With this patch:
    $  ip route get oif vrf-red 1.1.1.1
    RTNETLINK answers: No route to host

which is the correct response based on the default route

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index bf1486bd7e81..f10ad88bfb89 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2196,7 +2196,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 	if (err) {
 		res.fi = NULL;
 		res.table = NULL;
-		if (fl4->flowi4_oif) {
+		if (fl4->flowi4_oif &&
+		    !netif_index_is_l3_master(net, fl4->flowi4_oif)) {
 			/* Apparently, routing tables are wrong. Assume,
 			   that the destination is on link.
 
-- 
1.9.1
