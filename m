From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v3 1/2] ip_tunnel: fix ip tunnel lookup in collect_md mode
Date: Mon,  4 Sep 2017 16:36:13 +0800
Message-ID: <1504514174-14958-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Pravin B Shelar <pshelar@nicira.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In collect_md mode, if the tun dev is down, it still can call
ip_tunnel_rcv to receive on packets, and the rx statistics increase
improperly.

Fixes: 2e15ea390e6f ("ip_gre: Add support to collect tunnel metadata.")
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Change since v3:
  * Increment rx_dropped if tunnel device is not up, suggested by
  Pravin B Shelar
  * Fix wrong recipient addresss
---
 net/ipv4/ip_tunnel.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e1856bf..5b2e542 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -176,8 +176,11 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 		return cand;
 
 	t = rcu_dereference(itn->collect_md_tun);
-	if (t)
-		return t;
+	if (t) {
+		if (t->dev->flags & IFF_UP)
+			return t;
+		t->dev->stats.rx_dropped++;
+	}
 
 	if (itn->fb_tunnel_dev && itn->fb_tunnel_dev->flags & IFF_UP)
 		return netdev_priv(itn->fb_tunnel_dev);
-- 
1.8.3.1
