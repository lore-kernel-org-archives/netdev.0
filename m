From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net-next] enic: use kasprintf instead of snprintf
Date: Sun, 18 Jun 2017 22:05:37 -0700
Message-ID: <20170619050537.6393-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-7.cisco.com ([173.37.142.94]:48608 "EHLO
        alln-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdFSFG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 01:06:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With -Wformat-truncation=, gcc throws the following warning. Instead of
using snprintf, use kasprintf and allocate string size as needed.

drivers/net/ethernet/cisco/enic/enic_main.c: In function ‘enic_open’:
drivers/net/ethernet/cisco/enic/enic_main.c:1740:15: warning: ‘%u’ directive output may be truncated writing between 1 and 2 bytes into a region of size between 1 and 12 [-Wformat-truncation=]
     "%.11s-rx-%u", netdev->name, i);
               ^~
drivers/net/ethernet/cisco/enic/enic_main.c:1740:5: note: directive argument in the range [0, 16]
     "%.11s-rx-%u", netdev->name, i);
     ^~~~~~~~~~~~~
drivers/net/ethernet/cisco/enic/enic_main.c:1738:4: note: ‘snprintf’ output between 6 and 18 bytes into a destination of size 16
    snprintf(enic->msix[intr].devname,
    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     sizeof(enic->msix[intr].devname),
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     "%.11s-rx-%u", netdev->name, i);
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/net/ethernet/cisco/enic/enic_main.c:1751:5: warning: ‘snprintf’ output may be truncated before the last format character [-Wformat-truncation=]
     "%.11s-tx-%u", netdev->name, i);
     ^~~~~~~~~~~~~

also increment the version.

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  4 +--
 drivers/net/ethernet/cisco/enic/enic_main.c | 38 +++++++++++++++++++----------
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 2b23f46b34d3..b8de2813119f 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.3.0.31"
+#define DRV_VERSION		"2.3.0.42"
 #define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -47,7 +47,7 @@
 
 struct enic_msix_entry {
 	int requested;
-	char devname[IFNAMSIZ];
+	char *devname;
 	irqreturn_t (*isr)(int, void *);
 	void *devid;
 	cpumask_var_t affinity_mask;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 6a9c8878aca0..11b79f26af75 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1701,9 +1701,11 @@ static void enic_free_intr(struct enic *enic)
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < ARRAY_SIZE(enic->msix); i++)
-			if (enic->msix[i].requested)
+			if (enic->msix[i].requested) {
 				free_irq(enic->msix_entry[i].vector,
 					enic->msix[i].devid);
+				kfree(enic->msix[i].devname);
+			}
 		break;
 	default:
 		break;
@@ -1735,9 +1737,12 @@ static int enic_request_intr(struct enic *enic)
 
 		for (i = 0; i < enic->rq_count; i++) {
 			intr = enic_msix_rq_intr(enic, i);
-			snprintf(enic->msix[intr].devname,
-				sizeof(enic->msix[intr].devname),
-				"%.11s-rx-%u", netdev->name, i);
+			enic->msix[intr].devname = kasprintf(GFP_KERNEL,
+							     "%s-rx-%u",
+							     netdev->name, i);
+			if (!enic->msix[intr].devname)
+				netdev_warn(netdev, "name alloc failed for intr %d",
+					    intr);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[i];
 		}
@@ -1746,24 +1751,31 @@ static int enic_request_intr(struct enic *enic)
 			int wq = enic_cq_wq(enic, i);
 
 			intr = enic_msix_wq_intr(enic, i);
-			snprintf(enic->msix[intr].devname,
-				sizeof(enic->msix[intr].devname),
-				"%.11s-tx-%u", netdev->name, i);
+			enic->msix[intr].devname = kasprintf(GFP_KERNEL,
+							     "%s-tx-%u",
+							     netdev->name, i);
+			if (!enic->msix[intr].devname)
+				netdev_warn(netdev, "name alloc failed for intr %d",
+					    intr);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[wq];
 		}
 
 		intr = enic_msix_err_intr(enic);
-		snprintf(enic->msix[intr].devname,
-			sizeof(enic->msix[intr].devname),
-			"%.11s-err", netdev->name);
+		enic->msix[intr].devname = kasprintf(GFP_KERNEL, "%s-err",
+						     netdev->name);
+		if (!enic->msix[intr].devname)
+			netdev_warn(netdev, "name alloc failed for intr %d",
+				    intr);
 		enic->msix[intr].isr = enic_isr_msix_err;
 		enic->msix[intr].devid = enic;
 
 		intr = enic_msix_notify_intr(enic);
-		snprintf(enic->msix[intr].devname,
-			sizeof(enic->msix[intr].devname),
-			"%.11s-notify", netdev->name);
+		enic->msix[intr].devname = kasprintf(GFP_KERNEL, "%s-notify",
+						     netdev->name);
+		if (!enic->msix[intr].devname)
+			netdev_warn(netdev, "name alloc failed for intr %d",
+				    intr);
 		enic->msix[intr].isr = enic_isr_msix_notify;
 		enic->msix[intr].devid = enic;
 
-- 
2.13.1
