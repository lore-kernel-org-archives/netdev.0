From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Lookup actual route when oif is VRF device
Date: Mon,  5 Oct 2015 10:49:04 -0700
Message-ID: <1444067344-31144-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35898 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbbJERtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:49:11 -0400
Received: by pablk4 with SMTP id lk4so182190543pab.3
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:49:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user specifies a VRF device in a get route query the custom route
pointing to the VRF device is returned:

    $ ip route ls table vrf-red
    unreachable default
    broadcast 10.2.1.0 dev eth1  proto kernel  scope link  src 10.2.1.2
    10.2.1.0/24 dev eth1  proto kernel  scope link  src 10.2.1.2
    local 10.2.1.2 dev eth1  proto kernel  scope host  src 10.2.1.2
    broadcast 10.2.1.255 dev eth1  proto kernel  scope link  src 10.2.1.2

    $ ip route get oif vrf-red 10.2.1.40
    10.2.1.40 dev vrf-red
        cache

Add the flags to skip the custom route and go directly to the FIB. With
this patch the actual route is returned:

    $ ip route get oif vrf-red 10.2.1.40
    10.2.1.40 dev eth1  src 10.2.1.2
        cache

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 54e6f456a760..bf1486bd7e81 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2507,6 +2507,9 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 	fl4.flowi4_oif = tb[RTA_OIF] ? nla_get_u32(tb[RTA_OIF]) : 0;
 	fl4.flowi4_mark = mark;
 
+	if (netif_index_is_l3_master(net, fl4.flowi4_oif))
+		fl4.flowi4_flags = FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF;
+
 	if (iif) {
 		struct net_device *dev;
 
-- 
1.9.1
