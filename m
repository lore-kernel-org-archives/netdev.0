From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC 1/2] ipv6: disable autoconfiguration and DAD on non-multicast links
Date: Mon, 10 Feb 2014 14:29:50 -0800
Message-ID: <1392071391-13215-2-git-send-email-mcgrof@do-not-panic.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>, Olaf Kirch <okir@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:41819 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbaBJWaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:30:11 -0500
Received: by mail-pa0-f50.google.com with SMTP id kp14so6793001pab.37
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:30:10 -0800 (PST)
In-Reply-To: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

RFC4862 [0] on IPv6 on Stateless Address Autoconfiguration on
Sections 4 and 5 state that autoconfiguration is performed only
on multicast-capable links. Multicast is used to ensure the
automatically assigned address is unique by sending Neighbor
Solicitation Messages and listening for these same messages
on both the all-nodes multicast address and the solicited-node
multicast address of the tentative address, this is called
Duplicate Address Detection (DAD) and documented on Section 5.4.
DAD has an optimization, Optimistic DAD [1] and it also requires
multicast. Skip autoconfiguration and all forms of DAD on
non-multicast links.

We don't *fully* disable IPV6 for non-multicast links as
there are signs non-multicast IPV6 devices are wished to
be supported, one example being the ipv6 autoconf module
parameter, but it should be noted that RFC4682 Section 5.4
makes it clear that DAD *MUST* be performed on all unicast
addresses prior to assigning them to an interface, regardless of
whether they are obtained through stateless autoconfiguration,
DHCPv6, or manual configuration with the following exceptions:

   -  When DupAddrDetectTransmits is set to zero, DAD
      can be skipped
   -  Anycast addresses can skip DAD

In the case that autoconfiguration is disabled the interface
still gets assigned a temporary address via ipv6_create_tempaddr()
however it will be kept as temporary, IFA_F_TEMPORARY.

[0] http://tools.ietf.org/html/rfc4862
[1] http://tools.ietf.org/html/rfc4429

Cc: Olaf Kirch <okir@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 net/ipv6/addrconf.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad23569..362f64f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2211,7 +2211,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 
 	/* Try to figure out our local address for this prefix */
 
-	if (pinfo->autoconf && in6_dev->cnf.autoconf) {
+	if (pinfo->autoconf && in6_dev->cnf.autoconf &&
+	    dev->flags & IFF_MULTICAST) {
 		struct inet6_ifaddr *ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
@@ -2248,7 +2249,8 @@ ok:
 
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 			if (in6_dev->cnf.optimistic_dad &&
-			    !net->ipv6.devconf_all->forwarding && sllao)
+			    !net->ipv6.devconf_all->forwarding && sllao &&
+			    dev->flags & IFF_MULTICAST)
 				addr_flags = IFA_F_OPTIMISTIC;
 #endif
 
@@ -3161,6 +3163,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 		goto out;
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+	    !(dev->flags&IFF_MULTICAST) ||
 	    idev->cnf.accept_dad < 1 ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
@@ -3288,6 +3291,7 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 	send_rs = send_mld &&
 		  ipv6_accept_ra(ifp->idev) &&
 		  ifp->idev->cnf.rtr_solicits > 0 &&
+		  (dev->flags&IFF_MULTICAST) &&
 		  (dev->flags&IFF_LOOPBACK) == 0;
 	read_unlock_bh(&ifp->idev->lock);
 
@@ -4192,8 +4196,9 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
 }
 
-static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
-				__s32 *array, int bytes)
+static inline void ipv6_store_devconf(struct net_device *dev,
+				      struct ipv6_devconf *cnf,
+				      __s32 *array, int bytes)
 {
 	BUG_ON(bytes < (DEVCONF_MAX * 4));
 
@@ -4203,7 +4208,8 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_MTU6] = cnf->mtu6;
 	array[DEVCONF_ACCEPT_RA] = cnf->accept_ra;
 	array[DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
-	array[DEVCONF_AUTOCONF] = cnf->autoconf;
+	if (dev->flags & IFF_MULTICAST)
+		array[DEVCONF_AUTOCONF] = cnf->autoconf;
 	array[DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
 	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
 	array[DEVCONF_RTR_SOLICIT_INTERVAL] =
@@ -4326,7 +4332,7 @@ static int inet6_fill_ifla6_attrs(struct sk_buff *skb, struct inet6_dev *idev)
 	nla = nla_reserve(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(s32));
 	if (nla == NULL)
 		goto nla_put_failure;
-	ipv6_store_devconf(&idev->cnf, nla_data(nla), nla_len(nla));
+	ipv6_store_devconf(idev->dev, &idev->cnf, nla_data(nla), nla_len(nla));
 
 	/* XXX - MC not implemented */
 
-- 
1.8.5.3
