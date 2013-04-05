From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v2 3/4] vxlan: add ipv6 support
Date: Fri, 5 Apr 2013 09:33:42 -0400
Message-ID: <OFEB6AEA10.78B1A4D7-ON85257B44.004548C2-85257B44.004A7DDE@us.ibm.com>
References: <1365164186-21719-1-git-send-email-amwang@redhat.com> <1365164186-21719-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49348 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161177Ab3DENdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 09:33:53 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 5 Apr 2013 09:33:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7F01B6E8057
	for <netdev@vger.kernel.org>; Fri,  5 Apr 2013 09:33:45 -0400 (EDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r35DXjHK269490
	for <netdev@vger.kernel.org>; Fri, 5 Apr 2013 09:33:45 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r35DXikg025665
	for <netdev@vger.kernel.org>; Fri, 5 Apr 2013 07:33:44 -0600
In-Reply-To: <1365164186-21719-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote on 04/05/2013 08:16:24 AM:
 
 
> +struct vxlan_ip {
> +   union {
> +      struct sockaddr_in   sin;
> +#if IS_ENABLED(CONFIG_IPV6)
> +      struct sockaddr_in6   sin6;
> +#endif
> +      struct sockaddr      sa;
> +   } u;
> +#define ip4 u.sin.sin_addr.s_addr
> +#define ip6 u.sin6.sin6_addr
> +#define proto u.sa.sa_family
> +};
> +
        I'd prefer:

1) all #defines at the same level in the union/struct -- you
        have a) a field within an in6_addr struct, b) a in6_addr
        struct and c) a field within a sockaddr -- all at a different
        level in the union/struct
2) union tags the odd names and the defines indicating the type 
        and also not something likely to appear as a variable name
        (ie, maybe sun_sin6 for the union and vip_sin6 for the #define)
3) a family (e.g. AF_INET6) is not a proto (e.g. IPPROTO_IPV6)
4) "vxlan_ip" sounds like an ipv4 type to me -- maybe "vxlan_addr"?
5) I'd leave out the #ifdef; I believe sockaddr_in6 is defined without
        CONFIG_IPV6. I may me wrong on that, and it makes it bigger for
        v4-only configs, but fewer #ifdefs makes maintenance easier and
        there's an advantage in it always being the same size; this one
        is more a matter of taste.

So:

struct vxlan_addr {
        union {
                struct sockaddr_in      sun_sin
                struct sockaddr_in6     sun_sin6;
                struct sockaddr         sun_sa;
        } sun;
}
#define vip_sin sun.sin
#define vip_sin6        sun.sin6
#define vip_sa  sun.sa

As it is, you're trying to hide that it's a sockaddr, which
makes the code more difficult to read in context. "vip_sa.sa_family"
is obviously the sa_family field of a sockaddr, "proto" could be
lots of things.
 

 
> +#if IS_ENABLED(CONFIG_IPV6)
> +static inline bool vxlan_ip_equal(const struct vxlan_ip *a, const 
> struct vxlan_ip *b)
> +{
> +   if (a->proto != b->proto)
> +      return false;
> +   switch (a->proto) {
> +   case AF_INET:
> +      return a->ip4 == b->ip4;
> +   case AF_INET6:
> +      return ipv6_addr_equal(&a->ip6, &b->ip6);
> +   }
> +   return false;
> +}
> +
> +static inline bool vxlan_ip_any(const struct vxlan_ip *ipa)
> +{
> +   if (ipa->proto == AF_INET)
> +      return ipa->ip4 == htonl(INADDR_ANY);
> +   else
> +      return ipv6_addr_any(&ipa->ip6);
> +}

        I think these functions shouldn't be under the #ifdef; if
CONFIG_IPV6 is not set, you'll never have AF_INET6. Also, if you
zero everything on allocation, you can use "memcmp" on the whole
thing and don't need to check family and addresses separately or
explicitly, or use ipv6_addr_equal() with a CONFIG_IPV6 dependency.

