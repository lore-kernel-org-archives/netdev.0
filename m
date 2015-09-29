From: Alexander Duyck <aduyck@mirantis.com>
Subject: [PATCH 1/3] ixgbe/ixgbevf: use napi_schedule_irqoff()
Date: Tue, 29 Sep 2015 15:19:43 -0700
Message-ID: <20150929221943.3388.21859.stgit@ahduyck-vm-fedora22>
References: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32911 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770AbbI2WTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:19:46 -0400
Received: by pacex6 with SMTP id ex6so18077430pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:19:45 -0700 (PDT)
In-Reply-To: <20150929215117.3388.48642.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ixgbe_intr and ixgbe/ixgbevf_msix_clean_rings functions run from hard
interrupt context or with interrupts already disabled in netpoll.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 693f2da33569..67dc916c94d6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2754,7 +2754,7 @@ static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 	/* EIAM disabled interrupts (on this vector) for us */
 
 	if (q_vector->rx.ring || q_vector->tx.ring)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2948,7 +2948,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		ixgbe_ptp_check_pps_event(adapter, eicr);
 
 	/* would disable interrupts here but EIAM disabled it */
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	/*
 	 * re-enable link(maybe) and non-queue interrupts, no flush.
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 592ff237d692..f1c5f3372667 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1288,7 +1288,7 @@ static irqreturn_t ixgbevf_msix_clean_rings(int irq, void *data)
 
 	/* EIAM disabled interrupts (on this vector) for us */
 	if (q_vector->rx.ring || q_vector->tx.ring)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
