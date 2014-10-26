From: Tom Herbert <therbert@google.com>
Subject: Re: some failures with vxlan offloads..
Date: Sun, 26 Oct 2014 08:29:15 -0700
Message-ID: <CA+mtBx-Jp5Kps5WycYwN0PuyXLDtGM0s8USxdQoSLPRDVS19xw@mail.gmail.com>
References: <544CF8E3.8070207@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:34826 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbaJZP3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2014 11:29:16 -0400
Received: by mail-ig0-f178.google.com with SMTP id h3so3996333igd.5
        for <netdev@vger.kernel.org>; Sun, 26 Oct 2014 08:29:15 -0700 (PDT)
In-Reply-To: <544CF8E3.8070207@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 26, 2014 at 6:36 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> Hi all, Tom..
>
> Running VXLAN traffic using driver/NIC which support offloads (mlx4 driver,
> ConnectX-3 pro NIC), I see some configurationsthat don't really work. The
> testing was done over the net tree, 3.17.0+, as ofcommit d10845f "Merge
> branch 'gso_encap_fixes'", whenI say breaks, it means that encapsulated ping
> works, but encapsulatedTCP (netperf) doesn't.
>
> conf    client          server          status
> ----------------------------------------------
> 1       offloaded       offloaded       works
> 2       non-offloaded   non-offloaded   works
> 3       non-offloaded   offloaded       breaks
> 4       offloaded       non-offloaded   breaks
>
>
> In the cases where it breaks I can see
>
>         UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789
> ulen 726
>
> prints from __udp4_lib_rcv() in the kernel log of the node where offloads
> are OFF, where the badpacket is sent from the hostwhere offloading is
> enabled. I guess the packet is just dropped:
>
Can you determine what the TSO HW engine is setting in UDP checksum
field? tcpdump -vv might be able to show this. The symptoms seem to
indicate that it may not be zero.

