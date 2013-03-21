From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net: fix psock_fanout on sparc64
Date: Thu, 21 Mar 2013 14:10:03 -0400
Message-ID: <1363889403-7712-1-git-send-email-willemb@google.com>
References: <CA+FuTSewLdQZbWPLrdbtG2xtaWSdrPDO3yz6boXqgStYhh3fcg@mail.gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:55289 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab3CUSQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 14:16:01 -0400
Received: by mail-qc0-f201.google.com with SMTP id o22so286047qcr.0
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 11:15:59 -0700 (PDT)
In-Reply-To: <CA+FuTSewLdQZbWPLrdbtG2xtaWSdrPDO3yz6boXqgStYhh3fcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The packetsocket fanout test uses a packet ring. Use TPACKET_V2
instead of TPACKET_V1 to work around a known 32/64 bit issue in
the older ring that manifests on sparc64.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/psock_fanout.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 226e5e3..59bd636 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -182,7 +182,13 @@ static char *sock_fanout_open_ring(int fd)
 		.tp_frame_nr   = RING_NUM_FRAMES,
 	};
 	char *ring;
+	int val = TPACKET_V2;
 
+	if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, (void *) &val,
+		       sizeof(val))) {
+		perror("packetsock ring setsockopt version");
+		exit(1);
+	}
 	if (setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req,
 		       sizeof(req))) {
 		perror("packetsock ring setsockopt");
@@ -201,7 +207,7 @@ static char *sock_fanout_open_ring(int fd)
 
 static int sock_fanout_read_ring(int fd, void *ring)
 {
-	struct tpacket_hdr *header = ring;
+	struct tpacket2_hdr *header = ring;
 	int count = 0;
 
 	while (header->tp_status & TP_STATUS_USER && count < RING_NUM_FRAMES) {
-- 
1.8.1.3
