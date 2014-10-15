From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 3/3] virtio-net: conditionally enable tx
	interrupt
Date: Wed, 15 Oct 2014 11:34:35 +0800
Message-ID: <543DEB4B.1010505@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<1413011806-3813-4-git-send-email-jasowang@redhat.com>
	<20141014215146.GB23344@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-api@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141014215146.GB23344@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/15/2014 05:51 AM, Michael S. Tsirkin wrote:
> On Sat, Oct 11, 2014 at 03:16:46PM +0800, Jason Wang wrote:
>> > We free transmitted packets in ndo_start_xmit() in the past to get better
>> > performance in the past. One side effect is that skb_orphan() needs to be
>> > called in ndo_start_xmit() which makes sk_wmem_alloc not accurate in
>> > fact. For TCP protocol, this means several optimization could not work well
>> > such as TCP small queue and auto corking. This can lead extra low
>> > throughput of small packets stream.
>> > 
>> > Thanks to the urgent descriptor support. This patch tries to solve this
>> > issue by enable the tx interrupt selectively for stream packets. This means
>> > we don't need to orphan TCP stream packets in ndo_start_xmit() but enable
>> > tx interrupt for those packets. After we get tx interrupt, a tx napi was
>> > scheduled to free those packets.
>> > 
>> > With this method, sk_wmem_alloc of TCP socket were more accurate than in
>> > the past which let TCP can batch more through TSQ and auto corking.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---
>> >  drivers/net/virtio_net.c | 164 ++++++++++++++++++++++++++++++++++++-----------
>> >  1 file changed, 128 insertions(+), 36 deletions(-)
>> > 
>> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> > index 5810841..b450fc4 100644
>> > --- a/drivers/net/virtio_net.c
>> > +++ b/drivers/net/virtio_net.c
>> > @@ -72,6 +72,8 @@ struct send_queue {
>> >  
>> >  	/* Name of the send queue: output.$index */
>> >  	char name[40];
>> > +
>> > +	struct napi_struct napi;
>> >  };
>> >  
>> >  /* Internal representation of a receive virtqueue */
>> > @@ -217,15 +219,40 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
>> >  	return p;
>> >  }
>> >  
>> > +static int free_old_xmit_skbs(struct send_queue *sq, int budget)
>> > +{
>> > +	struct sk_buff *skb;
>> > +	unsigned int len;
>> > +	struct virtnet_info *vi = sq->vq->vdev->priv;
>> > +	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
>> > +	int sent = 0;
>> > +
>> > +	while (sent < budget &&
>> > +	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
>> > +		pr_debug("Sent skb %p\n", skb);
>> > +
>> > +		u64_stats_update_begin(&stats->tx_syncp);
>> > +		stats->tx_bytes += skb->len;
>> > +		stats->tx_packets++;
>> > +		u64_stats_update_end(&stats->tx_syncp);
>> > +
>> > +		dev_kfree_skb_any(skb);
>> > +		sent++;
>> > +	}
>> > +
>> > +	return sent;
>> > +}
>> > +
>> >  static void skb_xmit_done(struct virtqueue *vq)
>> >  {
>> >  	struct virtnet_info *vi = vq->vdev->priv;
>> > +	struct send_queue *sq = &vi->sq[vq2txq(vq)];
>> >  
>> > -	/* Suppress further interrupts. */
>> > -	virtqueue_disable_cb(vq);
>> > -
>> > -	/* We were probably waiting for more output buffers. */
>> > -	netif_wake_subqueue(vi->dev, vq2txq(vq));
>> > +	if (napi_schedule_prep(&sq->napi)) {
>> > +		virtqueue_disable_cb(vq);
>> > +		virtqueue_disable_cb_urgent(vq);
> This disable_cb is no longer safe in xmit_done callback,
> since queue can be running at the same time.
>
> You must do it under tx lock. And yes, this likely will not work
> work well without event_idx. We'll probably need extra
> synchronization for such old hosts.
>
>
>

Yes, and the virtqueue_enable_cb_prepare() in virtnet_poll_tx() needs to
be synced with virtqueue_enabled_cb_dealyed(). Otherwise an old idx will
be published and we may still see tx interrupt storm.
