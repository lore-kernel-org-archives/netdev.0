From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Wed, 10 Oct 2012 14:24:28 +0200
Message-ID: <1622789731.20121010142428@eikelenboom.it>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	<1349790863.21172.4406.camel@edumazet-glaptop>
	<1349792241.21847.199.camel@zakaz.uk.xensource.com>
	<1349792847.21172.4479.camel@edumazet-glaptop>
	<1349793630.21847.208.camel@zakaz.uk.xensource.com>
	<1349863984.10070.26.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, xen-devel <xen-devel@lists.xen.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1349863984.10070.26.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


Wednesday, October 10, 2012, 12:13:04 PM, you wrote:

> On Tue, 2012-10-09 at 15:40 +0100, Ian Campbell wrote:
>> On Tue, 2012-10-09 at 15:27 +0100, Eric Dumazet wrote:
>> > On Tue, 2012-10-09 at 15:17 +0100, Ian Campbell wrote:
>> > 
>> > > Does the higher order pages effectively reduce the number of frags which
>> > > are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
>> > > have 64K worth of frag data.
>> > > 
>> > > If we switch to order-3 pages everywhere then can the skb contain 512K
>> > > of data, or does the effective maximum number of frags in an skb reduce
>> > > to 2?
>> > 
>> > effective number of frags reduce to 2 or 3
>> > 
>> > (We still limit GSO packets to ~63536 bytes)
>> 
>> Great! Then I think the fix is more/less trivial...

> The following seems to work for me.

But it doesn't seem to work for me ... dmesg attached.

I don't know if the "mcelog:4359 map pfn expected mapping type write-back for [mem 0x0009f000-0x000a0fff], got uncached-minus"
is related, is shows up right after the nics get initialized ?

netback still fails with:

[  191.777994] ------------[ cut here ]------------
[  191.784245] kernel BUG at drivers/net/xen-netback/netback.c:481!
[  191.790423] invalid opcode: 0000 [#1] PREEMPT SMP 
[  191.796462] Modules linked in:
[  191.802315] CPU 1 
[  191.802367] Pid: 1177, comm: netback/1 Tainted: G        W    3.6.0pre-rc1-20121010 #1 MSI MS-7640/890FXA-GD70 (MS-7640)  
[  191.814043] RIP: e030:[<ffffffff8146de61>]  [<ffffffff8146de61>] netbk_gop_frag_copy+0x3f1/0x400
[  191.820171] RSP: e02b:ffff880037c6bb98  EFLAGS: 00010246
[  191.826271] RAX: 0000000000000244 RBX: ffffc90010827f98 RCX: ffff880031ed9880
[  191.832450] RDX: 00000000000000a8 RSI: ffff880037c6bd24 RDI: ffffea0000b03f80
[  191.838581] RBP: ffff880037c6bc28 R08: ffff8800319f8100 R09: 0000000000001000
[  191.844739] R10: 0000000000000000 R11: 0000000000000132 R12: 00000000000000a8
[  191.850785] R13: ffff880037c6bcd8 R14: 0000000000001000 R15: ffffc9001082cf70
[  191.856741] FS:  00007f9f3c944700(0000) GS:ffff88003f840000(0000) knlGS:0000000000000000
[  191.862841] CS:  e033 DS: 0000 ES: 0000 CR0: 000000008005003b
[  191.868901] CR2: 0000000001337ca0 CR3: 0000000032cec000 CR4: 0000000000000660
[  191.875053] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  191.881175] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  191.887247] Process netback/1 (pid: 1177, threadinfo ffff880037c6a000, task ffff880039984140)
[  191.893325] Stack:
[  191.899328]  ffff880037c6bd24 00000000000000a8 ffff8800319f8100 ffff880031ed9880
[  191.905534]  ffffc90000000000 0000000000001000 0000000000000000 0000000000000000
[  191.911742]  ffff880000000000 ffffffff817459f3 ffffc90010823420 ffffea0000b03f80
[  191.917898] Call Trace:
[  191.923939]  [<ffffffff817459f3>] ? _raw_spin_unlock_irqrestore+0x53/0xa0
[  191.930141]  [<ffffffff8146e1cb>] xen_netbk_rx_action+0x30b/0x830
[  191.936543]  [<ffffffff810ad22d>] ? trace_hardirqs_on+0xd/0x10
[  191.942942]  [<ffffffff8146f6da>] xen_netbk_kthread+0xba/0xa90
[  191.949147]  [<ffffffff81095b06>] ? try_to_wake_up+0x1b6/0x310
[  191.955250]  [<ffffffff81086b40>] ? wake_up_bit+0x40/0x40
[  191.961421]  [<ffffffff8146f620>] ? xen_netbk_tx_build_gops+0xa70/0xa70
[  191.967660]  [<ffffffff810864d6>] kthread+0xd6/0xe0
[  191.973834]  [<ffffffff81086400>] ? __init_kthread_worker+0x70/0x70
[  191.979953]  [<ffffffff8174677c>] ret_from_fork+0x7c/0x90
[  191.986107]  [<ffffffff81086400>] ? __init_kthread_worker+0x70/0x70
[  191.992174] Code: b8 b3 00 00 48 8d 8c f1 60 01 00 00 48 3b 14 01 0f 85 72 fc ff ff e9 7a fc ff ff 0f 0b eb fe 0f 0b eb fe 0f 0b eb fe 0f 0b eb fe <0f> 0b eb fe 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48 83 
[  192.005230] RIP  [<ffffffff8146de61>] netbk_gop_frag_copy+0x3f1/0x400
[  192.011786]  RSP <ffff880037c6bb98>
[  192.018402] ---[ end trace c51ab5e2c2c918fc ]---