> # dmesg -c ; nstat
> UDP: bad checksum. From 192.168.31.18:45084 to 192.168.31.17:4789 ulen 78
> UDP: bad checksum. From 192.168.31.18:45084 to 192.168.31.17:4789 ulen 78
> #kernel
> IpInReceives                    18                 0.0
> IpInDelivers                    18                 0.0
> IpOutRequests                   17                 0.0
> TcpInSegs                       15                 0.0
> TcpOutSegs                      12                 0.0
> TcpRetransSegs                  1                  0.0
> UdpInDatagrams                  1                  0.0
> UdpInErrors                     2                  0.0
> UdpOutDatagrams                 3                  0.0
> UdpInCsumErrors                 2                  0.0
> TcpExtTCPHPHits                 1                  0.0
> TcpExtTCPHPAcks                 12                 0.0
> TcpExtTCPAutoCorking            5                  0.0
> TcpExtTCPSynRetrans             1                  0.0
> TcpExtTCPOrigDataSent           12                 0.0
> IpExtInOctets                   1068               0.0
> IpExtOutOctets                  3174               0.0
> IpExtInNoECTPkts                18                 0.0
>
>
>
> The mlx4 driver advertizes NETIF_F_GSO_UDP_TUNNEL but
> notNETIF_F_GSO_UDP_TUNNEL_CSUM
>
> I wonder if such or similar configs work for people with other drivers/NIC
> that supports offloads?
>
> Tom, I think you were testing your changes with bnx2x
>
> Or.
>
> Setup details: I use OVS with VXLAN, create <veth0,veth1> pair,plug veth1 to
> OVS and as ip address on veth0, run ping and laternetperf over the veth
> interfaces IP subnet (192.168.52/24 in this case)which goes through VXLAN
> encapsulation over the host subnet(192.168.31/24 in this case).
>
> client: host 192.168.31.17 / inner 192.168.52.17
> server: host 192.168.31.18 / inner 192.168.52.18
>
> output from config #3
>
> the client side has these messages printed from __udp4_lib_rcv()
> on the csum_error label
>
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 70
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 726
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 70
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 726
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 70
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 70
> UDP: bad checksum. From 192.168.31.18:54748 to 192.168.31.17:4789 ulen 726
>
>
> output fromconfig #4
>
> the server side has these messages printed from __udp4_lib_rcv()
> on the csum_error label and the below warning
>
> UDP: bad checksum. From 192.168.31.17:34521 to 192.168.31.18:4789 ulen 1480
> UDP: bad checksum. From 192.168.31.17:34521 to 192.168.31.18:4789 ulen 1480
> UDP: bad checksum. From 192.168.31.17:34521 to 192.168.31.18:4789 ulen 1480
> UDP: bad checksum. From 192.168.31.17:34521 to 192.168.31.18:4789 ulen 1480
> UDP: bad checksum. From 192.168.31.17:60499 to 192.168.31.18:4789 ulen 78
> UDP: bad checksum. From 192.168.31.17:36909 to 192.168.31.18:4789 ulen 78
> UDP: bad checksum. From 192.168.31.17:36909 to 192.168.31.18:4789 ulen 78
> UDP: bad checksum. From 192.168.31.17:36909 to 192.168.31.18:4789 ulen 78
>
>
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 5427 at net/core/skbuff.c:4006
> skb_try_coalesce+0x25e/0x395()
> Modules linked in: mlx4_ib mlx4_en mlx4_core veth ib_ipoib ib_cm ib_umad
> ib_sa ib_mad ib_core ib_addrigb dca ptp pps_core hwmon autofs4 sunrpc
> target_core_mod configfs ipmi_devintf ipmi_si ipmi_msghandleripv6
> openvswitch vxlan geneve udp_tunnel ip6_udp_tunnel gre crc32c_generic
> libcrc32c dm_mirrordm_region_hash dm_log uinput dm_mod microcode sr_mod ext3
> jbd usb_storage floppy sd_mod ata_piixlibata scsi_mod uhci_hcd [last
> unloaded: mlx4_core]
> CPU: 0 PID: 5427 Comm: netserver Not tainted 3.17.0+ #172
> Hardware name: Supermicro X7DWU/X7DWU, BIOS  1.1 04/30/2008
>  0000000000000fa6 ffff8802156039b8 ffffffff813f6da9 0000000000000fa6
>  0000000000000000 ffff8802156039f8 ffffffff8103dc38 ffff8802239b40c0
>  ffffffff81352a6a ffff8800c5530e00 ffff880215fd1200 ffff880215603a74
> Call Trace:
>  [<ffffffff813f6da9>] dump_stack+0x51/0x70
>  [<ffffffff8103dc38>] warn_slowpath_common+0x7c/0x96
>  [<ffffffff81352a6a>] ? skb_try_coalesce+0x25e/0x395
>  [<ffffffff8103dc67>] warn_slowpath_null+0x15/0x17
>  [<ffffffff81352a6a>] skb_try_coalesce+0x25e/0x395
>  [<ffffffff813a0468>] tcp_try_coalesce+0x35/0x91
>  [<ffffffff813a0525>] tcp_queue_rcv+0x61/0x101
>  [<ffffffff813a344f>] tcp_rcv_established+0x3b9/0x602
>  [<ffffffff8134d7e1>] ? release_sock+0x30/0x1b0
>  [<ffffffff813aa139>] tcp_v4_do_rcv+0x105/0x41a
>  [<ffffffff8134d8b6>] release_sock+0x105/0x1b0
>  [<ffffffff8139a9cf>] tcp_recvmsg+0x912/0xa5b
>  [<ffffffff81084cef>] ? rcu_irq_exit+0x7d/0x8f
>  [<ffffffff813fcea0>] ? retint_restore_args+0xe/0xe
>  [<ffffffff813bc82d>] inet_recvmsg+0xd1/0xeb
>  [<ffffffff81349c0e>] sock_recvmsg+0x94/0xb2
>  [<ffffffff81070cd4>] ? trace_hardirqs_on+0xd/0xf
>  [<ffffffff813fbd99>] ? _raw_spin_unlock_irq+0x2b/0x38
>  [<ffffffff8113b882>] ? __fdget+0xe/0x10
>  [<ffffffff81349ceb>] SyS_recvfrom+0xbf/0x10f
>  [<ffffffff811e405e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff81062070>] ? try_to_wake_up+0x2d0/0x317
>  [<ffffffff8134d7e1>] ? release_sock+0x30/0x1b0
>  [<ffffffff813fc2d2>] system_call_fastpath+0x12/0x17
> ---[ end trace d39905841ae018aa ]---
>
