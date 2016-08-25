From: rick.jones2@hpe.com (Rick Jones)
Subject: [PATCH v2 net-next] documentation: Document issues with VMs and XPS and drivers enabling it on their own
Date: Thu, 25 Aug 2016 15:55:43 -0700 (PDT)
Message-ID: <20160825225543.BFA562900836@tardy>
Cc: <alexander.duyck@gmail.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t6225.austin.hp.com ([15.73.96.126]:52425 "EHLO
        g1t6225.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751972AbcHYWzt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:55:49 -0400
Received: from g2t4621.austin.hp.com (g2t4621.austin.hp.com [15.73.212.80])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g1t6225.austin.hp.com (Postfix) with ESMTPS id B1946446D
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 22:55:48 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hpe.com>

Since XPS was first introduced two things have happened.  Some drivers
have started enabling XPS on their own initiative, and it has been
found that when a VM is sending data through a host interface with XPS
enabled, that traffic can end-up seriously out of order.

Signed-off-by: Rick Jones <rick.jones2@hpe.com>
Reviewed-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 59f4db2..50cc888 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -400,15 +400,31 @@ transport layer is responsible for setting ooo_okay appropriately. TCP,
 for instance, sets the flag when all data for a connection has been
 acknowledged.
 
+When the traffic source is a VM running on the host, there is no
+socket structure known to the host.  In this case, unless the VM is
+itself CPU-pinned, the traffic being sent from it can end-up queued to
+multiple transmit queues and end-up being transmitted out of order.
+
+In some cases this can result in a considerable loss of performance.
+
+In such situations, XPS should not be enabled at runtime, or
+explicitly disabled if the NIC driver(s) in question enable it on
+their own.  Otherwise, if possible, the VMs should be CPU pinned.
+
 ==== XPS Configuration
 
-XPS is only available if the kconfig symbol CONFIG_XPS is enabled (on by
-default for SMP). The functionality remains disabled until explicitly
-configured. To enable XPS, the bitmap of CPUs that may use a transmit
-queue is configured using the sysfs file entry:
+XPS is available only if the kconfig symbol CONFIG_XPS is enabled
+prior to building the kernel.  It is enabled by default for SMP kernel
+configurations.  In many cases the functionality remains disabled at
+runtime until explicitly configured by the system administrator. To
+enable XPS, the bitmap of CPUs that may use a transmit queue is
+configured using the sysfs file entry:
 
 /sys/class/net/<dev>/queues/tx-<n>/xps_cpus
 
+However, some NIC drivers will configure XPS at runtime for the
+interfaces they drive, via a call to netif_set_xps_queue.
+
 == Suggested Configuration
 
 For a network device with a single transmission queue, XPS configuration
