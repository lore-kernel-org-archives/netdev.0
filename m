From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [RFC PATCH 5/5] netlink: rx mmap: notify only when
 NL_MMAP_STATUS_VALID frame exists
Date: Wed, 22 Jul 2015 22:23:31 +0900
Message-ID: <20150722132331.GF18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35270 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964830AbbGVNXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:23:36 -0400
Received: by pdrg1 with SMTP id g1so138806214pdr.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:23:36 -0700 (PDT)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id b10sm3393966pdo.84.2015.07.22.06.23.34
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:23:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netlink/af_netlink.c |   28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7e1610e..8901acd 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -576,16 +576,6 @@ netlink_current_frame(const struct netlink_ring *ring,
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
@@ -606,6 +596,21 @@ static void netlink_forward_ring(struct netlink_ring *ring)
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
@@ -653,8 +658,7 @@ static unsigned int netlink_poll(struct file *file, struct socket *sock,
 
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


----- End forwarded message -----
