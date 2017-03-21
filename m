From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: Re: [PATCH net-next v4 1/2]L2TP:Adjust intf MTU, add underlay L3,
 L2 hdrs
Date: Mon, 20 Mar 2017 19:28:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1703201919300.28905@vera100.eng.brocade.com>
References: <alpine.DEB.2.11.1703171847580.10094@vera100.eng.brocade.com> <b5a13abe-fdaf-18f9-b7db-e0c25d9c4ba2@katalix.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "R. Parameswaran" <parameswaran.r7@gmail.com>,
        netdev@vger.kernel.org, kleptog@svana.org, davem@redhat.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35457 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755123AbdCUC3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 22:29:20 -0400
In-Reply-To: <b5a13abe-fdaf-18f9-b7db-e0c25d9c4ba2@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi James,

Thanks for the response and suggestions, please see inline:

On Mon, 20 Mar 2017, James Chapman wrote:

> The patch comment of each patch should represent the changes of the
> patch. You seem to be using a common description for your two commits
> and this will look out of place when viewed using git log on one of the
> files modified by this patch. The patch summary line here is also
> inaccurate.
> 

For this specific patch, I was thinking of the following
header:

"New kernel API to get IP overhead on a socket.

A new API is needed to calculate the cumulative 
overhead imposed by the IP Header and IP options,
if any, on a socket's payload. Provided by the patch
here, this API is then used to determine the
the default pseudowire MTU on an L2TP interface,
relative to the underlay MTU. The new API returns
an overhead of zero for sockets that do not belong
to the IPv4 or IPv6 address families."

Please feel free to edit or suggest changes.

> Are you using git format-patch? Its "Patch 0" can be useful to provide a
> summary description of a patch series to help reviewers.
>

Yes, I am using git format-patch, but was individually generating each
commit's patch. I just figured out how to generate a cover letter and
multiple patches in one shot with git format-patch, will update with the 
suggested changes in a day or so. I also tested the latest patch, 
verified it to be working correctly.

thanks,

Ramkumar


 
> James
> 
> On 18/03/17 01:53, R. Parameswaran wrote:
> > In existing kernel code, when setting up the L2TP interface, all of the
> > tunnel encapsulation headers are not taken into account when setting
> > up the MTU on the  L2TP logical interface device. Due to this, the
> > packets created by the applications on top of the L2TP layer are larger
> > than they ought to be, relative to the underlay MTU, which leads to
> > needless fragmentation once the L2TP packet is encapsulated in an outer IP
> > packet.  Specifically, the MTU calculation  does not take into account the
> > (outer) IP header imposed on the encapsulated L2TP packet, and the Layer 2
> > header imposed on the inner L2TP packet prior to encapsulation.
> >
> > Change-set here (1/2) introduces a new kernel API to compute the IP overhead
> > on an IPv4 or IPv6 socket, which is then used in the L2TP code-path.
> >
> > Signed-off-by: R. Parameswaran <rparames@brocade.com>
> > ---
> >  include/linux/net.h |  3 +++
> >  net/socket.c        | 44 ++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 47 insertions(+)
> >
> > diff --git a/include/linux/net.h b/include/linux/net.h
> > index 0620f5e..a42fab2 100644
> > --- a/include/linux/net.h
> > +++ b/include/linux/net.h
> > @@ -298,6 +298,9 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
> >  int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
> >  int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
> >  
> > +/* Following routine returns the IP overhead imposed by a socket.  */
> > +u32 kernel_sock_ip_overhead(struct sock *sk);
> > +
> >  #define MODULE_ALIAS_NETPROTO(proto) \
> >  	MODULE_ALIAS("net-pf-" __stringify(proto))
> >  
> > diff --git a/net/socket.c b/net/socket.c
> > index e034fe4..69598e1 100644
> > --- a/net/socket.c
> > +++ b/net/socket.c
> > @@ -3345,3 +3345,47 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
> >  	return sock->ops->shutdown(sock, how);
> >  }
> >  EXPORT_SYMBOL(kernel_sock_shutdown);
> > +
> > +/* This routine returns the IP overhead imposed by a socket i.e.
> > + * the length of the underlying IP header, depending on whether
> > + * this is an IPv4 or IPv6 socket and the length from IP options turned
> > + * on at the socket.
> > + */
> > +u32 kernel_sock_ip_overhead(struct sock *sk)
> > +{
> > +	struct inet_sock *inet;
> > +	struct ipv6_pinfo *np;
> > +	struct ip_options_rcu *opt;
> > +	struct ipv6_txoptions *optv6 = NULL;
> > +	u32 overhead = 0;
> > +	bool owned_by_user;
> > +
> > +	if (!sk)
> > +		return overhead;
> > +
> > +	owned_by_user = sock_owned_by_user(sk);
> > +	switch (sk->sk_family) {
> > +	case AF_INET:
> > +		inet = inet_sk(sk);
> > +		overhead += sizeof(struct iphdr);
> > +		opt = rcu_dereference_protected(inet->inet_opt,
> > +						owned_by_user);
> > +		if (opt)
> > +			overhead += opt->opt.optlen;
> > +		return overhead;
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +	case AF_INET6:
> > +		np = inet6_sk(sk);
> > +		overhead += sizeof(struct ipv6hdr);
> > +		if (np)
> > +			optv6 = rcu_dereference_protected(np->opt,
> > +							  owned_by_user);
> > +		if (optv6)
> > +			overhead += (optv6->opt_flen + optv6->opt_nflen);
> > +		return overhead;
> > +#endif /* IS_ENABLED(CONFIG_IPV6) */
> > +	default: /* Returns 0 overhead if the socket is not ipv4 or ipv6 */
> > +		return overhead;
> > +	}
> > +}
> > +EXPORT_SYMBOL(kernel_sock_ip_overhead);
> 
> 
> -- 
> James Chapman
> Katalix Systems Ltd
> http://www.katalix.com
> Catalysts for your Embedded Linux software development
> 
> 
> 
