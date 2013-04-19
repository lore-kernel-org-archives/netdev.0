From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/2] packet: reorder a member in packet_ring_buffer
Date: Fri, 19 Apr 2013 18:12:28 +0200
Message-ID: <1366387949-9161-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757385Ab3DSQMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 12:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's a 4 byte hole in packet_ring_buffer structure before
prb_bdqc, that can be filled with 'pending' member, thus we can
reduce the overall structure size from 224 bytes to 216 bytes.
This also has the side-effect, that in struct packet_sock 2*4 byte
holes after the embedded packet_ring_buffer members are removed,
and overall, packet_sock can be reduced by 1 cacheline:

Before: size: 1344, cachelines: 21, members: 24
After:  size: 1280, cachelines: 20, members: 24

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/packet/internal.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/packet/internal.h b/net/packet/internal.h
index e891f02..650751b 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -54,6 +54,7 @@ struct pgv {
 
 struct packet_ring_buffer {
 	struct pgv		*pg_vec;
+
 	unsigned int		head;
 	unsigned int		frames_per_block;
 	unsigned int		frame_size;
@@ -63,8 +64,9 @@ struct packet_ring_buffer {
 	unsigned int		pg_vec_pages;
 	unsigned int		pg_vec_len;
 
-	struct tpacket_kbdq_core	prb_bdqc;
 	atomic_t		pending;
+
+	struct tpacket_kbdq_core	prb_bdqc;
 };
 
 extern struct mutex fanout_mutex;
-- 
1.7.11.7
