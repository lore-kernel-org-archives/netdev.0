From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC] virtio_net: multicast address list never sent to host
Date: Fri, 06 Dec 2013 09:38:35 -0500
Message-ID: <52A1E16B.8050507@redhat.com>
References: <20131205152052.064319c9@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Alex Williamson <alex.williamson@hp.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38473 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab3LFPWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 10:22:48 -0500
In-Reply-To: <20131205152052.064319c9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/2013 06:20 PM, Stephen Hemminger wrote:
> 
> The virtio_net driver never sends the second address list to
> the host. This is because send command takes a pointer to scatter list
> to send but only inserts that one entry into the scatter list that
> is sent to the host.
> 
> This bug has been there since:
> commit f565a7c259d71cc186753653d978c646d2354b36
> Author: Alex Williamson <alex.williamson@hp.com>
> Date:   Wed Feb 4 09:02:45 2009 +0000
> 
>     virtio_net: Add a MAC filter table
> 
> 
> I also dropped the in argument since it is never used.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> 
> --- a/drivers/net/virtio_net.c	2013-12-05 15:11:34.000000000 -0800
> +++ b/drivers/net/virtio_net.c	2013-12-05 15:17:16.211568831 -0800
> @@ -877,16 +877,16 @@ static netdev_tx_t start_xmit(struct sk_
>   * never fail unless improperly formated.
>   */
>  static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> -				 struct scatterlist *out,
> -				 struct scatterlist *in)
> +				 struct scatterlist *out, unsigned out_cnt)
>  {
>  	struct scatterlist *sgs[4], hdr, stat;
>  	struct virtio_net_ctrl_hdr ctrl;
>  	virtio_net_ctrl_ack status = ~0;
> -	unsigned out_num = 0, in_num = 0, tmp;
> +	unsigned out_num = 0, tmp;
>  
>  	/* Caller should know better */
>  	BUG_ON(!virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ));
> +	BUG_ON(out_cnt > 2);
>  

Not sure if we need this. Right now we only pass 2, but if some
future command needs more, this is yet another place that needs
to change.

>  	ctrl.class = class;
>  	ctrl.cmd = cmd;
> @@ -894,17 +894,14 @@ static bool virtnet_send_command(struct
>  	sg_init_one(&hdr, &ctrl, sizeof(ctrl));
>  	sgs[out_num++] = &hdr;
>  
> -	if (out)
> -		sgs[out_num++] = out;
> -	if (in)
> -		sgs[out_num + in_num++] = in;
> +	while (out_cnt-- > 0)
> +		sgs[out_num++] = out++;

I think we can skip sg_count and just use
        while ((sg = sg_next(out)) != NULL)
                sgs[out_num++] = sg;

And we can probably do this loop for both 'in' and 'out' pointers.

-vlad

>  
>  	/* Add return status. */
>  	sg_init_one(&stat, &status, sizeof(status));
> -	sgs[out_num + in_num++] = &stat;
> +	sgs[out_num] = &stat;
>  
> -	BUG_ON(out_num + in_num > ARRAY_SIZE(sgs));
> -	BUG_ON(virtqueue_add_sgs(vi->cvq, sgs, out_num, in_num, vi, GFP_ATOMIC)
> +	BUG_ON(virtqueue_add_sgs(vi->cvq, sgs, out_num, 1, vi, GFP_ATOMIC)
>  	       < 0);
>  
>  	if (unlikely(!virtqueue_kick(vi->cvq)))
> @@ -936,7 +933,7 @@ static int virtnet_set_mac_address(struc
>  		sg_init_one(&sg, addr->sa_data, dev->addr_len);
>  		if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
>  					  VIRTIO_NET_CTRL_MAC_ADDR_SET,
> -					  &sg, NULL)) {
> +					  &sg, 1)) {
>  			dev_warn(&vdev->dev,
>  				 "Failed to set mac address by vq command.\n");
>  			return -EINVAL;
> @@ -1009,7 +1006,7 @@ static void virtnet_ack_link_announce(st
>  {
>  	rtnl_lock();
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
> -				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL, NULL))
> +				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL, 0))
>  		dev_warn(&vi->dev->dev, "Failed to ack link announce.\n");
>  	rtnl_unlock();
>  }
> @@ -1027,7 +1024,7 @@ static int virtnet_set_queues(struct vir
>  	sg_init_one(&sg, &s, sizeof(s));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MQ,
> -				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg, NULL)) {
> +				  VIRTIO_NET_CTRL_MQ_VQ_PAIRS_SET, &sg, 1)) {
>  		dev_warn(&dev->dev, "Fail to set num of queue pairs to %d\n",
>  			 queue_pairs);
>  		return -EINVAL;
> @@ -1078,7 +1075,7 @@ static void virtnet_set_rx_mode(struct n
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
>  				  VIRTIO_NET_CTRL_RX_PROMISC,
> -				  sg, NULL))
> +				  sg, 1))
>  		dev_warn(&dev->dev, "Failed to %sable promisc mode.\n",
>  			 promisc ? "en" : "dis");
>  
> @@ -1086,7 +1083,7 @@ static void virtnet_set_rx_mode(struct n
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_RX,
>  				  VIRTIO_NET_CTRL_RX_ALLMULTI,
> -				  sg, NULL))
> +				  sg, 1))
>  		dev_warn(&dev->dev, "Failed to %sable allmulti mode.\n",
>  			 allmulti ? "en" : "dis");
>  
> @@ -1123,7 +1120,7 @@ static void virtnet_set_rx_mode(struct n
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC,
>  				  VIRTIO_NET_CTRL_MAC_TABLE_SET,
> -				  sg, NULL))
> +				  sg, 2))
>  		dev_warn(&dev->dev, "Failed to set MAC filter table.\n");
>  
>  	kfree(buf);
> @@ -1138,7 +1135,7 @@ static int virtnet_vlan_rx_add_vid(struc
>  	sg_init_one(&sg, &vid, sizeof(vid));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> -				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, NULL))
> +				  VIRTIO_NET_CTRL_VLAN_ADD, &sg, 1))
>  		dev_warn(&dev->dev, "Failed to add VLAN ID %d.\n", vid);
>  	return 0;
>  }
> @@ -1152,7 +1149,7 @@ static int virtnet_vlan_rx_kill_vid(stru
>  	sg_init_one(&sg, &vid, sizeof(vid));
>  
>  	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_VLAN,
> -				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, NULL))
> +				  VIRTIO_NET_CTRL_VLAN_DEL, &sg, 1))
>  		dev_warn(&dev->dev, "Failed to kill VLAN ID %d.\n", vid);
>  	return 0;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
