From: Alexander Drozdov <al.drozdov@gmail.com>
Subject: [PATCH] ipv4: ip_check_defrag should not assume that skb_network_offset is zero
Date: Thu,  5 Mar 2015 10:29:39 +0300
Message-ID: <1425540579-27464-1-git-send-email-al.drozdov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Drozdov <al.drozdov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ip_check_defrag() may be used by af_packet to defragment outgoing packets.
skb_network_offset() of af_packet's outgoing packets is not zero.

Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>
---
 net/ipv4/ip_fragment.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2c8d98e..145a50c 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -659,27 +659,30 @@ EXPORT_SYMBOL(ip_defrag);
 struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 {
 	struct iphdr iph;
+	int netoff;
 	u32 len;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		return skb;
 
-	if (skb_copy_bits(skb, 0, &iph, sizeof(iph)) < 0)
+	netoff = skb_network_offset(skb);
+
+	if (skb_copy_bits(skb, netoff, &iph, sizeof(iph)) < 0)
 		return skb;
 
 	if (iph.ihl < 5 || iph.version != 4)
 		return skb;
 
 	len = ntohs(iph.tot_len);
-	if (skb->len < len || len < (iph.ihl * 4))
+	if (skb->len < netoff + len || len < (iph.ihl * 4))
 		return skb;
 
 	if (ip_is_fragment(&iph)) {
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (skb) {
-			if (!pskb_may_pull(skb, iph.ihl*4))
+			if (!pskb_may_pull(skb, netoff + iph.ihl * 4))
 				return skb;
-			if (pskb_trim_rcsum(skb, len))
+			if (pskb_trim_rcsum(skb, netoff + len))
 				return skb;
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 			if (ip_defrag(skb, user))
-- 
1.9.1
