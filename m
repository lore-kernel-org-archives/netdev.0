From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/3] net: mpls fixes for GSO
Date: Thu, 11 Aug 2016 15:30:44 +0200
Message-ID: <20160811133043.GA10308@penelope.isobedori.kobe.vergenet.net>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
 <1470897812-8213-3-git-send-email-roopa@cumulusnetworks.com>
 <20160811074735.GA32385@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35995 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbcHKNas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:30:48 -0400
Received: by mail-wm0-f43.google.com with SMTP id q128so588514wma.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 06:30:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160811074735.GA32385@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

On Thu, Aug 11, 2016 at 09:47:36AM +0200, Simon Horman wrote:
> On Wed, Aug 10, 2016 at 11:43:31PM -0700, Roopa Prabhu wrote:
> > From: David Ahern <dsa@cumulusnetworks.com>
> > 
> > Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> > Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> Thanks. This looks like it should be correct to me.  However, I would
> appreciate it if you could give me a little time to test it against OvS.

Unfortunately I was a little bit optimistic.

I tested this patch on top of net-next.
My setup is OVS receiving TCP/IP from an ethernet interface,
adding an MPLS LSE; and outputting to a GRE vport (netdev).

This occurs:

[   11.629192] ------------[ cut here ]------------
[   11.629362] kernel BUG at net/core/skbuff.c:105!
[   11.629362] invalid opcode: 0000 [#1] SMP
[   11.629362] Modules linked in: vport_gre openvswitch
[   11.629362] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.7.0-11619-g218d62929694 #873
[   11.629362] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
[   11.629362] task: ffffffff8160c500 task.stack: ffffffff81600000
[   11.629362] RIP: 0010:[<ffffffff8127afd2>]  [<ffffffff8127afd2>] skb_panic+0x62/0x70
[   11.629362] RSP: 0018:ffff88001b4038c8  EFLAGS: 00010292
[   11.629362] RAX: 000000000000008a RBX: ffff88001b2e7400 RCX: 0000000000000000
[   11.629362] RDX: 000000000000008a RSI: ffff88001b40c748 RDI: ffff88001b40c748
[   11.629362] RBP: 0000000000004788 R08: 000000000000011a R09: 0000000000ffff0a
[   11.629362] R10: 0000000000000004 R11: 000000000000011a R12: 000000000000003c
[   11.629362] R13: 0000000000000012 R14: ffffffffffffff9e R15: ffffffffffffffea
[   11.629362] FS:  0000000000000000(0000) GS:ffff88001b400000(0000) knlGS:0000000000000000
[   11.629362] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   11.629362] CR2: 00007f998faa08a0 CR3: 000000001fa79000 CR4: 00000000000006b0
[   11.629362] Stack:
[   11.629362]  ffff87ff16bb609e 00000000000000c0 00000000000000c0 ffff880016b96800
[   11.629362]  ffffffff8127b01c ffffffff8139c34f ffff88001b2e7400 0000000000000001
[   11.629362]  0000000000000001 ffff880016b96800 ffff880016b6689c ffff880016b66800
[   11.629362] Call Trace:
[   11.629362]  <IRQ> 
[   11.629362]  [<ffffffff8127b01c>] ? skb_push+0x3c/0x40
[   11.629362]  [<ffffffff8139c34f>] ? mpls_gso_segment+0x12f/0x170
[   11.629362]  [<ffffffff8128e54f>] ? skb_mac_gso_segment+0x9f/0x100
[   11.629362]  [<ffffffff8128ea94>] ? validate_xmit_skb+0x144/0x2a0
[   11.629362]  [<ffffffff8128ee2e>] ? validate_xmit_skb_list+0x3e/0x60
[   11.629362]  [<ffffffff812ae466>] ? sch_direct_xmit+0xf6/0x190
[   11.629362]  [<ffffffff8128f142>] ? __dev_queue_xmit+0x222/0x640
[   11.629362]  [<ffffffffa000089d>] ? do_output.isra.30+0x1d/0x200 [openvswitch]
[   11.629362]  [<ffffffffa00011ab>] ? do_execute_actions+0x72b/0x12d0 [openvswitch]
[   11.629362]  [<ffffffffa0001d90>] ? ovs_execute_actions+0x40/0x120 [openvswitch]
[   11.629362]  [<ffffffffa0004e2d>] ? ovs_dp_process_packet+0x6d/0x110 [openvswitch]
[   11.629362]  [<ffffffffa0004e2d>] ? ovs_dp_process_packet+0x6d/0x110 [openvswitch]
[   11.629362]  [<ffffffffa0005c19>] ? key_extract+0x919/0xb90 [openvswitch]
[   11.629362]  [<ffffffffa000c602>] ? ovs_vport_receive+0x42/0x70 [openvswitch]
[   11.629362]  [<ffffffffa0001e0e>] ? ovs_execute_actions+0xbe/0x120 [openvswitch]
[   11.629362]  [<ffffffffa0004e2d>] ? ovs_dp_process_packet+0x6d/0x110 [openvswitch]
[   11.629362]  [<ffffffffa00054d5>] ? key_extract+0x1d5/0xb90 [openvswitch]
[   11.629362]  [<ffffffffa000c602>] ? ovs_vport_receive+0x42/0x70 [openvswitch]
[   11.629362]  [<ffffffff8132dc3c>] ? ip_tunnel_rcv+0x1bc/0x430
[   11.629362]  [<ffffffff81331265>] ? __ipgre_rcv+0x185/0x1d0
[   11.629362]  [<ffffffff81331313>] ? gre_rcv+0x63/0xf0
[   11.629362]  [<ffffffff812ebd80>] ? inet_del_offload+0x40/0x40
[   11.629362]  [<ffffffffa000d439>] ? netdev_frame_hook+0xf9/0x150 [openvswitch]
[   11.629362]  [<ffffffff8128a23c>] ? __netif_receive_skb_core+0x34c/0x950
[   11.629362]  [<ffffffff81280335>] ? __build_skb+0x25/0xd0
[   11.629362]  [<ffffffff812805eb>] ? __napi_alloc_skb+0x9b/0xd0
[   11.629362]  [<ffffffff8128c479>] ? netif_receive_skb_internal+0x29/0x90
[   11.629362]  [<ffffffff8128cf97>] ? napi_gro_receive+0x87/0x120
[   11.629362]  [<ffffffff8122fe64>] ? virtnet_receive+0x194/0x7d0
[   11.629362]  [<ffffffff81230588>] ? virtnet_poll+0x18/0x70
[   11.629362]  [<ffffffff8128d970>] ? net_rx_action+0x1a0/0x2e0
[   11.629362]  [<ffffffff813a8f2c>] ? __do_softirq+0x9c/0x2af
[   11.629362]  [<ffffffff81046922>] ? irq_exit+0x42/0x50
[   11.629362]  [<ffffffff813a8ccf>] ? do_IRQ+0x4f/0xd0
[   11.629362]  [<ffffffff813a76bf>] ? common_interrupt+0x7f/0x7f
[   11.629362]  <EOI> 
[   11.629362]  [<ffffffff81021f6a>] ? default_idle+0x1a/0xd0
[   11.629362]  [<ffffffff810758a0>] ? cpu_startup_entry+0x1b0/0x310
[   11.629362]  [<ffffffff8169add1>] ? start_kernel+0x3b6/0x3be
[   11.629362] Code: 00 00 48 89 44 24 10 8b 87 c8 00 00 00 48 89 44 24 08 48 8b 87 d8 00 00 00 48 c7 c7 e8 b9 54 81 48 89 04 24 31 c0 e8 5b 84 e5 ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 8b 
[   11.629362] RIP  [<ffffffff8127afd2>] skb_panic+0x62/0x70
[   11.629362]  RSP <ffff88001b4038c8>
[   11.711455] ---[ end trace c17de15e7cb43181 ]---
[   11.711953] Kernel panic - not syncing: Fatal exc
