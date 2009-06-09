From: Karsten Keil <kernel@linux-pingi.de>
Subject: Re: mISDN: WARNING: at kernel/softirq.c:124 local_bh_enable+0x8f/0xb0()
Date: Tue, 9 Jun 2009 15:05:31 +0200
Message-ID: <200906091505.31537.kernel@linux-pingi.de>
References: <20090603190952.2dd0cc70.sfr@canb.auug.org.au> <20090604195948.9c7af254.akpm@linux-foundation.org> <200906051201.04185.isdn@linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mathias Kretschmer <psoting@blx4.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:51196 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588AbZFINFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 09:05:39 -0400
In-Reply-To: <200906051201.04185.isdn@linux-pingi.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Freitag, 5. Juni 2009 12:01:03 Karsten Keil wrote:
> Hi,
>
> I'm currently see this too from time to time, but have no idea about it.
>
...

> > > [88563.318126] ------------[ cut here ]------------
> > > [88563.318129] WARNING: at kernel/softirq.c:124
> > > local_bh_enable+0x8f/0xb0() [88563.318130] Hardware name: empty
> > > [88563.318132] Modules linked in: usbtouchscreen dvb_usb_cinergyT2
> > > dummy bonding snd_emu10k1 snd_rawmidi snd_ac97_codec ath9k ac97_bus
> > > snd_pcm snd_page_alloc snd_util_mem forcedeth snd_hwdep
> > > [88563.318141] Pid: 826, comm: mISDN_hfc-pci.1 Not tainted
> > > 2.6.29.4-grsec #13 [88563.318142] Call Trace:
> > > [88563.318147]  [<ffffffff8025909a>] warn_slowpath+0xea/0x160
> > > [88563.318149]  [<ffffffff8025ee0f>] local_bh_enable+0x8f/0xb0
> > > [88563.318152]  [<ffffffff8065f284>] sk_filter+0x44/0xa0
> > > [88563.318154]  [<ffffffff8064548d>] sock_queue_rcv_skb+0x5d/0x120
> > > [88563.318156]  [<ffffffff8060410f>] mISDN_send+0x4f/0xa0
> > > [88563.318159]  [<ffffffff8060790e>] l2up_create+0x7e/0x100
> > > [88563.318161]  [<ffffffff8060b6e0>] l2_got_tei+0x0/0x90
> > > [88563.318163]  [<ffffffff8060b722>] l2_got_tei+0x42/0x90
> > > [88563.318164]  [<ffffffff80602d32>] mISDN_FsmEvent+0x82/0x100
> > > [88563.318167]  [<ffffffff8060cb00>] tei_id_assign+0x0/0x120
> > > [88563.318168]  [<ffffffff80602d32>] mISDN_FsmEvent+0x82/0x100
> > > [88563.318170]  [<ffffffff8060e373>] mgr_send+0x4d3/0x660

OK found it, it was in a inlined function call ph_data_ind() in mgr_send().

This patch should fix it (will send it upstream later).


From: Karsten Keil <keil@b1-systems.de>
Date: Tue, 9 Jun 2009 14:38:39 +0200
Subject: [PATCH] mISDN: Do not disable IRQ in ph_data_ind()


This fix triggering the WARN_ON_ONCE(in_irq() || irqs_disabled()); in
local_bh_enable().

Here is no need to grab this lock, this was wrong at all and may
cause a deadlock and access to freed memory, since on a TEI remove
the current listelement can be deleted under us. So this is clearly
a case for list_for_each_entry_safe.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/tei.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index bfcdd97..e04bad6 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -862,8 +862,7 @@ static int
 ph_data_ind(struct manager *mgr, struct sk_buff *skb)
 {
 	int		ret = -EINVAL;
-	struct layer2	*l2;
-	u_long		flags;
+	struct layer2	*l2, *nl2;
 	u_char		mt;
 
 	if (skb->len < 8) {
@@ -908,11 +907,9 @@ ph_data_ind(struct manager *mgr, struct sk_buff *skb)
 		new_tei_req(mgr, &skb->data[4]);
 		goto done;
 	}
-	read_lock_irqsave(&mgr->lock, flags);
-	list_for_each_entry(l2, &mgr->layer2, list) {
+	list_for_each_entry_safe(l2, nl2, &mgr->layer2, list) {
 		tei_ph_data_ind(l2->tm, mt, &skb->data[4], skb->len - 4);
 	}
-	read_unlock_irqrestore(&mgr->lock, flags);
 done:
 	return ret;
 }
-- 
1.6.0.2



