From: Jun Zhao <mypopydev@gmail.com>
Subject: [PATCH 1/1] ipv6 : ip6mr.c : Fix can't match the IPv6 multicast packets with input net device in netfilter FORWARD chain.
Date: Thu,  2 Aug 2012 21:00:55 +0800
Message-ID: <1343912455-4444-1-git-send-email-mypopydev@gmail.com>
Cc: mypopydev@gmail.com
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:57994 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab2HBNB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 09:01:28 -0400
Received: by ghrr11 with SMTP id r11so2196295ghr.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 06:01:27 -0700 (PDT)
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
 net/ipv6/ip6mr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 4532973..a9d3dd7 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1946,7 +1946,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	 * result in receiving multiple packets.
 	 */
 	dev = vif->dev;
-	skb->dev = dev;
+
 	vif->pkt_out++;
 	vif->bytes_out += skb->len;
 
-- 
1.7.2.5
