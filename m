From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 1/2] net: af_packet support for direct ring access
 in user space
Date: Tue, 13 Jan 2015 16:12:34 +0100
Message-ID: <54B535E2.7040600@redhat.com>
References: <20150113043509.29985.33515.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.zhou@intel.com,
	nhorman@tuxdriver.com, john.ronciak@intel.com,
	hannes@stressinduktion.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbbAMPNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 10:13:20 -0500
In-Reply-To: <20150113043509.29985.33515.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2015 05:35 AM, John Fastabend wrote:
...
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1190,6 +1240,35 @@ struct net_device_ops {
>   	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
>   							      u8 state);
>   #endif
> +	int			(*ndo_split_queue_pairs)(struct net_device *dev,
> +					 unsigned int qpairs_start_from,
> +					 unsigned int qpairs_num,
> +					 struct sock *sk);
...
> +	int			(*ndo_get_dma_region_info)
> +					(struct net_device *dev,
> +					 struct tpacket_dma_mem_region *region,
> +					 struct sock *sk);
>   };

Any slight chance these 8 ndo ops could be further reduced? ;)

>   /**
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index da2d668..eb7a727 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
...
> +struct tpacket_dev_qpair_map_region_info {
> +	unsigned int tp_dev_bar_sz;		/* size of BAR */
> +	unsigned int tp_dev_sysm_sz;		/* size of systerm memory */
> +	/* number of contiguous memory on BAR mapping to user space */
> +	unsigned int tp_num_map_regions;
> +	/* number of contiguous memory on system mapping to user apce */
> +	unsigned int tp_num_sysm_map_regions;
> +	struct map_page_region {
> +		unsigned page_offset;	/* offset to start of region */
> +		unsigned page_sz;	/* size of page */
> +		unsigned page_cnt;	/* number of pages */

Please use unsigned int et al, or preferably __u* variants consistently
in the uapi structs.

> +	} tp_regions[MAX_MAP_MEMORY_REGIONS];
> +};
...
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 6880f34..8cd17da 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
...
> @@ -2633,6 +2636,16 @@ static int packet_release(struct socket *sock)
>   	sock_prot_inuse_add(net, sk->sk_prot, -1);
>   	preempt_enable();
>
> +	if (po->tp_owns_queue_pairs) {
> +		struct net_device *dev;
> +
> +		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
> +		if (dev) {
> +			dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
> +			umem_release(dev, po);
> +		}
> +	}
> +
...
> +static int
>   packet_setsockopt(struct socket *sock, int level, int optname, char __user *optval, unsigned int optlen)
>   {
>   	struct sock *sk = sock->sk;
> @@ -3428,6 +3525,167 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>   		po->xmit = val ? packet_direct_xmit : dev_queue_xmit;
>   		return 0;
>   	}
> +	case PACKET_RXTX_QPAIRS_SPLIT:
> +	{
...
> +		/* This call only works after a bind call which calls a dev_hold
> +		 * operation so we do not need to increment dev ref counter
> +		 */
> +		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
> +		if (!dev)
> +			return -EINVAL;
> +		ops = dev->netdev_ops;
> +		if (!ops->ndo_split_queue_pairs)
> +			return -EOPNOTSUPP;
> +
> +		err =  ops->ndo_split_queue_pairs(dev,
> +						  qpairs.tp_qpairs_start_from,
> +						  qpairs.tp_qpairs_num, sk);
> +		if (!err)
> +			po->tp_owns_queue_pairs = true;

When this is being set here, above test in packet_release() and the chunk
quoted below in packet_mmap() are not guaranteed to work since we don't
test if some ndos are actually implemented by the driver. Seems a bit
fragile, I'm wondering if we should test this capability as a _whole_,
iow if all necessary functions to make this work are being provided by the
driver, e.g. flag the netdev as such and test for that instead.

> +		return err;
> +	}
> +	case PACKET_RXTX_QPAIRS_RETURN:
> +	{
...
> +		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
> +		if (!dev)
> +			return -EINVAL;
> +		ops = dev->netdev_ops;
> +		if (!ops->ndo_split_queue_pairs)
> +			return -EOPNOTSUPP;

Should test for ndo_return_queue_pairs.

> +		err =  dev->netdev_ops->ndo_return_queue_pairs(dev, sk);
> +		if (!err)
> +			po->tp_owns_queue_pairs = false;
> +
...
> +	case PACKET_RXTX_QPAIRS_SPLIT:
> +	{
...
> +		/* This call only work after a bind call which calls a dev_hold
> +		 * operation so we do not need to increment dev ref counter
> +		 */
> +		dev = __dev_get_by_index(sock_net(sk), po->ifindex);
> +		if (!dev)
> +			return -EINVAL;
> +		if (!dev->netdev_ops->ndo_split_queue_pairs)
> +			return -EOPNOTSUPP;

Copy-paste (although not quite, since here's no extra ops var). :)
Should be ndo_get_split_queue_pairs.

> +		err =  dev->netdev_ops->ndo_get_split_queue_pairs(dev,
> +					&qpairs_info.tp_qpairs_start_from,
> +					&qpairs_info.tp_qpairs_num, sk);
> +
...
> @@ -3927,8 +4309,20 @@ static int packet_mmap(struct file *file, struct socket *sock,
>   	if (vma->vm_pgoff)
>   		return -EINVAL;
>
> +	dev = __dev_get_by_index(sock_net(sk), po->ifindex);
> +	if (!dev)
> +		return -EINVAL;
> +
>   	mutex_lock(&po->pg_vec_lock);
>
> +	if (po->tp_owns_queue_pairs) {
> +		ops = dev->netdev_ops;
> +		err = ops->ndo_direct_qpair_page_map(vma, dev);
> +		if (err)
> +			goto out;
> +		goto done;
> +	}
> +
