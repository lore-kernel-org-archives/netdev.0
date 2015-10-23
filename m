From: Helge Deller <deller@gmx.de>
Subject: Re: CONFIG_XPS depends on L1_CACHE_BYTES being greater than
 sizeof(struct xps_map)
Date: Fri, 23 Oct 2015 23:09:42 +0200
Message-ID: <562AA216.5030107@gmx.de>
References: <32A3BF6F-B243-4AD4-9AE9-A5F9DAE0270A@bell.net>
 <B8E85737-5ECD-4CBE-8730-886B098C5FA4@bell.net>
 <trinity-eda7d55d-7234-4b29-a15c-955f8ba0c95e-1445513884942@3capp-gmx-bs32>
 <trinity-8980ad10-b889-45cf-8f37-a33ba9cf99ef-1445514797080@3capp-gmx-bs32>
 <1445524549.2207.1.camel@HansenPartnership.com> <5628F868.3040105@bell.net>
 <5629404B.8090805@gmx.de>
 <1445550615.22974.128.camel@edumazet-glaptop2.roam.corp.google.com>
 <562A8990.9000808@gmx.de>
 <1445630588.22974.187.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151023210810.GA1969@ls3530.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-parisc@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	John David Anglin <dave.anglin@bell.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20151023210810.GA1969@ls3530.box>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23.10.2015 23:08, Helge Deller wrote:
> * Eric Dumazet <eric.dumazet@gmail.com>:
>> On Fri, 2015-10-23 at 21:25 +0200, Helge Deller wrote:
>>
>>> Then, how about simply changing it to twice of L1_CACHE_BYTES ?
>>>
>>> #define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES * 2 - sizeof(struct xps_map)) / sizeof(u16))
>>
>>
>> Seems good to me.
> 
> Great!
> 
> Can you then maybe give me an Acked-by or signed-off for the patch below?
> It further adds a compile-time check to avoid that XPS_MIN_MAP_ALLOC
> gets calculated to zero on any architecture - otherwise no queues would
> be allocated. 
> 
> In addition I would like to push it for v4.3 then through my parisc-tree
> (after keeping it in for-next for 1-2 days), together with the patch
> which reduces L1_CACHE_BYTES to 16 on parisc.
> Would that be OK too? 
> 
> Thanks!
> Helge
> 
> 
> [PATCH] net/xps: Increase initial number of xps queues
> 
> Increase the number of initial allocated xps queues, so that the initial record
> allocates twice the size of L1_CACHE_BYTES bytes.
> 
> This change is needed to copy with architectures where L1_CACHE_BYTES is

s/copy/cope/g


> defined to equal or less than 16 bytes.
> 
> Signed-off-by: Helge Deller <deller@gmx.de>
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 2d15e38..d152788 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -718,7 +718,7 @@ struct xps_map {
>  	u16 queues[0];
>  };
>  #define XPS_MAP_SIZE(_num) (sizeof(struct xps_map) + ((_num) * sizeof(u16)))
> -#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES - sizeof(struct xps_map))	\
> +#define XPS_MIN_MAP_ALLOC ((L1_CACHE_BYTES * 2 - sizeof(struct xps_map)) \
>      / sizeof(u16))
>  
>  /*
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6bb6470..f6d6dd1 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1972,6 +1972,8 @@ static struct xps_map *expand_xps_map(struct xps_map *map,
>  	int alloc_len = XPS_MIN_MAP_ALLOC;
>  	int i, pos;
>  
> +	BUILD_BUG_ON(XPS_MIN_MAP_ALLOC == 0);
> +
>  	for (pos = 0; map && pos < map->len; pos++) {
>  		if (map->queues[pos] != index)
>  			continue;
> 

