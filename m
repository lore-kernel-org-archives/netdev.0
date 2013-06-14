From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panics in tcp_ack
Date: Fri, 14 Jun 2013 13:52:39 -0700
Message-ID: <1371243159.3252.134.camel@edumazet-glaptop>
References: <51ABE067.2050507@gmail.com>
	  <1370219787.24311.113.camel@edumazet-glaptop> <51ABFE10.1030206@gmail.com>
	  <51AC9499.8070207@gmail.com> <1370265931.24311.138.camel@edumazet-glaptop>
	 <51BB6B0A.2070502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:46991 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab3FNUwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 16:52:44 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so589090eek.8
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 13:52:43 -0700 (PDT)
In-Reply-To: <51BB6B0A.2070502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 14:12 -0500, Rob Herring wrote:
> On 06/03/2013 08:25 AM, Eric Dumazet wrote:
> > On Mon, 2013-06-03 at 08:05 -0500, Rob Herring wrote:
> >> On 06/02/2013 09:23 PM, Rob Herring wrote:
> >>> On 06/02/2013 07:36 PM, Eric Dumazet wrote:
> >>>> On Sun, 2013-06-02 at 19:16 -0500, Rob Herring wrote:
> >>>>> Sorry, this time with proper line wrapping...
> >>>>>
> >>>>> I'm debugging a kernel panic in the networking stack that happens with a
> >>>>> cluster (20-40 nodes) of Calxeda highbank (ARM Cortex A9) nodes and
> >>>>> typically only after 10-24 hours. The node are transferring files
> >>>>> between nodes over TCP with 20 clients and servers per node. The kernel
> >>>>> is based on ubuntu 3.5 kernel which is based on 3.5.7.11. So far testing
> >>>>> has shown that 3.8.11 based (ubuntu raring) kernel is fixed. Attempts to
> >>>>> bisect have not yielded results as it seems multiple problems mask the
> >>>>> issue. Perhaps there is some new feature which has indirectly fixed the
> >>>>> problem in 3.8.
> >>>>>
> >>>>> This commit appears to fix a similar panic and seems to reduce the
> >>>>> frequency after picking it up in the latest 3.5 stable:
> >>>>>
> >>>>> commit 16fad69cfe4adbbfa813de516757b87bcae36d93
> >>>>> Author: Eric Dumazet <edumazet@google.com>
> >>>>> Date:   Thu Mar 14 05:40:32 2013 +0000
> >>>>>
> >>>>>     tcp: fix skb_availroom()
> >>>>>         Chrome OS team reported a crash on a Pixel ChromeBook in TCP stack :
> >>>>>         https://code.google.com/p/chromium/issues/detail?id=182056
> >>>>>         commit a21d45726acac (tcp: avoid order-1 allocations on wifi and tx
> >>>>>     path) did a poor choice adding an 'avail_size' field to skb, while
> >>>>>     what we really needed was a 'reserved_tailroom' one.
> >>>>>         It would have avoided commit 22b4a4f22da (tcp: fix retransmit of
> >>>>>     partially acked frames) and this commit.
> >>>>>         Crash occurs because skb_split() is not aware of the 'avail_size'
> >>>>>     management (and should not be aware)
> >>>>>         Signed-off-by: Eric Dumazet <edumazet@google.com>
> >>>>>     Reported-by: Mukesh Agrawal <quiche@chromium.org>
> >>>>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>>>>
> >>>>> I've searched thru 3.8 and 3.9 stable fixes looking for possibly
> >>>>> relevant commits and applied these commits not in 3.5 stable. However,
> >>>>> they have not helped:
> >>>>>
> >>>>> net: drop dst before queueing fragments
> >>>>> tcp: call tcp_replace_ts_recent() from tcp_ack()
> >>>>> tcp: Reallocate headroom if it would overflow csum_start
> >>>>> tcp: incoming connections might use wrong route under synflood
> >>>>>
> >>>>
> >>>> try also :
> >>>>
> >>>> commit 093162553c33e94 (tcp: force a dst refcount when prequeue packet)
> >>>> commit 0d4f0608619de59 (tcp: dont handle MTU reduction on LISTEN socket)
> >>>
> >>> Will add and test.
> >>>
> >>>> commit 6731d2095bd4aef (tcp: fix for zero packets_in_flight was too
> >>>> broad)
> >>>> commit 2e5f421211ff76c (tcp: frto should not set snd_cwnd to 0)
> >>>
> >>> I have these 2.
> >>
> >> Ran overnight with the 2 additional patches. One panic after ~9 hours
> >> running on 75 nodes.
> >>
> >> <4>[30632.185861] [<c04070f4>] (tcp_ack+0x79c/0x1014) from [<c0407cb4>]
> >> (tcp_rcv_established+0x348/0x5e0)
> >> <4>[30632.194903] [<c0407cb4>] (tcp_rcv_established+0x348/0x5e0) from
> >> [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc)
> >> <4>[30632.204291] [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc) from
> >> [<c04111cc>] (tcp_v4_rcv+0x834/0x918)
> >> <4>[30632.212900] [<c04111cc>] (tcp_v4_rcv+0x834/0x918) from
> >> [<c03ef81c>] (ip_local_deliver_finish+0xe8/0x33c)
> >> <4>[30632.222376] [<c03ef81c>] (ip_local_deliver_finish+0xe8/0x33c) from
> >> [<c03ef3b4>] (ip_rcv_finish+0x140/0x4c0)
> >> <4>[30632.232115] [<c03ef3b4>] (ip_rcv_finish+0x140/0x4c0) from
> >> [<c03bf944>] (__netif_receive_skb+0x5e0/0x690)
> >> <4>[30632.241590] [<c03bf944>] (__netif_receive_skb+0x5e0/0x690) from
> >> [<c03c06e8>] (netif_receive_skb+0x1c/0x90)
> >> <4>[30632.251240] [<c03c06e8>] (netif_receive_skb+0x1c/0x90) from
> >> [<c03c2fac>] (napi_skb_finish+0x54/0x78)
> >> <4>[30632.260371] [<c03c2fac>] (napi_skb_finish+0x54/0x78) from
> >> [<c03301e4>] (xgmac_poll+0x3ac/0x4ec)
> >> <4>[30632.269066] [<c03301e4>] (xgmac_poll+0x3ac/0x4ec) from
> >> [<c03c2758>] (net_rx_action+0x140/0x228)
> >> <4>[30632.277761] [<c03c2758>] (net_rx_action+0x140/0x228) from
> >> [<c002ac94>] (__do_softirq+0xb4/0x1cc)
> >> <4>[30632.286541] [<c002ac94>] (__do_softirq+0xb4/0x1cc) from
> >> [<c002b18c>] (irq_exit+0x80/0x88)
> >> <4>[30632.294716] [<c002b18c>] (irq_exit+0x80/0x88) from [<c000ea7c>]
> >> (handle_IRQ+0x50/0xb0)
> >> <4>[30632.302629] [<c000ea7c>] (handle_IRQ+0x50/0xb0) from [<c00084d4>]
> >> (gic_handle_irq+0x24/0x58)
> >> <4>[30632.311062] [<c00084d4>] (gic_handle_irq+0x24/0x58) from
> >> [<c049e100>] (__irq_svc+0x40/0x50)
> >> <4>[30632.319402] Exception stack(0xeca4dc10 to 0xeca4dc58)
> >> <4>[30632.324445] dc00:                                     c2f7a580
> >> 02000020 02000000 00000000
> >> <4>[30632.332615] dc20: c2f7a580 e9e4f33c e9e4f34c 00000000 ec185300
> >> 00001000 00000000 00001000
> >> <4>[30632.340783] dc40: 00000001 eca4dc58 c0136cbc c0136cd4 200f0013
> >> ffffffff
> >> <4>[30632.347398] [<c049e100>] (__irq_svc+0x40/0x50) from [<c0136cd4>]
> >> (__set_page_dirty+0x80/0xc0)
> >> <4>[30632.355919] [<c0136cd4>] (__set_page_dirty+0x80/0xc0) from
> >> [<c01387ac>] (__block_commit_write+0xb4/0xe0)
> >> <4>[30632.365394] [<c01387ac>] (__block_commit_write+0xb4/0xe0) from
> >> [<c0138eb4>] (block_write_end+0x4c/0x84)
> >> <4>[30632.374782] [<c0138eb4>] (block_write_end+0x4c/0x84) from
> >> [<c0138f20>] (generic_write_end+0x34/0xb0)
> >> <4>[30632.383911] [<c0138f20>] (generic_write_end+0x34/0xb0) from
> >> [<c01a0b8c>] (ext4_da_write_end+0xa4/0x340)
> >> <4>[30632.393303] [<c01a0b8c>] (ext4_da_write_end+0xa4/0x340) from
> >> [<c00ca2bc>] (generic_file_buffered_write+0xe0/0x25
> >> 8)
> >> <4>[30632.403648] [<c00ca2bc>] (generic_file_buffered_write+0xe0/0x258)
> >> from [<c00cb1d8>] (__generic_file_aio_write+0x
> >> 274/0x4bc)
> >> <4>[30632.414684] [<c00cb1d8>] (__generic_file_aio_write+0x274/0x4bc)
> >> from [<c00cb47c>] (generic_file_aio_write+0x5c/0
> >> xc8)
> >> <4>[30632.425201] [<c00cb47c>] (generic_file_aio_write+0x5c/0xc8) from
> >> [<c019810c>] (ext4_file_write+0xcc/0x2a0)
> >> <4>[30632.434853] [<c019810c>] (ext4_file_write+0xcc/0x2a0) from
> >> [<c010a950>] (do_sync_write+0xa8/0xe8)
> >> <4>[30632.443722] [<c010a950>] (do_sync_write+0xa8/0xe8) from
> >> [<c010b360>] (vfs_write+0x9c/0x170)
> >> <4>[30632.452069] [<c010b360>] (vfs_write+0x9c/0x170) from [<c010b648>]
> >> (sys_write+0x38/0x70)
> >> <4>[30632.460068] [<c010b648>] (sys_write+0x38/0x70) from [<c000db60>]
> >> (ret_fast_syscall+0x0/0x30)
> >>
> >> The full stack looks like this:
> >>
> >> include/linux/skbuff.h:__skb_unlink
> >> include/net/tcp.h:tcp_unlink_write_queue
> >> net/ipv4/tcp_input.c:tcp_clean_rtx_queue
> >> net/ipv4/tcp_input.c:tcp_ack
> >>
> >> This panic is in __skb_unlink with the skb prev ptr being NULL. Here's
> >> the disassembly:
> >>
> >>                 if (!fully_acked)
> >> c04070cc:       e3520000        cmp     r2, #0
> >> c04070d0:       0afffecb        beq     c0406c04 <tcp_ack+0x2ac>
> >> extern void        skb_unlink(struct sk_buff *skb, struct sk_buff_head
> >> *list);
> >> static inline void __skb_unlink(struct sk_buff *skb, struct sk_buff_head
> >> *list)
> >> {
> >>         struct sk_buff *next, *prev;
> >>
> >>         list->qlen--;
> >> c04070d4:       e59430a8        ldr     r3, [r4, #168]  ; 0xa8
> >> static inline void sk_wmem_free_skb(struct sock *sk, struct sk_buff *skb)
> >> {
> >>         sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
> >>         sk->sk_wmem_queued -= skb->truesize;
> >>         sk_mem_uncharge(sk, skb->truesize);
> >>         __kfree_skb(skb);
> >> c04070d8:       e1a00005        mov     r0, r5
> >> c04070dc:       e2433001        sub     r3, r3, #1
> >> c04070e0:       e58430a8        str     r3, [r4, #168]  ; 0xa8
> >>         next       = skb->next;
> >>         prev       = skb->prev;
> >> c04070e4:       e895000c        ldm     r5, {r2, r3}
> >>         skb->next  = skb->prev = NULL;
> >> c04070e8:       e5859000        str     r9, [r5]
> >> c04070ec:       e5859004        str     r9, [r5, #4]
> >>         next->prev = prev;
> >> c04070f0:       e5823004        str     r3, [r2, #4]
> >>         prev->next = next;
> >> c04070f4:       e5832000        str     r2, [r3]
> >>
> >> Rob
> > 
> > 
> > This looks like random memory scribbling of NULL pointers to me.
> > 
> > I have never seen such a pattern. (I admit I do not use ARM machines as
> > much as you do :) )
> > 
> > Your best bet would be to perform a (reverse) bisection if you know
> > recent kernels are OK.
> 
> We've been able to get kgdb working for this and found some additional
> info. We first load the next and prev ptrs into r2 and r3 from the skb:
> 
>    0xc0407340 <+1932>:	ldm	r5, {r2, r3}
> 
> Then in kgdb, we get these values for r2 and r3:
> 
> r2             0xca6c3200
> r3             0x0
> 
> But, if we go read the skb in kgdb, both pointers are NULL:
> 
> (gdb) p *skb
> $3 = {next = 0x0, prev = 0x0, tstamp = {tv64 = 1371139692889955006}, sk
> = 0x0, dev = 0x0,
>   cb = '\000' <repeats 24 times>,
> "X\244\021\027\000\252\021\027\226Ts\000\020\000\000\000\000\000\000\000\000\000\000",
> _skb_refdst = 0, sp = 0x0, len = 1448, data_len = 1448, mac_len = 0,
>   hdr_len = 0, {csum = 0, {csum_start = 0, csum_offset = 0}}, priority =
> 0, local_df = 0 '\000',
>   cloned = 1 '\001', ip_summed = 3 '\003', nohdr = 1 '\001', nfctinfo =
> 0 '\000',
>   pkt_type = 0 '\000', fclone = 1 '\001', ipvs_property = 0 '\000',
> peeked = 0 '\000',
>   nf_trace = 0 '\000', protocol = 0, destructor = 0x0, nfct = 0x0,
> nfct_reasm = 0x0,
>   nf_bridge = 0x0, skb_iif = 0, rxhash = 0, vlan_tci = 0, tc_index = 0,
> tc_verd = 0,
>   queue_mapping = 0, ndisc_nodetype = 0 '\000', ooo_okay = 0 '\000',
> l4_rxhash = 0 '\000',
>   wifi_acked_valid = 0 '\000', wifi_acked = 0 '\000', no_fcs = 0 '\000',
> head_frag = 0 '\000',
>   secmark = 0, {mark = 48, dropcount = 48, reserved_tailroom = 48},
> transport_header = 0x0,
>   network_header = 0x0, mac_header = 0x0,
>   tail = 0xea286b10 "eachpeachpeachpeachpeachpeachpea\300\254\205",
> <incomplete sequence \302>,
>   end = 0xea286b40 "\001", head = 0xea286a00 "",
>   data = 0xea286b10 "eachpeachpeachpeachpeachpeachpea\300\254\205",
> <incomplete sequence \302>,
>   truesize = 2152, users = {counter = 1}}
> 
> This doesn't seem like random scribbling, but some ordering issue.
> 

I see nothing wrong, as __skb_unlink() clears skb->next and skb->prev

crash happens a bit later :

prev->next = next;


> Anything else look suspect in the skb?

Not really.

Only problem is skb->prev was NULL

> 
> What lock should be held at this point?
> 

The socket lock
