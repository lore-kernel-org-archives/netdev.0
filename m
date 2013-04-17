From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [Patch net-next v4 3/5] vxlan: add ipv6 support
Date: Wed, 17 Apr 2013 11:15:30 +0300
Message-ID: <CAF1J0HOYVCe-0MVE6-mxyjEOaEAWNR16Wpv7+CF6rxbEgBQ3GA@mail.gmail.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-4-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog106.obsmtp.com ([74.125.245.80]:47774 "HELO
	na3sys010aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965952Ab3DQIPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 04:15:32 -0400
Received: by mail-oa0-f70.google.com with SMTP id n9so8731620oag.1
        for <netdev@vger.kernel.org>; Wed, 17 Apr 2013 01:15:30 -0700 (PDT)
In-Reply-To: <1366175423-27310-4-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 01:10:20PM +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
>
> This patch adds IPv6 support to vxlan device, as the new version
> RFC already mentioned it:
>
>    http://tools.ietf.org/html/draft-mahalingam-dutt-dcops-vxlan-03
>
> Cc: David Stevens <dlstevens@us.ibm.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  drivers/net/vxlan.c          |  639 +++++++++++++++++++++++++++++++++---------
>  include/uapi/linux/if_link.h |    2 +
>  2 files changed, 505 insertions(+), 136 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index f8ac900..43ed40f 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -9,7 +9,6 @@
>   *
>   * TODO
>   *  - use IANA UDP port number (when defined)
> - *  - IPv6 (not in RFC)
>   */
>
>  #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> @@ -42,6 +41,11 @@
>  #include <net/inet_ecn.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
> +#if IS_ENABLED(CONFIG_IPV6)

It seems to me that some of the #ifdefs may be removed, especially on
the rtnetlink path.

> +#include <net/addrconf.h>
> +#include <net/ip6_route.h>
> +#include <net/ip6_tunnel.h>
> +#endif
>
>  #define VXLAN_VERSION	"0.1"
>

[ snip ]

> @@ -1342,6 +1603,25 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  			return -ERANGE;
>  	}
>
> +	if (data[IFLA_VXLAN_REMOTE]) {
> +		__be32 gaddr = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
> +		if (!IN_MULTICAST(ntohl(gaddr))) {
> +			pr_debug("group address is not IPv4 multicast\n");
> +			return -EADDRNOTAVAIL;
> +		}
> +	} else if (data[IFLA_VXLAN_REMOTE6]) {
> +#if IS_ENABLED(CONFIG_IPV6)
> +		struct in6_addr gaddr;
> +		nla_memcpy(&gaddr, data[IFLA_VXLAN_REMOTE6], sizeof(gaddr));
> +		if (!ipv6_addr_is_multicast(&gaddr)) {
> +			pr_debug("group address is not IPv6 multicast\n");
> +			return -EADDRNOTAVAIL;
> +		}
> +#else
> +		return -EPFNOSUPPORT;
> +#endif
> +	}

Adding back the test for multicast address contradicts the ability to
use unicast as default remote destination.

