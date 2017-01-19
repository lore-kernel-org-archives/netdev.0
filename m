From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH] ipv6: addrconf: Avoid addrconf_disable_change() using RCU read-side lock
Date: Thu, 19 Jan 2017 16:26:21 +0800
Message-ID: <1484814381-61150-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <dingtianhong@huawei.com>,
        <weiyongjun1@huawei.com>, <guohanjun@huawei.com>,
        Kefeng Wang <wangkefeng.wang@huawei.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just like commit 4acd4945cd1e ("ipv6: addrconf: Avoid calling
netdevice notifiers with RCU read-side lock"), it is unnecessary
to make addrconf_disable_change() use RCU iteration over the
netdev list, since it already holds the RTNL lock, or we may meet
Illegal context switch in RCU read-side critical section.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 net/ipv6/addrconf.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c1e124b..f60e88e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -5540,8 +5540,7 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
+	for_each_netdev(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.disable_ipv6) ^ (!newf);
@@ -5550,7 +5549,6 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 				dev_disable_change(idev);
 		}
 	}
-	rcu_read_unlock();
 }
 
 static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int newf)
-- 
1.7.12.4
