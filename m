From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next RFC 1/5] xen-netback: Introduce TX grant map
 definitions
Date: Thu, 31 Oct 2013 19:33:59 +0000
Message-ID: <5272B0A7.30104@citrix.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com> <1383094220-14775-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: Zoltan Kiss <zoltan.kiss@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383094220-14775-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/10/13 00:50, Zoltan Kiss wrote:
> +void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
> +{
> +	unsigned long flags;
> +	pending_ring_idx_t index;
> +	u16 pending_idx = ubuf->desc;
> +	struct pending_tx_info *temp =
> +		container_of(ubuf, struct pending_tx_info, callback_struct);
> +	struct xenvif *vif =
> +		container_of(temp - pending_idx, struct xenvif,
> +			pending_tx_info[0]);
> +
> +	spin_lock_irqsave(&vif->dealloc_lock, flags);
> +	do {
> +		pending_idx = ubuf->desc;
> +		ubuf = (struct ubuf_info *) ubuf->ctx;
> +		index = pending_index(vif->dealloc_prod);
> +		vif->dealloc_ring[index] = pending_idx;
> +		/* Sync with xenvif_tx_action_dealloc:
> +		 * insert idx then incr producer.
> +		 */
> +		smp_wmb();
> +		vif->dealloc_prod++;
> +		napi_schedule(&vif->napi);
> +	} while (ubuf);
> +	spin_unlock_irqrestore(&vif->dealloc_lock, flags);
> +}

Another possible place for improvement is the placing of napi_schedule. 
Now it get called after every fragment, which is probably suboptimal. I 
think it's likely that the vif thread can't finish one dealloc faster 
than one iteration of this while loop.
Another idea is to place it after the while, so it get called only once, 
but in the meantime the thread doesn't have chance to start working on 
the deallocs.
A compromise might be to do it once in the first iteration of the loop, 
and then once after the loop to make sure the thread knows about the 
dealloc.
Thoughts?

Zoli
