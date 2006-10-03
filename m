From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 3/5] ibmveth: kdump interrupt fix
Date: Tue, 03 Oct 2006 12:24:34 -0500
Message-ID: <20061003172434.14851.99084.sendpatchset@ltcml8p1.rchland.ibm.com>
References: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:19690 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030452AbWJCS1Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:27:24 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IRNpT003729
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IRN8m499274
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IRL4O026982
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:21 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santiago Leon <santil@us.ibm.com>

This patch fixes a race that panics the kernel when opening the device after a kdump.  Without this patch there is a window where the hypervisor can send an interrupt before all the structures for the kdump ibmveth module are ready (because the hypervisor is not aware that the partition crashed and that the virtual driver is reloading).  We close this window by disabling the interrupts before registering the adapter to the hypervisor.

This patch depends on the "ibmveth: Harden driver initilisation" patch.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---
 drivers/net/ibmveth.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -527,6 +527,8 @@ static int ibmveth_open(struct net_devic
 	ibmveth_debug_printk("filter list @ 0x%p\n", adapter->filter_list_addr);
 	ibmveth_debug_printk("receive q   @ 0x%p\n", adapter->rx_queue.queue_addr);
 
+	h_vio_signal(adapter->vdev->unit_address, VIO_IRQ_DISABLE);
+
 	lpar_rc = ibmveth_register_logical_lan(adapter, rxq_desc, mac_address);
 
 	if(lpar_rc != H_SUCCESS) {
