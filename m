From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH 1/1] r8152: fix NULL pointer dereference in r8152_poll
Date: Mon, 13 Mar 2017 13:47:27 +0100
Message-ID: <20170313124727.4681-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>, hayeswang@realtek.com,
        davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32952 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753000AbdCMMrh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 08:47:37 -0400
Received: by mail-wr0-f196.google.com with SMTP id g10so19933544wrg.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 05:47:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7489bdadb7d1 (r8152: check rx after napi is enabled) causes null
pointer dereference when using device as under root:

 # rmmod r8152 # or lsusb -v
NOHZ: local_softirq_pending 08
BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: r8152_poll+0x125/0x570 [r8152]
PGD 89b4cf067
PUD 898ff2067
PMD 0
Oops: 0002 [#1] PREEMPT SMP

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
NOTE: This is just a workaround, I suppose, there is better way how to fix that
(which allows keeping scheduling the napi for rx after napi_enable()).
---
 drivers/net/usb/r8152.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 986243c932cc..79c665a89a47 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3703,8 +3703,6 @@ static int rtl8152_resume(struct usb_interface *intf)
 			napi_enable(&tp->napi);
 			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
 			smp_mb__after_atomic();
-			if (!list_empty(&tp->rx_done))
-				napi_schedule(&tp->napi);
 		} else {
 			tp->rtl_ops.up(tp);
 			netif_carrier_off(tp->netdev);
-- 
2.12.0
