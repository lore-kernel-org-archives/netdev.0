From: Santwona.Behera@Sun.COM
Subject: [PATCH 1/1] niu: panic on reset
Date: Thu, 04 Sep 2008 16:55:16 -0700
Message-ID: <48C07564.3060306@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Matheos Worku <Matheos.Worku@Sun.COM>, agospoda@redhat.com,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:55554 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbYIDXzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 19:55:19 -0400
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m84NtIQu013549
	for <netdev@vger.kernel.org>; Thu, 4 Sep 2008 16:55:18 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K6P00L013NMMK00@fe-sfbay-09.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Thu,
 04 Sep 2008 16:55:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reset_task function in the niu driver does not reset the hardware 
fully. The buffer addresses and pointers are not being reset/updated in 
the hardware and that leads to panic on reset.

Signed-off-by: santwona.behera@sun.com <santwona.behera@sun.com>
---
 drivers/net/niu.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index e4765b7..422d7e5 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6006,11 +6006,27 @@ static void niu_reset_task(struct work_struct *work)

        niu_stop_hw(np);

+       spin_unlock_irqrestore(&np->lock, flags);
+
+       niu_free_channels(np);
+
+       err = niu_alloc_channels(np);
+       if (err) {
+               dev_err(np->device, PFX "%s:Failed to alloc niu channels\n",
+                       np->dev->name);
+               return;
+       }
+
+       spin_lock_irqsave(&np->lock, flags);
+
        err = niu_init_hw(np);
        if (!err) {
                np->timer.expires = jiffies + HZ;
                add_timer(&np->timer);
                niu_netif_start(np);
+       } else {
+               dev_err(np->device, PFX "%s:Failed to init hw\n",
+                       np->dev->name);
        }

        spin_unlock_irqrestore(&np->lock, flags);
--
1.5.2
