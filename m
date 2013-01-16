From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio-net: introduce a new control to set macaddr
Date: Wed, 16 Jan 2013 14:20:39 +0800
Message-ID: <8243136.frWZnRkUJV@jason-thinkpad-t430s>
References: <1358315821-29519-1-git-send-email-akong@redhat.com>
	<1358315821-29519-3-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, davem@davemloft.net
To: virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1358315821-29519-3-git-send-email-akong@redhat.com>
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

On Wednesday, January 16, 2013 01:57:01 PM akong@redhat.com wrote:
> From: Amos Kong <akong@redhat.com>
> 
> Currently we write MAC address to pci config space byte by byte,
> this means that we have an intermediate step where mac is wrong.
> This patch introduced a new control command to set MAC address
> in one time.
> 
> VIRTIO_NET_F_CTRL_MAC_ADDR is a new feature bit for compatibility.
> 
> Signed-off-by: Amos Kong <akong@redhat.com>
> ---
>  drivers/net/virtio_net.c        | 24 +++++++++++++++++-------
>  include/uapi/linux/virtio_net.h |  8 +++++++-
>  2 files changed, 24 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 395ab4f..c8901b6 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -802,16 +802,25 @@ static int virtnet_set_mac_address(struct net_device
> *dev, void *p) struct virtnet_info *vi = netdev_priv(dev);
>  	struct virtio_device *vdev = vi->vdev;
>  	int ret;
> +	struct sockaddr *addr = p;
> +	struct scatterlist sg;
> 
> -	ret = eth_mac_addr(dev, p);
> -	if (ret)
> -		return ret;
> -
> -	if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC))
> +	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
> +		sg_init_one(&sg, addr->sa_data, dev->addr_len);
> +		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
> +					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> +					  &sg, 1, 0)) {
> +			dev_warn(&vdev->dev,
> +				 "Failed to set mac address by vq command.\n");
> +			return -EINVAL;
> +		}
> +	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
>  		vdev->config->set(vdev, offsetof(struct virtio_net_config, mac),
> -		                  dev->dev_addr, dev->addr_len);
> +				  addr->sa_data, dev->addr_len);
> +	}
> +	ret = eth_mac_addr(dev, p);
> 

The you will the validity check in eth_mac_addr which may result a wrong mac 
address to be set in the hardware (or is there any check in qemu) and a 
inconsistency bettween what kernel assumes and qemu has.

You can take a look at netvsc driver that calls eth_mac_addr() first and 
restore the software mac address when fail to enforce it to hardware.

Thanks
> -	return 0;
> +	return ret;
>  }
> 
>  static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
> @@ -1627,6 +1636,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
>  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
> +	VIRTIO_NET_F_CTRL_MAC_ADDR,
>  };
> 
>  static struct virtio_driver virtio_net_driver = {
> diff --git a/include/uapi/linux/virtio_net.h
> b/include/uapi/linux/virtio_net.h index 848e358..a5a8c88 100644
> --- a/include/uapi/linux/virtio_net.h
> +++ b/include/uapi/linux/virtio_net.h
> @@ -53,6 +53,7 @@
>  					 * network */
>  #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
>  					 * Steering */
> +#define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> 
>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
>  #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
> @@ -127,7 +128,7 @@ typedef __u8 virtio_net_ctrl_ack;
>   #define VIRTIO_NET_CTRL_RX_NOBCAST      5
> 
>  /*
> - * Control the MAC filter table.
> + * Control the MAC
>   *
>   * The MAC filter table is managed by the hypervisor, the guest should
>   * assume the size is infinite.  Filtering should be considered
> @@ -140,6 +141,10 @@ typedef __u8 virtio_net_ctrl_ack;
>   * first sg list contains unicast addresses, the second is for multicast.
>   * This functionality is present if the VIRTIO_NET_F_CTRL_RX feature
>   * is available.
> + *
> + * The ADDR_SET command requests one out scatterlist, it contains a
> + * 6 bytes MAC address. This functionality is present if the
> + * VIRTIO_NET_F_CTRL_MAC_ADDR feature is available.
>   */
>  struct virtio_net_ctrl_mac {
>  	__u32 entries;
> @@ -148,6 +153,7 @@ struct virtio_net_ctrl_mac {
> 
>  #define VIRTIO_NET_CTRL_MAC    1
>   #define VIRTIO_NET_CTRL_MAC_TABLE_SET        0
> + #define VIRTIO_NET_CTRL_MAC_ADDR_SET         1
> 
>  /*
>   * Control VLAN filtering
