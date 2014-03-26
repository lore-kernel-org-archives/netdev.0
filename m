From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network troubles "bisected"
Date: Wed, 26 Mar 2014 20:57:09 +0100
Message-ID: <172833073.20140326205709@eikelenboom.it>
References: <1744594108.20140318162127@eikelenboom.it> <20140318160412.GB16807@zion.uk.xensource.com> <1701035622.20140318211402@eikelenboom.it> <722971844.20140318221859@eikelenboom.it> <1688396550.20140319001104@eikelenboom.it> <20140319113532.GD16807@zion.uk.xensource.com> <246793256.20140319220752@eikelenboom.it> <20140321164958.GA31766@zion.uk.xensource.com> <1334202265.20140321182727@eikelenboom.it> <1056661597.20140322192834@eikelenboom.it> <20140325151539.GG31766@zion.uk.xensource.com> <79975567.20140325162942@eikelenboom.it> <1972209744.20140326121116@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AD94@AMSPEX01CL01.citrite.net> <1715463578.20140326162245@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029AFC1@AMSPEX01CL01.citrite.net> <799579453.20140326170641@eikelenboom.it>
 <9AAE0902D5BC7E449B7C8E4E778ABCD029B106@AMSPEX01CL01.citrite.net> <789809468.20140326175352@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B277@AMSPEX01CL01.citrite.net> <966386043.20140326183304@eikelenboom.it> <9AAE0902D5BC7E449B7C8E4E778ABCD029B375@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, annie li <annie.li@oracle.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD029B375@AMSPEX01CL01.citrite.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Wednesday, March 26, 2014, 6:48:15 PM, you wrote:

>> -----Original Message-----
>> From: Paul Durrant
>> Sent: 26 March 2014 17:47
>> To: 'Sander Eikelenboom'
>> Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell; linux-
>> kernel; netdev@vger.kernel.org
>> Subject: RE: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> troubles "bisected"
>> 
>> Re-send shortened version...
>> 
>> > -----Original Message-----
>> > From: Sander Eikelenboom [mailto:linux@eikelenboom.it]
>> > Sent: 26 March 2014 16:54
>> > To: Paul Durrant
>> > Cc: Wei Liu; annie li; Zoltan Kiss; xen-devel@lists.xen.org; Ian Campbell;
>> linux-
>> > kernel; netdev@vger.kernel.org
>> > Subject: Re: [Xen-devel] Xen-unstable Linux 3.14-rc3 and 3.13 Network
>> > troubles "bisected"
>> >
>> [snip]
>> > >>
>> > >> - When processing an SKB we end up in "xenvif_gop_frag_copy" while
>> > prod
>> > >> == cons ... but we still have bytes and size left ..
>> > >> - start_new_rx_buffer() has returned true ..
>> > >> - so we end up in get_next_rx_buffer
>> > >> - this does a RING_GET_REQUEST and ups cons ..
>> > >> - and we end up with a bad grant reference.
>> > >>
>> > >> Sometimes we are saved by the bell .. since additional slots have
>> become
>> > >> free (you see cons become > prod in "get_next_rx_buffer" but shortly
>> > after
>> > >> that prod is increased ..
>> > >> just in time to not cause a overrun).
>> > >>
>> >
>> > > Ah, but hang on... There's a BUG_ON meta_slots_used >
>> > max_slots_needed, so if we are overflowing the worst-case calculation
>> then
>> > why is that BUG_ON not firing?
>> >
>> > You mean:
>> >                 sco = (struct skb_cb_overlay *)skb->cb;
>> >                 sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
>> >                 BUG_ON(sco->meta_slots_used > max_slots_needed);
>> >
>> > in "get_next_rx_buffer" ?
>> >
>> 
>> That code excerpt is from net_rx_action(),isn't it?
>> 
>> > I don't know .. at least now it doesn't crash dom0 and therefore not my
>> > complete machine and since tcp is recovering from a failed packet  :-)
>> >
>> 
>> Well, if the code calculating max_slots_needed were underestimating then
>> the BUG_ON() should fire. If it is not firing in your case then this suggests
>> your problem lies elsewhere, or that meta_slots_used is not equal to the
>> number of ring slots consumed.
>> 
>> > But probably because "npo->copy_prod++" seems to be used for the frags
>> ..
>> > and it isn't added to  npo->meta_prod ?
>> >
>> 
>> meta_slots_used is calculated as the value of meta_prod at return (from
>> xenvif_gop_skb()) minus the value on entry , and if you look back up the
>> code then you can see that meta_prod is incremented every time
>> RING_GET_REQUEST() is evaluated. So, we must be consuming a slot without
>> evaluating RING_GET_REQUEST() and I think that's exactly what's
>> happening... Right at the bottom of xenvif_gop_frag_copy() req_cons is
>> simply incremented in the case of a GSO. So the BUG_ON() is indeed off by
>> one.
>> 

