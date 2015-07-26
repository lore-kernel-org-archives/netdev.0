From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/ipv4: suppress NETDEV_UP notification on address lifetime update
Date: Sun, 26 Jul 2015 12:18:58 -0400
Message-ID: <1437927538-21703-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX1.LL.MIT.EDU ([129.55.12.45]:42300 "EHLO mx1.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755199AbbGZQrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2015 12:47:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This notification causes the FIB to be updated, which is not needed
because the address already exists, and more importantly it may undo
intentional changes that were made to the FIB after the address was
originally added. (As a point of comparison, when an address becomes
deprecated because its preferred lifetime expired, a notification on
this chain is not generated.)

The motivation for this commit is fixing an incompatibility between
DHCP clients which set and update the address lifetime according to
the lease, and a commercial VPN client which replaces kernel routes
in a way that outbound traffic is sent only through the tunnel (and
disconnects if any further route changes are detected via netlink).

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/ipv4/devinet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e813196..2d9cb17 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -882,7 +882,6 @@ static int inet_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		queue_delayed_work(system_power_efficient_wq,
 				&check_lifetime_work, 0);
 		rtmsg_ifa(RTM_NEWADDR, ifa, nlh, NETLINK_CB(skb).portid);
-		blocking_notifier_call_chain(&inetaddr_chain, NETDEV_UP, ifa);
 	}
 	return 0;
 }
-- 
1.7.1
