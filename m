From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH v2] ip_tunnel: clear IPCB in ip_tunnel_xmit() in case dst_link_failure()
 is called
Date: Thu, 23 Jan 2014 14:00:25 +0800
Message-ID: <52E0AFF9.6050803@cn.fujitsu.com>
References: <52DE1F60.2060109@cn.fujitsu.com>	<CALnjE+qFPoK_0EnZ_TWe1sx4s166iSjAH_+1r2uENeS4aRBckQ@mail.gmail.com> <20140122.212445.2236898585371895394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: daniel.petre@rcs-rds.ro, edumazet@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:38066 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbaAWGBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 01:01:06 -0500
In-Reply-To: <20140122.212445.2236898585371895394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


commit a622260254ee48("ip_tunnel: fix kernel panic with icmp_dest_unreach")
clear IPCB in ip_tunnel_xmit()  , or else skb->cb[] may contain garbage from
GSO segmentation layer.

But commit 0e6fbc5b6c621("ip_tunnels: extend iptunnel_xmit()") refactor codes,
and it clear IPCB behind the dst_link_failure().

So clear IPCB in ip_tunnel_xmit() just like commti a622260254ee48("ip_tunnel:
fix kernel panic with icmp_dest_unreach").

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---

v2: add the memset() before the dst_link_failure() call

 net/ipv4/ip_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 90ff957..471c8c1 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -618,6 +618,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
 			tunnel->err_count--;
 
+			memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 			dst_link_failure(skb);
 		} else
 			tunnel->err_count = 0;
-- 
1.8.3.1
