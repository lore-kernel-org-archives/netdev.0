From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v7 3/3] geneve: add IPv6 bits to geneve_fill_metadata_dst
Date: Mon, 26 Oct 2015 17:01:46 -0400
Message-ID: <1445893306-31225-3-git-send-email-linville@tuxdriver.com>
References: <1445611225-27095-1-git-send-email-linville@tuxdriver.com>
 <1445893306-31225-1-git-send-email-linville@tuxdriver.com>
Cc: Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	=?UTF-8?q?YOSHIFUJI=20Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<hideaki.yoshifuji@miraclelinux.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59297 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbJZVSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 17:18:43 -0400
In-Reply-To: <1445893306-31225-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
v7 -- initial version (numbered to match earlier patches in series)

 drivers/net/geneve.c | 28 +++++++++++++++++++++-------
 1 file changed, 21 insertions(+), 7 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 44e724508c55..be532d7b879d 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1006,16 +1006,30 @@ static int geneve_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct rtable *rt;
 	struct flowi4 fl4;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct dst_entry *dst;
+	struct flowi6 fl6;
+#endif
 
-	if (ip_tunnel_info_af(info) != AF_INET)
-		return -EINVAL;
+	if (ip_tunnel_info_af(info) == AF_INET) {
+		rt = geneve_get_v4_rt(skb, dev, &fl4, info);
+		if (IS_ERR(rt))
+			return PTR_ERR(rt);
 
-	rt = geneve_get_v4_rt(skb, dev, &fl4, info);
-	if (IS_ERR(rt))
-		return PTR_ERR(rt);
+		ip_rt_put(rt);
+		info->key.u.ipv4.src = fl4.saddr;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (ip_tunnel_info_af(info) == AF_INET6) {
+		dst = geneve_get_v6_dst(skb, dev, &fl6, info);
+		if (IS_ERR(dst))
+			return PTR_ERR(dst);
+
+		dst_release(dst);
+		info->key.u.ipv6.src = fl6.saddr;
+#endif
+	} else
+		return -EINVAL;
 
-	ip_rt_put(rt);
-	info->key.u.ipv4.src = fl4.saddr;
 	info->key.tp_src = udp_flow_src_port(geneve->net, skb,
 					     1, USHRT_MAX, true);
 	info->key.tp_dst = geneve->dst_port;
-- 
2.4.3
