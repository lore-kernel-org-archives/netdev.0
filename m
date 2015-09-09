From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] netlink, mmap: don't walk rx ring on poll if receive queue non-empty
Date: Thu, 10 Sep 2015 01:20:46 +0200
Message-ID: <5e369c9aa5889383aece50a6b5c22256b19ab334.1441839128.git.daniel@iogearbox.net>
Cc: chamaken@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50306 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbbIIXU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 19:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of netlink mmap, there can be situations where received frames
have to be placed into the normal receive queue. The ring buffer indicates
this through NL_MMAP_STATUS_COPY, so the user is asked to pick them up
via recvmsg(2) syscall, and to put the slot back to NL_MMAP_STATUS_UNUSED.

Commit 0ef707700f1c ("netlink: rx mmap: fix POLLIN condition") changed
polling, so that we walk in the worst case the whole ring through the
new netlink_has_valid_frame(), for example, when the ring would have no
NL_MMAP_STATUS_VALID, but at least one NL_MMAP_STATUS_COPY frame.

Since we do a datagram_poll() already earlier to pick up a mask that could
possibly contain POLLIN | POLLRDNORM already (due to NL_MMAP_STATUS_COPY),
we can skip checking the rx ring entirely.

In case the kernel is compiled with !CONFIG_NETLINK_MMAP, then all this is
irrelevant anyway as netlink_poll() is just defined as datagram_poll().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/netlink/af_netlink.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 50889be..72c1330 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -674,12 +674,19 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 
 	mask = datagram_poll(file, sock, wait);
 
-	spin_lock_bh(&sk->sk_receive_queue.lock);
-	if (nlk->rx_ring.pg_vec) {
-		if (netlink_has_valid_frame(&nlk->rx_ring))
-			mask |= POLLIN | POLLRDNORM;
+	/* We could already have received frames in the normal receive
+	 * queue, that will show up as NL_MMAP_STATUS_COPY in the ring,
+	 * so if mask contains pollin/etc already, there's no point
+	 * walking the ring.
+	 */
+	if ((mask & (POLLIN | POLLRDNORM)) != (POLLIN | POLLRDNORM)) {
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		if (nlk->rx_ring.pg_vec) {
+			if (netlink_has_valid_frame(&nlk->rx_ring))
+				mask |= POLLIN | POLLRDNORM;
+		}
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
 	}
-	spin_unlock_bh(&sk->sk_receive_queue.lock);
 
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	if (nlk->tx_ring.pg_vec) {
-- 
1.9.3
