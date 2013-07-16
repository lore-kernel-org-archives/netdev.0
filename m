From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv4: set transport header earlier
Date: Mon, 15 Jul 2013 20:03:19 -0700
Message-ID: <1373943799.10804.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	netfilter-devel@vger.kernel.org, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63566 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108Ab3GPDDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 23:03:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 45f00f99d6e ("ipv4: tcp: clean up tcp_v4_early_demux()") added a
performance regression for non GRO traffic, basically disabling
IP early demux.

IPv6 stack resets transport header in ip6_rcv() before calling
IP early demux in ip6_rcv_finish(), while IPv4 does this only in
ip_local_deliver_finish(), _after_ IP early demux.

GRO traffic happened to enable IP early demux because transport header
is also set in inet_gro_receive()

Instead of reverting the faulty commit, we can make IPv4/IPv6 behave the
same : transport_header should be set in ip_rcv() instead of
ip_local_deliver_finish()

ip_local_deliver_finish() can also use skb_network_header_len() which is
faster than ip_hdrlen()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_input.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3da817b..15e3e68 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -190,10 +190,7 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 
-	__skb_pull(skb, ip_hdrlen(skb));
-
-	/* Point into the IP datagram, just past the header. */
-	skb_reset_transport_header(skb);
+	__skb_pull(skb, skb_network_header_len(skb));
 
 	rcu_read_lock();
 	{
@@ -437,6 +434,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 	}
 
+	skb->transport_header = skb->network_header + iph->ihl*4;
+
 	/* Remove any debris in the socket control block */
 	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 
