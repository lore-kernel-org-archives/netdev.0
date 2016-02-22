From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] netcp: use pointer to fix build fail
Date: Mon, 22 Feb 2016 22:55:43 +0530
Message-ID: <1456161943-9206-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While building keystone_defconfig of arm we are getting build failure
with the error:

drivers/net/ethernet/ti/netcp_core.c:1846:31: error: invalid type argument of '->' (have 'struct tc_to_netdev')
  if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
                               ^
drivers/net/ethernet/ti/netcp_core.c:1851:35: error: invalid type argument of '->' (have 'struct tc_to_netdev')
      (dev->real_num_tx_queues < tc->tc))
                                   ^
drivers/net/ethernet/ti/netcp_core.c:1855:8: error: invalid type argument of '->' (have 'struct tc_to_netdev')
  if (tc->tc) {
        ^
drivers/net/ethernet/ti/netcp_core.c:1856:28: error: invalid type argument of '->' (have 'struct tc_to_netdev')
   netdev_set_num_tc(dev, tc->tc);
                            ^
drivers/net/ethernet/ti/netcp_core.c:1857:21: error: invalid type argument of '->' (have 'struct tc_to_netdev')
   for (i = 0; i < tc->tc; i++)
                     ^
drivers/net/ethernet/ti/netcp_core.c: At top level:
drivers/net/ethernet/ti/netcp_core.c:1879:2: warning: initialization from incompatible pointer type
  .ndo_setup_tc  = netcp_setup_tc,
  ^

The callback of ndo_setup_tc should be:
int (*ndo_setup_tc)(struct net_device *dev, u32 handle, __be16 protocol,
                    struct tc_to_netdev *tc);

But we missed marking the last argument as a pointer.

Fixes: 16e5cc647173 ("net: rework setup_tc ndo op to consume general tc operand")
CC: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>
---

build log at:
https://travis-ci.org/sudipm-mukherjee/parport/jobs/110890068

 drivers/net/ethernet/ti/netcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 8586a20..06a0a73 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1836,7 +1836,7 @@ static u16 netcp_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-			  struct tc_to_netdev tc)
+			  struct tc_to_netdev *tc)
 {
 	int i;
 
-- 
1.9.1
