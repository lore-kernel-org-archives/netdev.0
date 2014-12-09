From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisect] 3.18 oops in tcp_v4_send_reset()
Date: Tue, 09 Dec 2014 08:16:23 -0800
Message-ID: <1418141783.14835.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141209160023.GA31520@fluid.dannf>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: dann frazier <dann.frazier@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:47748 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296AbaLIQQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 11:16:25 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so809243ier.18
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 08:16:25 -0800 (PST)
In-Reply-To: <20141209160023.GA31520@fluid.dannf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-09 at 09:00 -0700, dann frazier wrote:
> I'm observing a very reproducible oops which I have bisected down to
> commit ca777ef:
> 
>     tcp: remove dst refcount false sharing for prequeue mode
> 
> I'm reproducing using the juju application, and this occurs when
> tearing down a local lxc container (juju bootstrap/juju
> destroy-environment local). Also worth noting that I'm on an
> arm64 system. I'll follow up w/ results once I've attempted to
> reproduce on x86, and if I'm able to create a simpler reproducer.
> 
> [  540.914174] Unable to handle kernel NULL pointer dereference at virtual address 00000018
> [  540.922254] pgd = ffffffc3ea9bb000
> [  540.925646] [00000018] *pgd=00000043e7bfb003, *pud=00000043e7bfb003, *pmd=0000000000000000
> [  540.933902] Internal error: Oops: 96000006 [#1] SMP
> [  540.938754] Modules linked in: veth xt_CHECKSUM xt_tcpudp iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf
> _conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack bridge stp llc ip_tables x_tables ahci_xgene libahci_platform lib
> ahci xgene_enet
> [  540.962592] CPU: 4 PID: 2788 Comm: mongod Not tainted 3.18.0 #65
> [  540.968566] task: ffffffc0fe45d400 ti: ffffffc3e6510000 task.ti: ffffffc3e6510000
> [  540.976014] PC is at tcp_v4_send_reset+0x2ec/0x3e4
> [  540.980778] LR is at tcp_v4_send_reset+0x3c8/0x3e4
> [  540.985542] pc : [<ffffffc00069b5dc>] lr : [<ffffffc00069b6b8>] pstate: 80000145
> [  540.992897] sp : ffffffc3e6513a60
> [  540.996192] x29: ffffffc3e6513a60 x28: ffffffc3e7a8c600 
> [  541.001494] x27: 0000000000000000 x26: ffffffc3e6510000 
> [  541.006796] x25: 0000000000000000 x24: ffffffc3e6513ab8 
> [  541.012099] x23: 0000000000000000 x22: 0000000000000000 
> [  541.017401] x21: ffffffc3e7a8c600 x20: ffffffc000b65000 
> [  541.022703] x19: ffffffc3e655e6e0 x18: 000000000000000d 
> [  541.028005] x17: 0000007fb2735e10 x16: ffffffc00012052c 
> [  541.033306] x15: 0000007fb2728590 x14: 282039363638333a 
> [  541.038608] x13: 0000000062df7dbf x12: 206e6f697463656e 
> [  541.043910] x11: 0000000000000000 x10: 0000000000000000 
> [  541.049212] x9 : 00000000000012d1 x8 : 00000000000346db 
> [  541.054515] x7 : 0000000000000018 x6 : 0000000000000014 
> [  541.059817] x5 : ffffffc3e6513ae0 x4 : 0000000000000000 
> [  541.065118] x3 : ffffffc0fe6d70ac x2 : ffffffc3e655e71c 
> [  541.070420] x1 : ffffffc3e655e6e0 x0 : 00000000000000ac 
> [  541.075722] 
> [  541.077202] Process mongod (pid: 2788, stack limit = 0xffffffc3e6510058)
> [  541.083868] Stack: (0xffffffc3e6513a60 to 0xffffffc3e6514000)

> [  541.455640] Call trace:
> [  541.458074] [<ffffffc00069b5dc>] tcp_v4_send_reset+0x2ec/0x3e4
> [  541.463877] [<ffffffc00069bc04>] tcp_v4_do_rcv+0xfc/0x350
> [  541.469247] [<ffffffc000686ff0>] tcp_prequeue_process+0x98/0xdc
> [  541.475134] [<ffffffc0006880cc>] tcp_recvmsg+0x4c8/0xa0c
> [  541.480419] [<ffffffc0006b1f10>] inet_recvmsg+0x98/0xb4
> [  541.485618] [<ffffffc0006241a8>] sock_aio_read.part.12+0xf0/0x118
> [  541.491679] [<ffffffc000624218>] sock_aio_read+0x48/0x74
> [  541.496964] [<ffffffc0002006bc>] do_sync_read+0x8c/0xd0
> [  541.502161] [<ffffffc000201290>] vfs_read+0x128/0x1a8
> [  541.507185] [<ffffffc000201c34>] SyS_read+0x50/0xb0
> [  541.512037] Code: 927ff884 b9408ba6 910203a5 8b000063 (f9400c80) 
> [  541.518108] ---[ end trace 524a277a323ba5bd ]---
> --


Following patch should have fixed this 

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c3658e8d0f10147fc86018be7f11668246c156d3
