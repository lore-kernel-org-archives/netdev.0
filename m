From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH net v5 1/5] forcedeth: fix race when unloading module
Date: Sat,  5 Nov 2011 17:38:20 -0700
Message-ID: <56e2eee6114a007182241428deee8821f1586b50.1320539724.git.david.decotigny@google.com>
References: <cover.1320539724.git.david.decotigny@google.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	David Decotigny <david.decotigny@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1320539724.git.david.decotigny@google.com>
In-Reply-To: <cover.1320539724.git.david.decotigny@google.com>
References: <cover.1320539724.git.david.decotigny@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When forcedeth module is unloaded, there exists a path that can lead
to mod_timer() after del_timer_sync(), causing an oops. This patch
short-circuits this unneeded path, which originates in
nv_get_ethtool_stats().

Tested:
  x86_64 16-way + 3 ethtool -S infinite loops + 100Mbps incoming traffic
  + rmmod/modprobe/ifconfig in a loop

Initial-Author: Salman Qazi <sqazi@google.com>
Discussion: http://patchwork.ozlabs.org/patch/123548/


Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 1e37eb9..344cb5f 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4566,7 +4566,7 @@ static void nv_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *e
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* update stats */
-	nv_do_stats_poll((unsigned long)dev);
+	nv_get_hw_stats(dev);
 
 	memcpy(buffer, &np->estats, nv_get_sset_count(dev, ETH_SS_STATS)*sizeof(u64));
 }
-- 
1.7.3.1
