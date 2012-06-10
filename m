From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Sun, 10 Jun 2012 13:25:12 +0300
Message-ID: <20120610102512.GB6793@redhat.com>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1338971724.2760.3913.camel@edumazet-glaptop>
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

On Wed, Jun 06, 2012 at 10:35:24AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> commit 3fa2a1df909 (virtio-net: per cpu 64 bit stats (v2)) added a race
> on 32bit arches.
> 
> We must use separate syncp for rx and tx path as they can be run at the
> same time on different cpus. Thus one sequence increment can be lost and
> readers spin forever.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>

I'm still thinking about moving tx to take a xmit lock long term,
meanwhile this fix appears appropriate for 3.5.

Acked-by: Michael S. Tsirkin <mst@redhat.com>

Dave, can you pick this up pls?

> ---
>  drivers/net/virtio_net.c |   19 ++++++++++++-------
>  1 file changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 5214b1e..f18149a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -42,7 +42,8 @@ module_param(gso, bool, 0444);
>  #define VIRTNET_DRIVER_VERSION "1.0.0"
>  
>  struct virtnet_stats {
> -	struct u64_stats_sync syncp;
> +	struct u64_stats_sync tx_syncp;
> +	struct u64_stats_sync rx_syncp;
>  	u64 tx_bytes;
>  	u64 tx_packets;
>  
> @@ -300,10 +301,10 @@ static void receive_buf(struct net_device *dev, void *buf, unsigned int len)
>  
>  	hdr = skb_vnet_hdr(skb);
>  
> -	u64_stats_update_begin(&stats->syncp);
> +	u64_stats_update_begin(&stats->rx_syncp);
>  	stats->rx_bytes += skb->len;
>  	stats->rx_packets++;
> -	u64_stats_update_end(&stats->syncp);
> +	u64_stats_update_end(&stats->rx_syncp);
>  
>  	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
>  		pr_debug("Needs csum!\n");
> @@ -565,10 +566,10 @@ static unsigned int free_old_xmit_skbs(struct virtnet_info *vi)
>  	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
>  		pr_debug("Sent skb %p\n", skb);
>  
> -		u64_stats_update_begin(&stats->syncp);
> +		u64_stats_update_begin(&stats->tx_syncp);
>  		stats->tx_bytes += skb->len;
>  		stats->tx_packets++;
> -		u64_stats_update_end(&stats->syncp);
> +		u64_stats_update_end(&stats->tx_syncp);
>  
>  		tot_sgs += skb_vnet_hdr(skb)->num_sg;
>  		dev_kfree_skb_any(skb);
> @@ -703,12 +704,16 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
>  		u64 tpackets, tbytes, rpackets, rbytes;
>  
>  		do {
> -			start = u64_stats_fetch_begin(&stats->syncp);
> +			start = u64_stats_fetch_begin(&stats->tx_syncp);
>  			tpackets = stats->tx_packets;
>  			tbytes   = stats->tx_bytes;
> +		} while (u64_stats_fetch_retry(&stats->tx_syncp, start));
> +
> +		do {
> +			start = u64_stats_fetch_begin(&stats->rx_syncp);
>  			rpackets = stats->rx_packets;
>  			rbytes   = stats->rx_bytes;
> -		} while (u64_stats_fetch_retry(&stats->syncp, start));
> +		} while (u64_stats_fetch_retry(&stats->rx_syncp, start));
>  
>  		tot->rx_packets += rpackets;
>  		tot->tx_packets += tpackets;
> 
