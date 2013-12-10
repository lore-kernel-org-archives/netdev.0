From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2 1/2] tun: unbreak truncated packet signalling
Date: Tue, 10 Dec 2013 17:32:56 +0200
Message-ID: <20131210153256.GF25293@redhat.com>
References: <1386654586-18151-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386654586-18151-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 10, 2013 at 01:49:45PM +0800, Jason Wang wrote:
> Commit 6680ec68eff47d36f67b4351bc9836fd6cba9532
> (tuntap: hardware vlan tx support) breaks the truncated packet signal by nev
> return a length greater than iov length in tun_put_user(). This patch fixes
> by always return the length of packet plus possible vlan header. Caller can
> detect the truncated packet by comparing the return value and the size of io
> length.
> 
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from v1:
> - increase total unconditionally
> - do not move veth structure out of the vlan handing block
> ---
>  drivers/net/tun.c | 16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e26cbea..cd142134 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1184,7 +1184,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  {
>  	struct tun_pi pi = { 0, skb->protocol };
>  	ssize_t total = 0;
> -	int vlan_offset = 0;
> +	int vlan_offset = 0, offset;
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if ((len -= sizeof(pi)) < 0)
> @@ -1248,6 +1248,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  		total += tun->vnet_hdr_sz;
>  	}
>  
> +	offset = total;
> +	total += skb->len;
>  	if (!vlan_tx_tag_present(skb)) {
>  		len = min_t(int, skb->len, len);
>  	} else {
> @@ -1262,24 +1264,24 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  
>  		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
>  		len = min_t(int, skb->len + VLAN_HLEN, len);
> +		total += VLAN_HLEN;
>  
>  		copy = min_t(int, vlan_offset, len);
> -		ret = skb_copy_datagram_const_iovec(skb, 0, iv, total, copy);
> +		ret = skb_copy_datagram_const_iovec(skb, 0, iv, offset, copy);
>  		len -= copy;
> -		total += copy;
> +		offset += copy;
>  		if (ret || !len)
>  			goto done;
>  
>  		copy = min_t(int, sizeof(veth), len);
> -		ret = memcpy_toiovecend(iv, (void *)&veth, total, copy);
> +		ret = memcpy_toiovecend(iv, (void *)&veth, offset, copy);
>  		len -= copy;
> -		total += copy;
> +		offset += copy;
>  		if (ret || !len)
>  			goto done;
>  	}
>  
> -	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
> -	total += len;
> +	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, offset, len);
>  
>  done:
>  	tun->dev->stats.tx_packets++;

offset is not descriptive. I would call new variable "copied",
and change all code to use that, do
total = copied + skb->len, total is then the total length.

> -- 
> 1.8.3.2
