From: Pavel Andrianov <andrianov@ispras.ru>
Subject: Re: [ldv-project] [net] libertas: potential race condition
Date: Tue, 14 Jun 2016 17:16:11 +0400
Message-ID: <5760039B.4050902@ispras.ru>
References: <57569424.9040906@ispras.ru> <1465310395.29158.2.camel@redhat.com> <20160607225114.GA21437@us.netrek.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020407090508040300010402"
Cc: Dan Williams <dcbw@redhat.com>, Kalle Valo <kvalo@codeaurora.org>,
	libertas-dev@lists.infradead.org, LDV list <ldv-project@ispras.ru>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, vaishali.thakkar@oracle.com
To: James Cameron <quozl@laptop.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160607225114.GA21437@us.netrek.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020407090508040300010402
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

08.06.2016 02:51, James Cameron пишет:
> On Tue, Jun 07, 2016 at 09:39:55AM -0500, Dan Williams wrote:
>> On Tue, 2016-06-07 at 13:30 +0400, Pavel Andrianov wrote:
>>> Hi!
>>>
>>> There is a potential race condition in
>>> drivers/net/wireless/libertas/libertas.ko.
>>> In the function lbs_hard_start_xmit(..), line 159, a socket buffer
>>> is
>>> written to priv->current_skb with a spin_lock protection.
>>> In the function lbs_mac_event_disconnected(..), lines 50-51, the
>>> field
>>> current_skb is cleaned. There is no protection used. The
>>> corresponding
>>> handlers are activated at the same time in lbs_start_card(..) and
>>> then
>>> may be executed simultaneously. Note, there are two structures
>>> lbs_netdev_ops and mesh_netdev_ops, which have the target handler
>>> lbs_hard_start_xmit.
>>> Is it a real race or I have missed something?
>> Yeah, it looks like it should be grabbing priv->driver_lock before
>> clearing priv->currenttxskb in lbs_mac_event_disconnected().  Care to
>> submit a patch after testing?  Do you have any of that hardware?
> I've hardware, with serial console.
>
> Can test any patch, on USB (8388) or SDIO (8686).
>
Hi!

I've prepare the patch for this issue. Could you test it?

Thank you.

-- 
Pavel Andrianov
Linux Verification Center, ISPRAS
web: http://linuxtesting.org
e-mail: andrianov@ispras.ru


--------------020407090508040300010402
Content-Type: text/x-patch;
 name="0001-libertas-Add-spinlock-to-avoid-race-condition.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-libertas-Add-spinlock-to-avoid-race-condition.patch"

>From b1a9e157ccdf8650da93844fd2dbdb6fca509b59 Mon Sep 17 00:00:00 2001
From: Pavel <andrianov@ispras.ru>
Date: Tue, 14 Jun 2016 16:59:00 +0400
Subject: [PATCH] libertas: Add spinlock to avoid race condition

lbs_mac_event_disconnected may free priv->currenttxskb
while lbs_hard_start_xmit accesses to it.
The patch adds a spinlock for mutual exclusion.

Signed-off-by: Pavel <andrianov@ispras.ru>
---
 drivers/net/wireless/marvell/libertas/cmdresp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/marvell/libertas/cmdresp.c b/drivers/net/wireless/marvell/libertas/cmdresp.c
index c95bf6d..c67ae07 100644
--- a/drivers/net/wireless/marvell/libertas/cmdresp.c
+++ b/drivers/net/wireless/marvell/libertas/cmdresp.c
@@ -27,6 +27,8 @@
 void lbs_mac_event_disconnected(struct lbs_private *priv,
 				bool locally_generated)
 {
+	unsigned long flags;
+
 	if (priv->connect_status != LBS_CONNECTED)
 		return;
 
@@ -46,9 +48,11 @@ void lbs_mac_event_disconnected(struct lbs_private *priv,
 	netif_carrier_off(priv->dev);
 
 	/* Free Tx and Rx packets */
+	spin_lock_irqsave(&priv->driver_lock, flags);
 	kfree_skb(priv->currenttxskb);
 	priv->currenttxskb = NULL;
 	priv->tx_pending_len = 0;
+	spin_unlock_irqrestore(&priv->driver_lock, flags);
 
 	priv->connect_status = LBS_DISCONNECTED;
 
-- 
1.7.11.7


--------------020407090508040300010402--
