From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.31 05/10] wimax/i2400m: remove redundant readiness checks from i2400m_report_tlv_*()
Date: Wed, 27 May 2009 18:05:10 -0700
Message-ID: <74bd64a25b220d21e50c7c9a85f26ff6617b3728.1243472510.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
 <e9de4b9426eeeddf56110425cfd88e43828e7146.1243472510.git.inaky@linux.intel.com>
 <22d4458f609ba31f1382e25844125e421dcd4163.1243472510.git.inaky@linux.intel.com>
 <05962df1398ad316feb1e20160b7502731bebc97.1243472510.git.inaky@linux.intel.com>
 <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:3119 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756419AbZE1BFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 21:05:48 -0400
In-Reply-To: <ba98dde3cde9f5910789b32852c692fc8cd0a4aa.1243472510.git.inaky@linux.intel.com>
In-Reply-To: <cover.1243472509.git.inaky@linux.intel.com>
References: <cover.1243472509.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions i2400m_report_tlv*() are only called from
i2400m_report_hook(), called in a workqueue by
i2400m_report_hook_work(). The scheduler checks for device readiness
before scheduling.

Added an extra check for readiness in i2400m_report_hook_work(), which
makes all the checks down the line redundant.

Obviously the device state could change in the middle, but error
handling would take care of that.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |    6 ------
 drivers/net/wimax/i2400m/rx.c      |    3 ++-
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index b42e347..bd193ae 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -292,8 +292,6 @@ void i2400m_report_tlv_system_state(struct i2400m *i2400m,
 
 	d_fnstart(3, dev, "(i2400m %p ss %p [%u])\n", i2400m, ss, i2400m_state);
 
-	if (unlikely(i2400m->ready == 0))	/* act if up */
-		goto out;
 	if (i2400m->state != i2400m_state) {
 		i2400m->state = i2400m_state;
 		wake_up_all(&i2400m->state_wq);
@@ -341,7 +339,6 @@ void i2400m_report_tlv_system_state(struct i2400m *i2400m,
 		i2400m->bus_reset(i2400m, I2400M_RT_WARM);
 		break;
 	};
-out:
 	d_fnend(3, dev, "(i2400m %p ss %p [%u]) = void\n",
 		i2400m, ss, i2400m_state);
 }
@@ -372,8 +369,6 @@ void i2400m_report_tlv_media_status(struct i2400m *i2400m,
 
 	d_fnstart(3, dev, "(i2400m %p ms %p [%u])\n", i2400m, ms, status);
 
-	if (unlikely(i2400m->ready == 0))	/* act if up */
-		goto out;
 	switch (status) {
 	case I2400M_MEDIA_STATUS_LINK_UP:
 		netif_carrier_on(net_dev);
@@ -393,7 +388,6 @@ void i2400m_report_tlv_media_status(struct i2400m *i2400m,
 		dev_err(dev, "HW BUG? unknown media status %u\n",
 			status);
 	};
-out:
 	d_fnend(3, dev, "(i2400m %p ms %p [%u]) = void\n",
 		i2400m, ms, status);
 }
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index a4adc78..7643850 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -177,7 +177,8 @@ void i2400m_report_hook_work(struct work_struct *ws)
 	struct i2400m_work *iw =
 		container_of(ws, struct i2400m_work, ws);
 	struct i2400m_report_hook_args *args = (void *) iw->pl;
-	i2400m_report_hook(iw->i2400m, args->l3l4_hdr, args->size);
+	if (iw->i2400m->ready)
+		i2400m_report_hook(iw->i2400m, args->l3l4_hdr, args->size);
 	kfree_skb(args->skb_rx);
 	i2400m_put(iw->i2400m);
 	kfree(iw);
-- 
1.6.2.3

