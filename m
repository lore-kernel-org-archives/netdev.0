From: Jiang Wang <Jiang.Wang@riverbed.com>
Subject: [PATCH] bnx2: turn off the network statck during initialization
Date: Thu, 16 Aug 2012 11:21:35 -0700
Message-ID: <1345141295-7589-1-git-send-email-Jiang.Wang@riverbed.com>
Cc: clala@riverbed.com, Francis.St.Amant@riverbed.com,
	Jiang Wang <Jiang.Wang@riverbed.com>,
	Jiang Wang <jwang@riverbed.com>
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initialization state of bnx2 driver is wrong. It does not turn
of the Linux network stack using netif_carrier_off. This may lead to
inconsistent report from ethtool as the link is up but speed is
unknown when the cable is not plugged in.

E.g.
        Speed: Unknown! (0)<--------------------------------------
        Duplex: Half       <--------------------------------------
        MDI: Unknown! (0)
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Link detected: yes <---------------------------------------

This patches fixed the problem by turning off the network stack
during initialization.

Signed-off-by: Jiang Wang <jwang@riverbed.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ac7b744..ce4548d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8463,6 +8463,10 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= dev->hw_features;
 	dev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* tell the stack to leave us alone until bnx2_open() is called */
+	netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
-- 
1.7.1
