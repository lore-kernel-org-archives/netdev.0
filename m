From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 6/8] vmxnet3: Disable napi in suspend,
	reenable in resume.
Date: Fri, 14 Jan 2011 16:59:52 -0800
Message-ID: <20110115005952.1064.9985.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Dmitry Torokhov <dtor@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a small possibility of a race where the suspend routine gets
called, while a napi callback is still pending and when that comes up,
it enables interrupts which just got disabled in the suspend routine.
This change adds napi disable call in suspend and enable in resume to
avoid race.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Acked-by: Dmitry Torokhov <dtor@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index a1632a9..20ef4f3 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3101,6 +3101,9 @@ vmxnet3_suspend(struct device *device)
 	if (!netif_running(netdev))
 		return 0;
 
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_disable(&adapter->rx_queue[i].napi);
+
 	vmxnet3_disable_all_intrs(adapter);
 	vmxnet3_free_irqs(adapter);
 	vmxnet3_free_intr_resources(adapter);
@@ -3192,7 +3195,7 @@ skip_arp:
 static int
 vmxnet3_resume(struct device *device)
 {
-	int err;
+	int err, i = 0;
 	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
@@ -3224,6 +3227,8 @@ vmxnet3_resume(struct device *device)
 			       VMXNET3_CMD_UPDATE_PMCFG);
 	vmxnet3_alloc_intr_resources(adapter);
 	vmxnet3_request_irqs(adapter);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		napi_enable(&adapter->rx_queue[i].napi);
 	vmxnet3_enable_all_intrs(adapter);
 
 	return 0;
