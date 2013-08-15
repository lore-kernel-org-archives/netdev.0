From: Sage Weil <sage@inktank.com>
Subject: Re: [patch 1/2] libceph: fix error handling in handle_reply()
Date: Wed, 14 Aug 2013 23:05:21 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1308142303020.1479@cobra.newdream.net>
References: <20130815055158.GA23580@elgon.mountain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cobra.newdream.net ([66.33.216.30]:58350 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab3HOGFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 02:05:22 -0400
In-Reply-To: <20130815055158.GA23580@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied all 3 of these.

Thanks, Dan!
sage

On Thu, 15 Aug 2013, Dan Carpenter wrote:

> We've tried to fix the error paths in this function before, but there
> is still a hidden goto in the ceph_decode_need() macro which goes to the
> wrong place.  We need to release the "req" and unlock a mutex before
> returning.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> index dbc0a73..559a832 100644
> --- a/net/ceph/osd_client.c
> +++ b/net/ceph/osd_client.c
> @@ -1488,14 +1488,14 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
>  	dout("handle_reply %p tid %llu req %p result %d\n", msg, tid,
>  	     req, result);
>  
> -	ceph_decode_need(&p, end, 4, bad);
> +	ceph_decode_need(&p, end, 4, bad_put);
>  	numops = ceph_decode_32(&p);
>  	if (numops > CEPH_OSD_MAX_OP)
>  		goto bad_put;
>  	if (numops != req->r_num_ops)
>  		goto bad_put;
>  	payload_len = 0;
> -	ceph_decode_need(&p, end, numops * sizeof(struct ceph_osd_op), bad);
> +	ceph_decode_need(&p, end, numops * sizeof(struct ceph_osd_op), bad_put);
>  	for (i = 0; i < numops; i++) {
>  		struct ceph_osd_op *op = p;
>  		int len;
> @@ -1513,7 +1513,7 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
>  		goto bad_put;
>  	}
>  
> -	ceph_decode_need(&p, end, 4 + numops * 4, bad);
> +	ceph_decode_need(&p, end, 4 + numops * 4, bad_put);
>  	retry_attempt = ceph_decode_32(&p);
>  	for (i = 0; i < numops; i++)
>  		req->r_reply_op_result[i] = ceph_decode_32(&p);
> --
> To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
