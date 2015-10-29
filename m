From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 1/6] net: dsa: Use delayed work instead of timer+work for
 polling
Date: Thu, 29 Oct 2015 14:22:41 +0100
Message-ID: <56321DA1.4060304@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:32854 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756979AbbJ2NWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 09:22:48 -0400
Received: by wmeg8 with SMTP id g8so24351945wme.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 06:22:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplifies the code and avoids a crash when removing the
module:
 dsa dsa ethmv2 (unregistering): Link is Down
 device eth1 left promiscuous mode
 Unable to handle kernel paging request at virtual address bacc5cf6
 ...
 (run_timer_softirq) from [<c003e810>] (__do_softirq+0xcc/0x320)
 (__do_softirq) from [<c003ed40>] (irq_exit+0xac/0x10c)
 (irq_exit) from [<c007ec20>] (__handle_domain_irq+0x50/0xa8)

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 include/net/dsa.h |  3 +--
 net/dsa/dsa.c     | 28 ++++++++--------------------
 2 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 98ccbde..d4d13f7 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -112,8 +112,7 @@ struct dsa_switch_tree {
 	 * Link state polling.
 	 */
 	int			link_poll_needed;
-	struct work_struct	link_poll_work;
-	struct timer_list	link_poll_timer;
+	struct delayed_work	link_poll_work;

 	/*
 	 * Data for the individual switch chips.
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 1eba07f..aeb6a7c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -513,7 +513,7 @@ static void dsa_link_poll_work(struct work_struct *ugly)
 	struct dsa_switch_tree *dst;
 	int i;

-	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work);
+	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work.work);

 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
@@ -522,17 +522,9 @@ static void dsa_link_poll_work(struct work_struct *ugly)
 			ds->drv->poll_link(ds);
 	}

-	mod_timer(&dst->link_poll_timer, round_jiffies(jiffies + HZ));
+	schedule_delayed_work(&dst->link_poll_work, round_jiffies_relative(HZ));
 }

-static void dsa_link_poll_timer(unsigned long _dst)
-{
-	struct dsa_switch_tree *dst = (void *)_dst;
-
-	schedule_work(&dst->link_poll_work);
-}
-
-
 /* platform driver init and cleanup *****************************************/
 static int dev_is_class(struct device *dev, void *class)
 {
@@ -880,12 +872,8 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	dev->dsa_ptr = (void *)dst;

 	if (dst->link_poll_needed) {
-		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-		init_timer(&dst->link_poll_timer);
-		dst->link_poll_timer.data = (unsigned long)dst;
-		dst->link_poll_timer.function = dsa_link_poll_timer;
-		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&dst->link_poll_timer);
+		INIT_DELAYED_WORK(&dst->link_poll_work, dsa_link_poll_work);
+		schedule_delayed_work(&dst->link_poll_work, round_jiffies_relative(HZ));
 	}

 	return 0;
@@ -954,10 +942,10 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;

-	if (dst->link_poll_needed)
-		del_timer_sync(&dst->link_poll_timer);
-
-	flush_work(&dst->link_poll_work);
+	if (dst->link_poll_needed) {
+		cancel_delayed_work_sync(&dst->link_poll_work);
+		flush_delayed_work(&dst->link_poll_work);
+	}

 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
-- 
1.9.1
