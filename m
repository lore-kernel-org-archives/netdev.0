From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 3/3] ehea: do not dereference possible NULL port
Date: Tue, 17 Apr 2012 11:41:55 -0300
Message-ID: <1334673715-16338-4-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:40156 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2DQOmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 10:42:24 -0400
Received: from /spool/local
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Tue, 17 Apr 2012 11:42:16 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id DE42F1DC004D
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:42:10 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3HEfvJ527066636
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 11:41:57 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3HCg6eZ025287
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 09:42:07 -0300
In-Reply-To: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

port may be NULL when we receive an interrupt too early in the probe.

commit 8c4877a4128e7931077b024a891a4b284d8756a3, in particular, has
introduced this problem in the case of port state change interrupt.

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
Cc: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 35caeb5..5e64e66 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1156,21 +1156,22 @@ static void ehea_parse_eqe(struct ehea_adapter *adapter, u64 eqe)
 	u8 ec;
 	u8 portnum;
 	struct ehea_port *port;
-	struct net_device *dev;
+	struct net_device *dev = NULL;
 
 	ec = EHEA_BMASK_GET(NEQE_EVENT_CODE, eqe);
 	portnum = EHEA_BMASK_GET(NEQE_PORTNUM, eqe);
 	port = ehea_get_port(adapter, portnum);
+	if (!port) {
+		pr_err("%s: unknown portnum %d, event %x\n",
+					adapter->ofdev->name, portnum, ec);
+		return;
+	}
+
 	dev = port->netdev;
 
 	switch (ec) {
 	case EHEA_EC_PORTSTATE_CHG:	/* port state change */
 
-		if (!port) {
-			netdev_err(dev, "unknown portnum %x\n", portnum);
-			break;
-		}
-
 		if (EHEA_BMASK_GET(NEQE_PORT_UP, eqe)) {
 			if (!netif_carrier_ok(dev)) {
 				ret = ehea_sense_port_attr(port);
-- 
1.7.4.4
