From: cooldavid@cooldavid.org
Subject: [PATCH net-2.6 2/3] jme: Protect vlgrp structure by pause RX actions.
Date: Wed, 17 Mar 2010 18:09:30 +0800
Message-ID: <1268820571-2092-2-git-send-email-cooldavid@cooldavid.org>
References: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>,
	"Hsiu-Che Chao" <hcchao@jmicron.com>, stable@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:35761 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754126Ab0CQKPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 06:15:55 -0400
In-Reply-To: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Temporary stop the RX IRQ, and disable (sync) tasklet or napi.
And restore it after finished the vlgrp pointer assignment.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: stable@kernel.org
---
 drivers/net/jme.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index cfc7b98..c0b59a5 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2083,12 +2083,45 @@ jme_tx_timeout(struct net_device *netdev)
 	jme_reset_link(jme);
 }
 
+static inline void jme_pause_rx(struct jme_adapter *jme)
+{
+	atomic_dec(&jme->link_changing);
+
+	jme_set_rx_pcc(jme, PCC_OFF);
+	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
+		JME_NAPI_DISABLE(jme);
+	} else {
+		tasklet_disable(&jme->rxclean_task);
+		tasklet_disable(&jme->rxempty_task);
+	}
+}
+
+static inline void jme_resume_rx(struct jme_adapter *jme)
+{
+	struct dynpcc_info *dpi = &(jme->dpi);
+
+	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
+		JME_NAPI_ENABLE(jme);
+	} else {
+		tasklet_hi_enable(&jme->rxclean_task);
+		tasklet_hi_enable(&jme->rxempty_task);
+	}
+	dpi->cur		= PCC_P1;
+	dpi->attempt		= PCC_P1;
+	dpi->cnt		= 0;
+	jme_set_rx_pcc(jme, PCC_P1);
+
+	atomic_inc(&jme->link_changing);
+}
+
 static void
 jme_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct jme_adapter *jme = netdev_priv(netdev);
 
+	jme_pause_rx(jme);
 	jme->vlgrp = grp;
+	jme_resume_rx(jme);
 }
 
 static void
-- 
1.6.4.4

