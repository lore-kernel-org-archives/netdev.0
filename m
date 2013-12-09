From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/2] tun: unbreak truncated packet signalling
Date: Mon, 9 Dec 2013 12:55:29 +0200
Message-ID: <20131209105529.GD15055@redhat.com>
References: <1386584717-5776-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315Ab3LIKvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Dec 2013 05:51:54 -0500
Content-Disposition: inline
In-Reply-To: <1386584717-5776-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 09, 2013 at 06:25:16PM +0800, Jason Wang wrote:
> Commit 6680ec68eff47d36f67b4351bc9836fd6cba9532
> (tuntap: hardware vlan tx support) breaks the truncated packet signal by never
> return a length greater than iov length in tun_put_user(). This patch fixes this
> by always return the length of packet plus possible vlan header. Caller can
> detect the truncated packet by comparing the return value and the size of iov
> length.
> 
> Reported-by: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Vlad Yasevich <vyasevich@gmail.com>
> Cc: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

So writer gets back a value greater than what was written?

> ---
> The patch is needed for stable.
> ---
>  drivers/net/tun.c | 23 ++++++++++++-----------
>  1 file changed, 12 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e26cbea..dd1bd7a 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1183,7 +1183,11 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  			    const struct iovec *iv, int len)
>  {
>  	struct tun_pi pi = { 0, skb->protocol };
> -	ssize_t total = 0;
> +	struct {
> +		__be16 h_vlan_proto;
> +		__be16 h_vlan_TCI;
> +	} veth;
> +	ssize_t total = 0, off = 0;

Why off = 0 here?
We initialize it to total unconditionally, don't we?

>  	int vlan_offset = 0;
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
> @@ -1248,14 +1252,11 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  		total += tun->vnet_hdr_sz;
>  	}
>  
> +	off = total;
>  	if (!vlan_tx_tag_present(skb)) {
>  		len = min_t(int, skb->len, len);
>  	} else {
>  		int copy, ret;
> -		struct {
> -			__be16 h_vlan_proto;
> -			__be16 h_vlan_TCI;
> -		} veth;
>  
>  		veth.h_vlan_proto = skb->vlan_proto;
>  		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
> @@ -1264,22 +1265,22 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  		len = min_t(int, skb->len + VLAN_HLEN, len);
>  
>  		copy = min_t(int, vlan_offset, len);
> -		ret = skb_copy_datagram_const_iovec(skb, 0, iv, total, copy);
> +		ret = skb_copy_datagram_const_iovec(skb, 0, iv, off, copy);
>  		len -= copy;
> -		total += copy;
> +		off += copy;
>  		if (ret || !len)
>  			goto done;
>  
>  		copy = min_t(int, sizeof(veth), len);
> -		ret = memcpy_toiovecend(iv, (void *)&veth, total, copy);
> +		ret = memcpy_toiovecend(iv, (void *)&veth, off, copy);
>  		len -= copy;
> -		total += copy;
> +		off += copy;
>  		if (ret || !len)
>  			goto done;

This seems wrong: if one of the branches above is taken, total is
never incremented.

>  	}
>  
> -	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
> -	total += len;
> +	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, off, len);
> +	total += skb->len + (vlan_offset ? sizeof(veth) : 0);
>  
>  done:
>  	tun->dev->stats.tx_packets++;

I also think it's inelegant that the veth struct is now in the
outside scope, and the extra ? is also ugly.

Here's a smaller patch to fix all these problems - what do you think?



Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 782e38b..3297e41 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1183,7 +1183,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 			    const struct iovec *iv, int len)
 {
 	struct tun_pi pi = { 0, skb->protocol };
-	ssize_t total = 0;
+	ssize_t total = 0, offset;
 	int vlan_offset = 0;
 
 	if (!(tun->flags & TUN_NO_PI)) {
@@ -1248,6 +1248,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += tun->vnet_hdr_sz;
 	}
 
+	offset = total;
+	total += skb->len;
 	if (!vlan_tx_tag_present(skb)) {
 		len = min_t(int, skb->len, len);
 	} else {
@@ -1257,6 +1259,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 			__be16 h_vlan_TCI;
 		} veth;
 
+		total += sizeof(veth);
+
 		veth.h_vlan_proto = skb->vlan_proto;
 		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
 
@@ -1279,7 +1283,6 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	}
 
 	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
-	total += len;
 
 done:
 	tun->dev->stats.tx_packets++;

> -- 
> 1.8.3.2
