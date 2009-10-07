From: John Wright <john.wright@hp.com>
Subject: skb_shinfo(skb)->nr_frags > 0 while skb_is_gso(skb) == 0?
Date: Tue, 6 Oct 2009 19:03:15 -0600
Message-ID: <20091007010315.GA26498@neptune.jswright>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
Cc: Bob Montgomery <bob.montgomery@hp.com>
To: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:12603 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933569AbZJGBDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 21:03:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Bob Montgomery and I are debugging an OOPS in the bnx2 driver.  The
driver OOPSes in bnx2_tx_int(), getting a NULL pointer dereference when
checking if the skb is GSO.  (This is on 2.6.29, before is_gso was
cached in the tx_buf (commit d62fda08), but bear with me - while kernels
with that commit might not crash in the same place, I think we have
discovered a bug that would manifest itself another way.)

So, first, a question for someone who knows more about sk_buff's than I:
is it reasonable/legal for an skb for which skb_is_gso(skb) == 0 to also
have skb_shinfo(skb)->nr_frags > 0?

If yes, then for Michael, or someone familiar with bnx2 hardware: are
"partial BD completions" (where the hw_tx_cons value is on a ring index
that, on the tx_buf_ring, would have a NULL skb value, and on the
tx_desc_ring, the tx_bd would not have the TX_BD_FLAGS_START flag set)
possible only for gso skb's, or is it possible any time nr_frags > 0?

We have a crash where both of the above conditions seem to be met.  Our
crash actually occurs in skb_is_gso(skb) - when dereferencing skb, which
is NULL - called from this chunk of code in bnx2_tx_int():

...
                tx_buf = &txr->tx_buf_ring[sw_ring_cons];
                skb = tx_buf->skb;

                /* partial BD completions possible with TSO packets */
                if (skb_is_gso(skb)) {
                        u16 last_idx, last_ring_idx;

                        last_idx = sw_cons +
                                skb_shinfo(skb)->nr_frags + 1;
...

An analysis of the disassembly shows that, at the time of the OOPS, RCX
contains the bnapi passed to bnx2_tx_int, RBX contains in its lower two
bytes the value of sw_cons, and R12 contains the value of hw_cons, the
last read value of the hardware consumer pointer.  (See the disassembly
of bnx2_poll_work, which all this was inlined into, at [1].)  Now, from
the OOPS:

[120223.249838] RAX: 000000000000005b RBX: 000000005746575b RCX: ffff8801a43cd680
[120223.249838] R10: 0000000000000006 R11: ffff8800562f6bc0 R12: 000000000000575a

Already, we see hw_cons is 0x575a (corresponding to a ring index of
0x5a), and our sw_cons (which is never supposed to go beyond hw_cons) is
0x575b.  How did this happen?

Unfortunately, it looks like another CPU ran bnx2_start_xmit and put
stuff on this ring before the OOPS handler finished running and
crash_kexec() was called.  So in our actual dump, it looks like the skb
we tried to read was not really NULL:

crash> struct bnx2_napi.tx_ring ffff8801a43cd680
  tx_ring = {
    tx_prod_bseq = 0xf8c4f09b, 
    tx_prod = 0x5783, 
    tx_bidx_addr = 0x12588, 
    tx_bseq_addr = 0x12590, 
    tx_desc_ring = 0xffff8801a3cb4000, 
    tx_buf_ring = 0xffff880325e52000, 
    tx_cons = 0x5746, 
    hw_tx_cons = 0x5746, 
    tx_desc_mapping = 0x1a3cb4000
  }
crash> p *((struct sw_tx_bd *)(0xffff880325e52000) + 0x5b)
$20 = {
  skb = 0xffff8801574c2780
}

But we'll assume for now that the kernel didn't lie, and that it really
was NULL at the time of the OOPS. :)  What's interesting, though, is
the place where the card thinks it is:

crash> p *((struct sw_tx_bd *)(0xffff880325e52000) + 0x5a)
$21 = {
  skb = 0x0
}

