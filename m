From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
Subject: Re: [RFC PATCH] unlock rtnl mutex in ic_open_devs while waiting
Date: Wed, 07 Jan 2015 11:06:47 +0100
Message-ID: <54AD0537.9080005@canonical.com>
References: <54AA9706.5020202@canonical.com> <20150106.172152.2034122593693302134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150106.172152.2034122593693302134.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Op 06-01-15 om 23:21 schreef David Miller:
> From: Maarten Lankhorst <maarten.lankhorst@canonical.com>
> Date: Mon, 05 Jan 2015 14:52:06 +0100
>
>> This fixes a deadlock with alx_link_check, which takes the rtnl_mutex in
>> a work item to check the link.
>>
>> I have no idea whether alx should be fixed or ipconfig.c,
>> but this saves 120 seconds off my boot time. ;-)
>>
>> Signed-off-by: Maarten Lankhorst <maarten.lankhorst@canonical.com>
> I genuinely think that alx_link_check() needs to use a smaller hammer
> to do it's locking, there is no reason to use the RTNL mutex.
>
> A driver private mutex will probably work just as well and not have
> this problem.

I guess alx_check_link uses the rtnl_lock for serializing against any possible alx_reset call.
The alternative is stopping check_link work before running anything that changes the device state.
Does the below patch look sane instead?
---
diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 8fc93c5f6abc..354f155b3144 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -88,6 +88,8 @@ struct alx_priv {
 		unsigned int size;
 	} descmem;
 
+	bool stop_link_check;
+
 	/* protect int_mask updates */
 	spinlock_t irq_lock;
 	u32 int_mask;
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index e398eda07298..ae93b8052cbf 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -315,7 +316,8 @@ static irqreturn_t alx_intr_handle(struct alx_priv *alx, u32 intr)
 		 */
 		alx->int_mask &= ~ALX_ISR_PHY;
 		write_int_mask = true;
-		alx_schedule_link_check(alx);
+		if (!alx->stop_link_check)
+			alx_schedule_link_check(alx);
 	}
 
 	if (intr & (ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0)) {
@@ -742,6 +744,17 @@ static netdev_features_t alx_fix_features(struct net_device *netdev,
 	return features;
 }
 
+static void alx_disable_link_check(struct alx_priv *alx)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&alx->irq_lock, flags);
+	alx->stop_link_check = true;
+	spin_unlock_irqrestore(&alx->irq_lock, flags);
+
+	cancel_work_sync(&alx->link_check_wk);
+}
+
 static void alx_netif_stop(struct alx_priv *alx)
 {
 	alx->dev->trans_start = jiffies;
@@ -756,6 +769,7 @@ static void alx_halt(struct alx_priv *alx)
 {
 	struct alx_hw *hw = &alx->hw;
 
+	alx_disable_link_check(alx);
 	alx_netif_stop(alx);
 	hw->link_speed = SPEED_UNKNOWN;
 	hw->duplex = DUPLEX_UNKNOWN;
@@ -788,6 +802,7 @@ static void alx_activate(struct alx_priv *alx)
 	/* clear old interrupts */
 	alx_write_mem32(&alx->hw, ALX_ISR, ~(u32)ALX_ISR_DIS);
 
+	alx->stop_link_check = false;
 	alx_irq_enable(alx);
 
 	alx_schedule_link_check(alx);
@@ -850,6 +865,7 @@ static int __alx_open(struct alx_priv *alx, bool resume)
 	/* clear old interrupts */
 	alx_write_mem32(&alx->hw, ALX_ISR, ~(u32)ALX_ISR_DIS);
 
+	alx->stop_link_check = false;
 	alx_irq_enable(alx);
 
 	if (!resume)
@@ -966,9 +982,7 @@ static void alx_link_check(struct work_struct *work)
 
 	alx = container_of(work, struct alx_priv, link_check_wk);
 
-	rtnl_lock();
 	alx_check_link(alx);
-	rtnl_unlock();
 }
 
