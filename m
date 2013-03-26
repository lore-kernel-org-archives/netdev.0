From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: defxx: skb_push() failing?
Date: Tue, 26 Mar 2013 09:30:10 -0700
Message-ID: <1364315410.1716.40.camel@edumazet-glaptop>
References: <5151B0CE.5000000@ll.mit.edu>
	 <1364310900.1716.21.camel@edumazet-glaptop> <5151C6C3.6090408@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"macro@linux-mips.org" <macro@linux-mips.org>
To: David Oostdyk <daveo@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:58012 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933918Ab3CZQaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:30:13 -0400
Received: by mail-da0-f54.google.com with SMTP id p1so3735552dad.27
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 09:30:12 -0700 (PDT)
In-Reply-To: <5151C6C3.6090408@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 12:03 -0400, David Oostdyk wrote:
> On 03/26/13 11:15, Eric Dumazet wrote:
> > On Tue, 2013-03-26 at 10:29 -0400, David Oostdyk wrote:
> >> Hello,
> >>
> >> In dfx_xmt_queue_pkt() in defxx.c, there is a skb_push(3) call which
> >> makes room for 3 packet request header bytes.  There is some discussion
> >> in the driver explaining why those three bytes will be available.  I
> >> have an old FDDI card that I'm trying to bring up:
> >>
> >> 05:05.0 FDDI network controller: Digital Equipment Corporation
> >> PCI-to-PDQ Interface Chip [PFI] (rev 02)
> >>
> >> Most skbuffs that come through dfx_xmit_queue_pkt() have 11 bytes
> >> between skb->head and skb->data.  On the other hand, at almost exactly
> >> 60-second intervals, an skb arrives that has zero bytes between
> >> skb->head and skb->data.  This normally causes a kernel panic, and for
> >> the time I just skip over such skb's.
> >>
> >> Does anyone have advice on where I should start digging to find the
> >> cause of this?
> >>
> > Have you read comments in defxx.c file around line 151 ?
> >
> > If one skb arrives with not enough headroom, you could add a
> >
> > WARN_ON_ONCE(skb_headroom(skb) < 3);
> >
> > and report stack trace so that we can identify and fix the caller.
> >
> >
> >
> 
> I have read the comments, and alloc_fddidev() seems to set the 
> hard_header_len as described.
> 
> As for the stack trace, thanks for the tip!  Here is the output 
> (including various defxx debug statements):
> 
> [  350.312482] defxx: v1.10 2006/12/14  Lawrence V. Stefani and others
> [  350.312582] In dfx_driver_init...
> [  350.312583] In dfx_bus_init...
> [  350.312585] In dfx_bus_config_check...
> [  351.699416] 0000:05:05.0: DEFPA at addr = 0xf9eeff80, IRQ = 26, 
> Hardware addr = 00-60-b0-58-48-53
> [  351.699425] 0000:05:05.0: Descriptor block virt = FFFF8800CB834000, 
> phys = CB834000
> [  351.699426] 0000:05:05.0: Command Request buffer virt = 
> FFFF8800CB835380, phys = CB835380
> [  351.699427] 0000:05:05.0: Command Response buffer virt = 
> FFFF8800CB835580, phys = CB835580
> [  351.699428] 0000:05:05.0: Receive buffer block virt = 
> FFFF8800CB835780, phys = CB835780
> [  351.699429] 0000:05:05.0: Consumer block virt = FFFF8800CB835780, 
> phys = CB835780
> [  351.700049] 0000:05:05.0: registered as fddi0
> [  351.756194] In dfx_open...
> [  351.756215] In dfx_adap_init...
> [  353.927747] fddi0: Multicast address table updated!  Added 1 addresses.
> [  353.930352] fddi0: Adapter filters updated!
> [  353.975887] fddi0: Multicast address table updated!  Added 1 addresses.
> [  353.978492] fddi0: Adapter filters updated!
> [  354.043455] fddi0: Multicast address table updated!  Added 2 addresses.
> [  354.046359] fddi0: Adapter filters updated!
> [  354.097315] fddi0: Multicast address table updated!  Added 3 addresses.
> [  354.099919] fddi0: Adapter filters updated!
> [  354.204301] fddi0: Multicast address table updated!  Added 3 addresses.
> [  354.207107] fddi0: Adapter filters updated!
> [  354.257972] fddi0: Multicast address table updated!  Added 3 addresses.
> [  354.261577] fddi0: Adapter filters updated!
> [  362.976038] ------------[ cut here ]------------
> [  362.976044] WARNING: at drivers/net/fddi/defxx.c:3202 
> dfx_xmt_queue_pkt+0xa2/0x2f2 [defxx]()
> [  362.976046] Hardware name: Precision WorkStation 490
> [  362.976047] Modules linked in: defxx snd_hda_codec_idt snd_hda_intel 
> snd_hda_codec snd_hwdep snd_pcm iTCO_wdt snd_page_alloc lpc_ich 
> snd_timer mfd_core i5000_edac rng_core i2c_i801 fddi rtc_cmos [last 
> unloaded: defxx]
> [  362.976066] Pid: 1773, comm: aoe_tx Tainted: G          I 
> 3.7.10-hippi+ #6
> [  362.976068] Call Trace:
> [  362.976076]  [<ffffffff810357e7>] warn_slowpath_common+0x7e/0x96
> [  362.976080]  [<ffffffff81035814>] warn_slowpath_null+0x15/0x17
> [  362.976083]  [<ffffffffa0063213>] dfx_xmt_queue_pkt+0xa2/0x2f2 [defxx]
> [  362.976088]  [<ffffffff813c3401>] ? map_single+0x45/0x45
> [  362.976093]  [<ffffffff819175a8>] dev_hard_start_xmit+0x288/0x398
> [  362.976097]  [<ffffffff81929d1c>] sch_direct_xmit+0x72/0x19b
> [  362.976100]  [<ffffffff819179ec>] dev_queue_xmit+0x145/0x339
> [  362.976105]  [<ffffffff8184ab20>] tx+0x1c/0x42
> [  362.976108]  [<ffffffff818489a2>] kthread+0x5e/0xbf
> [  362.976113]  [<ffffffff81056451>] ? try_to_wake_up+0x239/0x239
> [  362.976116]  [<ffffffff81848944>] ? rexmit_timer+0x349/0x349
> [  362.976119]  [<ffffffff8104c678>] kthread+0xb5/0xbd
> [  362.976122]  [<ffffffff8104c5c3>] ? __kthread_parkme+0x67/0x67
> [  362.976127]  [<ffffffff81a314ec>] ret_from_fork+0x7c/0xb0
> [  362.976129]  [<ffffffff8104c5c3>] ? __kthread_parkme+0x67/0x67
> [  362.976131] ---[ end trace ce553e95611628f3 ]---
> 
> 
> Thanks again for any help!

Are you really using AOE ?

drivers/block/aoe/aoenet.c can apparently call dev_queue_xmit() with non
compliant skbs.

Please try following patch :

diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 25ef5c0..92b6d7c 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -51,8 +51,9 @@ new_skb(ulong len)
 {
 	struct sk_buff *skb;
 
-	skb = alloc_skb(len, GFP_ATOMIC);
+	skb = alloc_skb(len + MAX_HEADER, GFP_ATOMIC);
 	if (skb) {
+		skb_reserve(skb, MAX_HEADER);
 		skb_reset_mac_header(skb);
 		skb_reset_network_header(skb);
 		skb->protocol = __constant_htons(ETH_P_AOE);