Ok, we might expect this if we've just cleared that skb, but we couldn't
have, since that would mean our sw_cons value would equal hw_cons, and
we wouldn't have performed that iteration in the for loop.  (We only try
to clean up a particular ring index after the card has *passed* it.)
Inside of the tx_desc_ring for this bnapi is something more interesting:

crash> p *((struct tx_bd *)(0xffff8801a3cb4000) + 0x5a)
$22 = {
  tx_bd_haddr_hi = 0x2, 
  tx_bd_haddr_lo = 0x5a8acd31, 
  tx_bd_mss_nbytes = 0x36, 
  tx_bd_vlan_tag_flags = 0x42
}

But 0x42 == 0100 0010 == TX_BD_FLAGS_TCP_UDP_CKSUM | TX_BD_FLAGS_END.
Note, TX_BD_FLAGS_START is not one of its flags, and yet it's also not
GSO - if it were, we'd expect TX_BD_FLAGS_SW_LSO (1 << 15) to be set.
See bnx2_start_xmit:

...
        if ((mss = skb_shinfo(skb)->gso_size)) {
                u32 tcp_opt_len;
                struct iphdr *iph;

                vlan_tag_flags |= TX_BD_FLAGS_SW_LSO;
...

(I have verified that this flag, among others, is indeed set on a tx_bd
whose skb we still have and has non-zero gso_size.)

If we go back one, we find a tx_bd with the TX_BD_FLAGS_START set, but
not TX_BD_FLAGS_END:

crash> p *((struct tx_bd *)(0xffff8801a3cb4000) + 0x59)
$24 = {
  tx_bd_haddr_hi = 0x1, 
  tx_bd_haddr_lo = 0xf915d3e, 
  tx_bd_mss_nbytes = 0x42, 
  tx_bd_vlan_tag_flags = 0x82
}

So, presumably, the corresponding skb would have nr_frags = 1.


That said, here's what we *think* is happening:

At the end of one of the iterations through the
while(sw_cons != hw_cons) loop, we have sw_cons == 0x5759, and

  hw_cons = bnx2_get_hw_tx_cons(bnapi);  /* hw_cons = 0x575a */

Then, next time around the loop, sw_cons != hw_cons, so we go back
inside the loop.  But since the skb is not gso, we don't detect that the
card is in the middle of the fragmented skb, and then we go ahead and
increment sw_cons (nr_frags + 1) times, which puts it at 0x575b.  Then,
we clean up an skb and a DMA mapping that the card might still be using,
and go around the loop again.  And we'll keep doing so, until the card
happens to catch up with us or we crash.  I'm not sure what happens to
the card when the skb's and DMA mappings get ripped out from under it,
but I suppose it's not good - in this case, we happened not even to have
any more skb's in the tx_buf_ring to go through, so we crashed before we
could find out. :)

I think this patch (against v2.6.29 - after d62fda08, is_gso and
nr_frags are actually stored in the tx_buf - see attached patch for one
that would apply against linux-2.6.git HEAD) would solve this issue:


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a7e688a..db075c8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2615,8 +2615,8 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int 
                tx_buf = &txr->tx_buf_ring[sw_ring_cons];
                skb = tx_buf->skb;
 
