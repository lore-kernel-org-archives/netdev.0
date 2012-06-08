From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 RFC net-next PATCH 2/2] virtio_net: export more statistics
	through ethtool
Date: Fri, 8 Jun 2012 10:02:37 +0300
Message-ID: <20120608070237.GA32532@redhat.com>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120606075217.29081.30713.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120607221911.GD16235@redhat.com> <4FD172FD.5070200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <4FD172FD.5070200@redhat.com>
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

On Fri, Jun 08, 2012 at 11:35:25AM +0800, Jason Wang wrote:
> >>>  @@ -655,7 +695,17 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>>    		kfree_skb(skb);
> >>>    		return NETDEV_TX_OK;
> >>>    	}
> >>>  -	virtqueue_kick(vi->svq);
> >>>  +
> >>>  +	kick = virtqueue_kick_prepare(vi->svq);
> >>>  +	if (unlikely(kick))
> >>>  +		virtqueue_notify(vi->svq);
> >>>  +
> >>>  +	u64_stats_update_begin(&stats->syncp);
> >>>  +	if (unlikely(kick))
> >>>  +		stats->data[VIRTNET_TX_KICKS]++;
> >>>  +	stats->data[VIRTNET_TX_Q_BYTES] += skb->len;
> >>>  +	stats->data[VIRTNET_TX_Q_PACKETS]++;
> >is this statistic interesting?
> >how about decrementing when we free?
> >this way we see how many are pending..
> >
> 
> Currently we didn't have per-vq statistics but per-cpu, so the skb
> could be sent by one vcpu and freed by another.
> Pehaps another reason to use per-queue satistics.

For transmit, it could be done easily as we both send and free skbs
under a lock. I'm not sure how acceptable it is to
take a lock in get_stats but send a separate patch like this
and we'll see what others say.

-- 
MST
