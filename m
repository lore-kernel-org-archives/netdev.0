From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: REGRESSION in nfnetlink on 3.18.x (bisected)
Date: Mon, 22 Dec 2014 12:56:07 +0100
Message-ID: <20141222115607.GA4961@salvia>
References: <5496075F.3060204@tomt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="9amGYk9869ThD9tj"
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Andre Tomt <andre@tomt.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44577 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345AbaLVLxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 06:53:35 -0500
Content-Disposition: inline
In-Reply-To: <5496075F.3060204@tomt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Dec 21, 2014 at 12:33:51AM +0100, Andre Tomt wrote:
> On at least Ubuntu 14.04 LTS and Ubuntu 14.10 "conntrack -E" has
> started failing with Linux 3.18.x. conntrack -L still works.
> 
> 14.04 and 14.10 ships conntrack-utils version 1.4.1, but 1.4.2 does
> not work either.
> 
> It fails with:
> ># conntrack -E
> >conntrack v1.4.2 (conntrack-tools): Can't open handler
> 
> strace shows:
> >bind(3, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
> >getsockname(3, {sa_family=AF_NETLINK, pid=14092, groups=00000000}, [12]) = 0
> >bind(3, {sa_family=AF_NETLINK, pid=14092, groups=00000007}, 12) = -1 EINVAL (Invalid argument)
> 
> Reverting 97840cb67ff5ac8add836684f011fd838518d698 - netfilter:
> nfnetlink: fix insufficient validation in nfnetlink_bind

Could you give a test to this patch? Thanks.

--9amGYk9869ThD9tj
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netlink-fix-wrong-subscription-bitmask-to-group-mapp.patch"

>From f4f65150fd2129607a7bd25f007c258045237c8c Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 21 Dec 2014 21:48:36 +0100
Subject: [PATCH nf] netlink: fix wrong subscription bitmask to group mapping in
 binding callbacks

The subscription bitmask passed via struct sockaddr_nl is converted to
the group number when calling the netlink_bind() and netlink_unbind()
callbacks.

The conversion is however incorrect since bitmask (1 << 0) needs to be
mapped to group number 1. Note that you cannot specify the group number 0
(usually known as _NONE) from setsockopt() using NETLINK_ADD_MEMBERSHIP
since this is rejected through -EINVAL.

This problem became noticeable since 97840cb ("netfilter: nfnetlink:
fix insufficient validation in nfnetlink_bind") when binding to bitmask
(1 << 0) in ctnetlink.

Reported-by: Andre Tomt <andre@tomt.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netlink/af_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 074cf3e..cbcf73b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1420,7 +1420,7 @@ static void netlink_unbind(int group, long unsigned int groups,
 
 	for (undo = 0; undo < group; undo++)
 		if (test_bit(undo, &groups))
-			nlk->netlink_unbind(undo);
+			nlk->netlink_unbind(undo + 1);
 }
 
 static int netlink_bind(struct socket *sock, struct sockaddr *addr,
@@ -1458,7 +1458,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		for (group = 0; group < nlk->ngroups; group++) {
 			if (!test_bit(group, &groups))
 				continue;
-			err = nlk->netlink_bind(group);
+			err = nlk->netlink_bind(group + 1);
 			if (!err)
 				continue;
 			netlink_unbind(group, groups, nlk);
-- 
1.7.10.4


--9amGYk9869ThD9tj--
