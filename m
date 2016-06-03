From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 -next] virtio-net: Add initial MTU advice feature
Date: Fri, 3 Jun 2016 19:04:35 +0300
Message-ID: <20160603190155-mutt-send-email-mst@redhat.com>
References: <1464901859-25906-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Aaron Conole <aconole@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1464901859-25906-1-git-send-email-aconole@redhat.com>
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

On Thu, Jun 02, 2016 at 05:10:59PM -0400, Aaron Conole wrote:
> This commit adds the feature bit and associated mtu device entry for the
> virtio network device.  When a virtio device comes up, it checks the
> feature bit for the VIRTIO_NET_F_MTU feature.  If such feature bit is
> enabled, the driver will read the advised MTU and use it as the initial
> value.
> 
> Signed-off-by: Aaron Conole <aconole@redhat.com>
> ---
> v1->v2:
> * Fixed omitted hunk from virtio_net.h
> * Squashed to a single commit
> * Fixed commit message.
> 
>  drivers/net/virtio_net.c        | 7 +++++++
>  include/uapi/linux/virtio_net.h | 3 +++
>  2 files changed, 10 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index e0638e5..ef5ee01 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1896,6 +1896,12 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
>  		vi->has_cvq = true;
>  
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
> +		dev->mtu = virtio_cread16(vdev,
> +					  offsetof(struct virtio_net_config,
> +						   mtu));
> +	}
> +
>  	if (vi->any_header_sg)
>  		dev->needed_headroom = vi->hdr_len;
>  

One comment though: I think we should validate the mtu.
If it's invalid, clear VIRTIO_NET_F_MTU and ignore.

> @@ -2067,6 +2073,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
>  	VIRTIO_NET_F_CTRL_MAC_ADDR,
>  	VIRTIO_F_ANY_LAYOUT,
> +	VIRTIO_NET_F_MTU,
>  };
>  
>  static struct virtio_driver virtio_net_driver = {
> diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> index ec32293..1ab4ea6 100644
> --- a/include/uapi/linux/virtio_net.h
> +++ b/include/uapi/linux/virtio_net.h
> @@ -55,6 +55,7 @@
>  #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
>  					 * Steering */
>  #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> +#define VIRTIO_NET_F_MTU 25	/* Initial MTU advice */
>  
>  #ifndef VIRTIO_NET_NO_LEGACY
>  #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
> @@ -73,6 +74,8 @@ struct virtio_net_config {
>  	 * Legal values are between 1 and 0x8000
>  	 */
>  	__u16 max_virtqueue_pairs;
> +	/* Default maximum transmit unit advice */
> +	__u16 mtu;
>  } __attribute__((packed));
>  
>  /*
> -- 
> 2.5.5
