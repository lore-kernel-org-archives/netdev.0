From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 12/19] ndisc: Calculate message body length and option
 length separately.
Date: Tue, 22 Jan 2013 01:48:49 +0900
Message-ID: <50FD7171.3040606@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50364 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753053Ab3AUQsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 62b1415..c2b16ff 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -426,6 +426,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
 	int len;
+	int optlen = 0;
 	u8 *opt;
 
 	if (!dev->addr_len)
@@ -433,13 +434,13 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 
 	len = sizeof(struct icmp6hdr) + (target ? sizeof(*target) : 0);
 	if (llinfo)
-		len += ndisc_opt_addr_space(dev);
+		optlen += ndisc_opt_addr_space(dev);
 
-	skb = ndisc_alloc_skb(dev, len);
+	skb = ndisc_alloc_skb(dev, len + optlen);
 	if (!skb)
 		return NULL;
 
-	skb_put(skb, len);
+	skb_put(skb, len + optlen);
 
 	hdr = (struct icmp6hdr *)skb_transport_header(skb);
 	memcpy(hdr, icmp6h, sizeof(*hdr));
@@ -1396,7 +1397,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct net_device *dev = skb->dev;
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
-	int len = sizeof(struct rd_msg);
+	int optlen = 0;
 	struct inet_peer *peer;
 	struct sk_buff *buff;
 	struct rd_msg *msg;
@@ -1463,7 +1464,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			memcpy(ha_buf, neigh->ha, dev->addr_len);
 			read_unlock_bh(&neigh->lock);
 			ha = ha_buf;
-			len += ndisc_opt_addr_space(dev);
+			optlen += ndisc_opt_addr_space(dev);
 		} else
 			read_unlock_bh(&neigh->lock);
 
@@ -1471,15 +1472,16 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	}
 
 	rd_len = min_t(unsigned int,
-		     IPV6_MIN_MTU-sizeof(struct ipv6hdr)-len, skb->len + 8);
+		       IPV6_MIN_MTU - sizeof(struct ipv6hdr) - sizeof(*msg) - optlen,
+		       skb->len + 8);
 	rd_len &= ~0x7;
-	len += rd_len;
+	optlen += rd_len;
 
-	buff = ndisc_alloc_skb(dev, len);
+	buff = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!buff)
 		goto release;
 
-	skb_put(buff, len);
+	skb_put(buff, sizeof(*msg) + optlen);
 	msg = (struct rd_msg *)icmp6_hdr(buff);
 
 	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
-- 
1.7.9.5
