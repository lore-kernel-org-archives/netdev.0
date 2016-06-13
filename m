From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: udp failures traced to e858fae2b0b8
Date: Mon, 13 Jun 2016 21:40:42 +0300
Message-ID: <20160613184040.GC14048@rapoport-lnx>
References: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
 <20160613064202.GA14048@rapoport-lnx>
 <2ba80fe2-8274-33e2-afef-70170f31002c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:16198 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753655AbcFMSkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 14:40:53 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DIcvM0050381
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:40:48 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23get1rdjn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 14:40:47 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 19:40:46 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 89F5A17D8056
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 19:41:56 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5DIeh8h4915612
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 18:40:43 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5DIehbY018178
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 12:40:43 -0600
Content-Disposition: inline
In-Reply-To: <2ba80fe2-8274-33e2-afef-70170f31002c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 07:48:39AM -0600, David Ahern wrote:
> On 6/13/16 12:42 AM, Mike Rapoport wrote:
> >Hi David,
> >
> >On Sun, Jun 12, 2016 at 08:47:20PM -0600, David Ahern wrote:
> >>Mike:
> >>
> >>UDP tests in my vrf unit test suite are failing. git bisect points to:
> >
> >Are you testing host or guest kernel?
> 
> Problem is with guest. Guest is running net-next kernel.

Can you please check with the below patch?

> host is running 4.6.
> 

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
 
