From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/3] ipv6: Select fragment id during UFO segmentation
	if not set.
Date: Sat, 31 Jan 2015 19:11:21 +0200
Message-ID: <20150131171121.GB31871@redhat.com>
References: <1422646047-13168-1-git-send-email-vyasevic@redhat.com>
	<1422646047-13168-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	hannes@stressinduktion.org, ben@decadent.org.uk
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1422646047-13168-2-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2015 at 02:27:25PM -0500, Vladislav Yasevich wrote:
> If the IPv6 fragment id has not been set and we perform
> fragmentation due to UFO, select a new fragment id.
> We now consider a fragment id of 0 as unset and if id selection
> process returns 0 (after all the pertrubations), we set it to
> 0x80000000, thus giving us ample space not to create collisions
> with the next packet we may have to fragment.
> 
> When doing UFO integrity checking, we also select the
> fragment id if it has not be set yet.   This is stored into

s/be/been/

> the skb_shinfo() thus allowing UFO to function correclty.
> 
> This patch also removes duplicate fragment id generation code
> and moves ipv6_select_ident() into the header as it may be
> used during GSO.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  include/net/ipv6.h     |  3 +++
>  net/ipv6/ip6_output.c  | 10 ++++------
>  net/ipv6/output_core.c | 28 ++++++++++++++++++++++------
>  net/ipv6/udp_offload.c | 10 +++++++++-
>  4 files changed, 38 insertions(+), 13 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 4292929..9bf85d3 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -671,6 +671,9 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
>  	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
>  }
>  
> +u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst,
> +			struct in6_addr *src);
> +void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt);
>  void ipv6_proxy_select_ident(struct sk_buff *skb);
>  
>  int ip6_dst_hoplimit(struct dst_entry *dst);
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index ce69a12..5dc91fe 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -537,17 +537,15 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
>  	skb_copy_secmark(to, from);
>  }
>  
> -static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
> +void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
>  {
>  	static u32 ip6_idents_hashrnd __read_mostly;
> -	u32 hash, id;
> +	u32 id;
>  
>  	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
>  
> -	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
> -	hash = __ipv6_addr_jhash(&rt->rt6i_src.addr, hash);
> -
> -	id = ip_idents_reserve(hash, 1);
> +	id = __ipv6_select_ident(ip6_idents_hashrnd, &rt->rt6i_dst.addr,
> +				 &rt->rt6i_src.addr);
>  	fhdr->identification = htonl(id);
>  }
>  
> diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
> index 97f41a3..ceb857d 100644
> --- a/net/ipv6/output_core.c
> +++ b/net/ipv6/output_core.c
> @@ -9,6 +9,24 @@
>  #include <net/addrconf.h>
>  #include <net/secure_seq.h>
>  
> +u32 __ipv6_select_ident(u32 hashrnd, struct in6_addr *dst, struct in6_addr *src)
> +{
> +	u32 hash, id;
> +
> +	hash = __ipv6_addr_jhash(dst, hashrnd);
> +	hash = __ipv6_addr_jhash(src, hash);
> +
> +	/* Treat id of 0 as unset and if we get 0 back from ip_idents_reserve,
> +	 * set the hight order instead thus minimizing possible future
> +	 * collisions.      
> +	*/
> +	id = ip_idents_reserve(hash, 1);
> +	if (unlikely(!id))
> +		id = 1 << 31;
> +
> +	return id;
> +}
> +
>  /* This function exists only for tap drivers that must support broken
>   * clients requesting UFO without specifying an IPv6 fragment ID.
>   *
> @@ -22,7 +40,7 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
>  	static u32 ip6_proxy_idents_hashrnd __read_mostly;
>  	struct in6_addr buf[2];
>  	struct in6_addr *addrs;
> -	u32 hash, id;
> +	u32 id;
>  
>  	addrs = skb_header_pointer(skb,
>  				   skb_network_offset(skb) +
> @@ -34,11 +52,9 @@ void ipv6_proxy_select_ident(struct sk_buff *skb)
>  	net_get_random_once(&ip6_proxy_idents_hashrnd,
>  			    sizeof(ip6_proxy_idents_hashrnd));
>  
> -	hash = __ipv6_addr_jhash(&addrs[1], ip6_proxy_idents_hashrnd);
> -	hash = __ipv6_addr_jhash(&addrs[0], hash);
> -
> -	id = ip_idents_reserve(hash, 1);
> -	skb_shinfo(skb)->ip6_frag_id = htonl(id);
> +	id = __ipv6_select_ident(ip6_proxy_idents_hashrnd,
> +				 &addrs[1], &addrs[0]);
> +	skb_shinfo(skb)->ip6_frag_id = id;
>  }
>  EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
>  
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index b6aa8ed..a562769 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -52,6 +52,10 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>  
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>  
> +		/* Set the IPv6 fragment id if not set yet */
> +		if (!skb_shinfo(skb)->ip6_frag_id)
> +			ipv6_proxy_select_ident(skb);
> +
>  		segs = NULL;
>  		goto out;
>  	}
> @@ -108,7 +112,11 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>  		fptr = (struct frag_hdr *)(skb_network_header(skb) + unfrag_ip6hlen);
>  		fptr->nexthdr = nexthdr;
>  		fptr->reserved = 0;
> -		fptr->identification = skb_shinfo(skb)->ip6_frag_id;
> +		if (skb_shinfo(skb)->ip6_frag_id)
> +			fptr->identification = skb_shinfo(skb)->ip6_frag_id;
> +		else
> +			ipv6_select_ident(fptr,
> +					  (struct rt6_info *)skb_dst(skb));
>  
>  		/* Fragment the skb. ipv6 header and the remaining fields of the
>  		 * fragment header are updated in ipv6_gso_segment()
> -- 
> 1.9.3
