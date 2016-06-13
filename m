From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net v2 4/4] ovs/geneve: fix rtnl notifications on iface deletion
Date: Mon, 13 Jun 2016 10:31:07 +0200
Message-ID: <1465806667-23148-5-git-send-email-nicolas.dichtel@6wind.com>
References: <CAOrHB_DCupNkAz+BSaOKKE+KLYhK-hytqW2vEV1yQ-iYr6hakg@mail.gmail.com>
 <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@ovn.org, jesse@kernel.org,
	linville@tuxdriver.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38149 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964986AbcFMIbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 04:31:13 -0400
In-Reply-To: <1465806667-23148-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function geneve_dev_create_fb() (only used by ovs) never calls
rtnl_configure_link(). The consequence is that dev->rtnl_link_state is
never set to RTNL_LINK_INITIALIZED.
During the deletion phase, the function rollback_registered_many() sends
a RTM_DELLINK only if dev->rtnl_link_state is set to RTNL_LINK_INITIALIZED.

Fixes: e305ac6cf5a1 ("geneve: Add support to collect tunnel metadata.")
CC: Pravin B Shelar <pshelar@nicira.com>
CC: Jesse Gross <jesse@nicira.com>
CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/geneve.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 086c2dae4c3d..305a04e45a13 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1532,6 +1532,10 @@ struct net_device *geneve_dev_create_fb(struct net *net, const char *name,
 	if (err)
 		goto err;
 
+	err = rtnl_configure_link(dev, NULL);
+	if (err < 0)
+		goto err;
+
 	return dev;
 
  err:
-- 
2.4.2
