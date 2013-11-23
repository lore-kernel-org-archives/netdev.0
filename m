From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] net: sched: tbf: fix an oops when a GSO packet cannot
 be enqueued
Date: Sat, 23 Nov 2013 16:08:47 +0800
Message-ID: <5290628F.6080604@huawei.com>
References: <1385112446-15564-1-git-send-email-yangyingliang@huawei.com> <1385131801.10637.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<ben@decadent.org.uk>, <jpirko@redhat.com>, <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43396 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab3KWIMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 03:12:08 -0500
In-Reply-To: <1385131801.10637.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/22 22:50, Eric Dumazet wrote:
> On Fri, 2013-11-22 at 17:27 +0800, Yang Yingliang wrote:
>> It seems commit e43ac79a4b("sch_tbf: segment too big GSO packets")
>> introduce this oops.
>>
>> When GSO mode is on, use the following command:
>> tc qdisc add dev eth0 root handle 1: tbf latency 50ms burst 1KB rate 50mbit mtu 1KB
>> iperf -c host -t 30
> 
> I think your patch is not needed, the stack trace point to a different
> spot.
> 
> The issue should be fixed by :
> 
> http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=9d8506cc2d7ea1f911c72c100193a3677f6668c3
> 
> Could you check again ?
> 
> Thanks

I've applied this patch, but it's oops too.
I think it's not the same problem. In this
problem, when the segs is not enqueued, we do
nothing to the segs.I think it causes the
problem. If I am wrong, please point out.
Thanks!

Here is the call trace after applying the above patch:
BTW, the call trace is not always same no matter the
above patch is applied.


[  355.298416] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[  355.391292] IP: [<ffffffff81377f99>] __skb_recv_datagram+0x259/0x500
[  355.466628] PGD 20312fc067 PUD 2030ed9067 PMD 0
[  355.521336] Oops: 0002 [#1] SMP
[  355.559528] Modules linked in: sch_tbf(O) tun ip6table_filter ip6_tables iptable_filter ip_tables x_tables edd af_packet bridge stp llc microcode fuse loop dm_mod igb dca i2c_algo_bit i2c_i801 ptp serio_raw sg ehci_pci ipv6 kvm_intel i2c_core kvm iTCO_wdt iTCO_vendor_support lpc_ich mfd_core hid_generic mptctl pps_core pcspkr button ext3 jbd mbcache usbhid hid uhci_hcd ehci_hcd usbcore sd_mod usb_common crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_hp_sw scsi_dh_emc scsi_dh_alua scsi_dh_rdac scsi_dh ata_generic ata_piix libata mptsas mptscsih mptbase scsi_transport_sas scsi_mod
[  356.186224] CPU: 9 PID: 10073 Comm: acc-snf Tainted: G           O 3.12.0-rc6-0.7-default+ #8
[  356.287345] Hardware name: Huawei Technologies Co., Ltd. Tecal XH620           /BC21THSA              , BIOS TTSAV020 12/02/2011
[  356.424571] task: ffff881fbd4e0380 ti: ffff881fbf028000 task.ti: ffff881fbf028000
[  356.513306] RIP: 0010:[<ffffffff81377f99>]  [<ffffffff81377f99>] __skb_recv_datagram+0x259/0x500
[  356.617524] RSP: 0018:ffff881fbf029b68  EFLAGS: 00210046
[  356.680466] RAX: 0000000000000000 RBX: ffff881fbd0e1b70 RCX: 0000000000200296
[  356.765074] RDX: 0000000000000000 RSI: 0000000000200296 RDI: ffff881fbbc6f0a4
[  356.849683] RBP: ffff881fbf029c48 R08: ffff881fbf029cb4 R09: ffff88203eb24840
[  356.934291] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
[  357.018900] R13: ffff881fbbc6f000 R14: ffff881fbbc6f090 R15: ffff881fbf029c64
[  357.103508] FS:  0000000000000000(0000) GS:ffff88203f320000(0063) knlGS:00000000f7320b70
[  357.199465] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[  357.267566] CR2: 0000000000000008 CR3: 0000001fbb973000 CR4: 00000000000027e0
[  357.352175] Stack:
[  357.375911]  0000000000200286 ffff881fbf029c00 ffff881fbf028010 ffff881fbd4e0380
[  357.463640]  ffff881fbf028010 ffff881fbbc6f1b8 ffff881fbf029cb4 ffff881fbf029c60
[  357.551369]  ffff881f80000020 7fffffffffffffff ffff881fbbc6f0a4 ffff881fbbc6f0cc
[  357.639099] Call Trace:
[  357.667998]  [<ffffffff81371afa>] ? skb_release_data+0xaa/0xe0
[  357.737135]  [<ffffffff81378272>] skb_recv_datagram+0x32/0x40
[  357.805237]  [<ffffffffa08d7096>] packet_recvmsg+0x66/0x360 [af_packet]
[  357.883662]  [<ffffffff81369cdc>] sock_recvmsg+0xac/0xe0
[  357.946613]  [<ffffffff8117f80d>] ? compat_core_sys_select+0x24d/0x260
[  358.024001]  [<ffffffff81369dce>] SyS_recvfrom+0xbe/0x120
[  358.087976]  [<ffffffff8136b898>] ? compat_sock_ioctl+0x88/0xb0
[  358.158145]  [<ffffffff811810ec>] ? compat_sys_ioctl+0x7c/0x1380
[  358.229344]  [<ffffffff81096d93>] ? ktime_get_ts+0x53/0x100
[  358.295387]  [<ffffffff8139e620>] compat_sys_socketcall+0x150/0x240
[  358.369685]  [<ffffffff8143f595>] sysenter_dispatch+0x7/0x1a
[  358.436756] Code: 00 48 89 8d 68 ff ff ff e9 38 fe ff ff 41 83 ad a0 00 00 00 01 48 8b 13 48 8b 43 08 48 c7 03 00 00 00 00 48 c7 43 08 00 00 00 00 <48> 89 42 08 48 89 10 48 8b bd 70 ff ff ff e8 04 f9 0b 00 48 8b
[  358.661068] RIP  [<ffffffff81377f99>] __skb_recv_datagram+0x259/0x500
------------------------------cut here-------------------------------------

Regards,
Yang
> 
> 
> 
> 
