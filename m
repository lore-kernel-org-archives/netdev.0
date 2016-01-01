From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ip_tunnel: make ip6tunnel_xmit definition conditional
Date: Fri, 01 Jan 2016 14:48:59 +0100
Message-ID: <12586917.ah4bPMnYUH@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, linux-kernel@vger.kernel.org,
 James Morris <jmorris@namei.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
 Patrick McHardy <kaber@trash.net>, linux-arm-kernel@lists.infradead.org
To: Pravin B Shelar <pshelar@nicira.com>,
 "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

>From 433df301cf49624871346fa63f3fc65033caeda3 Mon Sep 17 00:00:00 2001
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 1 Jan 2016 13:18:48 +0100
Subject: [PATCH] net: make ip6tunnel_xmit definition conditional

Moving the caller of iptunnel_xmit_stats causes a build error in
randconfig builds that disable CONFIG_INET:

In file included from ../net/xfrm/xfrm_input.c:17:0:
../include/net/ip6_tunnel.h: In function 'ip6tunnel_xmit':
../include/net/ip6_tunnel.h:93:2: error: implicit declaration of function 'iptunnel_xmit_stats' [-Werror=implicit-function-declaration]
  iptunnel_xmit_stats(dev, pkt_len);

The reason is that the iptunnel_xmit_stats definition is hidden
inside #ifdef CONFIG_INET but the caller is not. We can change
one or the other to fix it, and this patch adds a second #ifdef
around ip6tunnel_xmit() to avoid seeing the invalid call.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 039f50629b7f ("ip_tunnel: Move stats update to iptunnel_xmit()")

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index ae07e94778d8..0d0ce0b2d870 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -81,6 +81,7 @@ __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 struct net *ip6_tnl_get_link_net(const struct net_device *dev);
 int ip6_tnl_get_iflink(const struct net_device *dev);
 
+#ifdef CONFIG_INET
 static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 				  struct net_device *dev)
 {
@@ -93,3 +94,4 @@ static inline void ip6tunnel_xmit(struct sock *sk, struct sk_buff *skb,
 	iptunnel_xmit_stats(dev, pkt_len);
 }
 #endif
+#endif
