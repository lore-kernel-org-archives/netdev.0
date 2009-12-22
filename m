From: Anton Vorontsov <cbouatmailru@gmail.com>
Subject: [PATCH 3/3] ucc_geth: Fix netdev watchdog triggering on suspend
Date: Wed, 23 Dec 2009 01:15:04 +0300
Message-ID: <20091222221504.GC9268@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
	Andy Fleming <afleming@freescale.com>, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

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
index afaf088..7225d5d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3601,6 +3601,7 @@ static int ucc_geth_suspend(struct of_device *ofdev, pm_message_t state)
 	if (!netif_running(ndev))
 		return 0;
 
+	netif_device_detach(ndev);
 	napi_disable(&ugeth->napi);
 
 	/*
@@ -3659,7 +3660,7 @@ static int ucc_geth_resume(struct of_device *ofdev)
 	phy_start(ugeth->phydev);
 
 	napi_enable(&ugeth->napi);
-	netif_start_queue(ndev);
+	netif_device_attach(ndev);
 
 	return 0;
 }
-- 
1.6.3.3