--

Sander

> I haven't tackled netfront yet.

> 8<--------------------------------------------------------------

> From 551e42e3dd203f2eb97cb082985013bb33b8f020 Mon Sep 17 00:00:00 2001
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Tue, 9 Oct 2012 15:51:20 +0100
> Subject: [PATCH] xen: netback: handle compound page fragments on transmit.

> An SKB paged fragment can consist of a compound page with order > 0.
> However the netchannel protocol deals only in PAGE_SIZE frames.

> Handle this in netbk_gop_frag_copy and xen_netbk_count_skb_slots by
> iterating over the frames which make up the page.

> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Konrad Rzeszutek Wilk <konrad@kernel.org>
> Cc: Sander Eikelenboom <linux@eikelenboom.it>
> ---
>  drivers/net/xen-netback/netback.c |   40 ++++++++++++++++++++++++++++++++----
>  1 files changed, 35 insertions(+), 5 deletions(-)

> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 4ebfcf3..d747e30 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -335,21 +335,35 @@ unsigned int xen_netbk_count_skb_slots(struct xenvif *vif, struct sk_buff *skb)
>  
>         for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>                 unsigned long size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
> +               unsigned long offset = skb_shinfo(skb)->frags[i].page_offset;
>                 unsigned long bytes;
> +
> +               offset &= ~PAGE_MASK;
> +
>                 while (size > 0) {
> +                       BUG_ON(offset >= PAGE_SIZE);
>                         BUG_ON(copy_off > MAX_BUFFER_OFFSET);
>  
> -                       if (start_new_rx_buffer(copy_off, size, 0)) {
> +                       bytes = PAGE_SIZE - offset;
> +
> +                       if (bytes > size)
> +                               bytes = size;
> +
> +                       if (start_new_rx_buffer(copy_off, bytes, 0)) {
>                                 count++;
>                                 copy_off = 0;
>                         }
>  
> -                       bytes = size;
>                         if (copy_off + bytes > MAX_BUFFER_OFFSET)
>                                 bytes = MAX_BUFFER_OFFSET - copy_off;
>  
>                         copy_off += bytes;
> +
> +                       offset += bytes;
>                         size -= bytes;
> +
> +                       if (offset == PAGE_SIZE)
> +                               offset = 0;
>                 }
>         }
>         return count;
> @@ -403,14 +417,24 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>         unsigned long bytes;
>  
>         /* Data must not cross a page boundary. */
> -       BUG_ON(size + offset > PAGE_SIZE);
> +       BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
>  
>         meta = npo->meta + npo->meta_prod - 1;
>  
> +       /* Skip unused frames from start of page */
> +       page += offset >> PAGE_SHIFT;
> +       offset &= ~PAGE_MASK;
> +
>         while (size > 0) {
> +               BUG_ON(offset >= PAGE_SIZE);
>                 BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
>  
> -               if (start_new_rx_buffer(npo->copy_off, size, *head)) {
> +               bytes = PAGE_SIZE - offset;
> +
> +               if (bytes > size)
> +                       bytes = size;
> +
> +               if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
>                         /*
>                          * Netfront requires there to be some data in the head
>                          * buffer.
> @@ -420,7 +444,6 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>                         meta = get_next_rx_buffer(vif, npo);
>                 }
>  
> -               bytes = size;
>                 if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
>                         bytes = MAX_BUFFER_OFFSET - npo->copy_off;
>  
> @@ -453,6 +476,13 @@ static void netbk_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>                 offset += bytes;
>                 size -= bytes;
>  
> +               /* Next frame */
> +               if (offset == PAGE_SIZE) {
> +                       BUG_ON(!PageCompound(page));
> +                       page++;
> +                       offset = 0;
> +               }
> +
>                 /* Leave a gap for the GSO descriptor. */
>                 if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
>                         vif->rx.req_cons++;
