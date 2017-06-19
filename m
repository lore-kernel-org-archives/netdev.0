From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH net-next v2] enic: Fix format truncation warning
Date: Mon, 19 Jun 2017 16:28:44 -0700
Message-ID: <20170619232844.34916-1-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-5.cisco.com ([173.37.142.92]:19353 "EHLO
        alln-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752289AbdFSX3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 19:29:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With -Wformat-truncation, gcc throws the following warning.

Fix this by increasing the size of devname to accommodate 15 character
netdev interface name and description.

Remove length format precision for %s. We can fit entire name.

Also increment the version.

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

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
v2: dont use kasprintf, increase the devname size
    http://patchwork.ozlabs.org/patch/777568/

 drivers/net/ethernet/cisco/enic/enic.h      | 4 ++--
 drivers/net/ethernet/cisco/enic/enic_main.c | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 2b23f46b34d3..ba032ac9ae86 100644
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
+	char devname[IFNAMSIZ + 8];
 	irqreturn_t (*isr)(int, void *);
 	void *devid;
 	cpumask_var_t affinity_mask;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 6a9c8878aca0..d24ee1ad3be1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1737,7 +1737,7 @@ static int enic_request_intr(struct enic *enic)
 			intr = enic_msix_rq_intr(enic, i);
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
-				"%.11s-rx-%u", netdev->name, i);
+				"%s-rx-%u", netdev->name, i);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[i];
 		}
@@ -1748,7 +1748,7 @@ static int enic_request_intr(struct enic *enic)
 			intr = enic_msix_wq_intr(enic, i);
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
-				"%.11s-tx-%u", netdev->name, i);
+				"%s-tx-%u", netdev->name, i);
 			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[wq];
 		}
@@ -1756,14 +1756,14 @@ static int enic_request_intr(struct enic *enic)
 		intr = enic_msix_err_intr(enic);
 		snprintf(enic->msix[intr].devname,
 			sizeof(enic->msix[intr].devname),
-			"%.11s-err", netdev->name);
+			"%s-err", netdev->name);
 		enic->msix[intr].isr = enic_isr_msix_err;
 		enic->msix[intr].devid = enic;
 
 		intr = enic_msix_notify_intr(enic);
 		snprintf(enic->msix[intr].devname,
 			sizeof(enic->msix[intr].devname),
-			"%.11s-notify", netdev->name);
+			"%s-notify", netdev->name);
 		enic->msix[intr].isr = enic_isr_msix_notify;
 		enic->msix[intr].devid = enic;
 
-- 
2.13.1
