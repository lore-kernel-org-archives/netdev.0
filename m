From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 3/4] vxlan: add ipv6 support
Date: Tue, 09 Apr 2013 14:58:15 +0800
Message-ID: <1365490695.2557.12.camel@cr0>
References: <1365387536-25217-1-git-send-email-amwang@redhat.com>
	 <1365387536-25217-3-git-send-email-amwang@redhat.com>
	 <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39253 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756185Ab3DIG6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 02:58:38 -0400
In-Reply-To: <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 08:53 -0400, David Stevens wrote:
>         And also, these change all occurrences in the file, which is
> why I suggested they be unique field names. This makes a common
> "struct sockaddr_in sin;" declaration a syntax error. I suggested
> naming them "vip_sin" (or better,as above, "va_sin", with the new 
> vxlan_addr
> name) to make them unique field names, for the same reason it would
> be a bad idea to use "#define i u.sin"; because it is likely to
> create a problem maintaining it.

I will rename it to "va_sin".

> 
> >       port_max;
> > @@ -130,6 +146,59 @@ struct vxlan_dev {
> >  #define VXLAN_F_L2MISS   0x08
> >  #define VXLAN_F_L3MISS   0x10
> > 
> > +static inline
> > +bool vxlan_addr_equal(const struct vxlan_addr *a, const struct 
> vxlan_addr *b)
> > +{
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +   if (a->family != b->family)
> > +      return false;
> > +   if (a->family == AF_INET6)
> > +      return ipv6_addr_equal(&a->sin6, &b->sin6);
> > +   else
> > +#endif
> > +      return a->sin == b->sin;
> > +}
> 
>         Still think something like
> #define vxlan_addr_equal(a, b)  (memcmp((a),(b),sizeof(*a) == 0)
> 
> is better.

Even for IPv4 where we just need to compare 4 bytes?

Also, if you want to use memcmp, you have to zero all the struct
vxlan_addr on stack.

>         With your current definitions, "sin6" is just an in6_addr, but
> you are not checking the sin6_scope_id, which is not correct for IPv6
> link-local addresses. You can rely on "ifindex" in vxlan_rdst for
> fdb entries, but you'd at least need to make sure it is not 0 for LL
> scope, and you still need sin6_scope_id to match for calls in 
> vxlan_snoop()
> and vxlan_group_used(). The same sin6_addr with different sin6_scope_id
> for link-local addrs is not the same address in v6.
>         This is another reason to use memcmp(), and the whole 
> sockaddr_in6,
> not just the sin6_addr part. You need code to require non-zero 
> sin6_scope_id for
> link-local addrs in the netlink part regardless of how you fix the
> comparison here.


Alright, I will check sin6_scope_id as well.


> > +static int vxlan_nla_get_addr(struct vxlan_addr *ip, struct nlattr 
> *nla)
> > +{
> > +   if (nla_len(nla) == sizeof(struct in6_addr)) {
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +      nla_memcpy(&ip->sin6, nla, sizeof(struct in6_addr));
> > +      ip->family = AF_INET6;
> > +      return 0;
> > +#else
> > +      return -EAFNOSUPPORT;
> > +#endif
> > +   } else if (nla_len(nla) == sizeof(__be32)) {
> > +      ip->sin = nla_get_be32(nla);
> > +      ip->family = AF_INET;
> > +      return 0;
> > +   } else {
> > +      return -EAFNOSUPPORT;
> > +   }
> > +}
> 
>         You said in your other mail you already had a comment about
> padding here, but it isn't accounting for it. nla_ok() only requires
> nla_len() be >= sizeof(__be32) here.
> 

Maybe I should change the '==' above to '>='?
