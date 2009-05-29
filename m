From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/4 v2] netdev: bfin_mac: fix malformed UDP packet transmission when polling with KGDB
Date: Fri, 29 May 2009 09:40:43 -0400
Message-ID: <1243604443-27204-1-git-send-email-vapier@gentoo.org>
References: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Sonic Zhang <sonic.zhang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32996 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758816AbZE2Nks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2009 09:40:48 -0400
In-Reply-To: <1243404615-25879-3-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

Writes to the DMA descriptors may sit in the internal Blackfin data buffers
and not actually be available when the DMA engine goes to fetch them.  This
does not typically happen, but when dealing with short/fast packets such as
UDP and polling KGDB, this occurs much more frequently.  Same goes for
heavy loads as seen by netperf tests or large scp transfers.  So force the
buffers to drain with SSYNC otherwise we get random malformed packets.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
v2
	- make comment/changelog reflect what is actually going on

 drivers/net/bfin_mac.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 1905532..38d34ce 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -688,6 +688,12 @@ static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
 		}
 	}
 
+	/* make sure the internal data buffers in the core are drained
+	 * so that the DMA descriptors are completely written when the
+	 * DMA engine goes to fetch them below
+	 */
+	SSYNC();
+
 	/* enable this packet's dma */
 	current_tx_ptr->desc_a.config |= DMAEN;
 
-- 
1.6.3.1

