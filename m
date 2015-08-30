From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCH net] netlink: rx mmap: fix POLLIN condition
Date: Mon, 31 Aug 2015 07:54:49 +0900
Message-ID: <20150830225449.GA9533@gmail.com>
References: <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150820055447.GA2656@gmail.com>
 <20150825.201712.2151042716686513603.davem@davemloft.net>
 <20150828070058.GA32596@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34631 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbbH3Wyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 18:54:55 -0400
Received: by pabzx8 with SMTP id zx8so118010890pab.1
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 15:54:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150828070058.GA32596@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Poll() returns immediately after setting the kernel current frame
(ring->head) to SKIP from user space even though there is no new
frame. And in a case of all frames is VALID, user space program
unintensionally sets (only) kernel current frame to UNUSED, then
calls poll(), it will not return immediately even though there are
VALID frames.

To avoid situations like above, I think we need to scan all frames
to find VALID frames at poll() like netlink_alloc_skb(),
netlink_forward_ring() finding an UNUSED frame at skb allocation.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7965ca7..50889be 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -594,16 +594,6 @@ netlink_current_frame(const struct netlink_ring *ring,
 	return netlink_lookup_frame(ring, ring->head, status);
 }
 
-static struct nl_mmap_hdr *
-netlink_previous_frame(const struct netlink_ring *ring,
-		       enum nl_mmap_status status)
-{
-	unsigned int prev;
-
-	prev = ring->head ? ring->head - 1 : ring->frame_max;
-	return netlink_lookup_frame(ring, prev, status);
-}
-
 static void netlink_increment_head(struct netlink_ring *ring)
 {
 	ring->head = ring->head != ring->frame_max ? ring->head + 1 : 0;
@@ -624,6 +614,21 @@ static void netlink_forward_ring(struct netlink_ring *ring)
 	} while (ring->head != head);
 }
 
+static bool netlink_has_valid_frame(struct netlink_ring *ring)
+{
+	unsigned int head = ring->head, pos = head;
+	const struct nl_mmap_hdr *hdr;
+
+	do {
+		hdr = __netlink_lookup_frame(ring, pos);
+		if (hdr->nm_status == NL_MMAP_STATUS_VALID)
+			return true;
+		pos = pos != 0 ? pos - 1 : ring->frame_max;
+	} while (pos != head);
+
+	return false;
+}
+
 static bool netlink_dump_space(struct netlink_sock *nlk)
 {
 	struct netlink_ring *ring = &nlk->rx_ring;
@@ -671,8 +676,7 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 
 	spin_lock_bh(&sk->sk_receive_queue.lock);
 	if (nlk->rx_ring.pg_vec) {
-		netlink_forward_ring(&nlk->rx_ring);
-		if (!netlink_previous_frame(&nlk->rx_ring, NL_MMAP_STATUS_UNUSED))
+		if (netlink_has_valid_frame(&nlk->rx_ring))
 			mask |= POLLIN | POLLRDNORM;
 	}
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
-- 
1.7.10.4
