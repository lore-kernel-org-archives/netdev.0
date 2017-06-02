From: Liam McBirnie <mcbirnie.l@gmail.com>
Subject: [PATCH net] ip6_tunnel: fix traffic class routing for tunnels
Date: Fri, 2 Jun 2017 15:12:26 +1000
Message-ID: <91e31c60-5994-6784-cfe8-6a18016c6524@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: peter.a.dawson@boeing.com
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36095 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdFBFM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 01:12:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id n23so11198330pfb.3
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 22:12:27 -0700 (PDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liam McBirnie <mcbirnie.l@gmail.com>
Date: Thu, 1 Jun 2017 15:36:01 +1000
Subject: [PATCH net] ip6_tunnel: fix traffic class routing for tunnels

ip6_route_output() requires that the flowlabel contains the traffic
class for policy routing.

Commit 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
encapsulated packets") removed the code which previously added the
traffic class to the flowlabel.

The traffic class is added here because only route lookup needs the
flowlabel to contain the traffic class.

Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets")
Signed-off-by: Liam McBirnie <liam.mcbirnie@boeing.com>
---
 net/ipv6/ip6_tunnel.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 7ae6c50..9b37f97 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1095,6 +1095,9 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 	if (!dst) {
 route_lookup:
+		/* add dsfield to flowlabel for route lookup */
+		fl6->flowlabel = ip6_make_flowinfo(dsfield, fl6->flowlabel);
+
 		dst = ip6_route_output(net, NULL, fl6);
 
 		if (dst->error)
-- 
2.9.3
