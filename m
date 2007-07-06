From: David Miller <davem@davemloft.net>
Subject: -ENOCOMPILE
Date: Thu, 05 Jul 2007 17:37:42 -0700 (PDT)
Message-ID: <20070705.173742.104701626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44064
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758389AbXGFAhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 20:37:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Vlad, you're on my shit list for the next week for submitting
a patch to the 2.6.22 tree which won't even compile:

net/ipv6/addrconf.c: In function $,1rx(Baddrconf_ifdown$,1ry(B:
net/ipv6/addrconf.c:2475: error: $,1rx(Bifp$,1ry(B undeclared (first use in this function)
net/ipv6/addrconf.c:2475: error: (Each undeclared identifier is reported only once
net/ipv6/addrconf.c:2475: error: for each function it appears in.)

Being on my shit list means that I refuse to even look at your
patches until I see at least 3 other trustworthy developers
explicitly ACK your patches.

I'm even more furious because it is painfully obvious how you coded up
this patch, you cut and pasted another inet6addr_chain call from
another function in the same file and did not even bother to compile
test.  That's infuriating especially because of how much of my time is
consumed when I have to back out stuff like this, and it also means
there is no way in the world that you actually tested that this
patch fixes the SCTP bug, it can't possibly execute if it won't
even compile in the first place.

Please don't do this ever again, thanks.

commit d31c5de9bcb1c5e6915f4bc6f633bf36470f74de
Author: Vlad Yasevich <vladislav.yasevich@hp.com>
Date:   Thu Jul 5 16:59:43 2007 -0700

    [IPV6]: Call inet6addr_chain notifiers on link down.
    
    Currently if the link is brought down via ip link or ifconfig down,
    the inet6addr_chain notifiers are not called even though all
    the addresses are removed from the interface.  This caused SCTP
    to add duplicate addresses to it's list.
    
    Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f96ed76..6496e03 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2472,6 +2472,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
+		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifp);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);
