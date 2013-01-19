From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 1/3] ipv4: Invalidate the socket cached route on pmtu
 events if possible
Date: Sat, 19 Jan 2013 02:54:04 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1301190031080.1803@ja.ssi.bg>
References: <50D1BCC0.2000208@oktetlabs.ru> <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com> <50D1CECE.7090706@oktetlabs.ru> <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com> <20121220073445.GM18940@secunet.com> <50D2F4E5.4050904@oktetlabs.ru>
 <20121220123535.GN18940@secunet.com> <20121221102253.GO18940@secunet.com> <50F3C153.9030204@oktetlabs.ru> <20130118081145.GB24987@secunet.com> <20130118081419.GC24987@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:43617 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab3ASAu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 19:50:57 -0500
In-Reply-To: <20130118081419.GC24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 18 Jan 2013, Steffen Klassert wrote:

> The route lookup in ipv4_sk_update_pmtu() might return a route
> different from the route we cached at the socket. This is because
> standart routes are per cpu, so each cpu has it's own struct rtable.
> This means that we do not invalidate the socket cached route if the
> NET_RX_SOFTIRQ is not served by the same cpu that the sending socket
> uses. As a result, the cached route reused until we disconnect.
> 
> With this patch we invalidate the socket cached route if possible.
> If the socket is owened by the user, we can't update the cached
> route directly. A followup patch will implement socket release
> callback functions for datagram sockets to handle this case.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/route.c |   40 +++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 39 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 259cbee..e59541b 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -965,7 +965,7 @@ void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
>  }
>  EXPORT_SYMBOL_GPL(ipv4_update_pmtu);
>  
> -void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
> +static void __ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  {
>  	const struct iphdr *iph = (const struct iphdr *) skb->data;
>  	struct flowi4 fl4;
> @@ -978,6 +978,44 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  		ip_rt_put(rt);
>  	}
>  }
> +
> +void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
> +{
> +	const struct iphdr *iph = (const struct iphdr *) skb->data;
> +	struct flowi4 fl4;
> +	struct rtable *rt = (struct rtable *) __sk_dst_get(sk);

	I guess __sk_dst_get should be called after
bh_lock_sock ?

> +	struct dst_entry *dst;
> +
> +	bh_lock_sock(sk);
> +	if (sock_owned_by_user(sk) || !rt) {
> +		__ipv4_sk_update_pmtu(skb, sk, mtu);
> +		goto out;
> +	}

Regards

--
Julian Anastasov <ja@ssi.bg>
