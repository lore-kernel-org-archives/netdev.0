From: Mathias Kretschmer <posting@blx4.net>
Subject: Re: mISDN: WARNING: at kernel/softirq.c:124 local_bh_enable+0x8f/0xb0()
Date: Tue, 23 Jun 2009 00:37:41 +0200
Message-ID: <200906230037.42412.posting@blx4.net>
References: <20090603190952.2dd0cc70.sfr@canb.auug.org.au> <200906051201.04185.isdn@linux-pingi.de> <200906091505.31537.kernel@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2eAQKXpXn+mtmtX"
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Karsten Keil <kernel@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756046AbZFVWiB@vger.kernel.org>
In-Reply-To: <200906091505.31537.kernel@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_2eAQKXpXn+mtmtX
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Karsten,

applied your patch. Not sure if it fixed anything, though.
Attached is another call trace which looks slightly different.

Cheers,

Mathias

On Tuesday 09 June 2009 15:05:31 Karsten Keil wrote:
> On Freitag, 5. Juni 2009 12:01:03 Karsten Keil wrote:
> > Hi,
> >
> > I'm currently see this too from time to time, but have no idea about it.
>
> ...
>
> > > > [88563.318126] ------------[ cut here ]------------
> > > > [88563.318129] WARNING: at kernel/softirq.c:124
> > > > local_bh_enable+0x8f/0xb0() [88563.318130] Hardware name: empty
> > > > [88563.318132] Modules linked in: usbtouchscreen dvb_usb_cinergyT2
> > > > dummy bonding snd_emu10k1 snd_rawmidi snd_ac97_codec ath9k ac97_bus
> > > > snd_pcm snd_page_alloc snd_util_mem forcedeth snd_hwdep
> > > > [88563.318141] Pid: 826, comm: mISDN_hfc-pci.1 Not tainted
> > > > 2.6.29.4-grsec #13 [88563.318142] Call Trace:
> > > > [88563.318147]  [<ffffffff8025909a>] warn_slowpath+0xea/0x160
> > > > [88563.318149]  [<ffffffff8025ee0f>] local_bh_enable+0x8f/0xb0
> > > > [88563.318152]  [<ffffffff8065f284>] sk_filter+0x44/0xa0
> > > > [88563.318154]  [<ffffffff8064548d>] sock_queue_rcv_skb+0x5d/0x120
> > > > [88563.318156]  [<ffffffff8060410f>] mISDN_send+0x4f/0xa0
> > > > [88563.318159]  [<ffffffff8060790e>] l2up_create+0x7e/0x100
> > > > [88563.318161]  [<ffffffff8060b6e0>] l2_got_tei+0x0/0x90
> > > > [88563.318163]  [<ffffffff8060b722>] l2_got_tei+0x42/0x90
> > > > [88563.318164]  [<ffffffff80602d32>] mISDN_FsmEvent+0x82/0x100
> > > > [88563.318167]  [<ffffffff8060cb00>] tei_id_assign+0x0/0x120
> > > > [88563.318168]  [<ffffffff80602d32>] mISDN_FsmEvent+0x82/0x100
> > > > [88563.318170]  [<ffffffff8060e373>] mgr_send+0x4d3/0x660
>
> OK found it, it was in a inlined function call ph_data_ind() in mgr_send().
>
> This patch should fix it (will send it upstream later).
>
>
> From: Karsten Keil <keil@b1-systems.de>
> Date: Tue, 9 Jun 2009 14:38:39 +0200
> Subject: [PATCH] mISDN: Do not disable IRQ in ph_data_ind()
>
>
> This fix triggering the WARN_ON_ONCE(in_irq() || irqs_disabled()); in
> local_bh_enable().
>
> Here is no need to grab this lock, this was wrong at all and may
> cause a deadlock and access to freed memory, since on a TEI remove
> the current listelement can be deleted under us. So this is clearly
> a case for list_for_each_entry_safe.
>
> Signed-off-by: Karsten Keil <keil@b1-systems.de>
> ---
>  drivers/isdn/mISDN/tei.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
> index bfcdd97..e04bad6 100644
> --- a/drivers/isdn/mISDN/tei.c
> +++ b/drivers/isdn/mISDN/tei.c
> @@ -862,8 +862,7 @@ static int
>  ph_data_ind(struct manager *mgr, struct sk_buff *skb)
>  {
>  	int		ret = -EINVAL;
> -	struct layer2	*l2;
> -	u_long		flags;
> +	struct layer2	*l2, *nl2;
>  	u_char		mt;
>
>  	if (skb->len < 8) {
> @@ -908,11 +907,9 @@ ph_data_ind(struct manager *mgr, struct sk_buff *skb)
>  		new_tei_req(mgr, &skb->data[4]);
>  		goto done;
>  	}
> -	read_lock_irqsave(&mgr->lock, flags);
> -	list_for_each_entry(l2, &mgr->layer2, list) {
> +	list_for_each_entry_safe(l2, nl2, &mgr->layer2, list) {
>  		tei_ph_data_ind(l2->tm, mt, &skb->data[4], skb->len - 4);
>  	}
> -	read_unlock_irqrestore(&mgr->lock, flags);
>  done:
>  	return ret;
>  }






--Boundary-00=_2eAQKXpXn+mtmtX
Content-Type: text/plain;
  charset="utf-8";
  name="misdn.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="misdn.txt"

Jun 21 21:49:27 [kernel] [  202.818502] ------------[ cut here ]------------
Jun 21 21:49:27 [kernel] [  202.818520] WARNING: at kernel/softirq.c:141 local_bh_enable+0x8b/0xb0()
Jun 21 21:49:27 [kernel] [  202.818525] Hardware name: empty
Jun 21 21:49:27 [kernel] [  202.818528] Modules linked in: iscsi_trgt dummy bonding forcedeth usbtouchscreen
Jun 21 21:49:27 [kernel] [  202.818542] Pid: 811, comm: mISDN_hfc-pci.1 Not tainted 2.6.30 #6
Jun 21 21:49:27 [kernel] [  202.818546] Call Trace:
Jun 21 21:49:27 [kernel] [  202.818556]  [<ffffffff8026b45b>] ? local_bh_enable+0x8b/0xb0
Jun 21 21:49:27 [kernel] [  202.818562]  [<ffffffff8026b45b>] ? local_bh_enable+0x8b/0xb0
Jun 21 21:49:27 [kernel] [  202.818572]  [<ffffffff80265ad9>] ? warn_slowpath_common+0x79/0xd0
Jun 21 21:49:27 [kernel] [  202.818578]  [<ffffffff8026b45b>] ? local_bh_enable+0x8b/0xb0
Jun 21 21:49:27 [kernel] [  202.818587]  [<ffffffff806ea8e4>] ? sk_filter+0x44/0xa0
Jun 21 21:49:27 [kernel] [  202.818594]  [<ffffffff806d142d>] ? sock_queue_rcv_skb+0x5d/0x120
Jun 21 21:49:27 [kernel] [  202.818604]  [<ffffffff8066738f>] ? mISDN_send+0x4f/0xa0
Jun 21 21:49:27 [kernel] [  202.818610]  [<ffffffff8066c650>] ? l2_got_ui+0x0/0x70
Jun 21 21:49:27 [kernel] [  202.818617]  [<ffffffff8066a837>] ? l2up+0x27/0x50
Jun 21 21:49:27 [kernel] [  202.818623]  [<ffffffff80666052>] ? mISDN_FsmEvent+0x82/0x100
Jun 21 21:49:27 [kernel] [  202.818630]  [<ffffffff8066e7ba>] ? l2_send+0x6fa/0x980
Jun 21 21:49:27 [kernel] [  202.818636]  [<ffffffff8066bd40>] ? l2_pull_iqueue+0x0/0x310
Jun 21 21:49:27 [kernel] [  202.818643]  [<ffffffff80670733>] ? mgr_bcast+0x83/0x160
Jun 21 21:49:27 [kernel] [  202.818649]  [<ffffffff80669899>] ? mISDNStackd+0x429/0x670
Jun 21 21:49:27 [kernel] [  202.818657]  [<ffffffff8027c930>] ? autoremove_wake_function+0x0/0x30
Jun 21 21:49:27 [kernel] [  202.818663]  [<ffffffff80669470>] ? mISDNStackd+0x0/0x670
Jun 21 21:49:27 [kernel] [  202.818668]  [<ffffffff80669470>] ? mISDNStackd+0x0/0x670
Jun 21 21:49:27 [kernel] [  202.818674]  [<ffffffff8027c4d4>] ? kthread+0x54/0x90
Jun 21 21:49:27 [kernel] [  202.818681]  [<ffffffff8022dfba>] ? child_rip+0xa/0x20
Jun 21 21:49:27 [kernel] [  202.818687]  [<ffffffff8027c480>] ? kthread+0x0/0x90
Jun 21 21:49:27 [kernel] [  202.818692]  [<ffffffff8022dfb0>] ? child_rip+0x0/0x20
Jun 21 21:49:27 [kernel] [  202.818696] ---[ end trace d74f848acdfc6568 ]---

--Boundary-00=_2eAQKXpXn+mtmtX--
