From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH] ehea: only register irq after setting up ports
Date: Mon, 23 Apr 2012 10:46:29 -0300
Message-ID: <1335188789-6211-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:56394 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab2DWNqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 09:46:36 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Mon, 23 Apr 2012 10:46:34 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we receive an interrupt too early before we set up ports in the probe
function, there won't be any port ready to handle it.

Only registering the irq after the ports are setup fixes the problem,
and works fine without losing any interrupts.

This causes crashes in some situations:

[c000000f7ff7fd60] d000000008e223f0 .ehea_neq_tasklet+0x78/0x148 [ehea]
[c000000f7ff7fe00] c0000000000b6cac .tasklet_hi_action+0xdc/0x210
[c000000f7ff7fea0] c0000000000b7cc8 .__do_softirq+0x178/0x300
[c000000f7ff7ff90] c000000000022694 .call_do_softirq+0x14/0x24
[c000000f68ee7900] c000000000010e04 .do_softirq+0xec/0x110
[c000000f68ee79a0] c0000000000b789c .irq_exit+0xac/0xe0
[c000000f68ee7a20] c0000000000110bc .do_IRQ+0x114/0x2a8
[c000000f68ee7ae0] c00000000000553c hardware_interrupt_entry+0x18/0x1c
--- Exception: 501 (Hardware Interrupt) at c00000000000e6bc
.arch_local_irq_rest
ore+0x34/0x48
[link register   ] c000000000017a7c .cpu_idle+0x194/0x2f8
[c000000f68ee7dd0] c000000000017a70 .cpu_idle+0x188/0x2f8 (unreliable)
[c000000f68ee7e90] c00000000066b264 .start_secondary+0x3e4/0x524
[c000000f68ee7f90] c0000000000092e8 .start_secondary_prolog+0x10/0x14

cpu 0x8: Vector: 300 (Data Access) at [c000000f7ff7fa40]
    pc: d000000008e21fac: .ehea_parse_eqe+0x6c/0x438 [ehea]
    lr: d000000008e223f0: .ehea_neq_tasklet+0x78/0x148 [ehea]
    sp: c000000f7ff7fcc0
   msr: 8000000000009032
   dar: 8
 dsisr: 40000000
  current = 0xc000000f68efc0c0
  paca    = 0xc00000000ff41800
    pid   = 0, comm = kworker/0:1

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Cc: stable@vger.kernel.org
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   30 +++++++++++++++++-----------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 3516e17..acf34b6 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -3261,6 +3261,7 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 	struct ehea_adapter *adapter;
 	const u64 *adapter_handle;
 	int ret;
+	int i;
 
 	if (!dev || !dev->dev.of_node) {
 		pr_err("Invalid ibmebus device probed\n");
@@ -3314,17 +3315,9 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 	tasklet_init(&adapter->neq_tasklet, ehea_neq_tasklet,
 		     (unsigned long)adapter);
 
-	ret = ibmebus_request_irq(adapter->neq->attr.ist1,
-				  ehea_interrupt_neq, IRQF_DISABLED,
-				  "ehea_neq", adapter);
-	if (ret) {
-		dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
-		goto out_kill_eq;
-	}
-
 	ret = ehea_create_device_sysfs(dev);
 	if (ret)
-		goto out_free_irq;
+		goto out_kill_eq;
 
 	ret = ehea_setup_ports(adapter);
 	if (ret) {
@@ -3332,15 +3325,28 @@ static int __devinit ehea_probe_adapter(struct platform_device *dev,
 		goto out_rem_dev_sysfs;
 	}
 
+	ret = ibmebus_request_irq(adapter->neq->attr.ist1,
+				  ehea_interrupt_neq, IRQF_DISABLED,
+				  "ehea_neq", adapter);
+	if (ret) {
+		dev_err(&dev->dev, "requesting NEQ IRQ failed\n");
+		goto out_shutdown_ports;
+	}
+
+
 	ret = 0;
 	goto out;
 
+out_shutdown_ports:
+	for (i = 0; i < EHEA_MAX_PORTS; i++)
+		if (adapter->port[i]) {
+			ehea_shutdown_single_port(adapter->port[i]);
+			adapter->port[i] = NULL;
+		}
+
 out_rem_dev_sysfs:
 	ehea_remove_device_sysfs(dev);
 
-out_free_irq:
-	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
-
 out_kill_eq:
 	ehea_destroy_eq(adapter->neq);
 
-- 
1.7.4.4
