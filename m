From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: use consume_skb() in place of kfree_skb()
Date: Mon, 04 Jun 2012 13:17:19 +0200
Message-ID: <1338808639.2760.1802.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48238 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab2FDLR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 07:17:28 -0400
Received: by eeit10 with SMTP id t10so1480973eei.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 04:17:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove some dropwatch/drop_monitor false positives.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/atm/lec.c                   |    6 ++++--
 net/atm/pppoatm.c               |    2 +-
 net/ax25/ax25_out.c             |    2 +-
 net/ax25/ax25_route.c           |    2 +-
 net/decnet/dn_neigh.c           |    6 +++---
 net/ipv4/ip_output.c            |    4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c |    4 ++--
 7 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index a7d1721..3da125c 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -231,9 +231,11 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	if (skb_headroom(skb) < 2) {
 		pr_debug("reallocating skb\n");
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
-		kfree_skb(skb);
-		if (skb2 == NULL)
+		if (unlikely(!skb2)) {
+			kfree_skb(skb);
 			return NETDEV_TX_OK;
+		}
+		consume_skb(skb);
 		skb = skb2;
 	}
 	skb_push(skb, 2);
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index ce1e59f..226dca9 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -283,7 +283,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 				kfree_skb(n);
 				goto nospace;
 			}
-			kfree_skb(skb);
+			consume_skb(skb);
 			skb = n;
 			if (skb == NULL)
 				return DROP_PACKET;
diff --git a/net/ax25/ax25_out.c b/net/ax25/ax25_out.c
index be8a25e..be2acab 100644
--- a/net/ax25/ax25_out.c
+++ b/net/ax25/ax25_out.c
@@ -350,7 +350,7 @@ void ax25_transmit_buffer(ax25_cb *ax25, struct sk_buff *skb, int type)
 		if (skb->sk != NULL)
 			skb_set_owner_w(skbn, skb->sk);
 
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = skbn;
 	}
 
diff --git a/net/ax25/ax25_route.c b/net/ax25/ax25_route.c
index a655880..d390977 100644
--- a/net/ax25/ax25_route.c
+++ b/net/ax25/ax25_route.c
@@ -474,7 +474,7 @@ struct sk_buff *ax25_rt_build_path(struct sk_buff *skb, ax25_address *src,
 		if (skb->sk != NULL)
 			skb_set_owner_w(skbn, skb->sk);
 
-		kfree_skb(skb);
+		consume_skb(skb);
 
 		skb = skbn;
 	}
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index ac90f658..8e9a35b 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -240,7 +240,7 @@ static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = skb2;
 		net_info_ratelimited("dn_long_output: Increasing headroom\n");
 	}
@@ -283,7 +283,7 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = skb2;
 		net_info_ratelimited("dn_short_output: Increasing headroom\n");
 	}
@@ -322,7 +322,7 @@ static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 			kfree_skb(skb);
 			return -ENOBUFS;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = skb2;
 		net_info_ratelimited("dn_phase3_output: Increasing headroom\n");
 	}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 451f97c..157ebd2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -200,7 +200,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 		}
 		if (skb->sk)
 			skb_set_owner_w(skb2, skb->sk);
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = skb2;
 	}
 
@@ -709,7 +709,7 @@ slow_path:
 
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
 	}
-	kfree_skb(skb);
+	consume_skb(skb);
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
 	return err;
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 7fd66de..71d6ecb 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -823,7 +823,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_ERR_RL("%s(): no memory\n", __func__);
 			return NF_STOLEN;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = new_skb;
 		old_iph = ip_hdr(skb);
 	}
@@ -942,7 +942,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 			IP_VS_ERR_RL("%s(): no memory\n", __func__);
 			return NF_STOLEN;
 		}
-		kfree_skb(skb);
+		consume_skb(skb);
 		skb = new_skb;
 		old_iph = ipv6_hdr(skb);
 	}
