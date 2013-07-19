From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/2] tun: Support software transmit time stamping.
Date: Fri, 19 Jul 2013 19:40:10 +0200
Message-ID: <6f731f729eaa7f49e4c05f68e07f583b9ee1959f.1374254759.git.richardcochran@gmail.com>
References: <cover.1374254757.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:48508 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760631Ab3GSRk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 13:40:28 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so2539702eei.13
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 10:40:27 -0700 (PDT)
In-Reply-To: <cover.1374254757.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds transmit time stamping to the tun/tap driver. Similar
support already exists for UDP, can, and raw packets.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/tun.c           |   14 ++++++++++++--
 include/uapi/linux/if_tun.h |    3 +++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index db690a3..a72d141 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -739,6 +739,11 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 			  >= dev->tx_queue_len / tun->numqueues)
 		goto drop;
 
+	if (skb->sk) {
+		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
+		sw_tx_timestamp(skb);
+	}
+
 	/* Orphan the skb - required as we might hang on to it
 	 * for indefinite time. */
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
@@ -1476,7 +1481,6 @@ static int tun_sendmsg(struct kiocb *iocb, struct socket *sock,
 	return ret;
 }
 
-
 static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 		       struct msghdr *m, size_t total_len,
 		       int flags)
@@ -1488,10 +1492,15 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (!tun)
 		return -EBADFD;
 
-	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
+	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC|MSG_ERRQUEUE)) {
 		ret = -EINVAL;
 		goto out;
 	}
+	if (flags & MSG_ERRQUEUE) {
+		ret = sock_recv_errqueue(sock->sk, m, total_len,
+					 SOL_PACKET, TUN_TX_TIMESTAMP);
+		goto out;
+	}
 	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
@@ -2274,6 +2283,7 @@ static const struct ethtool_ops tun_ethtool_ops = {
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
 	.get_link	= ethtool_op_get_link,
+	.get_ts_info	= ethtool_op_get_ts_info,
 };
 
 
diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
index 82334f8..1870ee2 100644
--- a/include/uapi/linux/if_tun.h
+++ b/include/uapi/linux/if_tun.h
@@ -71,6 +71,9 @@
 /* read-only flag */
 #define IFF_PERSIST	0x0800
 
+/* Socket options */
+#define TUN_TX_TIMESTAMP 1
+
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
 #define TUN_F_TSO4	0x02	/* I can handle TSO for IPv4 packets */
-- 
1.7.10.4
