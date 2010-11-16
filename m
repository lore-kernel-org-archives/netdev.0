From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH] ipv6: fix missing in6_ifa_put in addrconf
Date: Mon, 15 Nov 2010 22:29:21 -0800
Message-ID: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17163 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756275Ab0KPGb5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 01:31:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix ref count bug introduced by

commit 2de795707294972f6c34bae9de713e502c431296
Author: Lorenzo Colitti <lorenzo@google.com>
Date:   Wed Oct 27 18:16:49 2010 +0000

ipv6: addrconf: don't remove address state on ifdown if the address
is being kept


Fix logic so that addrconf_ifdown() decrements the inet6_ifaddr
refcnt correctly with in6_ifa_put().

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/ipv6/addrconf.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b41ce0f..aaa3ca4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2754,13 +2754,13 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 			ifa->state = INET6_IFADDR_STATE_DEAD;
 			spin_unlock_bh(&ifa->state_lock);
 
-			if (state == INET6_IFADDR_STATE_DEAD) {
-				in6_ifa_put(ifa);
-			} else {
+			if (state != INET6_IFADDR_STATE_DEAD) {
 				__ipv6_ifa_notify(RTM_DELADDR, ifa);
 				atomic_notifier_call_chain(&inet6addr_chain,
 							   NETDEV_DOWN, ifa);
 			}
+
+			in6_ifa_put(ifa);
 			write_lock_bh(&idev->lock);
 		}
 	}

