From: Mike Accetta <maccetta@laurelnetworks.com>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Tue, 13 Feb 2007 11:18:52 -0500
Message-ID: <3189.1171383532@mdt.dhcp.pit.laurelnetworks.com>
References: <45D1CC83.8080603@trash.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from staple.laurelnetworks.com ([63.94.127.68]:40626 "EHLO
	staple.laurelnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbXBMQTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 11:19:10 -0500
In-reply-to: Your message of "Tue, 13 Feb 2007 15:34:43 +0100."
             <45D1CC83.8080603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy writes:
> Herbert Xu wrote:
> > Mike Accetta <maccetta@laurelnetworks.com> wrote:
> > 
> >>Obviously the code believes it can assume that there are always multiple
> >>sk_buff's in the chain.  The stack trace seems to implicate iptables in
> >>the scenario (twice) if that means anything.  Any ideas about what may
> >>be going wrong here?  There is indeed a private module loaded at the time
> >>but it does no networking and I doubt it is the culprit.
> > 
> > 
> > Yeah we should never get here if we only have one segment.
> > Could you get it to print out the value of skb->gso_*?
> 
> The callpath shows the REJECT target sending a TCP reset.
> I'm guessing it has something to do with skb_copy_expand
> copying the gso fields.

I've instrumented the code to print the gso_* fields as requested.
I also made a stab at keeping the box from crashing as well, but that
part may not be right.  In any case, the new code snippet is

    if (skb->next) {
	do {
		th->fin = th->psh = 0;

		th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
				       (__force u32)delta));
		if (skb->ip_summed != CHECKSUM_PARTIAL)
			th->check = csum_fold(csum_partial(skb->h.raw, thlen,
							   skb->csum));

		seq += len;
		skb = skb->next;
		th = skb->h.th;

		th->seq = htonl(seq);
		th->cwr = 0;
	} while (skb->next);
    } else {
	th->cwr = 0;
	printk("gso_size %d\n",  skb_shinfo(skb)->gso_size);
	printk("gso_segs %d\n",  skb_shinfo(skb)->gso_segs);
	printk("gso_type %d\n",  skb_shinfo(skb)->gso_type);
	WARN_ON(skb->next == 0);
    }

and the output was

gso_size 0
gso_segs 0
gso_type 0
BUG: at /u/mjaccetta/p4/mos/hog/1/BUILD/kernel-2.6/net/ipv4/tcp.c:2239
tcp_tso_segment()
 [<c030e9f8>] tcp_tso_segment+0x2b8/0x320
 [<c0329a85>] inet_gso_segment+0xc5/0x1a0
 [<c03299c0>] inet_gso_segment+0x0/0x1a0
 [<c02dcdf4>] skb_gso_segment+0xb4/0x170
 [<c02dcf5b>] dev_gso_segment+0x2b/0xc0
 [<c02dd05d>] dev_hard_start_xmit+0x6d/0xf0
 [<c02dd35f>] dev_queue_xmit+0x27f/0x300
 [<c0304eec>] ip_output+0x15c/0x290
 [<c0304bd0>] ip_finish_output+0x0/0x1c0
 [<c0339804>] send_reset+0x324/0x430
 [<c0339910>] dst_output+0x0/0x10
 [<c02f2e38>] __nf_conntrack_find+0x18/0xf0
 [<c037fe88>] _read_lock_bh+0x8/0x10
 [<c037ff65>] _read_unlock_bh+0x5/0x10
 [<c03363fb>] ipt_do_table+0x27b/0x340
 [<c02f3979>] nf_conntrack_in+0x1e9/0x290
 [<c0339978>] reject+0x58/0xb0
 [<c0336471>] ipt_do_table+0x2f1/0x340
 [<c02f1425>] nf_iterate+0x55/0x90
 [<c0304690>] dst_output+0x0/0x10
 [<c02f14c6>] nf_hook_slow+0x66/0x100
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c0216c4e>] copy_to_user+0x3e/0x50
 [<c02d9959>] memcpy_toiovec+0x29/0x50
 [<c015da63>] cache_alloc_refill+0x113/0x1c0
 [<c0315c07>] tcp_cwnd_restart+0x27/0xf0
 [<c031635d>] tcp_transmit_skb+0x2cd/0x460
 [<c03171dd>] tso_fragment+0x11d/0x1c0
 [<c0317c3c>] tcp_push_one+0xbc/0xf0
 [<c030c39d>] tcp_sendmsg+0x6bd/0xb40
 [<c037ff35>] _spin_unlock_bh+0x5/0x10
 [<c030cf84>] tcp_recvmsg+0x2e4/0x750
 [<c02d63d5>] sock_common_recvmsg+0x45/0x70
 [<c0329077>] inet_sendmsg+0x47/0x60
 [<c02d1fff>] sock_sendmsg+0xbf/0x110
 [<c02d5f9c>] sk_reset_timer+0xc/0x20
 [<c031913a>] tcp_connect+0x1aa/0x1c0
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c01071ef>] convert_fxsr_to_user+0x12f/0x1a0
 [<c02d32a7>] sys_sendto+0xf7/0x140
 [<c037ff25>] _spin_unlock_irq+0x5/0x10
 [<c01029c1>] handle_signal+0x121/0x170
 [<c014dee1>] do_wp_page+0x231/0x440
 [<c0102aac>] do_signal+0x9c/0x190
 [<c014f236>] __handle_mm_fault+0x276/0x2e0
 [<c02d3323>] sys_send+0x33/0x40
 [<c02d3c65>] sys_socketcall+0x195/0x2b0
 [<c0102180>] sys_sigreturn+0xd0/0xe0
 [<c0102d08>] syscall_call+0x7/0xb
 [<c0380000>] error_code+0x28/0x7c