-               /* partial BD completions possible with TSO packets */
-               if (skb_is_gso(skb)) {
+               /* partial BD completions possible with fragmented packets */
+               if (skb_shinfo(skb)->nr_frags) {
                        u16 last_idx, last_ring_idx;
 
                        last_idx = sw_cons +


Unfortunately, we haven't been able to reproduce this crash reliably.
(Under heavy network load, we've seen multiple crashes on the same
instruction; but this one seems to be the first that clearly exhibits
the "sw_cons overtakes hw_cons" behavior.  We're still analyzing some
older dumps to see if we can find evidence of the same behavior causing
those crashes.)

Can somebody who knows a bit more about sk_buff's and fragmenting
and/or the bnx2 chipsets comment on this?

I have attached the OOPS message and an equivalent patch that applies
against current linux-2.6.git, and posted a copy of the bnx2_poll_work
disassembly at [1].  I can also provide the debug vmlinux, modules, and
crash dump if necessary.

 [1]: http://free.linux.hp.com/~jswright/bnx2-crash-data/

Thanks!

-- 
+----------------------------------------------------------+
| John Wright <john.wright@hp.com>                         |
| HP Mission Critical OS Enablement & Solution Test (MOST) |
+----------------------------------------------------------+

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="oops-message.txt"

[120222.643171] BUG: unable to handle kernel NULL pointer dereference at 00000000000000cc
[120222.644007] IP: [<ffffffffa0089c65>] bnx2_poll_work+0xd5/0x1133 [bnx2]
[120222.644007] PGD 178498067 PUD 11f002067 PMD 0 
[120222.644007] Oops: 0000 [#1] SMP 
[120222.644007] last sysfs file: /sys/devices/system/cpu/cpu15/crash_notes
[120222.644007] CPU 0 
[120222.644007] Modules linked in: sctp crc32c libcrc32c ipmi_devintf nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc deflate zlib_deflate ctr twofish twofish_common camellia serpent blowfish des_generic cbc aes_x86_64 aes_generic xcbc rmd160 sha256_generic sha1_generic crypto_null af_key loop psmouse ipmi_si ipmi_msghandler hpilo serio_raw button container evdev ext3 jbd mbcache usbhid hid sg sr_mod cdrom ide_pci_generic ide_core ata_generic ata_piix libata ehci_hcd uhci_hcd cciss bnx2 zlib_inflate e1000e scsi_mod thermal processor fan thermal_sys
[120223.249838] Pid: 15233, comm: mirrorclient Not tainted 2.6.29-clim-3-amd64 #1 ProLiant DL380 G6
[120223.249838] RIP: 0010:[<ffffffffa0089c65>]  [<ffffffffa0089c65>] bnx2_poll_work+0xd5/0x1133 [bnx2]
[120223.249838] RSP: 0000:ffffffff8072ccf0  EFLAGS: 00010286
[120223.249838] RAX: 000000000000005b RBX: 000000005746575b RCX: ffff8801a43cd680
[120223.249838] RDX: ffff8801a43cd680 RSI: 000000000000005b RDI: ffff88007cfb4a28
[120223.249838] RBP: ffffffff8072ce60 R08: 0000000000000000 R09: 000000000000ad77
[120223.249838] R10: 0000000000000006 R11: ffff8800562f6bc0 R12: 000000000000575a
[120223.249838] R13: ffff880325e522d8 R14: 0000000000000000 R15: ffff8801a43c6b00
[120223.249838] FS:  0000000042df8950(0063) GS:ffffffff80735000(0000) knlGS:0000000000000000
[120223.249838] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[120223.249838] CR2: 00000000000000cc CR3: 000000003215c000 CR4: 00000000000006e0
[120223.249838] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[120223.249838] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[120223.249838] Process mirrorclient (pid: 15233, threadinfo ffff880035842000, task ffff880185c4b320)
[120223.249838] Stack:
[120223.249838]  000000000000001e 000000004d8d1012 0000000000000040 ffff8801a43cd680
[120223.249838]  ffff8801a43cc700 ffffffff80227322 ffffffff8072cd90 ffffffffa006765f
[120223.249838]  ffffffff8072cd70 ffff8801a4284000 ffff880325eb8800 ffff8801a425c940
[120223.249838] Call Trace:
[120223.249838]  <IRQ> <0> [<ffffffff80227322>] ? swiotlb_map_single_phys+0x0/0x18
[120223.249838]  [<ffffffffa006765f>] ? e1000_alloc_rx_buffers+0x13b/0x203 [e1000e]
[120225.260273]  [<ffffffffa0067a17>] ? e1000_clean_rx_irq+0x290/0x2cb [e1000e]
[120225.260273]  [<ffffffff80248291>] ? irq_exit+0x4c/0x79
[120225.401539]  [<ffffffffa008acf6>] bnx2_poll_msix+0x33/0xad [bnx2]
[120225.401539]  [<ffffffff804162e8>] net_rx_action+0xae/0x1a1
[120225.401539]  [<ffffffff80248584>] __do_softirq+0x8a/0x132
[120225.401539]  [<ffffffff8021251c>] call_softirq+0x1c/0x30
[120225.401539]  [<ffffffff8021362c>] do_softirq+0x44/0x8f
[120225.401539]  [<ffffffff80248284>] irq_exit+0x3f/0x79
[120225.770044]  [<ffffffff802138a6>] do_IRQ+0xc3/0xe5
[120225.770044]  [<ffffffff80211c93>] ret_from_intr+0x0/0x29
[120225.894313]  <EOI> <0> [<ffffffff8035d4fd>] ? copy_user_generic_string+0x2d/0x40
[120225.967993]  [<ffffffff80412b57>] ? memcpy_toiovec+0x37/0x67
[120226.056077]  [<ffffffff8041321e>] ? skb_copy_datagram_iovec+0x4b/0x1d8
[120226.056077]  [<ffffffff8044f389>] ? tcp_rcv_established+0x344/0xabb
[120226.220504]  [<ffffffff80456fa8>] ? tcp_v4_do_rcv+0x1b1/0x35e
[120226.289418]  [<ffffffff8025680d>] ? prepare_to_wait+0x60/0x69
[120226.289418]  [<ffffffff8040d2a7>] ? sk_wait_data+0xc3/0xd1
[120226.289418]  [<ffffffff80445955>] ? tcp_prequeue_process+0x73/0x89
[120226.289418]  [<ffffffff80446c40>] ? tcp_recvmsg+0x4eb/0xb18
[120226.289418]  [<ffffffff8040c022>] ? sock_common_recvmsg+0x32/0x47
[120226.289418]  [<ffffffff8040a6c2>] ? sock_recvmsg+0x10e/0x133
[120226.680001]  [<ffffffff8040a838>] ? sock_sendmsg+0xfd/0x120
[120226.680001]  [<ffffffff802565f0>] ? autoremove_wake_function+0x0/0x38
[120226.680001]  [<ffffffff802d0b4e>] ? core_sys_select+0x1df/0x254
[120226.680001]  [<ffffffff8024ca7a>] ? mod_timer+0x3d/0x43
[120226.680001]  [<ffffffff8040d0fe>] ? sk_reset_timer+0x17/0x27
[120226.680001]  [<ffffffff8020f6fc>] ? __switch_to+0xb9/0x3a5
[120226.680001]  [<ffffffff8040b805>] ? sys_recvfrom+0xa3/0xf8
[120226.680001]  [<ffffffff80240157>] ? finish_task_switch+0x2b/0xc8
[120226.680001]  [<ffffffff804c4a1d>] ? thread_return+0x3d/0xd4
[120226.680001]  [<ffffffff802111aa>] ? system_call_fastpath+0x16/0x1b
[120226.680001] Code: 00 00 00 41 01 c4 e9 f1 00 00 00 48 8b 8d a8 fe ff ff 0f b6 f3 0f b7 c6 4c 8d 2c c5 00 00 00 00 4c 03 a9 00 02 00 00 4d 8b 75 00 <41> 8b 86 cc 00 00 00 49 03 86 d0 00 00 00 66 83 78 06 00 74 24 
[120226.680001] RIP  [<ffffffffa0089c65>] bnx2_poll_work+0xd5/0x1133 [bnx2]
[120226.680001]  RSP <ffffffff8072ccf0>
[120226.680001] CR2: 00000000000000cc

--dDRMvlgZJXvWKvBx
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="bnx2-crash.patch"

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 08cddb6..7a2dc58 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2797,8 +2797,8 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 		/* prefetch skb_end_pointer() to speedup skb_shinfo(skb) */
 		prefetch(&skb->end);
 
-		/* partial BD completions possible with TSO packets */
-		if (tx_buf->is_gso) {
+		/* partial BD completions possible with fragmented packets */
+		if (tx_buf->nr_frags) {
 			u16 last_idx, last_ring_idx;
 
 			last_idx = sw_cons + tx_buf->nr_frags + 1;

--dDRMvlgZJXvWKvBx--