> +
> +static int vxlan_nla_get_addr(struct vxlan_ip *ip, struct nlattr *nla)
> +{
> +   if (nla_len(nla) == sizeof(__be32)) {
> +      ip->ip4 = nla_get_be32(nla);
> +      ip->proto = AF_INET;
> +   } else if (nla_len(nla) == sizeof(struct in6_addr)) {
> +      nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
> +      ip->proto = AF_INET6;
> +   } else
> +      return -EAFNOSUPPORT;
> +   return 0;
> +}

        netlink messages use padding -- I'm not sure nla_len() will
be correct in all cases here. I think using a sockaddr here too
would be better (then the family tells you the address type), as
long as that doesn't create include issues Dave mentioned within
the "ip" and "bridge" commands. Otherwise, maybe use a different
NL type for v6.
        Another reason to do this is that link-local v6 addresses
require a scope_id and matching addresses are only equal if the
interfaces are equal. You need to get that from user level and
compare it in address matching, too, but it is in the sockaddr_in6
so if you set it there, memcmp() will cover that as well.


> +static inline bool vxlan_ip_equal(const struct vxlan_ip *a, const 
> struct vxlan_ip *b)
> +{
> +   return a->ip4 == b->ip4;
> +}

        Again, shouldn't have entirely separate function for v4;
either use memcmp() on the whole thing, or just #ifdef the v6
case in the switch.

> +
> +static inline bool vxlan_ip_any(const struct vxlan_ip *ipa)
> +{
> +   return ipa->ip4 == htonl(INADDR_ANY);
> +}

        ditto. And also for nla_get/put funcs.


 


> @@ -617,7 +708,14 @@ static int vxlan_join_group(struct net_device *dev)
>     /* Need to drop RTNL to call multicast join */
>     rtnl_unlock();
>     lock_sock(sk);
> +#if IS_ENABLED(CONFIG_IPV6)
> +   if (vxlan->gaddr.proto == AF_INET)
> +      err = ip_mc_join_group(sk, &mreq);
> +   else
> +      err = ipv6_sock_mc_join(sk, vxlan->link, &vxlan->gaddr.ip6);
> +#else
>     err = ip_mc_join_group(sk, &mreq);
> +#endif

#if IS_ENABLED(CONFIG_IPV6)
        if (vxlan->gaddr.proto == AF_INET6)
                err = ipv6_sock_mc_join....
        else
#endif
                err = ip_mc_join_group..



> @@ -644,7 +742,14 @@ static int vxlan_leave_group(struct net_device 
*dev)
>     /* Need to drop RTNL to call multicast leave */
>     rtnl_unlock();
>     lock_sock(sk);
> +#if IS_ENABLED(CONFIG_IPV6)
> +   if (vxlan->gaddr.proto == AF_INET)
> +      err = ip_mc_leave_group(sk, &mreq);
> +   else
> +      err = ipv6_sock_mc_drop(sk, vxlan->link, &vxlan->gaddr.ip6);
> +#else
>     err = ip_mc_leave_group(sk, &mreq);
> +#endif
>     release_sock(sk);
>     rtnl_lock();

        Again, arrange as above so only one instance of v4 leave
and #ifdefs for the optional v6 code.
 

 

> +#if IS_ENABLED(CONFIG_IPV6)
> +   if (oip6) {
> +      err = IP6_ECN_decapsulate(oip6, skb);
> +      if (unlikely(err)) {
> +         if (log_ecn_error)
> +            net_info_ratelimited("non-ECT from %pI4\n",

        %pI6

> +                       &oip6->saddr);
> +         if (err > 1) {
> +            ++vxlan->dev->stats.rx_frame_errors;
> +            ++vxlan->dev->stats.rx_errors;
> +            goto drop;
> +         }
> +      }
> +   }
> +#endif
> +   if (oip) {
> +      err = IP_ECN_decapsulate(oip, skb);
> +      if (unlikely(err)) {
> +         if (log_ecn_error)
> +            net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
> +                       &oip->saddr, oip->tos);
> +         if (err > 1) {
> +            ++vxlan->dev->stats.rx_frame_errors;
> +            ++vxlan->dev->stats.rx_errors;
> +            goto drop;
> +         }
>        }
>     }

        These are duplicated sections of code -- would rather
see one common section for stats based on err, though the
logging would still need an ifdef.

I think the IP v6/v4 header and routing code can be
refactored better -- maybe separate functions to handle
each, since it's all one or the other.

                                                        +-DLS
