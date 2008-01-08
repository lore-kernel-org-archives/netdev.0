From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: Tue, 8 Jan 2008 22:36:40 +0100
Message-ID: <20080108213640.GC4450@electric-eye.fr.zoreil.com>
References: <20080108122814.12005.qmail@science.horizon.com> <20080108131956.13905.qmail@science.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net
To: linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38302 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751776AbYAHVuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 16:50:13 -0500
Content-Disposition: inline
In-Reply-To: <20080108131956.13905.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux@horizon.com <linux@horizon.com> :
> I take that back.  This patch does NOT fix the leak, at least if
> ping: sendmsg: No buffer space available
> is any indication...

Can you try the patch below ?

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..c304e5c 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -860,7 +860,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 	void __iomem *ioaddr = sp->ioaddr;
 	unsigned int curr;
 	u64 txd_map;
-	unsigned int released, pending;
+	unsigned int released, pending, dirty;
 
 	txd_map = (u64)sp->txd_map;
 	curr = ipg_r32(TFD_LIST_PTR_0) -
@@ -869,9 +869,9 @@ static void ipg_nic_txfree(struct net_device *dev)
 	IPG_DEBUG_MSG("_nic_txfree\n");
 
 	pending = sp->tx_current - sp->tx_dirty;
+	dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 
 	for (released = 0; released < pending; released++) {
-		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 		struct sk_buff *skb = sp->TxBuff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
@@ -898,6 +898,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 
 			sp->TxBuff[dirty] = NULL;
 		}
+		dirty = (dirty + 1) % IPG_TFDLIST_LENGTH;
 	}
 
 	sp->tx_dirty += released;
-- 
1.5.3.3

