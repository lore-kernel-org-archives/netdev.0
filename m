From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: null pointer at cls_api.c
Date: Thu, 5 Aug 2010 13:21:54 -0700
Message-ID: <20100805132154.15f92353@nehalam>
References: <282881281036255@web101.yandex.ru>
	<20100805.130755.57491167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: franchoze@yandex.ru, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47256 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934093Ab0HEUV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:21:57 -0400
In-Reply-To: <20100805.130755.57491167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 05 Aug 2010 13:07:55 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Franchoze Eric <franchoze@yandex.ru>
> Date: Thu, 05 Aug 2010 23:24:15 +0400
> 
> > @@ -255,6 +255,11 @@ replay:
> >  			kfree(tp);
> >  			goto errout;
> >  		}
> > +
> > +		if (!tp || !tp->ops) {
> > +			err = -ENOENT;
> > +			goto errout;
> > +		}
> >  		tp->ops = tp_ops;
> >  		tp->protocol = protocol;
> >  		tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
> > 
> 
> This patch makes no sense.
> 
> We check for "tp"  being non-NULL in the code block about the if() block you're
> adding these checks to.
> 
> And tp->ops of course might be NULL here, and that's perfectly fine,
> as we're about to assign "tp_ops" to it.
> 
> Looking at your backtrace I think perhaps your crash is elsewhere.

Looks like a cls_u32 bug:

