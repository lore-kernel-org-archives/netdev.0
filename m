From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/4] ucc_geth: Fix netdev watchdog triggering on suspend
Date: Wed, 30 Dec 2009 21:23:32 +0300
Message-ID: <20091230182332.GC13162@oksana.dev.rtsoft.ru>
References: <20091230182146.GA4515@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:43759 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752486AbZL3SXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:23:34 -0500
Content-Disposition: inline
In-Reply-To: <20091230182146.GA4515@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes ucc_geth fails to suspend with the following trace:

 ucc_geth e0103000.ucc: suspend
 ucc_geth e0102000.ucc: suspend
 NETDEV WATCHDOG: eth0 (ucc_geth): transmit queue 0 timed out
 ------------[ cut here ]------------
 Badness at net/sched/sch_generic.c:255
 NIP: c021cb5c LR: c021cb5c CTR: c01ab4b4
 [...]
 NIP [c021cb5c] dev_watchdog+0x298/0x2a8
 LR [c021cb5c] dev_watchdog+0x298/0x2a8
 Call Trace:
 [c0389da0] [c021cb5c] dev_watchdog+0x298/0x2a8 (unreliable)
 [c0389e00] [c0031ed8] run_timer_softirq+0x16c/0x1dc
 [c0389e50] [c002c638] __do_softirq+0xa4/0x11c
 [...]

This patch fixes the issue by properly detaching the device on
suspend, and attaching it back on resume.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 41ad2f3..96bdc0b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3607,6 +3607,7 @@ static int ucc_geth_suspend(struct of_device *ofdev, pm_message_t state)
 	if (!netif_running(ndev))
 		return 0;
 
+	netif_device_detach(ndev);
 	napi_disable(&ugeth->napi);
 
 	/*
@@ -3665,7 +3666,7 @@ static int ucc_geth_resume(struct of_device *ofdev)
 	phy_start(ugeth->phydev);
 
 	napi_enable(&ugeth->napi);
-	netif_start_queue(ndev);
+	netif_device_attach(ndev);
 
 	return 0;
 }
-- 
1.6.5.7

