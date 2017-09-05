From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ip6_gre: update mtu properly in ip6gre_err
Date: Tue,  5 Sep 2017 17:26:33 +0800
Message-ID: <bcd5956b4342a889e686a475e2ec4fcb36db3e57.1504603593.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37036 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751264AbdIEJ0m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 05:26:42 -0400
Received: by mail-pg0-f65.google.com with SMTP id j6so1639693pgc.4
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 02:26:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when probessing ICMPV6_PKT_TOOBIG, ip6gre_err only subtracts the
offset of gre header from mtu info. The expected mtu of gre device
should also subtract gre header. Otherwise, the next packets still
can't be sent out.

Jianlin found this issue when using the topo:
  client(ip6gre)<---->(nic1)route(nic2)<----->(ip6gre)server

and reducing nic2's mtu, then both tcp and sctp's performance with
big size data became 0.

This patch is to fix it by also subtracting grehdr (tun->tun_hlen)
from mtu info when updating gre device's mtu in ip6gre_err(). It
also needs to subtract ETH_HLEN if gre dev'type is ARPHRD_ETHER.

Reported-by: Jianlin Shi <jishi@redhat.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/ip6_gre.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 67ff2aa..b7a72d4 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -432,7 +432,9 @@ static void ip6gre_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		}
 		break;
 	case ICMPV6_PKT_TOOBIG:
-		mtu = be32_to_cpu(info) - offset;
+		mtu = be32_to_cpu(info) - offset - t->tun_hlen;
+		if (t->dev->type == ARPHRD_ETHER)
+			mtu -= ETH_HLEN;
 		if (mtu < IPV6_MIN_MTU)
 			mtu = IPV6_MIN_MTU;
 		t->dev->mtu = mtu;
-- 
2.1.0
