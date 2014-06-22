From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH RFC 18/30] net: fec: remove inappropriate calls around
	fec_restart()
Date: Sun, 22 Jun 2014 08:07:33 +0000
Message-ID: <128d67859f28449cbc00491cd552ee7f@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
 <E1Wxxgx-0005Y0-50@rmk-PC.arm.linux.org.uk>
 <869ac1ad635844ee84adbecd2eb0d0dc@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140622075514.GA32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0187.outbound.protection.outlook.com ([207.46.163.187]:41958
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751199AbaFVIHh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 04:07:37 -0400
In-Reply-To: <20140622075514.GA32514@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Sunday, June 22, 2014 3:55 PM
>To: Duan Fugang-B38611
>Cc: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org
>Subject: Re: [PATCH RFC 18/30] net: fec: remove inappropriate calls around
>fec_restart()
>
>On Sun, Jun 22, 2014 at 06:54:28AM +0000, fugang.duan@freescale.com wrote:
>> From: Russell King <rmk@arm.linux.org.uk> Data: Friday, June 20, 2014
>> 8:13 PM
>> >To: linux-arm-kernel@lists.infradead.org
>> >Cc: Duan Fugang-B38611; netdev@vger.kernel.org
>> >Subject: [PATCH RFC 18/30] net: fec: remove inappropriate calls
>> >around
>> >fec_restart()
>> >
>> >This is the second stage to "move calls to quiesce/resume packet
>> >processing out of fec_restart()", where we remove calls which are not
>> >appropriate to the call site.
>> >
>> >In the majority of cases, there is no need to detach and reattach the
>> >interface as we are holding the queue xmit lock across the reset.
>> >The exception to that is in fec_resume(), where we are already
>> >detached by the suspend function.  Here, we can remove the call to
>detach the interface.
>> >
>> >We also do not need to stop the transmit queue.  Holding the xmit
>> >lock is enough to ensure that the transmit packet processing is not
>> >running while we perform our task.  However, since fec_restart()
>> >always cleans the rings, we call netif_wake_queue() (or
>> >netif_device_attach() in the case of resume) just before dropping the
>xmit lock.  This prevents the watchdog firing.
>> >
>> >Lastly, always call napi_enable() after the device has been
>> >reattached in the resume path so that we know that the transmit
>> >packet processing is already in an enabled state, so we don't call
>> >netif_wake_queue() while detached.
>> >
>> >Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
>> >---
>> > drivers/net/ethernet/freescale/fec_main.c | 26
>> >++++++--------------------
>> > 1 file changed, 6 insertions(+), 20 deletions(-)
>> >
>> >diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> >b/drivers/net/ethernet/freescale/fec_main.c
>> >index 4a295b4bfb94..49c154af6da2 100644
>> >--- a/drivers/net/ethernet/freescale/fec_main.c
>> >+++ b/drivers/net/ethernet/freescale/fec_main.c
>> >@@ -1058,15 +1058,12 @@ static void fec_enet_work(struct work_struct
>*work)
>> > 		fep->delay_work.timeout = false;
>> > 		rtnl_lock();
>> > 		if (netif_device_present(ndev) || netif_running(ndev)) {
>> >-			netif_device_detach(ndev);
>> > 			napi_disable(&fep->napi);
>> >-			netif_tx_disable(ndev);
>> > 			netif_tx_lock_bh(ndev);
>> > 			fec_restart(ndev, fep->full_duplex);
>> >-			netif_tx_unlock_bh(ndev);
>> > 			netif_wake_queue(ndev);
>> >+			netif_tx_unlock_bh(ndev);
>> > 			napi_enable(&fep->napi);
>> >-			netif_device_attach(ndev);
>> > 		}
>> > 		rtnl_unlock();
>> > 	}
>> >@@ -1524,15 +1521,12 @@ static void fec_enet_adjust_link(struct
>> >net_device
>> >*ndev)
>> >
>> > 		/* if any of the above changed restart the FEC */
>> > 		if (status_change) {
>> >-			netif_device_detach(ndev);
>> > 			napi_disable(&fep->napi);
>> >-			netif_tx_disable(ndev);
>> > 			netif_tx_lock_bh(ndev);
>> > 			fec_restart(ndev, phy_dev->duplex);
>> >-			netif_tx_unlock_bh(ndev);
>> > 			netif_wake_queue(ndev);
>> >+			netif_tx_unlock_bh(ndev);
>> > 			napi_enable(&fep->napi);
>> >-			netif_device_attach(ndev);
>> > 		}
>> > 	} else {
>> > 		if (fep->link) {
>> >@@ -1919,15 +1913,12 @@ static int fec_enet_set_pauseparam(struct
>> >net_device *ndev,
>> > 		phy_start_aneg(fep->phy_dev);
>> > 	}
>> > 	if (netif_running(ndev)) {
>> >-		netif_device_detach(ndev);
>> > 		napi_disable(&fep->napi);
>> >-		netif_tx_disable(ndev);
>> > 		netif_tx_lock_bh(ndev);
>> > 		fec_restart(ndev, fep->full_duplex);
>> >-		netif_tx_unlock_bh(ndev);
>> > 		netif_wake_queue(ndev);
>> >+		netif_tx_unlock_bh(ndev);
>> > 		napi_enable(&fep->napi);
>> >-		netif_device_attach(ndev);
>> > 	}
>> >
>> > 	return 0;
>> >@@ -2372,15 +2363,12 @@ static int fec_set_features(struct net_device
>> >*netdev,
>> >
>> > 		if (netif_running(netdev)) {
>> > 			fec_stop(netdev);
>> >-			netif_device_detach(netdev);
>> > 			napi_disable(&fep->napi);
>> >-			netif_tx_disable(netdev);
>> > 			netif_tx_lock_bh(netdev);
>> > 			fec_restart(netdev, fep->phy_dev->duplex);
>> >-			netif_tx_unlock_bh(netdev);
>> > 			netif_wake_queue(netdev);
>> >+			netif_tx_unlock_bh(netdev);
>> > 			napi_enable(&fep->napi);
>> >-			netif_device_attach(netdev);
>> > 		}
>> > 	}
>> >
>> >@@ -2748,15 +2736,13 @@ fec_resume(struct device *dev)
>> >
>> > 	rtnl_lock();
>> > 	if (netif_running(ndev)) {
>> >-		netif_device_detach(ndev);
>> > 		napi_disable(&fep->napi);
>> >-		netif_tx_disable(ndev);
>> > 		netif_tx_lock_bh(ndev);
>> > 		fec_restart(ndev, fep->full_duplex);
>> >+		netif_device_attach(ndev);
>> > 		netif_tx_unlock_bh(ndev);
>> >-		netif_wake_queue(ndev);
>> >-		napi_enable(&fep->napi);
>> > 		netif_device_attach(ndev);
>> >+		napi_enable(&fep->napi);
>> > 		phy_start(fep->phy_dev);
>> > 	}
>> > 	rtnl_unlock();
>> >--
>> Patch #17 anc #18 can merge to one patch.
>
>While you can merge various patches together into a single patch, the
>question is whether it's the right thing to do.
>
>I kept 17 and 18 separate as 17 is merely moving the calls out without
>modification, whereas 18 is changing the functionality.
>
>That makes 17 easy to review - from the reviewer perspective, it's a case
>of ensuring that the calls are all placed at the fec_restart() callsite.
>Once that's done, then each callsite can be considered on its own merit
>for the changes in patch 18.
>
Understand.

Thanks,
Andy
