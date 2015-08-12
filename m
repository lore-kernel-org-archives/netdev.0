From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 5/5] netlink: mmap: notify only when
 NL_MMAP_STATUS_VALID frame exists
Date: Wed, 12 Aug 2015 17:38:02 +0900
Message-ID: <20150812083802.GF13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36421 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbbHLIiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:38:08 -0400
Received: by pacrr5 with SMTP id rr5so10000336pac.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:38:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index d8f5151..9f9e9ac 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -593,16 +593,6 @@ netlink_current_frame(const struct netlink_ring *ring,
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
@@ -623,6 +613,21 @@ static void netlink_forward_ring(struct netlink_ring *ring)
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
+		pos = pos != ring->frame_max ? pos + 1 : 0;
+	} while (pos != head);
+
+	return false;
+}
+
 static bool netlink_dump_space(struct netlink_sock *nlk)
 {
 	struct netlink_ring *ring = &nlk->rx_ring;
@@ -670,8 +675,7 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 
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
