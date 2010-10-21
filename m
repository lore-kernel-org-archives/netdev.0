From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: add a refcnt when turning on/off FCoE
	offload capability
Date: Thu, 21 Oct 2010 02:00:30 -0700
Message-ID: <20101021090027.12059.44871.stgit@localhost.localdomain>
References: <20101021085740.12059.20577.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:34081
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755354Ab0JUJAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 05:00:51 -0400
In-Reply-To: <20101021085740.12059.20577.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The FCoE offload is enabled/disabled per adapter, but upper FCoE protocol
stack could have multiple FCoE instances created on the same physical network
interface, e.g., FCoE on multiple VLAN interfaces on the same physical
network interface. In this case we want to turn on FCoE offload at the first
request from ndo_fcoe_enable() but only turn off FCoE offload at the very last
call to ndo_fcoe_disable(). This is fixed by adding a refcnt in the per adapter
FCoE structure and tear down FCoE offload when refcnt decrements to zero.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    6 ++++++
 drivers/net/ixgbe/ixgbe_fcoe.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 2f1de8b..05efa6a 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -604,11 +604,13 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 {
 	int rc = -EINVAL;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 
 
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_CAPABLE))
 		goto out_enable;
 
+	atomic_inc(&fcoe->refcnt);
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		goto out_enable;
 
@@ -648,6 +650,7 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 {
 	int rc = -EINVAL;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
 
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_CAPABLE))
 		goto out_disable;
@@ -655,6 +658,9 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		goto out_disable;
 
+	if (!atomic_dec_and_test(&fcoe->refcnt))
+		goto out_disable;
+
 	e_info(drv, "Disabling FCoE offload features.\n");
 	netdev->features &= ~NETIF_F_FCOE_CRC;
 	netdev->features &= ~NETIF_F_FSO;
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index abf4b2b..4bc2c55 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -66,6 +66,7 @@ struct ixgbe_fcoe {
 	u8 tc;
 	u8 up;
 #endif
+	atomic_t refcnt;
 	spinlock_t lock;
 	struct pci_pool *pool;
 	struct ixgbe_fcoe_ddp ddp[IXGBE_FCOE_DDP_MAX];