gso_size 0
gso_segs 0
gso_type 0
BUG: at /u/mjaccetta/p4/mos/hog/1/BUILD/kernel-2.6/net/ipv4/tcp.c:2239
tcp_tso_segment()
 [<c030e9f8>] tcp_tso_segment+0x2b8/0x320
 [<c0329a85>] inet_gso_segment+0xc5/0x1a0
 [<c03299c0>] inet_gso_segment+0x0/0x1a0
 [<c02dcdf4>] skb_gso_segment+0xb4/0x170
 [<c02dcf5b>] dev_gso_segment+0x2b/0xc0
 [<c02dd05d>] dev_hard_start_xmit+0x6d/0xf0
 [<c02dd35f>] dev_queue_xmit+0x27f/0x300
 [<c0304eec>] ip_output+0x15c/0x290
 [<c0304bd0>] ip_finish_output+0x0/0x1c0
 [<c0339804>] send_reset+0x324/0x430
 [<c0339910>] dst_output+0x0/0x10
 [<c02f2e38>] __nf_conntrack_find+0x18/0xf0
 [<c037fe88>] _read_lock_bh+0x8/0x10
 [<c037ff65>] _read_unlock_bh+0x5/0x10
 [<c03363fb>] ipt_do_table+0x27b/0x340
 [<c02f3979>] nf_conntrack_in+0x1e9/0x290
 [<c0339978>] reject+0x58/0xb0
 [<c0336471>] ipt_do_table+0x2f1/0x340
 [<c02f1425>] nf_iterate+0x55/0x90
 [<c0304690>] dst_output+0x0/0x10
 [<c02f14c6>] nf_hook_slow+0x66/0x100
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c0216c4e>] copy_to_user+0x3e/0x50
 [<c02d9959>] memcpy_toiovec+0x29/0x50
 [<c0315c07>] tcp_cwnd_restart+0x27/0xf0
 [<c031635d>] tcp_transmit_skb+0x2cd/0x460
 [<c0145711>] get_page_from_freelist+0x71/0xc0
 [<c03179d8>] tcp_write_xmit+0x168/0x280
 [<c0145710>] get_page_from_freelist+0x70/0xc0
 [<c0317b17>] __tcp_push_pending_frames+0x27/0x90
 [<c030c753>] tcp_sendmsg+0xa73/0xb40
 [<c037ff35>] _spin_unlock_bh+0x5/0x10
 [<c030cf84>] tcp_recvmsg+0x2e4/0x750
 [<c02d63d5>] sock_common_recvmsg+0x45/0x70
 [<c0329077>] inet_sendmsg+0x47/0x60
 [<c02d1fff>] sock_sendmsg+0xbf/0x110
 [<c02d5f9c>] sk_reset_timer+0xc/0x20
 [<c031913a>] tcp_connect+0x1aa/0x1c0
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c01071ef>] convert_fxsr_to_user+0x12f/0x1a0
 [<c02d32a7>] sys_sendto+0xf7/0x140
 [<c037ff25>] _spin_unlock_irq+0x5/0x10
 [<c01029c1>] handle_signal+0x121/0x170
 [<c014dee1>] do_wp_page+0x231/0x440
 [<c0102aac>] do_signal+0x9c/0x190
 [<c014f236>] __handle_mm_fault+0x276/0x2e0
 [<c02d3323>] sys_send+0x33/0x40
 [<c02d3c65>] sys_socketcall+0x195/0x2b0
 [<c0102180>] sys_sigreturn+0xd0/0xe0
 [<c0102d08>] syscall_call+0x7/0xb
 [<c0380000>] error_code+0x28/0x7c