> Can you re-test with the following patch applied?

>   Paul

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback
> index 438d0c0..4f24220 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -482,6 +482,8 @@ static void xenvif_rx_action(struct xenvif *vif)

>         while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
>                 RING_IDX max_slots_needed;
> +               RING_IDX old_req_cons;
> +               RING_IDX ring_slots_used;
>                 int i;

>                 /* We need a cheap worse case estimate for the number of
> @@ -511,8 +513,12 @@ static void xenvif_rx_action(struct xenvif *vif)
>                         vif->rx_last_skb_slots = 0;

>                 sco = (struct skb_cb_overlay *)skb->cb;
> +
> +               old_req_cons = vif->rx.req_cons;
>                 sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
> -               BUG_ON(sco->meta_slots_used > max_slots_needed);
> +               ring_slots_used = vif->rx.req_cons - old_req_cons;
> +
> +               BUG_ON(ring_slots_used > max_slots_needed);

>                 __skb_queue_tail(&rxq, skb);
>         }

That blew pretty fast .. on that BUG_ON

[  290.218182] ------------[ cut here ]------------
[  290.225425] kernel BUG at drivers/net/xen-netback/netback.c:664!
[  290.232717] invalid opcode: 0000 [#1] SMP
[  290.239875] Modules linked in:
[  290.246923] CPU: 0 PID: 10447 Comm: vif7.0 Not tainted 3.13.6-20140326-nbdebug35+ #1
[  290.254040] Hardware name: MSI MS-7640/890FXA-GD70 (MS-7640)  , BIOS V1.8B1 09/13/2010
[  290.261313] task: ffff880055d16480 ti: ffff88004cb7e000 task.ti: ffff88004cb7e000
[  290.268713] RIP: e030:[<ffffffff81780430>]  [<ffffffff81780430>] xenvif_rx_action+0x1650/0x1670
[  290.276193] RSP: e02b:ffff88004cb7fc28  EFLAGS: 00010202
[  290.283555] RAX: 0000000000000006 RBX: ffff88004c630000 RCX: 3fffffffffffffff
[  290.290908] RDX: 00000000ffffffff RSI: ffff88004c630940 RDI: 0000000000048e7b
[  290.298325] RBP: ffff88004cb7fde8 R08: 0000000000007bc9 R09: 0000000000000005
[  290.305809] R10: ffff88004cb7fd28 R11: ffffc90012690600 R12: 0000000000000004
[  290.313217] R13: ffff8800536a84e0 R14: 0000000000000001 R15: ffff88004c637618
[  290.320521] FS:  00007f1d3030c700(0000) GS:ffff88005f600000(0000) knlGS:0000000000000000
[  290.327839] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[  290.335216] CR2: ffffffffff600400 CR3: 0000000058537000 CR4: 0000000000000660
[  290.342732] Stack:
[  290.350129]  ffff88004cb7fd2c ffff880000000005 ffff88004cb7fd28 ffffffff810f7fc8
[  290.357652]  ffff880055d16b50 ffffffff00000407 ffff880000000000 ffffffff00000000
[  290.365048]  ffff880055d16b50 ffff880000000001 ffff880000000001 ffffffff00000000
[  290.372461] Call Trace:
[  290.379806]  [<ffffffff810f7fc8>] ? __lock_acquire+0x418/0x2220
[  290.387211]  [<ffffffff810df5f6>] ? finish_task_switch+0x46/0xf0
[  290.394552]  [<ffffffff81781400>] xenvif_kthread+0x40/0x190
[  290.401808]  [<ffffffff810f05e0>] ? __init_waitqueue_head+0x60/0x60
[  290.408993]  [<ffffffff817813c0>] ? xenvif_stop_queue+0x60/0x60
[  290.416238]  [<ffffffff810d4f24>] kthread+0xe4/0x100
[  290.423428]  [<ffffffff81b4cf30>] ? _raw_spin_unlock_irq+0x30/0x50
[  290.430615]  [<ffffffff810d4e40>] ? __init_kthread_worker+0x70/0x70
[  290.437793]  [<ffffffff81b4e13c>] ret_from_fork+0x7c/0xb0
[  290.444945]  [<ffffffff810d4e40>] ? __init_kthread_worker+0x70/0x70
[  290.452091] Code: fd ff ff 48 8b b5 f0 fe ff ff 48 c7 c2 10 98 ce 81 31 c0 48 8b be c8 7c 00 00 48 c7 c6 f0 f1 fd 81 e8 35 be 24 00 e9 ba f8 ff ff <0f> 0b 0f 0b 41 bf 01 00 00 00 e9 55 f6 ff ff 0f 0b 66 66 66 66
[  290.467121] RIP  [<ffffffff81780430>] xenvif_rx_action+0x1650/0x1670
[  290.474436]  RSP <ffff88004cb7fc28>
[  290.482400] ---[ end trace 2fcf9e9ae26950b3 ]---
