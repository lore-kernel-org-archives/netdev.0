From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V3] virtio-net: validate features during probe
Date: Thu, 20 Nov 2014 09:02:44 +0200
Message-ID: <20141120070244.GE30994@redhat.com>
References: <1416463835-7364-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1416463835-7364-1-git-send-email-jasowang@redhat.com>
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

On Thu, Nov 20, 2014 at 02:10:35PM +0800, Jason Wang wrote:
> We currently trigger BUG when VIRTIO_NET_F_CTRL_VQ
> is not set but one of features depending on it is.
> That's not a friendly way to report errors to
> hypervisors.
> Let's check, and fail probe instead.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>


Looks good, minor nits below:

> ---
> Changes from V2:
> - only check the features for ctrl vq (this fix the real bug)
> - better error message and simplify API
> ---
>  drivers/net/virtio_net.c | 37 +++++++++++++++++++++++++++++++++++++
>  1 file changed, 37 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index ec2a8b4..a6bcfce 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1673,6 +1673,40 @@ static const struct attribute_group virtio_net_mrg_rx_group = {
>  };
>  #endif
>  
> +static bool virtnet_fail_on_feature(struct virtio_device *vdev,
> +				    unsigned int fbit,
> +				    const char *fname, const char *dname)
> +{
> +	if (!virtio_has_feature(vdev, fbit))
> +		return false;
> +
> +	dev_err(&vdev->dev, "Hypervisor bug: advertise feature %s but not %s",

Well we don't know it's a hypervisor. How about:
Device bug: advertises feature %s but not %s.

> +		fname, dname);
> +
> +	return true;
> +}
> +
> +#define VIRTNET_FAIL_ON(vdev, fbit, dbit)			\
> +	virtnet_fail_on_feature(vdev, fbit, #fbit, #dbit)

I would pass dbit directly, and supply a string from caller,
instead if #dbit, this way it can be any string.

> +
> +static bool virtnet_validate_features(struct virtio_device *vdev)
> +{
> +	if (!virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ) &&
> +	    (VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_RX,
> +			     VIRTIO_NET_F_CTRL_VQ) ||
> +	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_VLAN,
> +			     VIRTIO_NET_F_CTRL_VQ) ||
> +	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_GUEST_ANNOUNCE,
> +			     VIRTIO_NET_F_TRL_VQ) ||

Typo: VIRTIO_NET_F_CTRL_VQ.

> +	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_MQ, VIRTIO_NET_F_CTRL_VQ) ||
> +	     VIRTNET_FAIL_ON(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR,
> +			     VIRTIO_NET_F_CTRL_VQ))) {
> +		return false;
> +	}
> +
> +	return true;
> +}
> +
>  static int virtnet_probe(struct virtio_device *vdev)
>  {
>  	int i, err;
> @@ -1680,6 +1714,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	struct virtnet_info *vi;
>  	u16 max_queue_pairs;
>  
> +	if (!virtnet_validate_features(vdev))
> +		return -EINVAL;
> +
>  	/* Find if host supports multiqueue virtio_net device */
>  	err = virtio_cread_feature(vdev, VIRTIO_NET_F_MQ,
>  				   struct virtio_net_config,
> -- 
> 1.9.1
