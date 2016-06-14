From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 1/9] liquidio: Avoid double free during soft command
Date: Tue, 14 Jun 2016 16:54:43 -0700
Message-ID: <1465948491-10541-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0098.outbound.protection.outlook.com ([65.55.169.98]:59776
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751826AbcFOALY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:11:24 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to resolve the double free issue by checking proper return
values from soft command.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 4 ++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 4 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 245c063..1096cdb 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -317,7 +317,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 
 	retval = octeon_send_soft_command(oct_dev, sc);
 
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		dev_err(&oct_dev->pci_dev->dev,
 			"octnet_mdio45_access instruction failed status: %x\n",
 			retval);
@@ -722,7 +722,7 @@ static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
 	sc->wait_time = 1000;
 
 	retval = octeon_send_soft_command(oct_dev, sc);
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct_dev, sc);
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 655d89e..47fba0e 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2583,7 +2583,7 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
 				     sc, ih->dlengsz, ndata->reqtype);
 
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		dev_err(&oct->pci_dev->dev, "timestamp data packet failed status: %x\n",
 			retval);
 		octeon_free_soft_command(oct, sc);
@@ -3192,7 +3192,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		sc->wait_time = 1000;
 
 		retval = octeon_send_soft_command(octeon_dev, sc);
-		if (retval) {
+		if (retval == IQ_SEND_FAILED) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				"iq/oq config failed status: %x\n",
 				retval);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 1a01915..aacabe4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -178,7 +178,7 @@ octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
 	}
 
 	retval = octeon_send_soft_command(oct, sc);
-	if (retval) {
+	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct, sc);
 		dev_err(&oct->pci_dev->dev, "%s soft command send failed status: %x\n",
 			__func__, retval);
-- 
1.8.3.1
