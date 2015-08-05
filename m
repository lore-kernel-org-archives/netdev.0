From: Nicholas Krause <uboot477@gmail.com>
Subject: [PATCH] ipv6:Fix concurrent access issue in the function inet6_rtm_deladdr
Date: Tue,  4 Aug 2015 22:39:00 -0400
Message-ID: <1438742340-28451-1-git-send-email-uboot477@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Krause <xerofoify@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Krause <xerofoify@gmail.com>

This fixes the issue with conncurrent access when calling the function
inte6_addr_del due to this function using non locked wrapper versions
of certain functions by locking the routing mutex before and after this
call with rtnl_lock/unlock. After the unlocking just return the error
code as normal to signal success or failure to the caller of the function
inet_6_rtm_addr.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..b6103e0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4006,8 +4006,11 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	/* We ignore other flags so far. */
 	ifa_flags &= IFA_F_MANAGETEMPADDR;
 
-	return inet6_addr_del(net, ifm->ifa_index, ifa_flags, pfx,
+	rtnl_lock();
+	err =  inet6_addr_del(net, ifm->ifa_index, ifa_flags, pfx,
 			      ifm->ifa_prefixlen);
+	rtnl_unlock();
+	return err;
 }
 
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
-- 
2.1.4
