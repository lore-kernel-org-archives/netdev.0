From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 2/2] tools: test case for TPACKET_V3/TX_RING support
Date: Sun,  1 Jan 2017 14:45:15 -0800
Message-ID: <d26567a7226d392b8105f35be5cf25a17dbdf2ed.1483309545.git.sowmini.varadhan@oracle.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com>
Cc: daniel@iogearbox.net, willemb@google.com, davem@davemloft.net
To: netdev@vger.kernel.org, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:47721 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755153AbdAAWpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 17:45:43 -0500
In-Reply-To: <cover.1483309545.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1483309545.git.sowmini.varadhan@oracle.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a test case and sample code for (TPACKET_V3, PACKET_TX_RING)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
v2: Added test case.

 tools/testing/selftests/net/psock_tpacket.c |  110 ++++++++++++++++++++++++++-
 1 files changed, 109 insertions(+), 1 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 24adf70..f2012dc 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -311,6 +311,17 @@ static inline void __v2_tx_user_ready(struct tpacket2_hdr *hdr)
 	__sync_synchronize();
 }
 
+static inline int __v3_tx_kernel_ready(struct tpacket3_hdr *hdr)
+{
+	return !(hdr->tp_status & (TP_STATUS_SEND_REQUEST | TP_STATUS_SENDING));
+}
+
+static inline void __v3_tx_user_ready(struct tpacket3_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_SEND_REQUEST;
+	__sync_synchronize();
+}
+
 static inline int __v1_v2_tx_kernel_ready(void *base, int version)
 {
 	switch (version) {
@@ -578,12 +589,108 @@ static void walk_v3_rx(int sock, struct ring *ring)
 	fprintf(stderr, " %u pkts (%u bytes)", NUM_PACKETS, total_bytes >> 1);
 }
 
+static inline void *
+get_v3_frame(struct ring *ring, int n)
+{
+	uint8_t *f0 = ring->rd[0].iov_base;
+
+	return f0 + (n * ring->req3.tp_frame_size);
+}
+
+static void walk_v3_tx(int sock, struct ring *ring)
+{
+	struct pollfd pfd;
+	int rcv_sock, ret;
+	size_t packet_len;
+	char packet[1024];
+	unsigned int frame_num = 0, got = 0;
+	struct sockaddr_ll ll = {
+		.sll_family = PF_PACKET,
+		.sll_halen = ETH_ALEN,
+	};
+
+	bug_on(ring->type != PACKET_TX_RING);
+	bug_on(ring->req3.tp_frame_nr < NUM_PACKETS);
+
+	rcv_sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
+	if (rcv_sock == -1) {
+		perror("socket");
+		exit(1);
+	}
+
+	pair_udp_setfilter(rcv_sock);
+
+	ll.sll_ifindex = if_nametoindex("lo");
+	ret = bind(rcv_sock, (struct sockaddr *) &ll, sizeof(ll));
+	if (ret == -1) {
+		perror("bind");
+		exit(1);
+	}
+
+	memset(&pfd, 0, sizeof(pfd));
+	pfd.fd = sock;
+	pfd.events = POLLOUT | POLLERR;
+	pfd.revents = 0;
+
+	total_packets = NUM_PACKETS;
+	create_payload(packet, &packet_len);
+
+	while (total_packets > 0) {
+		struct tpacket3_hdr *tx = get_v3_frame(ring, frame_num);
+
+		while (__v3_tx_kernel_ready(tx) && total_packets > 0) {
+			tx->tp_snaplen = packet_len;
+			tx->tp_len = packet_len;
+			memcpy((uint8_t *) tx + TPACKET3_HDRLEN -
+			       sizeof(struct sockaddr_ll), packet, packet_len);
+			total_bytes += tx->tp_snaplen;
+
+			status_bar_update();
+			total_packets--;
+
+			__v3_tx_user_ready(tx);
+
+			frame_num = (frame_num + 1) % ring->req3.tp_frame_nr;
+		}
+
+		poll(&pfd, 1, 1);
+	}
+
+	bug_on(total_packets != 0);
+
+	ret = sendto(sock, NULL, 0, 0, NULL, 0);
+	if (ret == -1) {
+		perror("sendto");
+		exit(1);
+	}
+
+	while ((ret = recvfrom(rcv_sock, packet, sizeof(packet),
+			       0, NULL, NULL)) > 0 &&
+	       total_packets < NUM_PACKETS) {
+		got += ret;
+		test_payload(packet, ret);
+
+		status_bar_update();
+		total_packets++;
+	}
+
+	close(rcv_sock);
+
+	if (total_packets != NUM_PACKETS) {
+		fprintf(stderr, "walk_v%d_rx: received %u out of %u pkts\n",
+			ring->version, total_packets, NUM_PACKETS);
+		exit(1);
+	}
+
+	fprintf(stderr, " %u pkts (%u bytes)", NUM_PACKETS, got);
+}
+
 static void walk_v3(int sock, struct ring *ring)
 {
 	if (ring->type == PACKET_RX_RING)
 		walk_v3_rx(sock, ring);
 	else
-		bug_on(1);
+		walk_v3_tx(sock, ring);
 }
 
 static void __v1_v2_fill(struct ring *ring, unsigned int blocks)
@@ -796,6 +903,7 @@ int main(void)
 	ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
 
 	ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
+	ret |= test_tpacket(TPACKET_V3, PACKET_TX_RING);
 
 	if (ret)
 		return 1;
-- 
1.7.1
