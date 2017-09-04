From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v3 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md mode
Date: Mon,  4 Sep 2017 16:36:14 +0800
Message-ID: <1504514174-14958-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1504514174-14958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Alexei Starovoitov <ast@fb.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:64502 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIDIgd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 04:36:33 -0400
In-Reply-To: <1504514174-14958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In collect_md mode, if the tun dev is down, it still can call
__ip6_tnl_rcv to receive on packets, and the rx statistics increase
improperly.

Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
Cc: Alexei Starovoitov <ast@fb.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Change since v3:
  * Increment rx_dropped if tunnel device is not up, suggested by
  Pravin B Shelar
  * Fix wrong recipient address
---
 net/ipv6/ip6_tunnel.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 10a693a..e91d3b6 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -171,8 +171,11 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 	}
 
 	t = rcu_dereference(ip6n->collect_md_tun);
-	if (t)
-		return t;
+	if (t) {
+		if (t->dev->flags & IFF_UP)
+			return t;
+		t->dev->stats.rx_dropped++;
+	}
 
 	t = rcu_dereference(ip6n->tnls_wc[0]);
 	if (t && (t->dev->flags & IFF_UP))
-- 
1.8.3.1
