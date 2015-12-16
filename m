From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] hv_netvsc: Use simple parser for IPv4 and v6
 headers
Date: Wed, 16 Dec 2015 09:08:08 -0800
Message-ID: <1450285688.8474.86.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
 davem@davemloft.net
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1450289022-9958-1-git-send-email-haiyangz@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-16 at 10:03 -0800, Haiyang Zhang wrote:
> To avoid performance overhead when using skb_flow_dissect_flow_keys(),
> we switch to the simple parsers to get the IP and port numbers.
> 
> Performance comparison: throughput (Gbps):
> Number of connections, before patch, after patch
> 1			8.56		10.18
> 4			11.17		14.07
> 16			12.21		21.78
> 64			18.71		32.08
> 256			15.92		26.32
> 1024			8.41		15.49
> 3000			7.82		11.58
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Tested-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |   38 +++++++++++++++++++++++++++++---------
>  1 files changed, 29 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 1c8db9a..e28951f 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -237,20 +237,40 @@ static u32 comp_hash(u8 *key, int klen, void *data, int dlen)
>  
>  static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
>  {
> -	struct flow_keys flow;
> +	struct iphdr *iphdr;
> +	struct ipv6hdr *ipv6hdr;
> +	__be32 dbuf[9];
>  	int data_len;
>  
> -	if (!skb_flow_dissect_flow_keys(skb, &flow, 0) ||
> -	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
> -	      flow.basic.n_proto == htons(ETH_P_IPV6)))
> +	if (eth_hdr(skb)->h_proto != htons(ETH_P_IP) &&
> +	    eth_hdr(skb)->h_proto != htons(ETH_P_IPV6))
>  		return false;
>  
> -	if (flow.basic.ip_proto == IPPROTO_TCP)
> -		data_len = 12;
> -	else
> -		data_len = 8;
> +	iphdr = ip_hdr(skb);
> +	ipv6hdr = ipv6_hdr(skb);
> +
> +	if (iphdr->version == 4) {
> +		dbuf[0] = iphdr->saddr;
> +		dbuf[1] = iphdr->daddr;
> +		if (iphdr->protocol == IPPROTO_TCP) {
> +			dbuf[2] = *(__be32 *)&tcp_hdr(skb)->source;
> +			data_len = 12;
> +		} else {
> +			data_len = 8;
> +		}
> +	} else if (ipv6hdr->version == 6) {
> +		memcpy(dbuf, &ipv6hdr->saddr, 32);
> +		if (ipv6hdr->nexthdr == IPPROTO_TCP) {
> +			dbuf[8] = *(__be32 *)&tcp_hdr(skb)->source;
> +			data_len = 36;
> +		} else {
> +			data_len = 32;
> +		}
> +	} else {
> +		return false;
> +	}
>  
> -	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, &flow, data_len);
> +	*hash = comp_hash(netvsc_hash_key, HASH_KEYLEN, dbuf, data_len);
>  
>  	return true;
>  }


This looks very very wrong to me.

How many times this is called per second, for the 'one flow' case ?

Don't you use TSO in this driver ?

What about encapsulation ?

I suspect you have a quite different issue here.

You simply could use skb_get_hash() since local TCP flows will provide a
l4 skb->hash and you have no further flow dissection to do.
