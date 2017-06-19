From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net] net: account for current skb length when deciding
 about UFO
Date: Mon, 19 Jun 2017 10:59:16 -0400
Message-ID: <9547a50c-2b2c-1772-2944-098b21eefa40@redhat.com>
References: <20170619110343.7CB5EA1377@unicorn.suse.cz>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Zheng Li <james.z.li@ericsson.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Michal Kubecek <mkubecek@suse.cz>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619110343.7CB5EA1377@unicorn.suse.cz>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/19/2017 07:03 AM, Michal Kubecek wrote:
> Our customer encountered stuck NFS writes for blocks starting at specific
> offsets w.r.t. page boundary caused by networking stack sending packets via
> UFO enabled device with wrong checksum. The problem can be reproduced by
> composing a long UDP datagram from multiple parts using MSG_MORE flag:
> 
>   sendto(sd, buff, 1000, MSG_MORE, ...);
>   sendto(sd, buff, 1000, MSG_MORE, ...);
>   sendto(sd, buff, 3000, 0, ...);
> 
> Assume this packet is to be routed via a device with MTU 1500 and
> NETIF_F_UFO enabled. When second sendto() gets into __ip_append_data(),
> this condition is tested (among others) to decide whether to call
> ip_ufo_append_data():
> 
>   ((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))
> 
> At the moment, we already have skb with 1028 bytes of data which is not
> marked for GSO so that the test is false (fragheaderlen is usually 20).
> Thus we append second 1000 bytes to this skb without invoking UFO. Third
> sendto(), however, has sufficient length to trigger the UFO path so that we
> end up with non-UFO skb followed by a UFO one. Later on, udp_send_skb()
> uses udp_csum() to calculate the checksum but that assumes all fragments
> have correct checksum in skb->csum which is not true for UFO fragments.
> 
> When checking against MTU, we need to add skb->len to length of new segment
> if we already have a partially filled skb and fragheaderlen only if there
> isn't one.
> 
> In the IPv6 case, skb can only be null if this is the first segment so that
> we have to use headersize (length of the first IPv6 header) rather than
> fragheaderlen (length of IPv6 header of further fragments) for skb == NULL.
> 
> Fixes: e89e9cf539a2 ("[IPv4/IPv6]: UFO Scatter-gather approach")
> Fixes: e4c5e13aa45c ("ipv6: Should use consistent conditional judgement for
> 	ip6 fragment between __ip6_append_data and ip6_finish_output")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

LGTM.

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/ipv4/ip_output.c  | 3 ++-
>  net/ipv6/ip6_output.c | 2 +-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 7a3fd25e8913..532b36e9ce2a 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -964,7 +964,8 @@ static int __ip_append_data(struct sock *sk,
>  		csummode = CHECKSUM_PARTIAL;
>  
>  	cork->length += length;
> -	if ((((length + fragheaderlen) > mtu) || (skb && skb_is_gso(skb))) &&
> +	if ((((length + (skb ? skb->len : fragheaderlen)) > mtu) ||
> +	     (skb && skb_is_gso(skb))) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
>  	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
>  	    (sk->sk_type == SOCK_DGRAM) && !sk->sk_no_check_tx) {
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index bf8a58a1c32d..1699acb2fa2c 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1390,7 +1390,7 @@ static int __ip6_append_data(struct sock *sk,
>  	 */
>  
>  	cork->length += length;
> -	if ((((length + fragheaderlen) > mtu) ||
> +	if ((((length + (skb ? skb->len : headersize)) > mtu) ||
>  	     (skb && skb_is_gso(skb))) &&
>  	    (sk->sk_protocol == IPPROTO_UDP) &&
>  	    (rt->dst.dev->features & NETIF_F_UFO) && !dst_xfrm(&rt->dst) &&
> 
