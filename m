From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH resend] virtio-net: Remove more stack DMA
Date: Tue, 19 Jul 2016 02:03:13 +0300
Message-ID: <20160719015549-mutt-send-email-mst@redhat.com>
References: <c2ebc30cc66aeccba56f6c49527c8a9fa04332cf.1468881101.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, x86@kernel.org,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <c2ebc30cc66aeccba56f6c49527c8a9fa04332cf.1468881101.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 03:34:49PM -0700, Andy Lutomirski wrote:
> VLAN and MQ control was doing DMA from the stack.  Fix it.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
> Signed-off-by: Andy Lutomirski <luto@kernel.org>

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
> 
> I tested VLAN addition and removal with CONFIG_VMAP_STACK=y,
> CONFIG_DEBUG_SG=y and it got rid of the warnings I saw.  I haven't
> tested the MQ part because I don't know how to enable it in the first
> place (I'm guessing it needs me to enable some QEMU feature I don't
> know about.)
> 
> DaveM, contrary to what I thought last time I sent this, I think this
> should go through net-next as long as it makes it in time for 4.8.
> 
>  drivers/net/virtio_net.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index e0638e556fe7..5044ca37d725 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -144,8 +144,10 @@ struct virtnet_info {
>  	/* Control VQ buffers: protected by the rtnl lock */
>  	struct virtio_net_ctrl_hdr ctrl_hdr;
>  	virtio_net_ctrl_ack ctrl_status;
> +	struct virtio_net_ctrl_mq ctrl_mq;
>  	u8 ctrl_promisc;
>  	u8 ctrl_allmulti;
> +	u16 ctrl_vid;
>  
>  	/* Ethtool settings */
>  	u8 duplex;
> @@ -1116,14 +1118,13 @@ static void virtnet_ack_link_announce(struct virtnet_info *vi)
>  static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
>  {
>  	struct scatterlist sg;
> -	struct virtio_net_ctrl_mq s;
>  	struct net_device *dev = vi->dev;
>  
>  	if (!vi->has_cvq || !virtio_has_feature(vi->vdev, VIRTIO_NET_F_MQ))
>  		return 0;
>  
> -	s.virtqueue_pairs = cpu_to_virtio16(vi->vdev, queue_pairs);
> -	sg_init_one(&sg, &s, sizeof(s));
> +	vi->ctrl_mq.virtqueue_pairs = cpu_to_virtio16(vi->vdev, queue_pairs);
> +	sg_init_one(&sg, &vi->ctrl_mq, sizeof(vi->ctrl_mq));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MQ,
>  				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg)) {
> @@ -1230,7 +1231,8 @@ static int virtnet_vlan_rx_add_vid(struct net_device *dev,
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct scatterlist sg;
>  
> -	sg_init_one(&sg, &vid, sizeof(vid));
> +	vi->ctrl_vid = vid;
> +	sg_init_one(&sg, &vi->ctrl_vid, sizeof(vi->ctrl_vid));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
>  				  VIRTIO_NET_CTRL_VLAN_ADD, &sg))
> @@ -1244,7 +1246,8 @@ static int virtnet_vlan_rx_kill_vid(struct net_device *dev,
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct scatterlist sg;
>  
> -	sg_init_one(&sg, &vid, sizeof(vid));
> +	vi->ctrl_vid = vid;
> +	sg_init_one(&sg, &vi->ctrl_vid, sizeof(vi->ctrl_vid));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
>  				  VIRTIO_NET_CTRL_VLAN_DEL, &sg))
> -- 
> 2.7.4
