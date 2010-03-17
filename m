From: Chase Douglas <chase.douglas@canonical.com>
Subject: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 10:33:16 -0400
Message-ID: <1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
References: <1268836396-23943-1-git-send-email-chase.douglas@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:39397 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753460Ab0CQOdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 10:33:35 -0400
Received: from hutte.canonical.com ([91.189.90.181])
	by adelie.canonical.com with esmtp (Exim 4.69 #1 (Debian))
	id 1NruJS-0004Vv-TR
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 14:33:34 +0000
Received: from cpe-98-31-46-159.woh.res.rr.com ([98.31.46.159] helo=canonical.com)
	by hutte.canonical.com with esmtpsa (TLS-1.0:DHE_RSA_AES_128_CBC_SHA1:16)
	(Exim 4.69)
	(envelope-from <chase.douglas@canonical.com>)
	id 1NruJS-0002TK-Jt
	for netdev@vger.kernel.org; Wed, 17 Mar 2010 14:33:34 +0000
In-Reply-To: <1268836396-23943-1-git-send-email-chase.douglas@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last year, threaded IRQ handlers were introduced to the mainline kernel.
This change requires the disable_irq function to sleep if any IRQ
handler threads for a given IRQ line are running.

Back in 2006, while working on the -rt patch set that had threaded IRQ
handlers, the vortex_timer function was causing scheduling bugs because
it is run in softirq context and called disable_irq. This patch was the
best fix determined at the time, and still exists in the .33 -rt
patchset. Now that threaded IRQ handlers are present in the mainline
kernel we need to apply the patch there as well.

http://lkml.org/lkml/2006/5/12/178

BugLink: http://bugs.launchpad.net/bugs/533335

Signed-off-by: Chase Douglas <chase.douglas@canonical.com>
---
 drivers/net/3c59x.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index f965431..bdaff0f 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1764,6 +1764,7 @@ vortex_timer(unsigned long data)
 	int next_tick = 60*HZ;
 	int ok = 0;
 	int media_status, old_window;
+	unsigned long flags;
 
 	if (vortex_debug > 2) {
 		pr_debug("%s: Media selection timer tick happened, %s.\n",
@@ -1771,7 +1772,7 @@ vortex_timer(unsigned long data)
 		pr_debug("dev->watchdog_timeo=%d\n", dev->watchdog_timeo);
 	}
 
-	disable_irq_lockdep(dev->irq);
+	spin_lock_irqsave(&vp->lock, flags);
 	old_window = ioread16(ioaddr + EL3_CMD) >> 13;
 	EL3WINDOW(4);
 	media_status = ioread16(ioaddr + Wn4_Media);
@@ -1851,7 +1852,7 @@ leave_media_alone:
 			 dev->name, media_tbl[dev->if_port].name);
 
 	EL3WINDOW(old_window);
-	enable_irq_lockdep(dev->irq);
+	spin_unlock_irqrestore(&vp->lock, flags);
 	mod_timer(&vp->timer, RUN_AT(next_tick));
 	if (vp->deferred)
 		iowrite16(FakeIntr, ioaddr + EL3_CMD);
-- 
1.6.3.3

