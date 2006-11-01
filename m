From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 03/18] e1000: FIX: enable hw TSO for IPV6
Date: Wed, 01 Nov 2006 09:51:35 -0800
Message-ID: <20061101175135.2356.61105.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:15376 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946961AbWKARm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:42:57 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Enable TSO for IPV6. All e1000 hardware supports it. This reduces CPU
utilizations by 50% when transmitting IPv6 frames.

Fix symbol naming enabling ipv6 TSO. Turn off TSO6 for 10/100.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    3 +++
 drivers/net/e1000/e1000_ethtool.c |    7 +++++++
 drivers/net/e1000/e1000_main.c    |   19 ++++++++++++++-----
 3 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 7ecce43..3f0be02 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -59,6 +59,9 @@
 #include <linux/capability.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#ifdef NETIF_F_TSO6
+#include <linux/ipv6.h>
+#endif
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <net/pkt_sched.h>
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 82d2c78..b9c0927 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -348,6 +348,13 @@ e1000_set_tso(struct net_device *netdev,
 	else
 		netdev->features &= ~NETIF_F_TSO;
 
+#ifdef NETIF_F_TSO6
+	if (data)
+		netdev->features |= NETIF_F_TSO6;
+	else
+		netdev->features &= ~NETIF_F_TSO6;
+#endif
+
 	DPRINTK(PROBE, INFO, "TSO is %s\n", data ? "Enabled" : "Disabled");
 	adapter->tso_force = TRUE;
 	return 0;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d3224c8..1e1198b 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -844,9 +844,9 @@ e1000_probe(struct pci_dev *pdev,
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-#ifdef NETIF_F_TSO_IPV6
+#ifdef NETIF_F_TSO6
 	if (adapter->hw.mac_type > e1000_82547_rev_2)
-		netdev->features |= NETIF_F_TSO_IPV6;
+		netdev->features |= NETIF_F_TSO6;
 #endif
 #endif
 	if (pci_using_dac)
@@ -1814,8 +1814,11 @@ e1000_setup_rctl(struct e1000_adapter *a
 		/* Configure extra packet-split registers */
 		rfctl = E1000_READ_REG(&adapter->hw, RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
-		/* disable IPv6 packet split support */
-		rfctl |= E1000_RFCTL_IPV6_DIS;
+		/* disable packet split support for IPv6 extension headers,
+		 * because some malformed IPv6 headers can hang the RX */
+		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
+		          E1000_RFCTL_NEW_IPV6_EXT_DIS);
+
 		E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
 
 		rctl |= E1000_RCTL_DTYP_PS;
@@ -2473,9 +2476,15 @@ e1000_watchdog(unsigned long data)
 					DPRINTK(PROBE,INFO,
 				        "10/100 speed: disabling TSO\n");
 					netdev->features &= ~NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+					netdev->features &= ~NETIF_F_TSO6;
+#endif
 					break;
 				case SPEED_1000:
 					netdev->features |= NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+					netdev->features |= NETIF_F_TSO6;
+#endif
 					break;
 				default:
 					/* oops */
@@ -2610,7 +2619,7 @@ e1000_tso(struct e1000_adapter *adapter,
 						   0);
 			cmd_length = E1000_TXD_CMD_IP;
 			ipcse = skb->h.raw - skb->data - 1;
-#ifdef NETIF_F_TSO_IPV6
+#ifdef NETIF_F_TSO6
 		} else if (skb->protocol == htons(ETH_P_IPV6)) {
 			skb->nh.ipv6h->payload_len = 0;
 			skb->h.th->check =



---
Auke Kok <auke-jan.h.kok@intel.com>