Aug  5 12:58:21 nehalam kernel: [15160.920162] u32 classifier
Aug  5 12:58:21 nehalam kernel: [15160.920165]     Actions configured
Aug  5 12:58:21 nehalam kernel: [15160.920346] PGD b6901067 PUD 93323067 PMD 0 
Aug  5 12:58:21 nehalam kernel: [15160.920357] CPU 6 
Aug  5 12:58:21 nehalam kernel: [15160.920358] Modules linked in: cls_u32 sch_sfq sch_htb dummy ntfs vfat msdos fat nfs lockd fscache nfs_acl auth_rpcgss sunrpc autofs4 binfmt_misc ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm radeon ttm drm_kms_helper drm i2c_algo_bit snd_hda_codec_analog ipv6 snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi snd_seq_midi_event snd_seq snd_timer snd_seq_device snd psmouse asus_atk0110 soundcore serio_raw snd_page_alloc usbhid mvsas libsas floppy scsi_transport_sas e1000e sky2
Aug  5 12:58:21 nehalam kernel: [15160.920427] 
Aug  5 12:58:21 nehalam kernel: [15160.920433] Pid: 25645, comm: tc Not tainted 2.6.35+ #31 P6T DELUXE/System Product Name
Aug  5 12:58:21 nehalam kernel: [15160.920436] RIP: 0010:[<0000000000000000>]  [<(null)>] (null)
Aug  5 12:58:21 nehalam kernel: [15160.920441] RSP: 0018:ffff880093399850  EFLAGS: 00010286
Aug  5 12:58:21 nehalam kernel: [15160.920445] RAX: ffffffffa0502fc0 RBX: ffff8801b38bd9c0 RCX: ffff880093399878
Aug  5 12:58:21 nehalam kernel: [15160.920449] RDX: 0000000000020001 RSI: 0000000000000000 RDI: ffff880047d88000
Aug  5 12:58:21 nehalam kernel: [15160.920452] RBP: ffff8800933998b8 R08: ffffffffa050a4a0 R09: 0000000000000000
Aug  5 12:58:21 nehalam kernel: [15160.920456] R10: ffffffffa050997e R11: 2222222222222222 R12: ffff8801b4eb9d40
Aug  5 12:58:21 nehalam kernel: [15160.920461] R13: ffff8800933998e8 R14: ffff880093399878 R15: ffff8801b4fdc740
Aug  5 12:58:21 nehalam kernel: [15160.920466] FS:  00007fb43c74d700(0000) GS:ffff880001ec0000(0000) knlGS:0000000000000000
Aug  5 12:58:21 nehalam kernel: [15160.920471] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  5 12:58:21 nehalam kernel: [15160.920475] CR2: 0000000000000000 CR3: 000000001ccfb000 CR4: 00000000000006e0
Aug  5 12:58:21 nehalam kernel: [15160.920480] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  5 12:58:21 nehalam kernel: [15160.920484] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  5 12:58:21 nehalam kernel: [15160.920489] Process tc (pid: 25645, threadinfo ffff880093398000, task ffff8801b77802c0)
Aug  5 12:58:21 nehalam kernel: [15160.920495]  ffffffffa0509c05 ffff8800933998a8 ffffffff8110208a ffff8800933998b8
Aug  5 12:58:21 nehalam kernel: [15160.920501] <0> 0000000000000000 0000000000000000 ffff8801b4fdc740 ffff8801b38bd9c0
Aug  5 12:58:21 nehalam kernel: [15160.920509] <0> ffff8801b4fdc740 ffff8801b38bd9c0 ffff8800933999e8 0000000080000800
Aug  5 12:58:21 nehalam kernel: [15160.920524]  [<ffffffffa0509c05>] ? u32_set_parms+0x125/0x260 [cls_u32]
Aug  5 12:58:21 nehalam kernel: [15160.920531]  [<ffffffff8110208a>] ? __kmalloc+0x21a/0x230
Aug  5 12:58:21 nehalam kernel: [15160.920537]  [<ffffffffa0509f18>] u32_change+0x1d8/0x4f0 [cls_u32]
Aug  5 12:58:21 nehalam kernel: [15160.920543]  [<ffffffffa050a338>] ? u32_init+0x108/0x180 [cls_u32]
Aug  5 12:58:21 nehalam kernel: [15160.920551]  [<ffffffff813f90e1>] tc_ctl_tfilter+0x321/0x780
Aug  5 12:58:21 nehalam kernel: [15160.920560]  [<ffffffff813ea733>] rtnetlink_rcv_msg+0x163/0x270
Aug  5 12:58:21 nehalam kernel: [15160.920564]  [<ffffffff813ea5d0>] ? rtnetlink_rcv_msg+0x0/0x270
Aug  5 12:58:21 nehalam kernel: [15160.920568]  [<ffffffff813fed31>] netlink_rcv_skb+0xa1/0xd0
Aug  5 12:58:21 nehalam kernel: [15160.920572]  [<ffffffff813ea5c0>] rtnetlink_rcv+0x20/0x30
Aug  5 12:58:21 nehalam kernel: [15160.920576]  [<ffffffff813fe966>] netlink_unicast+0x296/0x2e0
Aug  5 12:58:21 nehalam kernel: [15160.920579]  [<ffffffff813ff73e>] netlink_sendmsg+0x1fe/0x2e0
Aug  5 12:58:21 nehalam kernel: [15160.920585]  [<ffffffff813cac9e>] sock_sendmsg+0xee/0x120
Aug  5 12:58:21 nehalam kernel: [15160.920590]  [<ffffffff813cb77d>] ? move_addr_to_kernel+0x5d/0x60
Aug  5 12:58:21 nehalam kernel: [15160.920594]  [<ffffffff813d6513>] ? verify_iovec+0x93/0x100
Aug  5 12:58:21 nehalam kernel: [15160.920598]  [<ffffffff813cc510>] sys_sendmsg+0x240/0x3a0
Aug  5 12:58:21 nehalam kernel: [15160.920604]  [<ffffffff8109a664>] ? audit_syscall_entry+0x254/0x280
Aug  5 12:58:21 nehalam kernel: [15160.920609]  [<ffffffff8148622d>] ? do_page_fault+0x14d/0x310
Aug  5 12:58:21 nehalam kernel: [15160.920614]  [<ffffffff810026ab>] system_call_fastpath+0x16/0x1b
Aug  5 12:58:21 nehalam kernel: [15160.920625]  RSP <ffff880093399850>
Aug  5 12:58:21 nehalam kernel: [15160.920629] ---[ end trace fad08b9c79000a10 ]---
