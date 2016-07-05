From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Tue,  5 Jul 2016 15:35:32 +0300
Message-ID: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
Cc: Florian Westphal <fw@strlen.de>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25261 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcGEMgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:36:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Given:
 - tap0, vxlan0 enslaved under a bridge
 - eth0 is the tunnel underlay having small mtu (e.g. 1400)

Assume GSO skbs arriving from tap0 having a gso_size as determined by
user-provided virtio_net_hdr (e.g. 1460 corresponding to VM mtu of 1500).

After encapsulation these skbs have skb_gso_network_seglen that exceed
underlay ip_skb_dst_mtu.

These skbs are accidentally passed to ip_finish_output2 AS IS; however
each final segment (either segmented by validate_xmit_skb of eth0, or
by eth0 hardware UFO) would be larger than eth0 mtu.
As a result, those above-mtu segments get dropped on certain underlay
networks.

The expected behavior in such a setup would be segmenting the skb first,
and then fragmenting each segment according to dst mtu, and finally
passing the resulting fragments to ip_finish_output2.

'ip_finish_output_gso' already supports this "Slowpath" behavior,
but it is only considered if IPSKB_FORWARDED is set.

However in the bridged case, IPSKB_FORWARDED is off, and the "Slowpath"
behavior is not considered.

Fix, by performing ip_finish_output_gso "Slowpath" even for non
IPSKB_FORWARDED skbs.

This is also OK for locally created skbs, as they likely to have
skb_gso_network_seglen that equals dst mtu, and thus will go directly to
'ip_finish_output2' as done prior this fix.

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
---
 net/ipv4/ip_output.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cbac493..8ae65b3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -223,9 +223,8 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	struct sk_buff *segs;
 	int ret = 0;
 
-	/* common case: locally created skb or seglen is <= mtu */
-	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_validate_mtu(skb, mtu))
+	/* common case: seglen is <= mtu */
+	if (skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
-- 
1.9.1
