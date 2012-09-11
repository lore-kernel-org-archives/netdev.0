From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [PATCH 2/2] netprio_cgroup: Optimize the priomap copy loop slightly
Date: Tue, 11 Sep 2012 16:52:37 +0530
Message-ID: <20120911112237.13852.1095.stgit@srivatsabhat.in.ibm.com>
References: <20120911112231.13852.61794.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, gaofeng@cn.fujitsu.com,
	eric.dumazet@gmail.com, mark.d.rustad@intel.com,
	lizefan@huawei.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120911112231.13852.61794.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Check for non-NULL old_priomap outside the loop, since its
  not going to change.
* Copy the old_priomap's length to a local variable and use
  that for loop control, instead of costly pointer-dereferences.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 net/core/netprio_cgroup.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index fd339bb0..0775bc9 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -73,7 +73,7 @@ static int extend_netdev_table(struct net_device *dev, u32 new_len)
 			   ((sizeof(u32) * new_len));
 	struct netprio_map *new_priomap = kzalloc(new_size, GFP_KERNEL);
 	struct netprio_map *old_priomap;
-	int i;
+	int i, old_len;
 
 	old_priomap  = rtnl_dereference(dev->priomap);
 
@@ -82,10 +82,12 @@ static int extend_netdev_table(struct net_device *dev, u32 new_len)
 		return -ENOMEM;
 	}
 
-	for (i = 0;
-	     old_priomap && (i < old_priomap->priomap_len);
-	     i++)
-		new_priomap->priomap[i] = old_priomap->priomap[i];
+	if (old_priomap) {
+		old_len = old_priomap->priomap_len;
+
+		for (i = 0; i < old_len; i++)
+			new_priomap->priomap[i] = old_priomap->priomap[i];
+	}
 
 	new_priomap->priomap_len = new_len;
 
