From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4 04/10]: reset IPCB flags when neccessary
Date: Sat,  7 Jan 2006 02:09:36 +0100 (MET)
Message-ID: <20060107010901.8712.62416.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[IPV4]: reset IPCB flags when neccessary

Reset IPSKB_XFRM_TUNNEL_SIZE flags in ipip and ip_gre hard_start_xmit
function before the packet reenters IP. This is neccessary so the
encapsulated packets are checked not to be oversized in xfrm4_output.c
again. Reset all flags in sit when a packet changes its address family.

Also remove some obsolete IPSKB flags.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 0c72987fae9d4f21d80910ccca2beea4f77e1dc5
tree 71aa056fbac413a11a4d29053595e73803656974
parent 0ab5982305cae5d8e4fb41d8bb849ee1808946fc
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 00:42:27 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 00:42:27 +0100

 include/net/ip.h  |    8 +++-----
 net/ipv4/ip_gre.c |    1 +
 net/ipv4/ipip.c   |    1 +
 net/ipv6/sit.c    |    2 ++
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 7bb5804..52f4d9c 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -37,11 +37,9 @@ struct inet_skb_parm
 	struct ip_options	opt;		/* Compiled IP options		*/
 	unsigned char		flags;
 
-#define IPSKB_MASQUERADED	1
-#define IPSKB_TRANSLATED	2
-#define IPSKB_FORWARDED		4
-#define IPSKB_XFRM_TUNNEL_SIZE	8
-#define IPSKB_FRAG_COMPLETE	16
+#define IPSKB_FORWARDED		1
+#define IPSKB_XFRM_TUNNEL_SIZE	2
+#define IPSKB_FRAG_COMPLETE	4
 };
 
 struct ipcm_cookie
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 912c42f..65c3a91 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -832,6 +832,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, gre_hlen);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~IPSKB_XFRM_TUNNEL_SIZE;
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 35571cf..078b59b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -621,6 +621,7 @@ static int ipip_tunnel_xmit(struct sk_bu
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~IPSKB_XFRM_TUNNEL_SIZE;
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 577d497..02872ae 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -381,6 +381,7 @@ static int ipip6_rcv(struct sk_buff *skb
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = skb->data;
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
+		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
 		tunnel->stat.rx_packets++;
@@ -552,6 +553,7 @@ static int ipip6_tunnel_xmit(struct sk_b
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags = 0;
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
