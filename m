From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 2/2] netxen: protect resource cleanup by rtnl lock
Date: Tue,  2 Feb 2010 06:16:21 -0800
Message-ID: <1265120181-1671-3-git-send-email-amit.salecha@qlogic.com>
References: <1265120181-1671-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52384 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755943Ab0BBOQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 09:16:22 -0500
In-Reply-To: <1265120181-1671-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o context resources can be in used, while resource cleanup is in progress,
  during fw recover.
o Null pointer execption can occur in send_cmd_desc, if fw recovery
  module frees tx ring without rtnl lock.
o Same applies to ethtool register dump.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 5209095..24279e6 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2240,7 +2240,9 @@ netxen_detach_work(struct work_struct *work)
 
 	netxen_nic_down(adapter, netdev);
 
+	rtnl_lock();
 	netxen_nic_detach(adapter);
+	rtnl_unlock();
 
 	status = NXRD32(adapter, NETXEN_PEG_HALT_STATUS1);
 
-- 
1.5.6.1

