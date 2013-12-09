From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 2/2] macvtap: signal truncated packets
Date: Mon, 9 Dec 2013 13:02:51 +0200
Message-ID: <20131209110251.GE15055@redhat.com>
References: <1386584717-5776-1-git-send-email-jasowang@redhat.com>
 <1386584717-5776-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386584717-5776-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 09, 2013 at 06:25:17PM +0800, Jason Wang wrote:
> macvtap_put_user() never return a value grater than iov length, this in fact
> bypasses the truncated checking in macvtap_recvmsg(). Fix this by always
> returning the size of packet plus the possible vlan header to let the truncated
> checking work.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Same comments as for tun really, but here it's also
kind of ugly to call a variable copied if we don't copy.

Also, maybe we should name the variable "copied" for tun,
this would make the code more similar.

> ---
> The patch is needed for stable.
> ---
>  drivers/net/macvtap.c | 27 ++++++++++++++-------------
>  1 file changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 957cc5c..7544a0c 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -767,10 +767,14 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  				const struct sk_buff *skb,
>  				const struct iovec *iv, int len)
>  {
> -	int ret;
> +	int ret, off;
>  	int vnet_hdr_len = 0;
>  	int vlan_offset = 0;
>  	int copied;
> +	struct {
> +		__be16 h_vlan_proto;
> +		__be16 h_vlan_TCI;
> +	} veth;
>  
>  	if (q->flags & IFF_VNET_HDR) {
>  		struct virtio_net_hdr vnet_hdr;
> @@ -785,16 +789,13 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
>  			return -EFAULT;
>  	}
> -	copied = vnet_hdr_len;
> +	off = copied = vnet_hdr_len;
>  
>  	if (!vlan_tx_tag_present(skb))
>  		len = min_t(int, skb->len, len);
>  	else {
>  		int copy;
> -		struct {
> -			__be16 h_vlan_proto;
> -			__be16 h_vlan_TCI;
> -		} veth;
> +
>  		veth.h_vlan_proto = skb->vlan_proto;
>  		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
>  
> @@ -802,22 +803,22 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  		len = min_t(int, skb->len + VLAN_HLEN, len);
>  
>  		copy = min_t(int, vlan_offset, len);
> -		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
> +		ret = skb_copy_datagram_const_iovec(skb, 0, iv, off, copy);
>  		len -= copy;
> -		copied += copy;
> +		off += copy;
>  		if (ret || !len)
>  			goto done;
>  
>  		copy = min_t(int, sizeof(veth), len);
> -		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
> +		ret = memcpy_toiovecend(iv, (void *)&veth, off, copy);
>  		len -= copy;
> -		copied += copy;
> +		off += copy;
>  		if (ret || !len)
>  			goto done;
>  	}
>  
> -	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
> -	copied += len;
> +	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, off, len);
> +	copied += skb->len + (vlan_offset ? sizeof(veth) : 0);
>  
>  done:
>  	return ret ? ret : copied;
> @@ -875,7 +876,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
>  	}
>  
>  	ret = macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
> -	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
> +	ret = min_t(ssize_t, ret, len);
>  	if (ret > 0)
>  		iocb->ki_pos = ret;
>  out:



> -- 
> 1.8.3.2
