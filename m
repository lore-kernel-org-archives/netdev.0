From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 2/8] netlink: Avoid netlink mmap alloc if msg size exceeds frame size
Date: Thu, 21 Nov 2013 19:13:33 +0100
Message-ID: <ec90cfecc3489a9959757243c12ddbb8f72aacdd.1385057355.git.tgraf@suug.ch>
References: <cover.1385057355.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54586 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab3KUSNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:13:50 -0500
In-Reply-To: <cover.1385057355.git.tgraf@suug.ch>
In-Reply-To: <cover.1385057355.git.tgraf@suug.ch>
References: <cover.1385057355.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An insufficent ring frame size configuration can lead to an
unnecessary skb allocation for every Netlink message. Check frame
size before taking the queue lock and allocating the skb and
re-check with lock to be safe.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/netlink/af_netlink.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index bca50b9..6433489 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1769,6 +1769,9 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	if (ring->pg_vec == NULL)
 		goto out_put;
 
+	if (ring->frame_size - NL_MMAP_HDRLEN < size)
+		goto out_put;
+
 	skb = alloc_skb_head(gfp_mask);
 	if (skb == NULL)
 		goto err1;
@@ -1778,6 +1781,7 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	if (ring->pg_vec == NULL)
 		goto out_free;
 
+	/* check again under lock */
 	maxlen = ring->frame_size - NL_MMAP_HDRLEN;
 	if (maxlen < size)
 		goto out_free;
-- 
1.8.3.1
