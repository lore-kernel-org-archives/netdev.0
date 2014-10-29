From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3 01/15] net: dsa: Don't set skb->protocol on outgoing tagged packets
Date: Wed, 29 Oct 2014 10:44:53 -0700
Message-ID: <1414604707-22407-2-git-send-email-linux@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setting skb->protocol to a private protocol type may result in warning
messages such as
	e1000e 0000:00:19.0 em1: checksum_partial proto=dada!

This happens if the L3 protocol is IP or IPv6 and skb->ip_summed is set
to CHECKSUM_PARTIAL. Looking through the code, it appears that changing
skb->protocol for transmitted packets is not necessary and may actually
be harmful. For example, it prevents purposely unmodified (from a DSA
perspective) network drivers from properly setting up their transmit
checksum offload pointers since they inspect skb->protocol to set up the
IPv4 header or IPv6 header pointers. So don't unnecessarily change the
protocol field.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3:
- Updated description
v2:
- No change

 net/dsa/tag_dsa.c     | 2 --
 net/dsa/tag_edsa.c    | 2 --
 net/dsa/tag_trailer.c | 2 --
 3 files changed, 6 deletions(-)

diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index ce90c8b..2dab270 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -63,8 +63,6 @@ static netdev_tx_t dsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		dsa_header[3] = 0x00;
 	}
 
-	skb->protocol = htons(ETH_P_DSA);
-
 	skb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(skb);
 
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 94fcce7..9aeda59 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -76,8 +76,6 @@ static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 		edsa_header[7] = 0x00;
 	}
 
-	skb->protocol = htons(ETH_P_EDSA);
-
 	skb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(skb);
 
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 115fdca..e268f9d 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -57,8 +57,6 @@ static netdev_tx_t trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	trailer[2] = 0x10;
 	trailer[3] = 0x00;
 
-	nskb->protocol = htons(ETH_P_TRAILER);
-
 	nskb->dev = p->parent->dst->master_netdev;
 	dev_queue_xmit(nskb);
 
-- 
1.9.1
