From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v3 3/4] vxlan: add ipv6 support
Date: Mon, 8 Apr 2013 08:53:12 -0400
Message-ID: <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com>
References: <1365387536-25217-1-git-send-email-amwang@redhat.com> <1365387536-25217-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:54404 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935703Ab3DHMxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 08:53:43 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 8 Apr 2013 06:53:42 -0600
In-Reply-To: <1365387536-25217-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Cong Wang <amwang@redhat.com>


> +#define sin u.sin.sin_addr.s_addr
> +#define sin6 u.sin6.sin6_addr
> +#define family u.sa.sa_family

        The suggestion here was to make a sockaddr_in and
then the name "sin" is the commonly used name for
sockaddr_in's. You're using the name, but for a __be32,
which is actually more misleading. Similary for "sin6",
which is not a sockaddr_in6 but rather is an in_addr6.
        I think these should be at the same level and named
according to their types.
        In your response, you said these are shorter. That's
true, but "a" is shorter still. We're not trying to save text
bytes here -- it should be easy to read and modify. It doesn't
need to be unnecessarily wordy, of course, but using
"x->va_sin.sin_addr" in context conveys meaning (namely, "this
is the address part of a sockaddr_in"). Naming it "XX_sin" to
most will mean it is a sockaddr_in, but then "x->va_sin = 
htonl(INADDR_ANY)"
is nonsense for a sockaddr_in, and "x->va_sin.sin_family" would be an
error.
        And also, these change all occurrences in the file, which is
why I suggested they be unique field names. This makes a common
"struct sockaddr_in sin;" declaration a syntax error. I suggested
naming them "vip_sin" (or better,as above, "va_sin", with the new 
vxlan_addr
name) to make them unique field names, for the same reason it would
be a bad idea to use "#define i u.sin"; because it is likely to
create a problem maintaining it.

>       port_max;
> @@ -130,6 +146,59 @@ struct vxlan_dev {
>  #define VXLAN_F_L2MISS   0x08
>  #define VXLAN_F_L3MISS   0x10
> 
> +static inline
> +bool vxlan_addr_equal(const struct vxlan_addr *a, const struct 
vxlan_addr *b)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +   if (a->family != b->family)
> +      return false;
> +   if (a->family == AF_INET6)
> +      return ipv6_addr_equal(&a->sin6, &b->sin6);
> +   else
> +#endif
> +      return a->sin == b->sin;
> +}

        Still think something like
#define vxlan_addr_equal(a, b)  (memcmp((a),(b),sizeof(*a) == 0)

is better.
        With your current definitions, "sin6" is just an in6_addr, but
you are not checking the sin6_scope_id, which is not correct for IPv6
link-local addresses. You can rely on "ifindex" in vxlan_rdst for
fdb entries, but you'd at least need to make sure it is not 0 for LL
scope, and you still need sin6_scope_id to match for calls in 
vxlan_snoop()
and vxlan_group_used(). The same sin6_addr with different sin6_scope_id
for link-local addrs is not the same address in v6.
        This is another reason to use memcmp(), and the whole 
sockaddr_in6,
not just the sin6_addr part. You need code to require non-zero 
sin6_scope_id for
link-local addrs in the netlink part regardless of how you fix the
comparison here.

> +
> +static inline bool vxlan_addr_any(const struct vxlan_addr *ipa)
> +{
> +#if IS_ENABLED(CONFIG_IPV6)
> +   if (ipa->family == AF_INET6)
> +      return ipv6_addr_any(&ipa->sin6);
> +   else
> +#endif
> +      return ipa->sin == htonl(INADDR_ANY);
> +}

        Again, "ipa->sin" looks like a sockaddr_in, which INADDR_ANY is
not. And bad idea to #define the generic name "sin".

> +
> +static int vxlan_nla_get_addr(struct vxlan_addr *ip, struct nlattr 
*nla)
> +{
> +   if (nla_len(nla) == sizeof(struct in6_addr)) {
> +#if IS_ENABLED(CONFIG_IPV6)
> +      nla_memcpy(&ip->sin6, nla, sizeof(struct in6_addr));
> +      ip->family = AF_INET6;
> +      return 0;
> +#else
> +      return -EAFNOSUPPORT;
> +#endif
> +   } else if (nla_len(nla) == sizeof(__be32)) {
> +      ip->sin = nla_get_be32(nla);
> +      ip->family = AF_INET;
> +      return 0;
> +   } else {
> +      return -EAFNOSUPPORT;
> +   }
> +}

        You said in your other mail you already had a comment about
padding here, but it isn't accounting for it. nla_ok() only requires
nla_len() be >= sizeof(__be32) here.


>  /* Add/update destinations for multicast */
> -static int vxlan_fdb_append(struct vxlan_fdb *f,
> -             __be32 ip, __u32 port, __u32 vni, __u32 ifindex)
> +static int vxlan_fdb_append(struct vxlan_fdb *f, struct vxlan_addr *ip,
> +             __u32 port, __u32 vni, __u32 ifindex)
>  {
>     struct vxlan_rdst *rd_prev, *rd;
> 
>     rd_prev = NULL;
>     for (rd = &f->remote; rd; rd = rd->remote_next) {
> -      if (rd->remote_ip == ip &&
> +      if (vxlan_addr_equal(&rd->remote_ip, ip) &&
>            rd->remote_port == port &&
>            rd->remote_vni == vni &&
>            rd->remote_ifindex == ifindex)

This is where I mentioned above you need ifindex !=0 with LL scope,
or (better), require non-zero sin6_scope_id for LL scope in netlink
and use whole sockaddr_in6 for comparison.


                                                        +-DLS
