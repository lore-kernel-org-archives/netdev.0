From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [V2 RFC net-next PATCH 1/2] virtio_net: convert the statistics
	into array
Date: Wed, 06 Jun 2012 10:22:19 +0200
Message-ID: <1338970939.2760.3887.camel@edumazet-glaptop>
References: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120606075208.29081.75284.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

On Wed, 2012-06-06 at 15:52 +0800, Jason Wang wrote:
> Currently, we store the statistics in the independent fields of virtnet_stats,
> this is not scalable when we want to add more counters. As suggested by Michael,
> this patch convert it to an array and use the enum as the index to access them.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c |   30 +++++++++++++++++-------------
>  1 files changed, 17 insertions(+), 13 deletions(-)
> 

>  struct virtnet_stats {
>  	struct u64_stats_sync syncp;
> -	u64 tx_bytes;
> -	u64 tx_packets;
> -
> -	u64 rx_bytes;
> -	u64 rx_packets;
> +	u64 data[VIRTNET_NUM_STATS];
>  };
>  

Interesting, but I fear you'll have a lot of problems.

Current code is buggy, and you are adding more possible races.

We could have one cpu doing the :

       u64_stats_update_begin(&stats->syncp);
       stats->rx_bytes += skb->len;
       stats->rx_packets++;
       u64_stats_update_end(&stats->syncp);

And another one doing :

       u64_stats_update_begin(&stats->syncp);
       stats->tx_bytes += skb->len;
       stats->tx_packets++;
       u64_stats_update_end(&stats->syncp);
 
And one syncp sequence increment can be lost, since both cpus are
basically doing this at the same time :

    write_seqcount_begin(&syncp->seq);

I'll send a fix in a separate thread.
