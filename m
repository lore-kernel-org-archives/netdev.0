From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH 1/2] packet: report tx_dropped in packet_direct_xmit
Date: Wed,  2 Apr 2014 20:52:56 +0200
Message-ID: <1396464777-18375-2-git-send-email-dborkman@redhat.com>
References: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815AbaDBSxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2014 14:53:08 -0400
In-Reply-To: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 015f0688f57c ("net: net: add a core netdev->tx_dropped
counter"), we can now account for TX drops from within the core
stack instead of drivers.

Therefore, fix packet_direct_xmit() and increase drop count when we
encounter a problem before driver's xmit function was called (we do
not want to doubly account for it).

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/af_packet.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 01039d2..c81a971 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -275,6 +275,7 @@ static int packet_direct_xmit(struct sk_buff *skb)
 
 	return ret;
 drop:
+	atomic_long_inc(&dev->tx_dropped);
 	kfree_skb(skb);
 	return NET_XMIT_DROP;
 }
-- 
1.7.11.7
