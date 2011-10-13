From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 3/8] caif-hsi: Fix for wakeup condition problem
Date: Thu, 13 Oct 2011 23:29:24 +0200
Message-ID: <1318541369-8141-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dmitry.tarnyagin@stericsson.com, daniel.martensson@stericsson.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:41517 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab1JMW36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:29:58 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001E4X1M7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:46 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:46 +0200 (CEST)
In-reply-to: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

Under stressed conditions a race could happen when del_timer_sync() was=
 called
from softirq context at the same time when mod_timer_pending() for the =
same
timer was called from the workqueue. This leaded to a state mismatch in=
 the
CAIF HSI driver and following unexpected link wakeup procedure.

The fix puts del_timer_sync() and mod_timer_pending() calls under a spi=
n lock
to protect against the race condition.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 36da27b..82c4d6c 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -551,7 +551,9 @@ static void cfhsi_rx_done_work(struct work_struct *=
work)
 		return;
=20
 	/* Update inactivity timer if pending. */
+	spin_lock_bh(&cfhsi->lock);
 	mod_timer_pending(&cfhsi->timer, jiffies + CFHSI_INACTIVITY_TOUT);
+	spin_unlock_bh(&cfhsi->lock);
=20
 	if (cfhsi->rx_state =3D=3D CFHSI_RX_STATE_DESC) {
 		desc_pld_len =3D cfhsi_rx_desc(desc, cfhsi);
@@ -866,10 +868,10 @@ static int cfhsi_xmit(struct sk_buff *skb, struct=
 net_device *dev)
 		start_xfer =3D 1;
 	}
=20
-	spin_unlock_bh(&cfhsi->lock);
-
-	if (!start_xfer)
+	if (!start_xfer) {
+		spin_unlock_bh(&cfhsi->lock);
 		return 0;
+	}
=20
 	/* Delete inactivity timer if started. */
 #ifdef CONFIG_SMP
@@ -878,6 +880,8 @@ static int cfhsi_xmit(struct sk_buff *skb, struct n=
et_device *dev)
 	timer_active =3D del_timer(&cfhsi->timer);
 #endif /* CONFIG_SMP */
=20
+	spin_unlock_bh(&cfhsi->lock);
+
 	if (timer_active) {
 		struct cfhsi_desc *desc =3D (struct cfhsi_desc *)cfhsi->tx_buf;
 		int len;
--=20
1.7.0.4
