From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next 1/4] net: dsa: remove DSA link polling
Date: Mon,  7 Dec 2015 13:57:32 +0100
Message-ID: <1449493055-29047-2-git-send-email-narmstrong@baylibre.com>
References: <56321D9A.8010109@baylibre.com>
 <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since no more DSA driver uses the polling callback, and since
the phylib handles the link detection, remove the link polling
work and timer code.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 include/net/dsa.h | 12 ------------
 net/dsa/dsa.c     | 43 -------------------------------------------
 2 files changed, 55 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 3f23dd9..26a0e86 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -117,13 +117,6 @@ struct dsa_switch_tree {
 	s8			cpu_port;
 
 	/*
-	 * Link state polling.
-	 */
-	int			link_poll_needed;
-	struct work_struct	link_poll_work;
-	struct timer_list	link_poll_timer;
-
-	/*
 	 * Data for the individual switch chips.
 	 */
 	struct dsa_switch	*ds[DSA_MAX_SWITCHES];
@@ -232,11 +225,6 @@ struct dsa_switch_driver {
 			     int regnum, u16 val);
 
 	/*
-	 * Link state polling and IRQ handling.
-	 */
-	void	(*poll_link)(struct dsa_switch *ds);
-
-	/*
 	 * Link state adjustment (called from libphy)
 	 */
 	void	(*adjust_link)(struct dsa_switch *ds, int port,
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b7448c8..0f41f71 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -508,33 +508,6 @@ static int dsa_switch_resume(struct dsa_switch *ds)
 }
 #endif
 
-
-/* link polling *************************************************************/
-static void dsa_link_poll_work(struct work_struct *ugly)
-{
-	struct dsa_switch_tree *dst;
-	int i;
-
-	dst = container_of(ugly, struct dsa_switch_tree, link_poll_work);
-
-	for (i = 0; i < dst->pd->nr_chips; i++) {
-		struct dsa_switch *ds = dst->ds[i];
-
-		if (ds != NULL && ds->drv->poll_link != NULL)
-			ds->drv->poll_link(ds);
-	}
-
-	mod_timer(&dst->link_poll_timer, round_jiffies(jiffies + HZ));
-}
-
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
@@ -877,8 +850,6 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		}
 
 		dst->ds[i] = ds;
-		if (ds->drv->poll_link != NULL)
-			dst->link_poll_needed = 1;
 
 		++configured;
 	}
@@ -897,15 +868,6 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	wmb();
 	dev->dsa_ptr = (void *)dst;
 
-	if (dst->link_poll_needed) {
-		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-		init_timer(&dst->link_poll_timer);
-		dst->link_poll_timer.data = (unsigned long)dst;
-		dst->link_poll_timer.function = dsa_link_poll_timer;
-		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&dst->link_poll_timer);
-	}
-
 	return 0;
 }
 
@@ -972,11 +934,6 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
-	if (dst->link_poll_needed)
-		del_timer_sync(&dst->link_poll_timer);
-
-	flush_work(&dst->link_poll_work);
-
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];
 
-- 
1.9.1
