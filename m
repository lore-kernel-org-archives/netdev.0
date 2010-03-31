From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH RFC] virtio_net: use NAPI for xmit (UNTESTED)
Date: Wed, 31 Mar 2010 00:13:21 -0700
Message-ID: <1270019601.25337.7.camel@localhost.localdomain>
References: <201003311429.57793.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:35794 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab0CaHNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 03:13:43 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2V7707p021725
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 01:07:00 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V7DO4B058814
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 01:13:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2V7DMfv021461
	for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 01:13:24 -0600
In-Reply-To: <201003311429.57793.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 14:29 +1030, Rusty Russell wrote:
> +static int virtnet_xmit_poll(struct napi_struct *xmit_napi, int
> budget)
> +{
> +       struct virtnet_info *vi =
> +               container_of(xmit_napi, struct virtnet_info,
> xmit_napi);
> +
> +       /* Don't access vq/capacity at same time as start_xmit. */
> +       __netif_tx_lock(netdev_get_tx_queue(vi->dev, 0),
> smp_processor_id());
> +
> +       vi->capacity += free_old_xmit_skbs(vi);
> +       if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
> +               /* Suppress further xmit interrupts. */
> +               vi->svq->vq_ops->disable_cb(vi->svq);
> +               napi_complete(xmit_napi);
> +
> +               /* Don't wake it if link is down. */
> +               if (likely(netif_carrier_ok(vi->vdev)))

This should be if (likely(netif_carrier_ok(vi->dev)))

> +                       netif_wake_queue(vi->dev);
> +       }
> +
> +       __netif_tx_unlock(netdev_get_tx_queue(vi->dev, 0));
> +       return 1;
> +}
> + 

I tested the backport patch with vhost on, the initial netperf test
result showed BW performance decreased 10% with same cpu utilization. I
will look at it tomorrow.

Shirley

