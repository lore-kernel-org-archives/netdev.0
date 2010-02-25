From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] IPv6: fix anycast address ref count leakage
Date: Thu, 25 Feb 2010 15:57:07 -0800
Message-ID: <20100225155707.779c582a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36408 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759320Ab0BYX5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2010 18:57:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent change in net-next to keep IPv6 address can lead to device
hanging with unresolved refcount on removal. The issue is that the conversion
of address from permanent to temporary needs to notify the anycast list
code to clean up it's ref count. Also, want to tell other uses of IPv6
(bonding/sctp) that the address is no longer available.

The fix is to notify like a regular delete.  When link comes back, DAD
runs and will notify with NETDEV_UP that address is back.

The decrement of idev refcount when cleaning up addrconf_hash, should
never cause address to be freed; therefore it can use __in6_ifa_put.

The timer cleanup should be done when address deletion is done
in second loop.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv6/addrconf.c	2010-02-25 15:04:58.207491933 -0800
+++ b/net/ipv6/addrconf.c	2010-02-25 15:07:57.735384610 -0800
@@ -2653,8 +2653,7 @@ static int addrconf_ifdown(struct net_de
 			    (how || !(ifa->flags&IFA_F_PERMANENT))) {
 				*bifa = ifa->lst_next;
 				ifa->lst_next = NULL;
-				addrconf_del_timer(ifa);
-				in6_ifa_put(ifa);
+				__in6_ifa_put(ifa);
 				continue;
 			}
 			bifa = &ifa->lst_next;
@@ -2706,14 +2705,15 @@ static int addrconf_ifdown(struct net_de
 			ifa->if_next = NULL;
 
 			ifa->dead = 1;
-			write_unlock_bh(&idev->lock);
+		}
+		addrconf_del_timer(ifa);
+		write_unlock_bh(&idev->lock);
 
-			__ipv6_ifa_notify(RTM_DELADDR, ifa);
-			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
-			in6_ifa_put(ifa);
+		__ipv6_ifa_notify(RTM_DELADDR, ifa);
+		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		in6_ifa_put(ifa);
 
-			write_lock_bh(&idev->lock);
-		}
+		write_lock_bh(&idev->lock);
 	}
 	write_unlock_bh(&idev->lock);
 

