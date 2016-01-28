From: Gregory Herrero <gregory.herrero@intel.com>
Subject: [PATCH] ipv6: release idev lock before calling ipv6_ifa_notify()
Date: Thu, 28 Jan 2016 09:34:52 +0100
Message-ID: <1453970092-10605-1-git-send-email-gregory.herrero@intel.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org,
	Gregory Herrero <gregory.herrero@intel.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipv6_ifa_notify() may need to acquire idev->lock, for example
when calling __ipv6_dev_ac_inc() from addrconf_join_anycast()
in __ipv6_ifa_notify().
So caller must release idev->lock before calling ipv6_ifa_notify() to
avoid a deadlock.
Fix a checkpatch warning present in the same area to make checkpatch
happy.

Signed-off-by: Gregory Herrero <gregory.herrero@intel.com>
---
 net/ipv6/addrconf.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 38eedde..af7fc84 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2302,8 +2302,11 @@ static void manage_tempaddrs(struct inet6_dev *idev,
 			ift->flags &= ~IFA_F_DEPRECATED;
 
 		spin_unlock(&ift->lock);
-		if (!(flags&IFA_F_TENTATIVE))
+		if (!(flags & IFA_F_TENTATIVE)) {
+			read_unlock_bh(&idev->lock);
 			ipv6_ifa_notify(0, ift);
+			read_lock_bh(&idev->lock);
+		}
 	}
 
 	if ((create || list_empty(&idev->tempaddr_list)) &&
@@ -3583,7 +3586,9 @@ static void addrconf_dad_begin(struct inet6_ifaddr *ifp)
 			/* Because optimistic nodes can use this address,
 			 * notify listeners. If DAD fails, RTM_DELADDR is sent.
 			 */
+			read_unlock_bh(&idev->lock);
 			ipv6_ifa_notify(RTM_NEWADDR, ifp);
+			read_lock_bh(&idev->lock);
 		}
 	}
 
-- 
2.6.2
