From: Artem Savkov <artem.savkov@gmail.com>
Subject: [PATCH] r8169: enable napi on resume.
Date: Wed,  4 Apr 2012 00:29:11 +0400
Message-ID: <1333484951-5432-1-git-send-email-artem.savkov@gmail.com>
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	Artem Savkov <artem.savkov@gmail.com>
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54973 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab2DCUaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 16:30:35 -0400
Received: by bkcik5 with SMTP id ik5so131991bkc.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 13:30:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAPI is disabled during suspend and needs to be enabled on resume. Without
this the driver locks up during resume in rtl_reset_work() trying to disable
NAPI again.

Signed-off-by: Artem Savkov <artem.savkov@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d2ec075..e259c88 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5810,7 +5810,10 @@ static void __rtl8169_resume(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
+	rtl_lock_work(tp);
+	napi_enable(&tp->napi);
 	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
+	rtl_unlock_work(tp);
 
 	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
-- 
1.7.9.5
