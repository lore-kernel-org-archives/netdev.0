From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] virtio-vsock: Fix unbound rx buffer
Date: Wed, 03 Aug 2016 11:42:23 -0700 (PDT)
Message-ID: <20160803.114223.772489117054301264.davem@davemloft.net>
References: <20160801171821.32662-1-ggarcia@deic.uab.cat>
	<20160801171821.32662-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755250AbcHCSns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 14:43:48 -0400
In-Reply-To: <20160801171821.32662-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ggarcia@abra.uab.cat
Date: Mon, 01 Aug 2016 19:18:21 +0200

> From: Gerard Garcia <ggarcia@deic.uab.cat>
> 
> Reset connection and close rx socket when the sender is ignoring our announced available buffer.
> 
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  net/vmw_vsock/virtio_transport_common.c | 22 ++++++++++++++++------
>  1 file changed, 16 insertions(+), 6 deletions(-)
> 
> diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
> index a53b3a1..3c38d43 100644
> --- a/net/vmw_vsock/virtio_transport_common.c
> +++ b/net/vmw_vsock/virtio_transport_common.c
> @@ -773,13 +773,23 @@ virtio_transport_recv_connected(struct sock *sk,
>  		pkt->len = le32_to_cpu(pkt->hdr.len);
>  		pkt->off = 0;
>  
> -		spin_lock_bh(&vvs->rx_lock);
> -		virtio_transport_inc_rx_pkt(vvs, pkt);
> -		list_add_tail(&pkt->list, &vvs->rx_queue);
> -		spin_unlock_bh(&vvs->rx_lock);
> +		if (vvs->rx_bytes + pkt->len <= vvs->buf_size) {
> +			spin_lock_bh(&vvs->rx_lock);
> +			virtio_transport_inc_rx_pkt(vvs, pkt);
> +			list_add_tail(&pkt->list, &vvs->rx_queue);
> +			spin_unlock_bh(&vvs->rx_lock);
> +
> +			sk->sk_data_ready(sk);
> +			return err;
> +		} else {
> +			/* Sender is ignoring our buf_alloc */
> +			spin_unlock_bh(&vvs->rx_lock);

You don't hold vvs->rx_lock here, so it's a bug to try and release it.

I'd also expect the maintainers of this driver to give some feedback
before I apply this.
