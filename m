From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/2][RFC] virtio_net: Add MAC fitler table support
Date: Fri, 09 Jan 2009 11:34:12 +0000
Message-ID: <1231500852.4481.72.camel@localhost.localdomain>
References: <1231351563.7109.130.camel@lappy>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37390 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbZAILeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 06:34:19 -0500
In-Reply-To: <1231351563.7109.130.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-07 at 11:06 -0700, Alex Williamson wrote:
> virtio_net: Add MAC fitler table support
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> ---
> 
>  drivers/net/virtio_net.c   |   52 +++++++++++++++++++++++++++++++++++++++++---
>  include/linux/virtio_net.h |    6 ++++-
>  2 files changed, 54 insertions(+), 4 deletions(-)
> 
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index f502edd..d751711 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -505,6 +505,8 @@ static void virtnet_set_rx_mode(struct net_device *dev)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	struct virtio_device *vdev = vi->vdev;
>  	u16 status = vi->status.raw;
> +	struct dev_addr_list *uc_ptr, *mc_ptr;
> +	int i;
>  
>  	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
>  		return;
> @@ -519,11 +521,55 @@ static void virtnet_set_rx_mode(struct net_device *dev)
>  	else
>  		status &= ~VIRTIO_NET_S_ALLMULTI;
>  		
> -	if (dev->uc_count)
> +	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_MAC_TABLE)) {
> +		if (dev->uc_count)
> +			status |= VIRTIO_NET_S_PROMISC;
> +		if (dev->mc_count)
> +			status |= VIRTIO_NET_S_ALLMULTI;

Maybe a goto set_status here?

> +		if (status != vi->status.raw) {
> +			vi->status.raw = status;
> +			vdev->config->set(vdev,
> +					  offsetof(struct virtio_net_config,
> +					  status), &vi->status,
> +					  sizeof(vi->status));
> +		}
> +		return;
> +	}
> +
> +	if (dev->uc_count > 16) {
>  		status |= VIRTIO_NET_S_PROMISC;
> -	if (dev->mc_count)
> +		if (dev->mc_count > 16)
> +			status |= VIRTIO_NET_S_ALLMULTI;
> +	} else if (dev->uc_count + dev->mc_count > 16)
>  		status |= VIRTIO_NET_S_ALLMULTI;
>  
> +	if ((dev->uc_count && !(status & VIRTIO_NET_S_PROMISC)) ||
> +	    (dev->mc_count && !(status & VIRTIO_NET_S_ALLMULTI)))
> +		status |= VIRTIO_NET_S_MAC_TABLE;
> +	else
> +		status &= ~VIRTIO_NET_S_MAC_TABLE;
> +
> +	uc_ptr = dev->uc_list;
> +	mc_ptr = dev->mc_list;
> +
> +	for (i = 0; i < 16; i++) {
> +		uint8_t entry[8] = { 0 };
> +
> +		if (uc_ptr && !(status & VIRTIO_NET_S_PROMISC)) {
> +			memcpy(entry, uc_ptr->da_addr, 6);

Use ETH_ALEN.

> +			entry[7] = 1;
> +			uc_ptr = uc_ptr->next;
> +		} else if (mc_ptr && !(status & VIRTIO_NET_S_ALLMULTI)) {
> +			memcpy(entry, mc_ptr->da_addr, 6);
> +			entry[7] = 1;
> +			mc_ptr = mc_ptr->next;
> +		}
> +
> +		vdev->config->set(vdev, offsetof(struct virtio_net_config,
> +				  mac_table) + (sizeof(entry) * i),
> +				  &entry, sizeof(entry));
> +	}
> +
>  	if (status != vi->status.raw) {
>  		vi->status.raw = status;
>  		vdev->config->set(vdev, offsetof(struct virtio_net_config,
> @@ -744,7 +790,7 @@ static unsigned int features[] = {
>  	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
>  	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
>  	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
> -	VIRTIO_NET_F_STATUS,
> +	VIRTIO_NET_F_STATUS, VIRTIO_NET_F_MAC_TABLE,
>  	VIRTIO_F_NOTIFY_ON_EMPTY,
>  };
>  
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 5a70edb..905319b 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -21,10 +21,12 @@
>  #define VIRTIO_NET_F_HOST_ECN	13	/* Host can handle TSO[6] w/ ECN in. */
>  #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
>  #define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
> +#define VIRTIO_NET_F_MAC_TABLE	17	/* Additional MAC addresses */
>  
>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
>  #define VIRTIO_NET_S_PROMISC	2	/* Promiscuous mode */
>  #define VIRTIO_NET_S_ALLMULTI	4	/* All-multicast mode */
> +#define VIRTIO_NET_S_MAC_TABLE	8	/* Enable MAC filter table */
>  
>  struct virtio_net_config
>  {
> @@ -38,8 +40,10 @@ struct virtio_net_config
>  			__u16 link:1;
>  			__u16 promisc:1;
>  			__u16 allmulti:1;
> +			__u16 mac_table:1;
>  		} bits;
> -       } status;
> +	} status;
> +	__u64 mac_table[16];

You're using two bytes per entry to indicate the flag is valid. Why not
an array of 6 byte entries with a count of how many entries are valid?

That would also keep the virtio-net I/O space under 128 bytes.

Cheers,
Mark.

