From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 3/4] cxgb3: Fix potential msi-x vector leak
Date: Fri, 17 Apr 2009 15:21:22 -0700
Message-ID: <20090417222122.8537.43636.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752815AbZDQXD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 19:03:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Release vectors when a MSI-X allocation fails.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 99b5032..cbd59fe 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2917,8 +2917,13 @@ static int __devinit cxgb_enable_msix(struct adapter *adap)
 	while ((err = pci_enable_msix(adap->pdev, entries, vectors)) > 0)
 		vectors = err;
 
-	if (!err && vectors < (adap->params.nports + 1))
+	if (err < 0)
+		pci_disable_msix(adap->pdev);
+
+	if (!err && vectors < (adap->params.nports + 1)) {
+		pci_disable_msix(adap->pdev);
 		err = -1;
+	}
 
 	if (!err) {
 		for (i = 0; i < vectors; ++i)

