From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH v3 net-next] packet: doc: describe PACKET_MMAP with one packet socket for rx and tx
Date: Fri, 10 Jan 2014 10:22:37 +0100
Message-ID: <1389345757-13579-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbaAJJWm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 04:22:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>

Document how to use one AF_PACKET mmap socket for RX and TX.

Signed-off-by: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 v1->v2:
  - add setsockopt() calls
 v2->v3:
  - did the rebase to net-next for Norbert

 Documentation/networking/packet_mmap.txt | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/Documentation/networking/packet_mmap.txt b/Documentation/networking/packet_mmap.txt
index 723bf3d..91ffe1d 100644
--- a/Documentation/networking/packet_mmap.txt
+++ b/Documentation/networking/packet_mmap.txt
@@ -98,6 +98,11 @@ by the kernel.
 The destruction of the socket and all associated resources
 is done by a simple call to close(fd).
 
+Similarly as without PACKET_MMAP, it is possible to use one socket
+for capture and transmission. This can be done by mapping the
+allocated RX and TX buffer ring with a single mmap() call.
+See "Mapping and use of the circular buffer (ring)".
+
 Next I will describe PACKET_MMAP settings and its constraints,
 also the mapping of the circular buffer in the user process and 
 the use of this buffer.
@@ -414,6 +419,19 @@ tp_block_size/tp_frame_size frames there will be a gap between
 the frames. This is because a frame cannot be spawn across two
 blocks. 
 
+To use one socket for capture and transmission, the mapping of both the
+RX and TX buffer ring has to be done with one call to mmap:
+
+    ...
+    setsockopt(fd, SOL_PACKET, PACKET_RX_RING, &foo, sizeof(foo));
+    setsockopt(fd, SOL_PACKET, PACKET_TX_RING, &bar, sizeof(bar));
+    ...
+    rx_ring = mmap(0, size * 2, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
+    tx_ring = rx_ring + size;
+
+RX must be the first as the kernel maps the TX ring memory right
+after the RX one.
+
 At the beginning of each frame there is an status field (see 
 struct tpacket_hdr). If this field is 0 means that the frame is ready
 to be used for the kernel, If not, there is a frame the user can read 
-- 
1.7.11.7
