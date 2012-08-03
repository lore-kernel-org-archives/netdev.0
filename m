From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH v2 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6 multicast packets with input net device in netfilter FORWARD chain.
Date: Fri,  3 Aug 2012 14:27:51 +0800
Message-ID: <1343975271-4263-1-git-send-email-mypopydev@gmail.com>
Cc: netdev@vger.kernel.org, mypopydev@gmail.com
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35269 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab2HCG2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2012 02:28:01 -0400
Received: by ghrr11 with SMTP id r11so431471ghr.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 23:28:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current kernel change the skb's net device with output device before netfilter FORWARD chain,
that will lead to can't match the IPv6 multicast packets with input net device in netfilter
FORWARD chain.

the test case for reproduce this issue as follow:

IPv6 multicast udp stream from eth0(input device) to eth1(output device)

Dst Addr: Port
{ff03::4}:6789 --->

                    Router
         +---------------------------+
-------> | [eth0] --FORWARD--> [eth1]| ------->
         +---------------------------+

ip6tables -I FORWARD -p udp -i eth0 -o eth1 --dst ff03::4 -j ACCEPT [first rules ]
ip6tables -A FORWARD -p udp -i eth1 -o eth1 --dst ff03::4 -j ACCEPT [second rules]

Before fix this issue, it will match the second rules not the first rules. you can used
command "ip6tables -L -vnx" to check the match result.

Signed-off-by: Jun Zhao <mypopydev@gmail.com>
---
 net/ipv6/ip6mr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4532973..b099dfb 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1901,6 +1901,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	struct ipv6hdr *ipv6h;
 	struct mif_device *vif = &mrt->vif6_table[vifi];
 	struct net_device *dev;
+	struct net_device *indev;
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 
@@ -1946,6 +1947,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	 * result in receiving multiple packets.
 	 */
 	dev = vif->dev;
+	indev = skb->dev;
 	skb->dev = dev;
 	vif->pkt_out++;
 	vif->bytes_out += skb->len;
@@ -1960,7 +1962,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, indev, dev,
 		       ip6mr_forward2_finish);
 
 out_free:
-- 
1.7.2.5
