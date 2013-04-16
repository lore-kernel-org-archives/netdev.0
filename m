From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] packet: minor: add generic tpacket_uhdr to access packet headers
Date: Tue, 16 Apr 2013 13:57:46 +0200
Message-ID: <1366113466-17071-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346Ab3DPL5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 07:57:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to add a dozen unions each time at the start
of the function. So, do this once and use it instead. Thus, we
can remove some duplicate code and make it more readable.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Note: this applies without conflicts on top of my previous set sent today

 net/packet/af_packet.c | 39 ++++++++++++---------------------------
 1 file changed, 12 insertions(+), 27 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 77d71f8..e566b79 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -158,10 +158,16 @@ struct packet_mreq_max {
 	unsigned char	mr_address[MAX_ADDR_LEN];
 };
 
+union tpacket_uhdr {
+	struct tpacket_hdr  *h1;
+	struct tpacket2_hdr *h2;
+	struct tpacket3_hdr *h3;
+	void *raw;
+};
+
 static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
 		int closing, int tx_ring);
 
-
 #define V3_ALIGNMENT	(8)
 
 #define BLK_HDR_LEN	(ALIGN(sizeof(struct tpacket_block_desc), V3_ALIGNMENT))
@@ -290,11 +296,7 @@ static inline __pure struct page *pgv_to_page(void *addr)
 
 static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 {
-	union {
-		struct tpacket_hdr *h1;
-		struct tpacket2_hdr *h2;
-		void *raw;
-	} h;
+	union tpacket_uhdr h;
 
 	h.raw = frame;
 	switch (po->tp_version) {
@@ -317,11 +319,7 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
 
 static int __packet_get_status(struct packet_sock *po, void *frame)
 {
-	union {
-		struct tpacket_hdr *h1;
-		struct tpacket2_hdr *h2;
-		void *raw;
-	} h;
+	union tpacket_uhdr h;
 
 	smp_rmb();
 
@@ -347,11 +345,7 @@ static void *packet_lookup_frame(struct packet_sock *po,
 		int status)
 {
 	unsigned int pg_vec_pos, frame_offset;
-	union {
-		struct tpacket_hdr *h1;
-		struct tpacket2_hdr *h2;
-		void *raw;
-	} h;
+	union tpacket_uhdr h;
 
 	pg_vec_pos = position / rb->frames_per_block;
 	frame_offset = position % rb->frames_per_block;
@@ -1669,12 +1663,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sk;
 	struct packet_sock *po;
 	struct sockaddr_ll *sll;
-	union {
-		struct tpacket_hdr *h1;
-		struct tpacket2_hdr *h2;
-		struct tpacket3_hdr *h3;
-		void *raw;
-	} h;
+	union tpacket_uhdr h;
 	u8 *skb_head = skb->data;
 	int skb_len = skb->len;
 	unsigned int snaplen, res;
@@ -1909,11 +1898,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		void *frame, struct net_device *dev, int size_max,
 		__be16 proto, unsigned char *addr, int hlen)
 {
-	union {
-		struct tpacket_hdr *h1;
-		struct tpacket2_hdr *h2;
-		void *raw;
-	} ph;
+	union tpacket_uhdr ph;
 	int to_write, offset, len, tp_len, nr_frags, len_max;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
-- 
1.7.11.7
