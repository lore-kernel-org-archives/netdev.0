From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/3] virtio_net: pass well-formed sgs to virtqueue_add_*()
Date: Wed,  3 Sep 2014 13:59:14 +0930
Message-ID: <1409718556-3041-2-git-send-email-rusty@rustcorp.com.au>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Cc: Andy Lutomirski <luto@amacapital.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:43243 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751598AbaICEaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 00:30:12 -0400
In-Reply-To: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the only driver which doesn't hand virtqueue_add_inbuf and
virtqueue_add_outbuf a well-formed, well-terminated sg.  Fix it,
so we can make virtio_add_* simpler.

pktgen results:
	modprobe pktgen
	echo 'add_device eth0' > /proc/net/pktgen/kpktgend_0
	echo nowait 1 > /proc/net/pktgen/eth0
	echo count 1000000 > /proc/net/pktgen/eth0
	echo clone_skb 100000 > /proc/net/pktgen/eth0
	echo dst_mac 4e:14:25:a9:30:ac > /proc/net/pktgen/eth0
	echo dst 192.168.1.2 > /proc/net/pktgen/eth0
	for i in `seq 20`; do echo start > /proc/net/pktgen/pgctrl; tail -n1 /proc/net/pktgen/eth0; done

Before:
  746547-793084(786421+/-9.6e+03)pps 346-367(364.4+/-4.4)Mb/sec (346397808-367990976(3.649e+08+/-4.5e+06)bps) errors: 0

After:
  767390-792966(785159+/-6.5e+03)pps 356-367(363.75+/-2.9)Mb/sec (356068960-367936224(3.64314e+08+/-3e+06)bps) errors: 0

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 59caa06f34a6..31cac511b3c3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -546,8 +546,8 @@ static int add_recvbuf_small(struct receive_queue *rq, gfp_t gfp)
 	skb_put(skb, GOOD_PACKET_LEN);
 
 	hdr = skb_vnet_hdr(skb);
+	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);
 	sg_set_buf(rq->sg, &hdr->hdr, sizeof hdr->hdr);
-
 	skb_to_sgvec(skb, rq->sg + 1, 0, skb->len);
 
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, 2, skb, gfp);
@@ -563,6 +563,8 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 	char *p;
 	int i, err, offset;
 
+	sg_init_table(rq->sg, MAX_SKB_FRAGS + 2);
+
 	/* page in rq->sg[MAX_SKB_FRAGS + 1] is list tail */
 	for (i = MAX_SKB_FRAGS + 1; i > 1; --i) {
 		first = get_a_page(rq, gfp);
@@ -899,6 +901,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	if (vi->mergeable_rx_bufs)
 		hdr->mhdr.num_buffers = 0;
 
+	sg_init_table(sq->sg, MAX_SKB_FRAGS + 2);
 	if (can_push) {
 		__skb_push(skb, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
-- 
1.9.1
