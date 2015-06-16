From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] packet: read num_members once in packet_rcv_fanout()
Date: Tue, 16 Jun 2015 07:59:11 -0700
Message-ID: <1434466751.27504.176.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:36601 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbbFPO7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 10:59:14 -0400
Received: by igbiq7 with SMTP id iq7so44721409igb.1
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 07:59:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We need to tell compiler it must not read f->num_members multiple
times. Otherwise testing if num is not zero is flaky, and we could
attempt an invalid divide by 0 in fanout_demux_cpu()

Note bug was present in packet_rcv_fanout_hash() and
packet_rcv_fanout_lb() but final 3.1 had a simple location
after commit 95ec3eb417115fb ("packet: Add 'cpu' fanout policy.")

Fixes: dc99f600698dc ("packet: Add fanout support.")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
Note : I chose to use READ_ONCE() but stable backports should use
ACCESS_ONCE()

 net/packet/af_packet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5989c6ee551..131545a06f05 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1353,7 +1353,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 			     struct packet_type *pt, struct net_device *orig_dev)
 {
 	struct packet_fanout *f = pt->af_packet_priv;
-	unsigned int num = f->num_members;
+	unsigned int num = READ_ONCE(f->num_members);
 	struct packet_sock *po;
 	unsigned int idx;
 
