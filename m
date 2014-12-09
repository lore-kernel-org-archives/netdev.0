From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [bisect] 3.18 oops in tcp_v4_send_reset()
Date: Tue, 09 Dec 2014 17:13:32 +0100
Message-ID: <54871FAC.1080700@redhat.com>
References: <20141209160023.GA31520@fluid.dannf>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: dann frazier <dann.frazier@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424AbaLIQsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 11:48:09 -0500
In-Reply-To: <20141209160023.GA31520@fluid.dannf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/2014 05:00 PM, dann frazier wrote:
> I'm observing a very reproducible oops which I have bisected down to
> commit ca777ef:
>
>      tcp: remove dst refcount false sharing for prequeue mode
>
> I'm reproducing using the juju application, and this occurs when
> tearing down a local lxc container (juju bootstrap/juju
> destroy-environment local). Also worth noting that I'm on an
> arm64 system. I'll follow up w/ results once I've attempted to
> reproduce on x86, and if I'm able to create a simpler reproducer.

It should be fixed in:

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=c3658e8d0f10147fc86018be7f11668246c156d3

Does your kernel include that commit?

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
> [  541.089585] 3a60: e6513b20 ffffffc3 0069bc08 ffffffc0 e655e6e0 ffffffc3 e7a8c600 ffffffc3
> [  541.097720] 3a80: 00000000 00000000 00000001 00000000 009be3c0 ffffffc0 e7a8cacc ffffffc3
> [  541.105855] 3aa0: e7a8c690 ffffffc3 e7a8c600 ffffffc3 00000000 00000000 bccb9990 bf7ddf62
> [  541.113990] 3ac0: 00000000 00000450 00000000 00000000 00000000 00000000 00000000 00000000
> [  541.122124] 3ae0: e6513ab8 ffffffc3 00000014 00000000 00000000 02001afe 00000008 00000000
> [  541.130259] 3b00: 00000000 00000000 00628130 ffffffc0 e6513b40 ffffffc3 dc8cb000 cb88537f
> [  541.138394] 3b20: e6513b80 ffffffc3 00686ff4 ffffffc0 e7a8c600 ffffffc3 e7a8cb08 ffffffc3
> [  541.146528] 3b40: 00000000 00000000 00000001 00000000 009be3c0 ffffffc0 e7a8cacc ffffffc3
> [  541.154662] 3b60: 00000000 00000000 00628130 ffffffc0 e7a8c600 ffffffc3 00000000 00000000
> [  541.162797] 3b80: e6513ba0 ffffffc3 006880d0 ffffffc0 00000000 00000000 00000005 00000000
> [  541.170931] 3ba0: e6513c50 ffffffc3 006b1f14 ffffffc0 e6513d20 ffffffc3 e6513de8 ffffffc3
> [  541.179066] 3bc0: 00000000 00000000 e6513de8 ffffffc3 efc54f00 ffffffc3 00000005 00000000
> [  541.187200] 3be0: 00000119 00000000 0000003f 00000000 00ab8000 ffffffc0 e6510000 ffffffc3
> [  541.195335] 3c00: efc54f00 ffffffc3 0000003d 00000000 e6513ba0 ffffffc3 00000040 00000000
> [  541.203469] 3c20: e6513d20 ffffffc3 009be400 ffffffc0 92000007 00000000 fe45d400 ffffffc0
> [  541.211604] 3c40: eb2fc7e0 ffffffc3 ffffffff 7fffffff e6513ca0 ffffffc3 006241ac ffffffc0
> [  541.219738] 3c60: 00000005 00000000 e6513d20 ffffffc3 e6513ca0 ffffffc3 efc54f00 ffffffc3
> [  541.227873] 3c80: 00000005 00000000 ffffffff 00000000 e6513d20 ffffffc3 00000005 00000000
> [  541.236009] 3ca0: e6513d60 ffffffc3 0062421c ffffffc0 e6513de8 ffffffc3 e99e1d00 ffffffc3
> [  541.244144] 3cc0: 00000005 00000000 18006fe3 0000007f 80000000 00000000 00000015 00000000
> [  541.252278] 3ce0: e6513ec8 ffffffc3 e99e1d00 ffffffc3 0000003d 00000000 00000000 00000005
> [  541.260413] 3d00: efc54f00 ffffffc3 00000015 00000000 00000000 00000000 e6513d20 ffffffc3
> [  541.268547] 3d20: 00000000 00000000 00000000 ffffffc3 e6513dd8 ffffffc3 00000001 00000000
> [  541.276682] 3d40: 00000000 00000000 00000000 00000000 00000000 00000000 e6513de8 ffffffc3
> [  541.284817] 3d60: e6513da0 ffffffc3 002006c0 ffffffc0 e6513ec8 ffffffc3 00364ea0 ffffffc0
> [  541.292952] 3d80: e99e1d00 ffffffc3 e6513dd8 ffffffc3 00000001 00000000 00000000 00000000
> [  541.301086] 3da0: e6513e40 ffffffc3 00201294 ffffffc0 00000005 00000000 e99e1d00 ffffffc3
> [  541.309221] 3dc0: 18006fe3 0000007f e6513ec8 ffffffc3 e6513e00 ffffffc3 18006fe3 0000007f
> [  541.317355] 3de0: 00000005 00000000 e99e1d00 ffffffc3 00000000 00000000 00000000 00000000
> [  541.325490] 3e00: e6513ce8 ffffffc3 fe45d400 ffffffc0 00000000 00000000 00000000 00000000
> [  541.333624] 3e20: 00000005 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> [  541.341758] 3e40: e6513e80 ffffffc3 00201c38 ffffffc0 e99e1d01 ffffffc3 e99e1d00 ffffffc3
> [  541.349893] 3e60: ffffffff ffffffff b273b864 0000007f 80000000 00000000 b2737188 0000007f
> [  541.358027] 3e80: 841faef0 0000007f 0008425c ffffffc0 00000000 00000000 00000005 00000000
> [  541.366162] 3ea0: ffffffff ffffffff 00000001 00000000 18006fe3 0000007f 00000005 00000000
> [  541.374296] 3ec0: 00000000 00000000 00000000 00000000 00000024 00000000 18006fe3 0000007f
> [  541.382431] 3ee0: 00000005 00000000 841fbeb8 0000007f 841faeac 0000007f 841fc4a0 0000007f
> [  541.390565] 3f00: ffffffbb 00000000 00000000 00000000 0000003f 00000000 93ccf8ed 00e370ef
> [  541.398700] 3f20: 0000009e 00000000 00000070 00000000 93ccf8ed 000000ef 00000009 00000000
> [  541.406834] 3f40: 0000009b 00000000 00000095 00000000 00000000 00000000 b273b810 0000007f
> [  541.414968] 3f60: 000000aa 00000000 180016b0 0000007f 00000005 00000000 18006fe3 0000007f
> [  541.423103] 3f80: 00000005 00000000 00000005 00000000 18006fe3 0000007f 00000000 00000000
> [  541.431237] 3fa0: 841fc900 0000007f 0000feff 00000000 180012e0 0000007f 841faef0 0000007f
> [  541.439372] 3fc0: b273b84c 0000007f 841faee0 0000007f b273b864 0000007f 80000000 00000000
> [  541.447506] 3fe0: 00000024 00000000 0000003f 00000000 ed238e70 ffffffbe ed238ea8 ffffffbe
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
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
