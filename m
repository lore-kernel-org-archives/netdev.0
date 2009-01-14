From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 4/4] virtio_net: Add a MAC filter table
Date: Wed, 14 Jan 2009 10:15:12 +0000
Message-ID: <1231928112.4944.292.camel@localhost.localdomain>
References: <1231881800.9095.189.camel@bling>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm <kvm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231881800.9095.189.camel@bling>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-01-13 at 14:23 -0700, Alex Williamson wrote:
> Number of entries configurable via module param.

Could do with some more details here, like explaining that it means the
we no longer run the NIC in promiscuous mode and the guest only receives
packets destined for it.

> Signed-off-by: Alex Williamson <alex.williamson@hp.com
> ---
> 
>  drivers/net/virtio_net.c   |   71 +++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/virtio_net.h |    4 ++
>  2 files changed, 73 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b18dd4c..1f021c4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -32,6 +32,11 @@ static int csum = 1, gso = 1;
>  module_param(csum, bool, 0444);
>  module_param(gso, bool, 0444);
>  
> +static unsigned int mac_entries = 16;
> +module_param(mac_entries, uint, 0444);
> +MODULE_PARM_DESC(mac_entries,
> +	"Number of entries in the MAC filter table.");

Not sure it needs to be configurable? No harm, I guess.

>  /* FIXME: MTU in config. */
>  #define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
>  #define GOOD_COPY_LEN	128
> @@ -669,9 +674,61 @@ static void virtnet_set_rx_mode(struct net_device *dev)
>  	struct virtnet_info *vi = netdev_priv(dev);
>  	u8 promisc, allmulti;
>  
> -	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
> -	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
> +	promisc = ((dev->flags & IFF_PROMISC) != 0);
> +	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
> +
> +	if (dev->uc_count > mac_entries) {
> +		promisc = 1;
> +		if (dev->mc_count > mac_entries)
> +			allmulti = 1;
> +	} else if (dev->uc_count + dev->mc_count > mac_entries)
> +		allmulti = 1;
> +
> +	if (!promisc && (dev->uc_count || (dev->mc_count && !allmulti))) {
> +		u8 *buf, *cur;
> +		int count, i;
> +		struct dev_addr_list *uc_ptr, *mc_ptr;
> +
> +		count = dev->uc_count + (allmulti ? 0 : dev->mc_count);
>  
> +		buf = kzalloc(count * ETH_ALEN, GFP_ATOMIC);
> +		if (!buf) {
> +			promisc = 1;
> +			goto set_status;

s/set_status/set_mode/ maybe

> +		}
> +
> +		cur = buf;
> +		uc_ptr = dev->uc_list;
> +		mc_ptr = dev->mc_list;
> +
> +		for (i = 0; i < dev->uc_count; i++) {
> +			memcpy(cur, uc_ptr->da_addr, ETH_ALEN);
> +			cur += ETH_ALEN;
> +			uc_ptr = uc_ptr->next;
> +		}
> +		if (!allmulti) {
> +			for (i = 0; i < dev->mc_count; i++) {
> +				memcpy(cur, mc_ptr->da_addr, ETH_ALEN);
> +				cur += ETH_ALEN;
> +				mc_ptr = mc_ptr->next;
> +			}
> +		}
> +		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
> +					 VIRTIO_NET_CTRL_MAC_TABLE_SET,
> +					 buf, count * ETH_ALEN)) {
> +			printk(KERN_WARNING "%s: failed to program MAC filter "
> +			       "table, running in promiscuous mode.\n",

Any way to re-jig that so the grepable text is all on one line?

> +			       dev->name);
> +			promisc = 1;
> +		}
> +		kfree(buf);
> +	} else {
> +		/* Set an empty MAC table - disabled */
> +		virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
> +				     VIRTIO_NET_CTRL_MAC_TABLE_SET, NULL, 0);
> +	}
> +
> +set_status:
>  	virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
>  			     VIRTIO_NET_CTRL_RX_MODE_PROMISC,
>  			     &promisc, sizeof(promisc));
> @@ -799,6 +856,16 @@ static int virtnet_probe(struct virtio_device *vdev)
>  	vi->cvq = vdev->config->find_vq(vdev, 2, NULL);
>  	if (IS_ERR(vi->cvq))
>  		vi->cvq = NULL;
> +	else {
> +		unsigned int entries;
> +
> +		entries = mac_entries = min(mac_entries,
> +					(unsigned int)(PAGE_SIZE / ETH_ALEN));
> +		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
> +					 VIRTIO_NET_CTRL_MAC_TABLE_ALLOC,
> +					 &entries, sizeof(entries)))
> +			mac_entries = 0;
> +	}

Should have a warning here.

Also, no need for the extra variable or the case, is there?

>  	/* Initialize our empty receive and send queues. */
>  	skb_queue_head_init(&vi->recv);
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 80cd7d3..31235a0 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -60,4 +60,8 @@ struct virtio_net_hdr_mrg_rxbuf {
>   #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
>   #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
>  
> +#define VIRTIO_NET_CTRL_MAC_TABLE  1
> + #define VIRTIO_NET_CTRL_MAC_TABLE_ALLOC      0
> + #define VIRTIO_NET_CTRL_MAC_TABLE_SET        1

I'd prefer:

#define VIRTIO_NET_CMD_ALLOC_MAC_TABLE 1
#define VIRTIO_NET_CMD_SET_MAC_TABLE   2

Also, could do with some comments here to note e.g.:

  - alloc before set
  - subsequent allocs will fail
  - table limited to PAGE_SIZE (hmm, who's PAGE_SIZE?)
  - format of the table

Cheers,
Mark.

