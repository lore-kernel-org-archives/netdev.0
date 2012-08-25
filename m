From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 2/3] forcedeth: fix TX timeout caused by TX pause on down link
Date: Fri, 24 Aug 2012 20:22:52 -0700
Message-ID: <e4db06d22eafcafc2f9e1345832ec4283fbecefe.1345864542.git.decot@googlers.com>
References: <cover.1345864542.git.decot@googlers.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: Ayaz Abdulla <aabdulla@nvidia.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1345864542.git.decot@googlers.com>
In-Reply-To: <cover.1345864542.git.decot@googlers.com>
References: <cover.1345864542.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some dual-port forcedeth devices such as MCP55 10de:0373 (rev a3),
when autoneg & TX pause are enabled while port is connected but
interface is down, the NIC will eventually freeze (TX timeouts,
network unreachable).

This patch ensures that TX pause is not configured in hardware when
interface is down. The TX pause request will be honored when interface
is later configured.

Tested:
 - hardware is MCP55 device id 10de:0373 (rev a3), dual-port
 - eth0 connected and UP, eth1 connected but DOWN
 - without this patch, following sequence would brick NIC:
      ifconfig eth0 down
      ifconfig eth1 up
      ifconfig eth1 down
      ethtool -A eth1 autoneg off rx on tx off
      ifconfig eth1 up
      ifconfig eth1 down
      ethtool -A eth1 autoneg on rx on tx on
      ifconfig eth1 up
      ifconfig eth1 down
      ifup eth0
      sleep 120  # or longer
      ethtool eth1
   Just in case, sequence to un-brick:
      ifconfig eth0 down
      ethtool -A eth1 autoneg off rx on tx off
      ifconfig eth1 up
      ifconfig eth1 down
      ifup eth0
 - with this patch: no TX timeout after "bricking" sequence above

Details:
 - The following register accesses have been identified as the ones
   causing the NIC to freeze in "bricking" sequence above:
    - write NVREG_TX_PAUSEFRAME_ENABLE_V1 to eth1's register NvRegTxPauseFrame
    - write NVREG_MISC1_PAUSE_TX | NVREG_MISC1_FORCE to eth1's register NvRegMisc1
    - write 0 to eth1's register NvRegTransmitterControl
   This is what this patch avoids.



Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 51d19d8..8b82457 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3409,7 +3409,7 @@ set_speed:
 
 	pause_flags = 0;
 	/* setup pause frame */
-	if (np->duplex != 0) {
+	if (netif_running(dev) && (np->duplex != 0)) {
 		if (np->autoneg && np->pause_flags & NV_PAUSEFRAME_AUTONEG) {
 			adv_pause = adv & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
 			lpa_pause = lpa & (LPA_PAUSE_CAP | LPA_PAUSE_ASYM);
@@ -5455,6 +5455,7 @@ static int nv_close(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	spin_lock_irq(&np->lock);
+	nv_update_pause(dev, 0); /* otherwise stop_tx bricks NIC */
 	nv_stop_rxtx(dev);
 	nv_txrx_reset(dev);
 
-- 
1.7.10.2.5.g20d7bc9
