From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 3/5] tun: drop broken IFF_VNET_LE
Date: Wed, 17 Dec 2014 03:23:23 +0008
Message-ID: <1418786123.6058.1@smtp.corp.redhat.com>
References: <1418732988-3535-1-git-send-email-mst@redhat.com>
	<1418732988-3535-4-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>, Xi Wang <xii@google.com>,
	Masatake YAMATO <yamato@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108AbaLQDQB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 22:16:01 -0500
In-Reply-To: <1418732988-3535-4-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Dec 16, 2014 at 9:05 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> Use TUNSETVNETLE/TUNGETVNETLE instead.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/tun.c | 26 +++++++++++++++++++++++---
>  1 file changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index c052bd6b..e3e8a0e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -109,9 +109,11 @@ do {								\
>   * overload it to mean fasync when stored there.
>   */
>  #define TUN_FASYNC	IFF_ATTACH_QUEUE
> +/* High bits in flags field are unused. */
> +#define TUN_VNET_LE     0x80000000
>  
>  #define TUN_FEATURES (IFF_NO_PI | IFF_ONE_QUEUE | IFF_VNET_HDR | \
> -		      IFF_VNET_LE | IFF_MULTI_QUEUE)
> +		      IFF_MULTI_QUEUE)
>  #define GOODCOPY_LEN 128
>  
>  #define FLT_EXACT_COUNT 8
> @@ -207,12 +209,12 @@ struct tun_struct {
>  
>  static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 
> val)
>  {
> -	return __virtio16_to_cpu(tun->flags & IFF_VNET_LE, val);
> +	return __virtio16_to_cpu(tun->flags & TUN_VNET_LE, val);
>  }
>  
>  static inline __virtio16 cpu_to_tun16(struct tun_struct *tun, u16 
> val)
>  {
> -	return __cpu_to_virtio16(tun->flags & IFF_VNET_LE, val);
> +	return __cpu_to_virtio16(tun->flags & TUN_VNET_LE, val);
>  }
>  
>  static inline u32 tun_hashfn(u32 rxhash)
> @@ -1853,6 +1855,7 @@ static long __tun_chr_ioctl(struct file *file, 
> unsigned int cmd,
>  	int sndbuf;
>  	int vnet_hdr_sz;
>  	unsigned int ifindex;
> +	int le;
>  	int ret;
>  
>  	if (cmd == TUNSETIFF || cmd == TUNSETQUEUE || _IOC_TYPE(cmd) == 
> 0x89) {
> @@ -2052,6 +2055,23 @@ static long __tun_chr_ioctl(struct file *file, 
> unsigned int cmd,
>  		tun->vnet_hdr_sz = vnet_hdr_sz;
>  		break;
>  
> +	case TUNGETVNETLE:
> +		le = !!(tun->flags & TUN_VNET_LE);
> +		if (put_user(le, (int __user *)argp))
> +			ret = -EFAULT;
> +		break;
> +
> +	case TUNSETVNETLE:
> +		if (get_user(le, (int __user *)argp)) {
> +			ret = -EFAULT;
> +			break;
> +		}
> +		if (le)
> +			tun->flags |= TUN_VNET_LE;
> +		else
> +			tun->flags &= ~TUN_VNET_LE;
> +		break;
> +

A little bit different from persistent devices:

- TUNSETPERSIST check argp instead
- Userspace may check persist flags through TUNGETIFF

Probably this patch may needs more modifications on userspace.
> 
>  	case TUNATTACHFILTER:
>  		/* Can be set only for TAPs */
>  		ret = -EINVAL;
> -- 
> MST
> 
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
