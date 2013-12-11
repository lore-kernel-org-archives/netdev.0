From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net V3 2/2] macvtap: signal truncated packets
Date: Wed, 11 Dec 2013 09:25:08 -0500
Message-ID: <52A875C4.5040900@gmail.com>
References: <1386738514-1502-1-git-send-email-jasowang@redhat.com> <1386738514-1502-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386738514-1502-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/11/2013 12:08 AM, Jason Wang wrote:
> macvtap_put_user() never return a value grater than iov length, this in fact
> bypasses the truncated checking in macvtap_recvmsg(). Fix this by always
> returning the size of packet plus the possible vlan header to let the trunca
> checking work.
> 
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
> ---
> Changes from V2:
> - use total as the bytes of packet returned
> Changes from V1:
> - increase total unconditionally
> - do not move the structure veth out of the vlan handling block
> ---
>  drivers/net/macvtap.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 957cc5c..2a89da0 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -770,7 +770,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  	int ret;
>  	int vnet_hdr_len = 0;
>  	int vlan_offset = 0;
> -	int copied;
> +	int copied, total;
>  
>  	if (q->flags & IFF_VNET_HDR) {
>  		struct virtio_net_hdr vnet_hdr;
> @@ -785,7 +785,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
>  			return -EFAULT;
>  	}
> -	copied = vnet_hdr_len;
> +	total = copied = vnet_hdr_len;
> +	total += skb->len;
>  
>  	if (!vlan_tx_tag_present(skb))
>  		len = min_t(int, skb->len, len);
> @@ -800,6 +801,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  
>  		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
>  		len = min_t(int, skb->len + VLAN_HLEN, len);
> +		total += VLAN_HLEN;
>  
>  		copy = min_t(int, vlan_offset, len);
>  		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
> @@ -817,10 +819,9 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  	}
>  
>  	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
> -	copied += len;
>  
>  done:
> -	return ret ? ret : copied;
> +	return ret ? ret : total;
>  }
>  
>  static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
> @@ -875,7 +876,7 @@ static ssize_t macvtap_aio_read(struct kiocb *iocb, const struct iovec *iv,
>  	}
>  
>  	ret = macvtap_do_read(q, iocb, iv, len, file->f_flags & O_NONBLOCK);
> -	ret = min_t(ssize_t, ret, len); /* XXX copied from tun.c. Why? */
> +	ret = min_t(ssize_t, ret, len);
>  	if (ret > 0)
>  		iocb->ki_pos = ret;
>  out:
> 