gso_size 0
gso_segs 0
gso_type 0
BUG: at /u/mjaccetta/p4/mos/hog/1/BUILD/kernel-2.6/net/ipv4/tcp.c:2239
tcp_tso_segment()
 [<c030e9f8>] tcp_tso_segment+0x2b8/0x320
 [<c0329a85>] inet_gso_segment+0xc5/0x1a0
 [<c03299c0>] inet_gso_segment+0x0/0x1a0
 [<c02dcdf4>] skb_gso_segment+0xb4/0x170
 [<c02dcf5b>] dev_gso_segment+0x2b/0xc0
 [<c02dd05d>] dev_hard_start_xmit+0x6d/0xf0
 [<c02dd35f>] dev_queue_xmit+0x27f/0x300
 [<c0304eec>] ip_output+0x15c/0x290
 [<c0304bd0>] ip_finish_output+0x0/0x1c0
 [<c0339804>] send_reset+0x324/0x430
 [<c0339910>] dst_output+0x0/0x10
 [<c02f2e38>] __nf_conntrack_find+0x18/0xf0
 [<c037fe88>] _read_lock_bh+0x8/0x10
 [<c037ff65>] _read_unlock_bh+0x5/0x10
 [<c03363fb>] ipt_do_table+0x27b/0x340
 [<c02f3979>] nf_conntrack_in+0x1e9/0x290
 [<c0339978>] reject+0x58/0xb0
 [<c0336471>] ipt_do_table+0x2f1/0x340
 [<c02f1425>] nf_iterate+0x55/0x90
 [<c0304690>] dst_output+0x0/0x10
 [<c02f14c6>] nf_hook_slow+0x66/0x100
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c0216a64>] __copy_to_user_ll+0x34/0x60
 [<c0216c4e>] copy_to_user+0x3e/0x50
 [<c02d9959>] memcpy_toiovec+0x29/0x50
 [<c037fe39>] _spin_lock_irqsave+0x9/0x10
 [<c0145507>] buffered_rmqueue+0x77/0x110
 [<c031635d>] tcp_transmit_skb+0x2cd/0x460
 [<c03171dd>] tso_fragment+0x11d/0x1c0
 [<c0317c3c>] tcp_push_one+0xbc/0xf0
 [<c030c39d>] tcp_sendmsg+0x6bd/0xb40
 [<c037ff35>] _spin_unlock_bh+0x5/0x10
 [<c030cf84>] tcp_recvmsg+0x2e4/0x750
 [<c02d623b>] release_sock+0x1b/0xa0
 [<c0329077>] inet_sendmsg+0x47/0x60
 [<c02d1fff>] sock_sendmsg+0xbf/0x110
 [<c02d5f9c>] sk_reset_timer+0xc/0x20
 [<c031913a>] tcp_connect+0x1aa/0x1c0
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c012a850>] autoremove_wake_function+0x0/0x50
 [<c01071ef>] convert_fxsr_to_user+0x12f/0x1a0
 [<c0144b61>] free_pages_bulk+0x31/0x1a0
 [<c02d32a7>] sys_sendto+0xf7/0x140
 [<c014dee1>] do_wp_page+0x231/0x440
 [<c032844e>] inet_sock_destruct+0xbe/0x200
 [<c014f236>] __handle_mm_fault+0x276/0x2e0
 [<c02d3323>] sys_send+0x33/0x40
 [<c02d3c65>] sys_socketcall+0x195/0x2b0
 [<c01600f6>] sys_close+0x66/0xd0
 [<c0102d08>] syscall_call+0x7/0xb
 [<c0380000>] error_code+0x28/0x7c

gso_size 0
gso_segs 0
gso_type 0
BUG: at /u/mjaccetta/p4/mos/hog/1/BUILD/kernel-2.6/net/ipv4/tcp.c:2239
tcp_tso_segment()
 [<c030e9f8>] tcp_tso_segment+0x2b8/0x320
 [<c0329a85>] inet_gso_segment+0xc5/0x1a0
 [<c03299c0>] inet_gso_segment+0x0/0x1a0
 [<c02dcdf4>] skb_gso_segment+0xb4/0x170
 [<c02dcf5b>] dev_gso_segment+0x2b/0xc0
 [<c02dd05d>] dev_hard_start_xmit+0x6d/0xf0
 [<c02dd35f>] dev_queue_xmit+0x27f/0x300
 [<c0304eec>] ip_output+0x15c/0x290
 [<c0304bd0>] ip_finish_output+0x0/0x1c0
 [<c0339804>] send_reset+0x324/0x430
 [<c0339910>] dst_output+0x0/0x10
 [<c02f2e38>] __nf_conntrack_find+0x18/0xf0
 [<c037fe88>] _read_lock_bh+0x8/0x10
 [<c037ff65>] _read_unlock_bh+0x5/0x10
 [<c03363fb>] ipt_do_table+0x27b/0x340
 [<c02f3979>] nf_conntrack_in+0x1e9/0x290
 [<c0339978>] reject+0x58/0xb0
 [<c0336471>] ipt_do_table+0x2f1/0x340
 [<c02f1425>] nf_iterate+0x55/0x90
 [<c0304690>] dst_output+0x0/0x10
 [<c02f14c6>] nf_hook_slow+0x66/0x100
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c03053f8>] ip_queue_xmit+0x3d8/0x4c0
 [<c0304690>] dst_output+0x0/0x10
 [<c0216a64>] __copy_to_user_ll+0x34/0x60
 [<c0216c4e>] copy_to_user+0x3e/0x50
 [<c02d9959>] memcpy_toiove
--
Mike Accetta

ECI Telecom Ltd.
Data Networking Division (previously Laurel Networks)
