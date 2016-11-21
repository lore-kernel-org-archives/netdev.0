From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] udp: avoid one cache line miss in recvmsg()
Date: Mon, 21 Nov 2016 22:36:48 +0100
Message-ID: <1479764208.5596.0.camel@redhat.com>
References: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46012 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752977AbcKUVgu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 16:36:50 -0500
In-Reply-To: <1479518283.8455.312.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-18 at 17:18 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> UDP_SKB_CB(skb)->partial_cov is located at offset 66 in skb,
> requesting a cold cache line being read in cpu cache.
> 
> We can avoid this cache line miss for UDP sockets,
> as partial_cov has a meaning only for UDPLite.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/udp.c |    3 ++-
>  net/ipv6/udp.c |    3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index e1fc0116e8d59d8185670c6e55d1219bde55610d..b949770fdc08398a10f3974505a50b2b4f4b2cf3 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1389,7 +1389,8 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
>  	 * coverage checksum (UDP-Lite), do it before the copy.
>  	 */
>  
> -	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
> +	if (copied < ulen || peeking ||
> +	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
>  		checksum_valid = !udp_lib_checksum_complete(skb);
>  		if (!checksum_valid)
>  			goto csum_copy_err;
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 4f99417d9b401f2a65c7828e7d6b86d1d6161794..8fd4d89380b86c8630f7fd27ce4e9958497a2b89 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -363,7 +363,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
>  	 * coverage checksum (UDP-Lite), do it before the copy.
>  	 */
>  
> -	if (copied < ulen || UDP_SKB_CB(skb)->partial_cov || peeking) {
> +	if (copied < ulen || peeking ||
> +	    (is_udplite && UDP_SKB_CB(skb)->partial_cov)) {
>  		checksum_valid = !udp_lib_checksum_complete(skb);
>  		if (!checksum_valid)
>  			goto csum_copy_err;
> 
> 

Nice catch, thank you Eric!

This gives up to 8% speed-up in my performance test (wire speed udp flood
with small packets)

Tested-by: Paolo Abeni <pabeni@redhat.com>
