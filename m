From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: BUG: MARK in OUTPUT + ip_tunnel causes kernel panic
Date: Wed, 21 Aug 2013 16:00:36 +0200
Message-ID: <CAKfDRXgJwyhE6sg1Ej=S35A+-dnPiU9TBA69zb-n7hGXgG+Sxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:59628 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3HUOAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 10:00:37 -0400
Received: by mail-ob0-f180.google.com with SMTP id up14so752644obb.25
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 07:00:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

When trying to tunnel traffic originating from the same machine as the
tunnel endpoint, I am experiencing kernel panics for some types of
traffic (ICMP and UDP). TCP seems not to be affected by this, at least
I have not been able to trigger the panic.

I have one tunnel (without an IP address) and use policy routing to
steer some traffic through the tunnels. For my example, I use the
following commands to configure the tunnel and the routing:

ip tunnel add tun0 mode ipip remote 10.110.112.2 local 10.110.112.1
ip link set dev tun0 up
ip rule add fwmark 0x1 lookup 101
ip ro add default via tun0 table 101
iptables -A OUTPUT -t mangle -d 8.8.8.8 -j MARK --set-mark 0x1

The remote address of the tunnel does not matter, as the packets never
get that far. I then run ping 8.8.8.8/nc -u 8.8.8.8 9999, which
triggers the panic:

With ICMP:
skbuff: skb_under_panic: text:ffffffff815f9baf len:118 put:14
head:ffff880100cff800 data:ffff880100cff7ee tail:0x64 end:0xc0
dev:eth4

With UDP:
skbuff: skb_under_panic: text:ffffffff815f9baf len:71 put:14
head:ffff880118554c00 data:ffff880118554bee tail:0x35 end:0xc0
dev:eth4

