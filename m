From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Patch net-next v4 4/5] vxlan: add scope_id support for ll addr
Date: Fri, 19 Apr 2013 07:14:21 -0400
Message-ID: <OFA1761298.DF396ECD-ON85257B52.003AE2CA-85257B52.003DBDAB@us.ibm.com>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com> <1366175423-27310-5-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:34287 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757087Ab3DSLOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 07:14:31 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 19 Apr 2013 05:14:30 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 037C73E40039
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 05:14:13 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3JBEPew095954
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 05:14:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3JBEONG013210
	for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 05:14:25 -0600
In-Reply-To: <1366175423-27310-5-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> wrote on 04/17/2013 01:10:21 AM:
 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 43ed40f..531c5e2 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -92,9 +92,10 @@ struct vxlan_addr {
>        struct sockaddr_in6   sin6;
>        struct sockaddr      sa;
>     } u;
> -#define va_sin  u.sin.sin_addr.s_addr
> -#define va_sin6 u.sin6.sin6_addr
> -#define va_sa   u.sa.sa_family
> +#define va_sin      u.sin.sin_addr.s_addr
> +#define va_sin6      u.sin6.sin6_addr
> +#define va_scope_id   u.sin6.sin6_scope_id
> +#define va_sa      u.sa.sa_family
>  };

        As I commented before, you're obscuring the types here,
which makes it less readable. "va_sin6" ought to be a sockaddr_in6,
not a sin6_addr, and the scope id ought to then be 
"va_sin6.sin6_scope_id",
without any other #define necessary for it.



> @@ -1708,6 +1712,17 @@ static int vxlan_newlink(struct net *net, 
> struct net_device *dev,
>        /* update header length based on lower device */
>        dev->hard_header_len = lowerdev->hard_header_len +
>                     VXLAN_HEADROOM;
> +#if IS_ENABLED(CONFIG_IPV6)
> +      dst->remote_ip.va_scope_id = ipv6_iface_scope_id
> (&dst->remote_ip.va_sin6,
> +                         dst->remote_ifindex);
> +      if (ipv6_addr_type(&dst->remote_ip.va_sin6) & 
IPV6_ADDR_LINKLOCAL) {
> +         struct vxlan_net *vn = net_generic(net, vxlan_net_id);
> +         struct sock *sk = vn->sock->sk;
> +
> +                        sk->sk_bound_dev_if = 
dst->remote_ip.va_scope_id;
> +      }
> +#endif
> +
>     }

        The socket is not used for transmits, which is where the 
sin6_scope_id is
relevant-- we need this in vxlan_xmit_one() for the route lookup. It also
permanently binds to an interface, which I believe prevents VXLAN traffic 
from
other interfaces on receive, and this socket is an INADDR_ANY-bound socket 
for
all VXLAN devices on the host.
        So, we shouldn't be doing anything with sk_bound_dev_if, but LL 
addrs need
to use the the sin6_scope_id in the route lookup for transmissions. It 
should
be saved in remote_ifindex per destination and stored in flowi6_oif for 
route
lookup, as the v4 code does now for fdb entries, and LL v6 destinations 
for fdb
entries ought to be done the same way.

        So, no, I don't think this patch is correct or complete.

 +-DLS