> +
>  	if (data[IFLA_VXLAN_PORT_RANGE]) {
>  		const struct ifla_vxlan_port_range *p
>  			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
> @@ -1386,11 +1666,31 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
>  	}
>  	dst->remote_vni = vni;
>
> -	if (data[IFLA_VXLAN_REMOTE])
> -		dst->remote_ip = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
> +	if (data[IFLA_VXLAN_REMOTE]) {
> +		dst->remote_ip.va_sin = nla_get_be32(data[IFLA_VXLAN_REMOTE]);
> +		dst->remote_ip.va_sa = AF_INET;
> +	} else if (data[IFLA_VXLAN_REMOTE6]) {
> +#if IS_ENABLED(CONFIG_IPV6)
> +		nla_memcpy(&dst->remote_ip.va_sin6, data[IFLA_VXLAN_REMOTE6],
> +			   sizeof(struct in6_addr));
> +		dst->remote_ip.va_sa = AF_INET6;
> +#else
> +		return -EPFNOSUPPORT;
> +#endif
> +	}
>
> -	if (data[IFLA_VXLAN_LOCAL])
> -		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
> +	if (data[IFLA_VXLAN_LOCAL]) {
> +		vxlan->saddr.va_sin = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
> +		vxlan->saddr.va_sa = AF_INET;
> +	} else if (data[IFLA_VXLAN_LOCAL6]) {
> +#if IS_ENABLED(CONFIG_IPV6)
> +		nla_memcpy(&vxlan->saddr.va_sin6, data[IFLA_VXLAN_LOCAL6],
> +			   sizeof(struct in6_addr));
> +		vxlan->saddr.va_sa = AF_INET6;
> +#else
> +		return -EPFNOSUPPORT;
> +#endif
> +	}
>
>  	if (data[IFLA_VXLAN_LINK] &&
>  	    (dst->remote_ifindex = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
> @@ -1468,9 +1768,9 @@ static size_t vxlan_get_size(const struct net_device *dev)
>  {
>
>  	return nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_ID */
> -		nla_total_size(sizeof(__be32)) +/* IFLA_VXLAN_REMOTE */
> +		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_REMOTE{6} */
>  		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LINK */
> -		nla_total_size(sizeof(__be32))+	/* IFLA_VXLAN_LOCAL */
> +		nla_total_size(sizeof(struct in6_addr)) + /* IFLA_VXLAN_LOCAL{6} */
>  		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
>  		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
>  		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
> @@ -1496,14 +1796,34 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
>  	if (nla_put_u32(skb, IFLA_VXLAN_ID, dst->remote_vni))
>  		goto nla_put_failure;
>
> -	if (dst->remote_ip && nla_put_be32(skb, IFLA_VXLAN_REMOTE, dst->remote_ip))
> -		goto nla_put_failure;
> +	if (!vxlan_addr_any(&dst->remote_ip)) {
> +		if (dst->remote_ip.va_sa == AF_INET) {
> +			if (nla_put_be32(skb, IFLA_VXLAN_REMOTE, dst->remote_ip.va_sin))
> +				goto nla_put_failure;
> +		} else {
> +#if IS_ENABLED(CONFIG_IPV6)
> +			if (nla_put(skb, IFLA_VXLAN_REMOTE6, sizeof(struct in6_addr),
> +				    &dst->remote_ip.va_sin6))
> +				goto nla_put_failure;
> +#endif
> +		}
> +	}
>
>  	if (dst->remote_ifindex && nla_put_u32(skb, IFLA_VXLAN_LINK, dst->remote_ifindex))
>  		goto nla_put_failure;
>
> -	if (vxlan->saddr && nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr))
> -		goto nla_put_failure;
> +	if (!vxlan_addr_any(&vxlan->saddr)) {
> +		if (vxlan->saddr.va_sa == AF_INET) {
> +			if (nla_put_be32(skb, IFLA_VXLAN_LOCAL, vxlan->saddr.va_sin))
> +				goto nla_put_failure;
> +		} else {
> +#if IS_ENABLED(CONFIG_IPV6)
> +			if (nla_put(skb, IFLA_VXLAN_LOCAL6, sizeof(struct in6_addr),
> +				    &vxlan->saddr.va_sin6))
> +				goto nla_put_failure;
> +#endif
> +		}
> +	}
>
>  	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
>  	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
> @@ -1542,38 +1862,82 @@ static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
>  	.fill_info	= vxlan_fill_info,
>  };
>
> -static __net_init int vxlan_init_net(struct net *net)
> +/* Create UDP socket for encapsulation receive. AF_INET6 socket
> + * could be used for both IPv4 and IPv6 communications.
> + */
> +#if IS_ENABLED(CONFIG_IPV6)
> +static __net_init int create_sock(struct net *net, struct sock **sk)
> +{
> +	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> +	struct sockaddr_in6 vxlan_addr = {
> +		.sin6_family = AF_INET6,
> +		.sin6_port = htons(vxlan_port),
> +	};
> +	int rc;
> +
> +	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
> +	if (rc < 0) {
> +		pr_debug("UDP socket create failed\n");
> +		return rc;
> +	}
> +	/* Put in proper namespace */
> +	*sk = vn->sock->sk;
> +	sk_change_net(*sk, net);
> +
> +	rc = kernel_bind(vn->sock, (struct sockaddr *)&vxlan_addr,
> +			 sizeof(struct sockaddr_in6));
> +	if (rc < 0) {
> +		pr_debug("bind for UDP socket %pI6:%u (%d)\n",
> +			 &vxlan_addr.sin6_addr, ntohs(vxlan_addr.sin6_port), rc);
> +		sk_release_kernel(*sk);
> +		vn->sock = NULL;
> +		return rc;
> +	}
> +	return 0;
> +}
> +#else
> +static __net_init int create_sock(struct net *net, struct sock **sk)
>  {
>  	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> -	struct sock *sk;
>  	struct sockaddr_in vxlan_addr = {
>  		.sin_family = AF_INET,
> +		.sin_port = htons(vxlan_port),
>  		.sin_addr.s_addr = htonl(INADDR_ANY),
>  	};
>  	int rc;
> -	unsigned h;
>
> -	/* Create UDP socket for encapsulation receive. */
>  	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &vn->sock);
>  	if (rc < 0) {
>  		pr_debug("UDP socket create failed\n");
>  		return rc;
>  	}
>  	/* Put in proper namespace */
> -	sk = vn->sock->sk;
> -	sk_change_net(sk, net);
> -
> -	vxlan_addr.sin_port = htons(vxlan_port);
> +	*sk = vn->sock->sk;
> +	sk_change_net(*sk, net);
>
> -	rc = kernel_bind(vn->sock, (struct sockaddr *) &vxlan_addr,
> -			 sizeof(vxlan_addr));
> +	rc = kernel_bind(vn->sock, (struct sockaddr *)&vxlan_addr,
> +			 sizeof(struct sockaddr_in));
>  	if (rc < 0) {
>  		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
>  			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
> -		sk_release_kernel(sk);
> +		sk_release_kernel(*sk);
>  		vn->sock = NULL;
>  		return rc;
>  	}
> +	return 0;
> +}
> +#endif
> +
> +static __net_init int vxlan_init_net(struct net *net)
> +{
> +	struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> +	struct sock *sk;
> +	int rc;
> +	unsigned h;
> +
> +	rc = create_sock(net, &sk);
> +	if (rc < 0)
> +		return rc;
>
>  	/* Disable multicast loopback */
>  	inet_sk(sk)->mc_loop = 0;
> @@ -1582,6 +1946,9 @@ static __net_init int vxlan_init_net(struct net *net)
>  	udp_sk(sk)->encap_type = 1;
>  	udp_sk(sk)->encap_rcv = vxlan_udp_encap_recv;
>  	udp_encap_enable();
> +#if IS_ENABLED(CONFIG_IPV6)
> +	udpv6_encap_enable();
> +#endif
>
>  	for (h = 0; h < VNI_HASH_SIZE; ++h)
>  		INIT_HLIST_HEAD(&vn->vni_list[h]);
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 9922704..f47ab4c 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -309,6 +309,8 @@ enum {
>  	IFLA_VXLAN_RSC,
>  	IFLA_VXLAN_L2MISS,
>  	IFLA_VXLAN_L3MISS,
> +	IFLA_VXLAN_REMOTE6,
> +	IFLA_VXLAN_LOCAL6,
>  	__IFLA_VXLAN_MAX
>  };
>  #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
