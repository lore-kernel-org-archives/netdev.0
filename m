From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 2/6] netprio_cgroup: don't allocate prio table when a device
 is registered
Date: Wed, 01 Feb 2012 14:55:31 +0800
Message-ID: <4F28E1E3.80507@cn.fujitsu.com>
References: <4F28E1D1.900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F28E1D1.900-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

So we delay the allocation till the priority is set through cgroup,
and this makes skb_update_priority() faster when it's not set.

This also eliminates an off-by-one bug similar with the one fixed
in the previous patch.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/core/netprio_cgroup.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index a296cbb..2edfa6b 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -270,7 +270,6 @@ static int netprio_device_event(struct notifier_block *unused,
 {
 	struct net_device *dev = ptr;
 	struct netprio_map *old;
-	u32 max_len = atomic_read(&max_prioidx);
 
 	/*
 	 * Note this is called with rtnl_lock held so we have update side
@@ -278,11 +277,6 @@ static int netprio_device_event(struct notifier_block *unused,
 	 */
 
 	switch (event) {
-
-	case NETDEV_REGISTER:
-		if (max_len)
-			extend_netdev_table(dev, max_len);
-		break;
 	case NETDEV_UNREGISTER:
 		old = rtnl_dereference(dev->priomap);
 		RCU_INIT_POINTER(dev->priomap, NULL);
-- 
1.7.3.1
