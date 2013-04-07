From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2 3/4] vxlan: add ipv6 support
Date: Sun, 07 Apr 2013 22:54:54 +0800
Message-ID: <1365346494.29856.10.camel@cr0>
References: <1365164186-21719-1-git-send-email-amwang@redhat.com>
	 <1365164186-21719-3-git-send-email-amwang@redhat.com>
	 <OFEB6AEA10.78B1A4D7-ON85257B44.004548C2-85257B44.004A7DDE@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933837Ab3DGOzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 10:55:04 -0400
In-Reply-To: <OFEB6AEA10.78B1A4D7-ON85257B44.004548C2-85257B44.004A7DDE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-05 at 09:33 -0400, David Stevens wrote:
> Cong Wang <amwang@redhat.com> wrote on 04/05/2013 08:16:24 AM:
>  
> 
> > +struct vxlan_ip {
> > +   union {
> > +      struct sockaddr_in   sin;
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +      struct sockaddr_in6   sin6;
> > +#endif
> > +      struct sockaddr      sa;
> > +   } u;
> > +#define ip4 u.sin.sin_addr.s_addr
> > +#define ip6 u.sin6.sin6_addr
> > +#define proto u.sa.sa_family
> > +};
> > +
>         I'd prefer:
> 
> 1) all #defines at the same level in the union/struct -- you
>         have a) a field within an in6_addr struct, b) a in6_addr
>         struct and c) a field within a sockaddr -- all at a different
>         level in the union/struct

Why? They are aliases of the fields, so should stay inside the
union/struct.

> 2) union tags the odd names and the defines indicating the type 
>         and also not something likely to appear as a variable name
>         (ie, maybe sun_sin6 for the union and vip_sin6 for the #define)

Why "sun_" prefix?

> 3) a family (e.g. AF_INET6) is not a proto (e.g. IPPROTO_IPV6)

Agreed, s/proto/family/.

> 4) "vxlan_ip" sounds like an ipv4 type to me -- maybe "vxlan_addr"?

Agreed.

> 5) I'd leave out the #ifdef; I believe sockaddr_in6 is defined without
>         CONFIG_IPV6. I may me wrong on that, and it makes it bigger for
>         v4-only configs, but fewer #ifdefs makes maintenance easier and
>         there's an advantage in it always being the same size; this one
>         is more a matter of taste.
> 

Yeah, you are right.

> So:
> 
> struct vxlan_addr {
>         union {
>                 struct sockaddr_in      sun_sin
>                 struct sockaddr_in6     sun_sin6;
>                 struct sockaddr         sun_sa;
>         } sun;
> }
> #define vip_sin sun.sin
> #define vip_sin6        sun.sin6
> #define vip_sa  sun.sa
> 
> As it is, you're trying to hide that it's a sockaddr, which
> makes the code more difficult to read in context. "vip_sa.sa_family"
> is obviously the sa_family field of a sockaddr, "proto" could be
> lots of things.
>  

No, I just want to keep them short. I don't think "vip_sin6" is better
than "ip6".

> > +
> > +static int vxlan_nla_get_addr(struct vxlan_ip *ip, struct nlattr *nla)
> > +{
> > +   if (nla_len(nla) == sizeof(__be32)) {
> > +      ip->ip4 = nla_get_be32(nla);
> > +      ip->proto = AF_INET;
> > +   } else if (nla_len(nla) == sizeof(struct in6_addr)) {
> > +      nla_memcpy(&ip->ip6, nla, sizeof(struct in6_addr));
> > +      ip->proto = AF_INET6;
> > +   } else
> > +      return -EAFNOSUPPORT;
> > +   return 0;
> > +}
> 
>         netlink messages use padding -- I'm not sure nla_len() will
> be correct in all cases here. I think using a sockaddr here too
> would be better (then the family tells you the address type), as
> long as that doesn't create include issues Dave mentioned within
> the "ip" and "bridge" commands. Otherwise, maybe use a different
> NL type for v6.

At least Thomas doesn't object this, although he pointed out the same
thing.

>         Another reason to do this is that link-local v6 addresses
> require a scope_id and matching addresses are only equal if the
> interfaces are equal. You need to get that from user level and
> compare it in address matching, too, but it is in the sockaddr_in6
> so if you set it there, memcmp() will cover that as well.
> 

It is not convenient to zero the whole struct just for memcmp(), just
compare the part we need is sufficient.


All the rest you point out are all fixed in v3.

Thanks for review!
