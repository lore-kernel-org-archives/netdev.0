From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 2/2] geneve: handle ipv6 priority like ipv4 tos
Date: Tue, 20 Oct 2015 11:11:06 -0400
Message-ID: <1445353866-32710-2-git-send-email-linville@tuxdriver.com>
References: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Cc: Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39386 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbJTPP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:15:27 -0400
In-Reply-To: <1445353866-32710-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other callers of udp_tunnel6_xmit_skb just pass 0 for the prio
argument.  Jesse Gross <jesse@nicira.com> suggested that prio is really
the same as IPv4's tos and should be handled the same, so this is my
interpretation of that suggestion.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Reported-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/geneve.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 217b472ab9e7..cef71bdda13d 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -748,6 +748,7 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
+	__u8 prio;
 
 	memset(fl6, 0, sizeof(*fl6));
 	fl6->flowi6_mark = skb->mark;
@@ -756,7 +757,16 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 	if (info) {
 		fl6->daddr = info->key.u.ipv6.dst;
 		fl6->saddr = info->key.u.ipv6.src;
+		fl6->flowi6_tos = RT_TOS(info->key.tos);
 	} else {
+		prio = geneve->tos;
+		if (prio == 1) {
+			const struct iphdr *iip = ip_hdr(skb);
+
+			prio = ip_tunnel_get_dsfield(iip, skb);
+		}
+
+		fl6->flowi6_tos = RT_TOS(prio);
 		fl6->daddr = geneve->remote.sin6.sin6_addr;
 	}
 
@@ -876,8 +886,9 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct geneve_dev *geneve = netdev_priv(dev);
 	struct geneve_sock *gs6 = geneve->sock6;
 	struct dst_entry *dst = NULL;
+	const struct iphdr *iip; /* interior IP header */
 	struct flowi6 fl6;
-	__u8 ttl;
+	__u8 prio, ttl;
 	__be16 sport;
 	bool udp_csum;
 	int err;
@@ -906,6 +917,8 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	sport = udp_flow_src_port(geneve->net, skb, 1, USHRT_MAX, true);
 	skb_reset_mac_header(skb);
 
+	iip = ip_hdr(skb);
+
 	if (info) {
 		const struct ip_tunnel_key *key = &info->key;
 		u8 *opts = NULL;
@@ -922,6 +935,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto err;
 
+		prio = ip_tunnel_ecn_encap(key->tos, iip, skb);
 		ttl = key->ttl;
 	} else {
 		udp_csum = false;
@@ -930,13 +944,14 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto err;
 
+		prio = ip_tunnel_ecn_encap(fl6.flowi6_tos, iip, skb);
 		ttl = geneve->ttl;
 		if (!ttl && ipv6_addr_is_multicast(&fl6.daddr))
 			ttl = 1;
 		ttl = ttl ? : ip6_dst_hoplimit(dst);
 	}
 	err = udp_tunnel6_xmit_skb(dst, gs6->sock->sk, skb, dev,
-				   &fl6.saddr, &fl6.daddr, 0, ttl,
+				   &fl6.saddr, &fl6.daddr, prio, ttl,
 				   sport, geneve->dst_port, !udp_csum);
 
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
-- 
2.4.3
