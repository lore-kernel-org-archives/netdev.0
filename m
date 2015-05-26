From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH RFC 1/3] ip_vti/ip6_vti: Do not touch skb->mark on
 xmit
Date: Tue, 26 May 2015 15:41:17 -0700
Message-ID: <20150526224117.1328.98060.stgit@ahduyck-vm-fedora22>
References: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of modifying skb->mark we can simply modify the flowi_mark that is
generated as a result of the xfrm_decode_session.  By doing this we don't
need to actually touch the skb->mark and it can be preserved as it passes
out through the tunnel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/ip_vti.c  |    5 +++--
 net/ipv6/ip6_vti.c |    4 +++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 9f7269f3c54a..4c318e1c13c8 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -216,8 +216,6 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	memset(&fl, 0, sizeof(fl));
 
-	skb->mark = be32_to_cpu(tunnel->parms.o_key);
-
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		xfrm_decode_session(skb, &fl, AF_INET);
@@ -233,6 +231,9 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 	}
 
+	/* override mark with tunnel output key */
+	fl.flowi_mark = be32_to_cpu(tunnel->parms.o_key);
+
 	return vti_xmit(skb, dev, &fl);
 }
 
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index ed9d681207fa..104de4da3ff3 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -495,7 +495,6 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	int ret;
 
 	memset(&fl, 0, sizeof(fl));
-	skb->mark = be32_to_cpu(t->parms.o_key);
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IPV6):
@@ -516,6 +515,9 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto tx_err;
 	}
 
+	/* override mark with tunnel output key */
+	fl.flowi_mark = be32_to_cpu(t->parms.o_key);
+
 	ret = vti6_xmit(skb, dev, &fl);
 	if (ret < 0)
 		goto tx_err;
