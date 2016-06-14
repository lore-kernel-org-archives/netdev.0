From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH net-next] virtio_net: fix csum generation for virtio-net devices
Date: Tue, 14 Jun 2016 08:29:38 +0300
Message-ID: <1465882178-5098-1-git-send-email-rppt@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Ahern <dsa@cumulusnetworks.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:26833 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750752AbcFNFaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 01:30:11 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5E5TbNp146353
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 01:30:05 -0400
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23gc8wuvjh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 01:30:05 -0400
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 14 Jun 2016 06:30:03 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 086CE1B08061
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 06:30:51 +0100 (BST)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5E5TgUA4718946
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 05:29:42 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5E5Tf5n020278
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 23:29:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit e858fae2b0b8 ("virtio_net: use common code for virtio_net_hdr
and skb GSO conversion") replaced the tun code for header manipulation
with the generic helpers. While doing so, it implictly moved the
skb_partial_csum_set() invocation after eth_type_trans(), which
invalidate the current gso start/offset values.
Fix it by moving the helper invocation before the mac pulling.

Fixes: e858fae2b0b8 ("virtio_net: use common code for virtio_net_hdr and
skb GSO conversion")

Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9af0a98..9f8be96 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -482,10 +482,6 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	skb->protocol = eth_type_trans(skb, dev);
-	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
-		 ntohs(skb->protocol), skb->len, skb->pkt_type);
-
 	if (virtio_net_hdr_to_skb(skb, &hdr->hdr,
 				  virtio_is_little_endian(vi->vdev))) {
 		net_warn_ratelimited("%s: bad gso: type: %u, size: %u\n",
@@ -494,6 +490,10 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 		goto frame_err;
 	}
 
+	skb->protocol = eth_type_trans(skb, dev);
+	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
+		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+
 	napi_gro_receive(&rq->napi, skb);
 	return;
 
-- 
1.9.1
