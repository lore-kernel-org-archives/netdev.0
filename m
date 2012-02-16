From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] atl1c: dont use highprio tx queue
Date: Thu, 16 Feb 2012 07:43:11 +0100
Message-ID: <1329374591.5646.23.camel@edumazet-laptop>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
	 <C6B7BB6C-D1B8-4454-A2B2-558FCA5B0BBD@m3y3r.de>
	 <1329373082.5646.9.camel@edumazet-laptop>
	 <21390AB8-BD9B-44D7-B2CE-B20AF7605CE7@m3y3r.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>, Josh Boyer <jwboyer@gmail.com>
To: Thomas Meyer <thomas@m3y3r.de>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <21390AB8-BD9B-44D7-B2CE-B20AF7605CE7@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver attempts to use two TX rings but lacks proper support :

1) IRQ handler only takes care of TX completion on first TX ring
2) the stop/start logic uses the legacy functions (for non multiqueue
drivers)

This means all packets witk skb mark set to 1 are sent through high
queue but are never cleaned and queue eventualy fills and block the
device, triggering the infamous "NETDEV WATCHDOG" message. 

Lets use a single TX ring to fix the problem, this driver is not a real
multiqueue one yet.

Minimal fix for stable kernels.

Reported-by: Thomas Meyer <thomas@m3y3r.de>
Tested-by: Thomas Meyer <thomas@m3y3r.de>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b859124..1ff3c6d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -2244,10 +2244,6 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
 			dev_info(&adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
-	if (skb->mark == 0x01)
-		type = atl1c_trans_high;
-	else
-		type = atl1c_trans_normal;
 
 	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
 		/* no enough descriptor, just stop queue */
