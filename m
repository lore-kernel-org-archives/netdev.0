From: Mike Accetta <maccetta@laurelnetworks.com>
Subject: 2.6.20 crash in tcp_tso_segment()
Date: Fri, 09 Feb 2007 00:57:52 -0500
Message-ID: <7478.1171000672@mdt.dhcp.pit.laurelnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from paperclip.laurelnetworks.com ([63.94.127.69]:46149 "EHLO
	paperclip.laurelnetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1946144AbXBIGS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 01:18:56 -0500
Received: from notepad.laurelnetworks.com (notepad.laurelnetworks.com [63.94.127.20])
	by paperclip.laurelnetworks.com (ECI-DND/ECI-DND) with ESMTP id l195vqaT009042
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 00:57:52 -0500
Received: from mdt.dhcp.pit.laurelnetworks.com (mdt.dhcp.pit.laurelnetworks.com [10.0.21.56])
	by notepad.laurelnetworks.com (ECI-DND/ECI-DND) with ESMTP id l195vqsv029589
	for <netdev@vger.kernel.org>; Fri, 9 Feb 2007 00:57:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In 2.6.20 (and at least 2.6.19) we occasionally see a crash in
tcp_tso_segment() which looks like it is occuring because the sk_buff
chain has only a single element.  Based on the register dump, the code
looks to be crashing at the statement

	th = skb->h.th;

in the loop

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

which always runs at least once.  The loop looks safe to me as long as
there are at least two sk_buff's in the chain but it will clearly try
to dereference a null skb pointer on the first loop iteration if the
chain contains only a single sk_buff.

Obviously the code believes it can assume that there are always multiple
sk_buff's in the chain.  The stack trace seems to implicate iptables in
the scenario (twice) if that means anything.  Any ideas about what may
be going wrong here?  There is indeed a private module loaded at the time
but it does no networking and I doubt it is the culprit.
--------------------------

	0xc030e8b1 <tcp_tso_segment+369>:       mov    (%esi),%esi
	0xc030e8b3 <tcp_tso_segment+371>:       mov    0x14(%esp,1),%ecx
EIP ->  0xc030e8b7 <tcp_tso_segment+375>:       mov    0x1c(%esi),%ebx

--------------------------

BUG: unable to handle kernel NULL pointer
dereference at virtual address 0000001c
 printing eip:
c030e8b7
*pde = 38966067
Oops: 0000 [#1]
Modules linked in: e1000 Depalma(P) w83627hf i2c_isa hwmon_vid i2c_core
CPU:    0
EIP:    0060:[<c030e8b7>]    Tainted: P      VLI
EFLAGS: 00010246   (2.6.20 #11)
EIP is at tcp_tso_segment+0x177/0x280
eax: 00000004   ebx: d9c1a034   ecx: 000005a8   edx: 8b810000
esi: 00000000   edi: b84f3728   ebp: 00000014   esp: d45a1a2c
ds: 007b   es: 007b   ss: 0068
Process rcpd (pid: 22462, ti=d45a1000 task=d2332030 task.ti=d45a1000)
Stack: c037fec5 c033635b c037fec5 a7050100 d45a1a58 000005a8 0000ffeb
eef1d0c0
       00001065 d0b36020 eee8e200 00000000 00001065 c03299e5 ffffffa3
c04499a0
       eee8e200 c0329920 00000008 c02dcdf4 d45a1ac8 00000000 00001065
eee8e200
Call Trace:
 [<c037fec5>] _read_unlock_bh+0x5/0x10
 [<c033635b>] ipt_do_table+0x27b/0x340
 [<c037fec5>] _read_unlock_bh+0x5/0x10
 [<c03299e5>] inet_gso_segment+0xc5/0x1a0
 [<c0329920>] inet_gso_segment+0x0/0x1a0
 [<c02dcdf4>] skb_gso_segment+0xb4/0x170
 [<c02dcf5b>] dev_gso_segment+0x2b/0xc0
 [<c02dd05d>] dev_hard_start_xmit+0x6d/0xf0
 [<c02dd35f>] dev_queue_xmit+0x27f/0x300
 [<c0304eec>] ip_output+0x15c/0x290
 [<c0304bd0>] ip_finish_output+0x0/0x1c0
 [<c0339764>] send_reset+0x324/0x430
 [<c0339870>] dst_output+0x0/0x10
 [<c02f2e38>] __nf_conntrack_find+0x18/0xf0
 [<c037fde8>] _read_lock_bh+0x8/0x10
 [<c037fec5>] _read_unlock_bh+0x5/0x10
 [<c033635b>] ipt_do_table+0x27b/0x340
 [<c02f3979>] nf_conntrack_in+0x1e9/0x290

--
Mike Accetta

ECI Telecom Ltd.
Data Networking Division (previously Laurel Networks)
