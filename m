From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Do not return 0 in ixgbe_fcoe_ddp() upon
	FCP_RSP in DDP completion
Date: Thu, 13 Aug 2009 17:09:58 -0700
Message-ID: <20090814000958.20911.72817.stgit@localhost.localdomain>
References: <20090814000929.20911.77027.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:40909
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756063AbZHNAKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 20:10:17 -0400
In-Reply-To: <20090814000929.20911.77027.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

We return the ddp->len in ixgbe_fcoe_ddp() to indicate the length of data that
have been DDPed. However, it is possible that the length is 0, e.g., for SCSI
READ, the FCP_RSP may come back w/ SCSI status 0x28 as Task Set Full with no FCP
data for DDP. In ixgbe_fcoe_ddp(), we return 0 to indicate not passing DDPed
packets to upper layer. Therefore in the case of ddp->len being 0 upon FCP_RSP,
we do not want to return the 0 ddp->len as we want FCP_RSP to be always
delivered to the upper layer. This patch fixes this bug by setting rc only if
ddp->len is non-zero.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index fa9f24e..28cf104 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -336,7 +336,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		/* return 0 to bypass going to ULD for DDPed data */
 		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_DDP)
 			rc = 0;
-		else
+		else if (ddp->len)
 			rc = ddp->len;
 	}
 

