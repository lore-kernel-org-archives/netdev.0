From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] tun: fix csum generation for tap devices
Date: Tue, 14 Jun 2016 08:31:11 +0300
Message-ID: <20160614053110.GA2843@rapoport-lnx>
References: <b4a4ba554658d07e8213e1e57cddef2f9485cc1b.1465854647.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:44778 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbcFNFbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 01:31:20 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5E5TbJK057735
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 01:31:19 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23get0sa3t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 01:31:19 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 14 Jun 2016 06:31:16 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 353B517D8056
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 06:32:27 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5E5VEDG5898662
	for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 05:31:14 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5E5VDwr011041
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 23:31:14 -0600
Content-Disposition: inline
In-Reply-To: <b4a4ba554658d07e8213e1e57cddef2f9485cc1b.1465854647.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 12:00:04AM +0200, Paolo Abeni wrote:
> The commit 34166093639b ("tuntap: use common code for virtio_net_hdr
> and skb GSO conversion") replaced the tun code for header manipulation
> with the generic helpers. While doing so, it implictly moved the
> skb_partial_csum_set() invocation after eth_type_trans(), which
> invalidate the current gso start/offset values.
> Fix it by moving the helper invocation before the mac pulling.
> 
> Fixes: 34166093639 ("tuntap: use common code for virtio_net_hdr and skb GSO conversion")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Acked-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  drivers/net/tun.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8cc6bf4..4884802 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1254,6 +1254,13 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		return -EFAULT;
>  	}
> 
> +	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
> +	if (err) {
> +		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
> +		kfree_skb(skb);
> +		return -EINVAL;
> +	}
> +
>  	switch (tun->flags & TUN_TYPE_MASK) {
>  	case IFF_TUN:
>  		if (tun->flags & IFF_NO_PI) {
> @@ -1280,13 +1287,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		break;
>  	}
> 
> -	err = virtio_net_hdr_to_skb(skb, &gso, tun_is_little_endian(tun));
> -	if (err) {
> -		this_cpu_inc(tun->pcpu_stats->rx_frame_errors);
> -		kfree_skb(skb);
> -		return -EINVAL;
> -	}
> -
>  	/* copy skb_ubuf_info for callback when skb has no error */
>  	if (zerocopy) {
>  		skb_shinfo(skb)->destructor_arg = msg_control;
> -- 
> 1.8.3.1
> 
