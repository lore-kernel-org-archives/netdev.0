From: Andrew Vagin <avagin@openvz.org>
Subject: [PATCH] bridge: Fix potential deadlock on br->multicast_lock
Date: Thu, 10 Nov 2011 18:48:03 +0300
Message-ID: <1320940083-3719823-1-git-send-email-avagin@openvz.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, avagin@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

multicast_lock is taken in softirq context, so we should use
spin_lock_bh() in userspace.

call-chain in softirq context:
run_timer_softirq()
	br_multicast_query_expired()

call-chain in userspace:
sysfs_write_file()
	store_multicast_snooping()
		br_multicast_toggle()

Signed-off-by: Andrew Vagin <avagin@openvz.org>
---
 net/bridge/br_multicast.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 995cbe0..2eefe27 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1770,7 +1770,7 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 	int err = 0;
 	struct net_bridge_mdb_htable *mdb;
 
-	spin_lock(&br->multicast_lock);
+	spin_lock_bh(&br->multicast_lock);
 	if (br->multicast_disabled == !val)
 		goto unlock;
 
@@ -1806,7 +1806,7 @@ rollback:
 	}
 
 unlock:
-	spin_unlock(&br->multicast_lock);
+	spin_unlock_bh(&br->multicast_lock);
 
 	return err;
 }
-- 
1.7.1
