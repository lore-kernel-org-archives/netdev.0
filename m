From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2 7/7] net/ipv4: add dst cache support for gre lwtunnels
Date: Fri, 12 Feb 2016 15:43:59 +0100
Message-ID: <4003a3a6a754d0f277bb7199b2db1a1bcbb75a89.1455287867.git.pabeni@redhat.com>
References: <cover.1455287867.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <therbert@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35372 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395AbcBLOoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2016 09:44:34 -0500
In-Reply-To: <cover.1455287867.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of UDP traffic with datagram length below MTU this
gives about 4% performance increase

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Suggested-and-Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

---
v2: codying style cleanup
---
 net/ipv4/ip_gre.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7c51c4e..dfa98cc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -531,9 +531,16 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto err_free_skb;
 
 	key = &tun_info->key;
-	rt = gre_get_rt(skb, dev, &fl, key);
-	if (IS_ERR(rt))
-		goto err_free_skb;
+	rt = !skb->mark ? dst_cache_get_ip4(&tun_info->dst_cache, &fl.saddr) :
+			 NULL;
+	if (!rt) {
+		rt = gre_get_rt(skb, dev, &fl, key);
+		if (IS_ERR(rt))
+				goto err_free_skb;
+		if (!skb->mark)
+			dst_cache_set_ip4(&tun_info->dst_cache, &rt->dst,
+					  fl.saddr);
+	}
 
 	tunnel_hlen = ip_gre_calc_hlen(key->tun_flags);
 
-- 
1.8.3.1
