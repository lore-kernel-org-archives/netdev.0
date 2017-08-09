From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Wed,  9 Aug 2017 12:42:02 +0200
Message-ID: <20170809104202.30959-1-vkuznets@redhat.com>
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent 'transparenf VF' changes to netvsc driver made VF interfaces
register as netvsc interface slaves upon appearance. This led to udev
not being able to rename the interface according to the 'predictable
interface names' scheme:

 kernel: mlx4_core 0002:00:02.0 eth2: joined to eth1
 kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: VF
  registering: eth2
 kernel: mlx4_en: eth2: Link Up
 kernel: hv_netvsc 33b7a6f9-6736-451f-8fce-b382eaa50bee eth1: Data path
  switched to VF: eth2
 systemd-udevd[1785]: Error changing net interface name 'eth2' to
  'enP2p0s2': Device or resource busy
 systemd-udevd[1785]: could not rename interface '5' from 'eth2' to
  'enP2p0s2': Device or resource busy

What happens is: __netvsc_vf_setup() does dev_open() for the VF device and
the consecutive dev_change_name() fails with -EBUSY because of the
(dev->flags & IFF_UP) check. The history of this code predates git so I
wasn't able to figure out when and why the check was added, everything
seems to work fine without it. dev_change_name() has only two call sites,
both hold rtnl_lock.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 RFC: I'm probably miossing something obvious and the check can't be just
 dropped. Stephen suggested a different solution to the isuue:
 https://www.spinics.net/lists/netdev/msg448243.html but it has its own
 drawbacks.
---
 net/core/dev.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1d75499add72..c608e233a78a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1186,8 +1186,6 @@ int dev_change_name(struct net_device *dev, const char *newname)
 	BUG_ON(!dev_net(dev));
 
 	net = dev_net(dev);
-	if (dev->flags & IFF_UP)
-		return -EBUSY;
 
 	write_seqcount_begin(&devnet_rename_seq);
 
-- 
2.13.4
