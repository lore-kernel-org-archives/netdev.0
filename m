From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/5] r8169: bh locking redux and task scheduling.
Date: Tue, 31 Jan 2012 14:55:56 +0100
Message-ID: <20120131135555.GB18167@electric-eye.fr.zoreil.com>
References: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52426 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753780Ab2AaOHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:07:16 -0500
Content-Disposition: inline
In-Reply-To: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- atomic bit operations are globally visible
- pending status is always cleared before execution
- scheduled works are either idempotent or only required to happen once
  after a series of originating events, say link events for instance

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Suggested-by: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   20 ++++----------------
 1 files changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 859554a..118f6f6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3273,17 +3273,8 @@ out_mod_timer:
=20
 static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_fla=
g flag)
 {
-	spin_lock(&tp->lock);
 	if (!test_and_set_bit(flag, tp->wk.flags))
 		schedule_work(&tp->wk.work);
-	spin_unlock(&tp->lock);
-}
-
-static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum rtl_=
flag flag)
-{
-	local_bh_disable();
-	rtl_schedule_task(tp, flag);
-	local_bh_enable();
 }
=20
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -3291,7 +3282,7 @@ static void rtl8169_phy_timer(unsigned long __opa=
que)
 	struct net_device *dev =3D (struct net_device *)__opaque;
 	struct rtl8169_private *tp =3D netdev_priv(dev);
=20
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_PHY_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
=20
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -5635,7 +5626,7 @@ static void rtl8169_pcierr_interrupt(struct net_d=
evice *dev)
=20
 	rtl8169_hw_reset(tp);
=20
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
=20
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
@@ -5852,7 +5843,7 @@ static void rtl_slow_event_work(struct rtl8169_pr=
ivate *tp)
 		/* Work around for rx fifo overflow */
 		case RTL_GIGA_MAC_VER_11:
 			netif_stop_queue(dev);
-			rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+			rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 		default:
 			break;
 		}
@@ -5894,10 +5885,7 @@ static void rtl_task(struct work_struct *work)
 	for (i =3D 0; i < ARRAY_SIZE(rtl_work); i++) {
 		bool pending;
=20
-		spin_lock_bh(&tp->lock);
 		pending =3D test_and_clear_bit(rtl_work[i].bitnr, tp->wk.flags);
-		spin_unlock_bh(&tp->lock);
-
 		if (pending)
 			rtl_work[i].action(tp);
 	}
@@ -6116,7 +6104,7 @@ static void __rtl8169_resume(struct net_device *d=
ev)
=20
 	tp->wk.enabled =3D true;
=20
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
=20
 static int rtl8169_resume(struct device *device)
--=20
1.7.6.5