Stack trace is the same:
[  304.217036] ------------[ cut here ]------------
[  304.217106] Kernel BUG at ffffffff816b75cc [verbose debug info unavailable]
[  304.217195] invalid opcode: 0000 [#1] SMP
[  304.217278] Modules linked in: iptable_mangle xt_mark ip_tables
x_tables ipip tunnel4 ip_tunnel netconsole configfs asix usbnet mii
i915 snd_hda_codec_hdmi snd_hda_intel joydev snd_hda_codec hid_generic
drm_kms_helper snd_hwdep drm usbhid hid snd_pcm video snd_page_alloc
mac_hid snd_timer snd lpc_ich soundcore i2c_algo_bit lp parport e1000e
ahci libahci ptp pps_core [last unloaded: netconsole]
[  304.218140] CPU: 3 PID: 1437 Comm: nc Not tainted 3.11.0-rc5 #33
[  304.218221] Hardware name:                  /D33217GKE, BIOS
GKPPT10H.86A.0020.2012.0919.2135 09/19/2012
[  304.218325] task: ffff880110555d40 ti: ffff88011ef4c000 task.ti:
ffff88011ef4c000
[  304.218411] RIP: 0010:[<ffffffff816b75cc>]  [<ffffffff816b75cc>]
skb_panic+0x63/0x65
[  304.218528] RSP: 0018:ffff88011ef4d8d0  EFLAGS: 00010292
[  304.218595] RAX: 0000000000000084 RBX: ffff88011f1e8f00 RCX: 0000000000000006
[  304.218677] RDX: 0000000000000007 RSI: 0000000000000046 RDI: ffff88011f38d490
[  304.218759] RBP: ffff88011ef4d8f0 R08: 0000000002000000 R09: 0000000000000300
[  304.218841] R10: ffff88002ed6b880 R11: 0000000000000000 R12: ffff8801104f72d8
[  304.218923] R13: 000000000000000e R14: ffff8801104f72e8 R15: 0000000000000000
[  304.219005] FS:  00007f49f196d740(0000) GS:ffff88011f380000(0000)
knlGS:0000000000000000
[  304.219095] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  304.219164] CR2: 00007f49f10799d0 CR3: 00000001184ed000 CR4: 00000000001407e0
[  304.219245] Stack:
[  304.219273]  ffff880118554bee 0000000000000035 00000000000000c0
ffff8801193d7000
[  304.219411]  ffff88011ef4d900 ffffffff815b183a ffff88011ef4d948
ffffffff815f9baf
[  304.219544]  ffff8801193d7000 02706e0a81d00380 ffff88011f1e8f00
0000000000000000
[  304.219672] Call Trace:
[  304.219724]  [<ffffffff815b183a>] skb_push+0x3a/0x40
[  304.219794]  [<ffffffff815f9baf>] ip_finish_output+0x2af/0x3d0
[  304.219873]  [<ffffffff815fa5d5>] ip_output+0x55/0x90
[  304.219941]  [<ffffffff815f9d85>] ip_local_out+0x25/0x30
[  304.220014]  [<ffffffff8163be77>] iptunnel_xmit+0x1a7/0x1e0
[  304.220095]  [<ffffffffa0284d49>] ip_tunnel_xmit+0x2e9/0x15a0 [ip_tunnel]
[  304.220181]  [<ffffffffa028a6a1>] ipip_tunnel_xmit+0x61/0x80 [ipip]
[  304.220264]  [<ffffffff815c3138>] dev_hard_start_xmit+0x338/0x510
[  304.220342]  [<ffffffffa02a710b>] ? iptable_mangle_hook+0x7b/0x13c
[iptable_mangle]
[  304.220435]  [<ffffffff815c363f>] dev_queue_xmit+0x32f/0x490
[  304.220512]  [<ffffffff815c9401>] neigh_direct_output+0x11/0x20
[  304.220589]  [<ffffffff815f9aaf>] ip_finish_output+0x1af/0x3d0
[  304.220665]  [<ffffffff815fa5d5>] ip_output+0x55/0x90
[  304.220735]  [<ffffffff815f9d85>] ip_local_out+0x25/0x30
[  304.220806]  [<ffffffff815fb075>] ip_send_skb+0x15/0x50
[  304.220880]  [<ffffffff816201f7>] udp_send_skb+0x227/0x2b0
[  304.220953]  [<ffffffff815f82d0>] ? ip_copy_metadata+0x1a0/0x1a0
[  304.221034]  [<ffffffff81621c14>] udp_sendmsg+0x2c4/0x9e0
[  304.221108]  [<ffffffff81128f00>] ? __page_cache_alloc+0xc0/0xd0
[  304.221186]  [<ffffffff8112af2d>] ? filemap_fault+0xbd/0x470
[  304.221259]  [<ffffffff81129443>] ? unlock_page+0x23/0x30
[  304.221335]  [<ffffffff8114dc39>] ? __do_fault+0x3a9/0x4c0
[  304.221407]  [<ffffffff8162ce73>] inet_sendmsg+0x63/0xb0
[  304.221481]  [<ffffffff815aa36f>] sock_aio_write+0x13f/0x160
[  304.221555]  [<ffffffff81402e32>] ? n_tty_set_room+0x12/0xc0
[  304.221634]  [<ffffffff8118def0>] do_sync_write+0x80/0xb0
[  304.221707]  [<ffffffff8118edc5>] vfs_write+0x1b5/0x1e0
[  304.221778]  [<ffffffff8118f1c2>] SyS_write+0x52/0xa0
[  304.221850]  [<ffffffff816c4346>] system_call_fastpath+0x1a/0x1f
[  304.221924] Code: 00 00 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44
24 08 48 8b 87 e0 00 00 00 48 c7 c7 58 14 ad 81 48 89 04 24 31 c0 e8
d9 97 ff ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 56 41 55 41 54 53 48
89 fb
[  304.222830] RIP  [<ffffffff816b75cc>] skb_panic+0x63/0x65
[  304.222910]  RSP <ffff88011ef4d8d0>
[  304.222993] ---[ end trace e19b480453293c10 ]---
[  304.223086] Kernel panic - not syncing: Fatal exception in interrupt
[  304.223221] drm_kms_helper: panic occurred, switching back to text console

An interesting thing is that I have seen different kernel panics being
triggered. The other one I have seen has RIP pointing to
e1000_xmit_frame() and the message "protocol 0800 is buggy". However,
the one I have posted is by far the most common.

What puzzles me is this additional skb_push()-call. I have not been
able to trace its origin. As far as I can see, the skb data is not
touched after iptunnel_xmit(). It is clear that some bogus data is
introduced to the head of the packet at some point after
iptunnel_xmit():

[  500.537604] ip_tunnel_core: Len before push: 84 (size of iphdr struct 20)
[  500.541096] ip_tunnel_core: Len after push: 104
[  500.650000] ip_tunnel_core: 4 5 2706e0a 1706e0a (protocol, header
length, dst, src ip)
[  500.735787] rawpost: IN= OUT=eth4 SRC=236.168.107.243
DST=138.226.8.0 LEN=0 TOS=0x00 PREC=0x00 TTL=1 ID=180 DF FRAG:7704
PROTO=UDPLITE MARK=0x1

The three first lines is debug-output I added to iptunnel_xmit(),
while the last line is from iptables' LOG target used in rawpost
(combined with a DROP to avoid triggering the panic).

I do not see this kernel panic when I mangle in PREROUTING, give the
interface an address or don't mangle at all (for example ping -I tun0
8.8.8.8). The machine this occurs on is an Intel NUC with the Intel
82579 Gigabit Ethernet Controller. I have tested this against latest
net-next (pulled this morning).

Thanks in advance for any help,
Kristian
