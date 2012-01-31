From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/5] r8169: move task enable boolean to bitfield.
Date: Tue, 31 Jan 2012 14:56:42 +0100
Message-ID: <20120131135642.GC18167@electric-eye.fr.zoreil.com>
References: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52435 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094Ab2AaOH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:07:56 -0500
Content-Disposition: inline
In-Reply-To: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simpler, more consistent, with negligible cost in non-critical paths.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Suggested-by: Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>
Cc: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index 118f6f6..679711e 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -668,6 +668,7 @@ struct rtl8169_counters {
 };
=20
 enum rtl_flag {
+	RTL_FLAG_TASK_ENABLED,
 	RTL_FLAG_TASK_SLOW_PENDING,
 	RTL_FLAG_TASK_RESET_PENDING,
 	RTL_FLAG_TASK_PHY_PENDING,
@@ -725,7 +726,6 @@ struct rtl8169_private {
 		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
 		struct mutex mutex;
 		struct work_struct work;
-		bool enabled;
 	} wk;
=20
 	unsigned features;
@@ -4352,7 +4352,7 @@ static int rtl8169_open(struct net_device *dev)
=20
 	rtl_lock_work(tp);
=20
-	tp->wk.enabled =3D true;
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
=20
 	napi_enable(&tp->napi);
=20
@@ -5879,7 +5879,8 @@ static void rtl_task(struct work_struct *work)
=20
 	rtl_lock_work(tp);
=20
-	if (!netif_running(dev) || !tp->wk.enabled)
+	if (!netif_running(dev) ||
+	    !test_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags))
 		goto out_unlock;
=20
 	for (i =3D 0; i < ARRAY_SIZE(rtl_work); i++) {
@@ -5977,7 +5978,7 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_update_counters(dev);
=20
 	rtl_lock_work(tp);
-	tp->wk.enabled =3D false;
+	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
=20
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
@@ -6076,7 +6077,7 @@ static void rtl8169_net_suspend(struct net_device=
 *dev)
=20
 	rtl_lock_work(tp);
 	napi_disable(&tp->napi);
-	tp->wk.enabled =3D false;
+	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 	rtl_unlock_work(tp);
=20
 	rtl_pll_power_down(tp);
@@ -6102,7 +6103,7 @@ static void __rtl8169_resume(struct net_device *d=
ev)
=20
 	rtl_pll_power_up(tp);
=20
-	tp->wk.enabled =3D true;
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
=20
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
--=20
1.7.6.5
