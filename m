From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: don't remove address state on ifdown if
 the address is being kept
Date: Wed, 27 Oct 2010 23:45:17 -0700
Message-ID: <AANLkTimLicmgC3BptZvXGoA0aN6-cFJtRG3DpqJ3NTpJ@mail.gmail.com>
References: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	Brian Haley <brian.haley@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:11612 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153Ab0J1Gpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 02:45:41 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o9S6jeLw010059
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 23:45:40 -0700
Received: from gyb13 (gyb13.prod.google.com [10.243.49.77])
	by wpaz21.hot.corp.google.com with ESMTP id o9S6jOiZ004704
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 23:45:39 -0700
Received: by gyb13 with SMTP id 13so1063424gyb.23
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 23:45:39 -0700 (PDT)
In-Reply-To: <AANLkTimyqFoUvjQM_qLS2YeVmJQ_6-LJc6KfLVE-mzH3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 9:16 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> Fix it so that none of this state is updated if the address is being kept on the interface.

Or, since the logic of the patched code is a little hard to follow,
here's an alternative patch against 2.6.36. I think it does exactly
the same as the previous patch, but it moves things around to make the
result more readable.

Tested: Added a statically configured IPv6 address to an interface,
started ping, brought link down, brought link up again. When link came
up ping kept on going and "ip -6 maddr" showed that the host was still
subscribed to there

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

--- 2.6.36-orig/net/ipv6/addrconf.c	2010-10-20 13:30:22.000000000 -0700
+++ linux-2.6.36/net/ipv6/addrconf.c	2010-10-27 23:26:57.000000000 -0700
@@ -2737,10 +2737,6 @@ static int addrconf_ifdown(struct net_de
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
 			ifa->state = INET6_IFADDR_STATE_DAD;
-
-			write_unlock_bh(&idev->lock);
-
-			in6_ifa_hold(ifa);
 		} else {
 			list_del(&ifa->if_list);

@@ -2755,19 +2751,15 @@ static int addrconf_ifdown(struct net_de
 			ifa->state = INET6_IFADDR_STATE_DEAD;
 			spin_unlock_bh(&ifa->state_lock);

-			if (state == INET6_IFADDR_STATE_DEAD)
-				goto put_ifa;
+			if (state == INET6_IFADDR_STATE_DEAD) {
+				in6_ifa_put(ifa);
+			} else {
+				__ipv6_ifa_notify(RTM_DELADDR, ifa);
+				atomic_notifier_call_chain(&inet6addr_chain,
+							   NETDEV_DOWN, ifa);
+			}
+			write_lock_bh(&idev->lock);
 		}
-
-		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		if (ifa->state == INET6_IFADDR_STATE_DEAD)
-			atomic_notifier_call_chain(&inet6addr_chain,
-						   NETDEV_DOWN, ifa);
-
-put_ifa:
-		in6_ifa_put(ifa);
-
-		write_lock_bh(&idev->lock);
 	}

 	list_splice(&keep_list, &idev->addr_list);
