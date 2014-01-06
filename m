From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] ipv6 addrconf: add IFA_F_NOPREFIXROUTE flag to
 suppress creation of IP6 routes
Date: Mon, 6 Jan 2014 18:38:37 +0100
Message-ID: <20140106173837.GA2571@minipsycho.orion>
References: <20140106160139.GB10204@order.stressinduktion.org>
 <1389029375-17698-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, stephen@networkplumber.org, dcbw@redhat.com
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:47371 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbaAFRik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 12:38:40 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so6788713eek.20
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 09:38:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389029375-17698-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 06, 2014 at 06:29:35PM CET, thaller@redhat.com wrote:
>When adding/modifying an IPv6 address, the userspace application needs
>a way to suppress adding a prefix route. This is for example relevant
>together with IFA_F_MANAGERTEMPADDR, where userspace creates autoconf
>generated addresses, but depending on on-link, no route should for the
>prefix should be added.
>
>This flag will not be set as ifa_flags of the address, it is only
>considered as parameter while adding/modifying an address.
>
>Signed-off-by: Thomas Haller <thaller@redhat.com>
>---
> Hi, how about this?
>
> The flag is only a parameter for the netlink command.
> This might be unexpected, because when adding an address,
> you won't see the flag in `ip -6 addr`.
> Still, I think, it is better to do it this way, because having
> an address with the NOPREFIXROUTE flag, does not mean, that
> there is no route for this prefix. It only means, that at the
> moment of setting the address, no route was added.
>
> The alternative would be, not to add a prefix route, when
> IFA_F_MANAGERTEMPADDR is set.
>
> Thomas
>
> include/uapi/linux/if_addr.h |  1 +
> net/ipv6/addrconf.c          | 19 +++++++++++++------
> 2 files changed, 14 insertions(+), 6 deletions(-)
>
>diff --git a/include/uapi/linux/if_addr.h b/include/uapi/linux/if_addr.h
>index cfed10b..dea10a8 100644
>--- a/include/uapi/linux/if_addr.h
>+++ b/include/uapi/linux/if_addr.h
>@@ -49,6 +49,7 @@ enum {
> #define IFA_F_TENTATIVE		0x40
> #define IFA_F_PERMANENT		0x80
> #define IFA_F_MANAGETEMPADDR	0x100
>+#define IFA_F_NOPREFIXROUTE	0x200
> 
> struct ifa_cacheinfo {
> 	__u32	ifa_prefered;
>diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>index 6c16345..51bd757 100644
>--- a/net/ipv6/addrconf.c
>+++ b/net/ipv6/addrconf.c
>@@ -2429,12 +2429,16 @@ static int inet6_addr_add(struct net *net, int ifindex,
> 		prefered_lft = timeout;
> 	}
> 
>-	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope, ifa_flags,
>+	ifp = ipv6_add_addr(idev, pfx, peer_pfx, plen, scope,
>+			    ifa_flags & ~IFA_F_NOPREFIXROUTE,
> 			    valid_lft, prefered_lft);
> 
> 	if (!IS_ERR(ifp)) {
>-		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
>-				      expires, flags);
>+		if (ifa_flags & IFA_F_NOPREFIXROUTE == 0) {

if (!(ifa_flags & IFA_F_NOPREFIXROUTE)) {

>+			addrconf_prefix_route(&ifp->addr, ifp->prefix_len, dev,
>+					      expires, flags);
>+		}
>+
> 		/*
> 		 * Note that section 3.1 of RFC 4429 indicates
> 		 * that the Optimistic flag should not be set for
>@@ -3662,8 +3666,10 @@ static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
> 	if (!(ifp->flags&IFA_F_TENTATIVE))
> 		ipv6_ifa_notify(0, ifp);
> 
>-	addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
>-			      expires, flags);
>+	if (ifa_flags & IFA_F_NOPREFIXROUTE == 0) {
>+		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, ifp->idev->dev,
>+				      expires, flags);
>+	}
> 
> 	if (was_managetempaddr || ifp->flags & IFA_F_MANAGETEMPADDR) {
> 		if (was_managetempaddr && !(ifp->flags & IFA_F_MANAGETEMPADDR))
>@@ -3717,7 +3723,8 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
> 	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
> 
> 	/* We ignore other flags so far. */
>-	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR;
>+	ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
>+		     IFA_F_NOPREFIXROUTE;
> 
> 	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
> 	if (ifa == NULL) {
>-- 
>1.8.4.2
>
