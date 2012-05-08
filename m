From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 2/2] macvtap: restore vlan header on user read
Date: Tue, 8 May 2012 22:28:06 +0300
Message-ID: <20120508192806.GB28536@redhat.com>
References: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Basil Gor <basil.gor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8776 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263Ab2EHT2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 15:28:05 -0400
Content-Disposition: inline
In-Reply-To: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 04, 2012 at 12:55:24PM +0400, Basil Gor wrote:
> Ethernet vlan header is not on the packet and kept in the skb->vlan_tci
> when it comes from lower dev. This patch inserts vlan header in user
> buffer during skb copy on user read.
> 
> Signed-off-by: Basil Gor <basil.gor@gmail.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

Eric, ack?

> ---
>  drivers/net/macvtap.c |   43 ++++++++++++++++++++++++++++++++++++++-----
>  1 files changed, 38 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 0427c65..cb8fd50 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -1,5 +1,6 @@
>  #include <linux/etherdevice.h>
>  #include <linux/if_macvlan.h>
> +#include <linux/if_vlan.h>
>  #include <linux/interrupt.h>
>  #include <linux/nsproxy.h>
>  #include <linux/compat.h>
> @@ -759,6 +760,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  	struct macvlan_dev *vlan;
>  	int ret;
>  	int vnet_hdr_len = 0;
> +	int vlan_offset = 0;
> +	int copied;
>  
>  	if (q->flags & IFF_VNET_HDR) {
>  		struct virtio_net_hdr vnet_hdr;
> @@ -773,18 +776,48 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
>  			return -EFAULT;
>  	}
> +	copied = vnet_hdr_len;
> +
> +	if (!vlan_tx_tag_present(skb))
> +		len = min_t(int, skb->len, len);
> +	else {
> +		int copy;
> +		struct {
> +			__be16 h_vlan_proto;
> +			__be16 h_vlan_TCI;
> +		} veth;
> +		veth.h_vlan_proto = htons(ETH_P_8021Q);
> +		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
> +
> +		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
> +		len = min_t(int, skb->len + VLAN_HLEN, len);
> +
> +		copy = min_t(int, vlan_offset, len);
> +		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
> +		len -= copy;
> +		copied += copy;
> +		if (ret || !len)
> +			goto done;
> +
> +		copy = min_t(int, sizeof(veth), len);
> +		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
> +		len -= copy;
> +		copied += copy;
> +		if (ret || !len)
> +			goto done;
> +	}
>  
> -	len = min_t(int, skb->len, len);
> -
> -	ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len, len);
> +	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
> +	copied += len;
>  
> +done:
>  	rcu_read_lock_bh();
>  	vlan = rcu_dereference_bh(q->vlan);
>  	if (vlan)
> -		macvlan_count_rx(vlan, len, ret == 0, 0);
> +		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
>  	rcu_read_unlock_bh();
>  
> -	return ret ? ret : (len + vnet_hdr_len);
> +	return ret ? ret : copied;
>  }
>  
>  static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
> -- 
> 1.7.6.5
