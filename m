From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc v7 3/3] virtio-net: change the number of queues
	through ethtool
Date: Sun, 2 Dec 2012 18:09:06 +0200
Message-ID: <20121202160906.GB27761@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
	<1354011360-39479-4-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1354011360-39479-4-git-send-email-jasowang@redhat.com>
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

On Tue, Nov 27, 2012 at 06:16:00PM +0800, Jason Wang wrote:
> This patch implement the {set|get}_channels method of ethool to allow user to
> change the number of queues dymaically when the device is running. This would
> let the user to configure it on demand.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/virtio_net.c |   41 +++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 41 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index bcaa6e5..f08ec2a 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1578,10 +1578,51 @@ static struct virtio_driver virtio_net_driver = {
>  #endif
>  };
>  
> +/* TODO: Eliminate OOO packets during switching */
> +static int virtnet_set_channels(struct net_device *dev,
> +				struct ethtool_channels *channels)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +	u16 queue_pairs = channels->combined_count;
> +
> +	/* We don't support separate rx/tx channels.
> +	 * We don't allow setting 'other' channels.
> +	 */
> +	if (channels->rx_count || channels->tx_count || channels->other_count)
> +		return -EINVAL;
> +
> +	/* Only two modes were support currently */
> +	if (queue_pairs != vi->max_queue_pairs && queue_pairs != 1)
> +		return -EINVAL;
> +

Why the limitation?
Also how does userspace discover what the legal values are?

> +	vi->curr_queue_pairs = queue_pairs;
> +	BUG_ON(virtnet_set_queues(vi));
> +
> +	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
> +	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
> +
> +	return 0;
> +}
> +
> +static void virtnet_get_channels(struct net_device *dev,
> +				 struct ethtool_channels *channels)
> +{
> +	struct virtnet_info *vi = netdev_priv(dev);
> +
> +	channels->combined_count = vi->curr_queue_pairs;
> +	channels->max_combined = vi->max_queue_pairs;
> +	channels->max_other = 0;
> +	channels->rx_count = 0;
> +	channels->tx_count = 0;
> +	channels->other_count = 0;
> +}
> +
>  static const struct ethtool_ops virtnet_ethtool_ops = {
>  	.get_drvinfo = virtnet_get_drvinfo,
>  	.get_link = ethtool_op_get_link,
>  	.get_ringparam = virtnet_get_ringparam,
> +	.set_channels = virtnet_set_channels,
> +	.get_channels = virtnet_get_channels,
>  };
>  
>  static int __init init(void)
> -- 
> 1.7.1
