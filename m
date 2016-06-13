From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: udp failures traced to e858fae2b0b8
Date: Mon, 13 Jun 2016 09:42:03 +0300
Message-ID: <20160613064202.GA14048@rapoport-lnx>
References: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:29259 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964807AbcFMGmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 02:42:11 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5D6dhGW048424
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:42:11 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23geqmka57-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:42:10 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 13 Jun 2016 07:42:08 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 6E0C417D805A
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 07:43:17 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5D6g4R524707368
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 06:42:04 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5D6g4xB016462
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:42:04 -0400
Content-Disposition: inline
In-Reply-To: <84272f6d-8c68-6b84-7f0a-6ef4ad8b9e03@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Sun, Jun 12, 2016 at 08:47:20PM -0600, David Ahern wrote:
> Mike:
> 
> UDP tests in my vrf unit test suite are failing. git bisect points to:

Are you testing host or guest kernel?
If it's the host, can you please check if the patch below helps? 
 
> dsa@kenny:~/kernel-2.git$ git bisect good
> e858fae2b0b8f41f0bed2cdffde25e7c97da38a7 is the first bad commit
> commit e858fae2b0b8f41f0bed2cdffde25e7c97da38a7
> Author: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
>     virtio_net: use common code for virtio_net_hdr and skb GSO conversion
> 
> On console I get the following:
> 
> [   80.414134] skbuff: bad partial csum: csum=34/6 len=40
> [   80.416105] eth1: bad gso: type: 0, size: 0
> 
> Networking arg:
> 
> -netdev
> type=tap,vhost=on,ifname=vm01-eth1,script=no,downscript=no,id=netdev1
> -device virtio-net-pci,mac=02:e0:f9:1c:b9:74,netdev=netdev1,romfile=
> 
> tap device is connected to a bridge.
> 
> David
> 

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8cc6bf4..4884802 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1254,6 +1254,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		return -EFAULT;
 	}
 
+	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
+	if (err) {
+		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
+		kfree_skb(skb);
+		return -EINVAL;
+	}
+
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case IFF_TUN:
 		if (tun->flags & IFF_NO_PI) {
@@ -1280,13 +1287,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		break;
 	}
 
-	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
-	if (err) {
-		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
-		kfree_skb(skb);
-		return -EINVAL;
-	}
-
 	/* copy skb_ubuf_info for callback when skb has no error */
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = msg_control;
