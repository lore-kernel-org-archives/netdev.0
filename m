From: Matt Ginzton <matt@ginzton.net>
Subject: reproducible kernel freeze using r8169 in Linux 3.0
Date: Sat, 17 Dec 2011 19:31:42 -0800
Message-ID: <E8F55547-7D58-4616-BC71-26651A42027E@ginzton.net>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:61628 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab1LRDbp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 22:31:45 -0500
Received: by iaeh11 with SMTP id h11so6590102iae.19
        for <netdev@vger.kernel.org>; Sat, 17 Dec 2011 19:31:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi r8169 maintainers,

I have a completely reproducible kernel freeze apparently in the r8169 =
driver. All I have to do is generate a decent network load in both dire=
ctions, and the kernel will freeze hard, not responding to network requ=
ests or input from a local console including magic sysrq, necessitating=
 a hard reboot.

Summary: r8169 from Linux 3.0 freezes reproducibly on my RTL8111/R8168B=
 hardware. r8169 from Linux 3.1 is better -- no freeze, but it still re=
sponds with a kernel warning to my repro scenario.

Details:

Software: Ubuntu 11.10 Server, x86, all updates as of today.
Hardware: Fit-pc2i, specs at http://www.fit-pc.com/web/fit-pc2/fit-pc2i=
-specifications/
uname -a: Linux flux 3.0.0-14-generic #23-Ubuntu SMP
lspci | grep Realtek: 02:00.0 Ethernet controller: Realtek Semiconducto=
r Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet Controller (rev =
02)
ethtool -i eth0 says: driver: r8169, version: 2.3LK-NAPI, firmware-vers=
ion: N/A

How I can reproduce the freeze:

- configure pktgen to generate a lot of TX traffic on eth0. I started w=
ith pktgen config in ftp://robur.slu.se/pub/Linux/net-development/pktge=
n-testing/examples/pktgen.conf-1-1, and modified it to use 1500 byte pa=
ckets. Leaving it at the default 10 million packet count, the test gene=
rates 15GB of outgoing packets and takes about 3 minutes to run.
- during that 3 minutes, generate some RX traffic too. On another box, =
I do "dd if=3D/dev/zero of=3D/tmp/foo bs=3D1048576 count=3D128". I then=
 scp that file back to the target box. If this succeeds, I do it again.
- usually this will reproduce the freeze within a few seconds, and alwa=
ys within a minute or two.
- often but not always, before it freezes, I will see multiple "r8169 0=
000:02:00.0: eth0: link up" messages (with no intervening "link down"),=
 if I'm watching the kernel log or appropriately configured console. Th=
is is kind of a canary for the impending freeze.

What happens when it freezes:

- apparently, nothing at all, though the other test box running the cli=
ent side of the scp will notice the transfer stalling.
- at this point, the target box won't respond at all on the network.
- it also won't respond to keyboard input from a USB keyboard
- including the magic sysrq key, which is configured (i.e. it works bef=
ore the freeze)
- even if I use sysrq+9 to set console loglevel to 9, nothing is printe=
d to console when it freezes
- upon reboot, there's nothing interesting or recent in /var/log/kern.l=
og
- the "eth0: link up" messages being the exception; they do show up on =
the console at log level 9, and do show up in kern.log if it was synced=
 before the freeze.
- I tried configuring nmi watchdog but could not get it to work on this=
 box. So, no info from where it's freezing.

So what then:

It was the multiple "eth0: link up" messages that drew my attention in =
the direction of the network. As soon as I started googling for "r8169 =
freeze", I found all sorts of reports of different problems with r8169,=
 going back years, so it's hard to know what's still relevant now and o=
n my hardware -- people complain about freezes, dropped packets, refusa=
l to autonegotiate media type or to work at rates faster than 10mbit=85=
 I didn't have any of these problems except the freeze.

The fix usually suggested for problems with r8169 is to go to Realtek a=
nd get r8168 instead. I'm a little leery of this (why is there an appar=
ently open-source driver but not in-tree, maintained only by Realtek bu=
t with modinfo reporting "author: Realtek and the Linux r8168 crew <net=
dev@vger.kernel.org>"?; also I noticed http://packages.debian.org/unsta=
ble/main/r8168-dkms which says "This driver should only be used for dev=
ices not yet supported by the in-kernel driver r8169") but hey, I gave =
it a try. I downloaded the 8.027 version of this, compiled it, installe=
d, it, used it, and couldn't get it to crash, but also couldn't get it =
to work with vlan virtual interfaces, which I intend to use (and which =
work fine with r8169), so it's not much good to me. (I gather from, for=
 example, http://patchwork.ozlabs.org/patch/28045/ that this list doesn=
't maintain r8168 and doesn't care about bugs in it and is annoyed by t=
he author claim, so I'm not coming here to complain about r8168, but ju=
st to point out that I did try it.)

I was losing hope of getting reliable Linux networking on this fit-pc a=
t all, but then I found https://bugs.launchpad.net/ubuntu/+source/linux=
-backports-modules-3.0.0/+bug/839393, wherein some enterprising souls h=
ave backported the r8169 driver from "Linux 3.1" (I don't know exactly =
what vintage 3.1) because it's more reliable. So I tried that backporte=
d one and it does indeed seem to work better. If I perform the same tes=
t as above (pktgen generating TX traffic and scp generating RX traffic)=
, I still see the multiple "eth0: link up" messages, but now the kernel=
 does not freeze, and I get a backtrace (once -- soon after the "link u=
p" thing starts, probably corresponding to when the freeze would have h=
appened).

A run of my test with this driver, including the kernel backtrace, look=
s something like:

Dec 17 19:20:22 flux kernel: [  200.958872] pktgen: Packet Generator fo=
r packet performance testing. Version: 2.74
Dec 17 19:20:34 flux kernel: [  213.029292] SysRq : Changing Loglevel
Dec 17 19:20:34 flux kernel: [  213.029437] Loglevel set to 9
Dec 17 19:20:53 flux kernel: [  232.052203] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:20:55 flux kernel: [  233.772238] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:20:55 flux kernel: [  233.788188] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:20:55 flux kernel: [  234.196614] ------------[ cut here ]---=
---------
Dec 17 19:20:55 flux kernel: [  234.196802] WARNING: at /build/buildd/l=
inux-3.0.0/net/core/dev.c:3809 net_rx_action+0x1f3/0x220()
Dec 17 19:20:55 flux kernel: [  234.197053] Hardware name: CM-iAM/SBC-F=
ITPC2i
Dec 17 19:20:55 flux kernel: [  234.197181] Modules linked in: pktgen a=
ct_police cls_flow cls_fw cls_u32 sch_tbf sch_prio sch_htb sch_hfsc sch=
_ingress sch_sfq xt_time xt_connlimit xt_realm xt_addrtype iptable_raw =
xt_comment xt_recent xt_policy ipt_ULOG ipt_REJECT ipt_REDIRECT ipt_NET=
MAP ipt_MASQUERADE ipt_ECN ipt_ecn ipt_CLUSTERIP ipt_ah xt_set ip_set n=
f_nat_tftp nf_nat_snmp_basic nf_conntrack_snmp nf_nat_sip nf_nat_pptp n=
f_nat_proto_gre nf_nat_irc nf_nat_h323 nf_nat_ftp nf_nat_amanda ts_kmp =
nf_conntrack_amanda nf_conntrack_sane nf_conntrack_tftp nf_conntrack_si=
p nf_conntrack_proto_sctp nf_conntrack_pptp nf_conntrack_proto_gre nf_c=
onntrack_netlink nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conn=
track_irc nf_conntrack_h323 nf_conntrack_ftp xt_TPROXY nf_tproxy_core i=
p6_tables nf_defrag_ipv6 xt_tcpmss xt_pkttype xt_physdev xt_owner xt_NF=
QUEUE xt_NFLOG nfnetlink_log xt_multiport xt_mark xt_mac xt_limit xt_le=
ngth xt_iprange xt_helper xt_hashlimit xt_DSCP xt_dscp xt_dccp xt_connt=
rack xt_connmark xt_CLASSIFY xt
Dec 17 19:20:55 flux kernel: _AUDIT ipt_LOG xt_tcpudp xt_state iptable_=
nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack iptable_mangle=
 nfnetlink iptable_filter ip_tables x_tables 8021q garp stp vesafb i2c_=
isch sch_gpio psb_gfx(C) snd_hda_codec_realtek psmouse drm_kms_helper s=
nd_hda_intel serio_raw snd_hda_codec drm snd_hwdep lpc_sch snd_pcm snd_=
timer i2c_algo_bit snd soundcore snd_page_alloc poulsbo video lp parpor=
t usbhid hid pata_sch sdhci_pci sdhci r8169
Dec 17 19:20:55 flux kernel: [  234.202347] Pid: 1550, comm: kpktgend_0=
 Tainted: G         C  3.0.0-14-generic #23-Ubuntu
Dec 17 19:20:55 flux kernel: [  234.202576] Call Trace:
Dec 17 19:20:55 flux kernel: [  234.202664]  [<c151a3f2>] ? printk+0x2d=
/0x2f
Dec 17 19:20:55 flux kernel: [  234.202804]  [<c1047a22>] warn_slowpath=
_common+0x72/0xa0
Dec 17 19:20:55 flux kernel: [  234.202962]  [<c143ba03>] ? net_rx_acti=
on+0x1f3/0x220
Dec 17 19:20:55 flux kernel: [  234.203112]  [<c143ba03>] ? net_rx_acti=
on+0x1f3/0x220
Dec 17 19:20:55 flux kernel: [  234.203263]  [<c1047a72>] warn_slowpath=
_null+0x22/0x30
Dec 17 19:20:55 flux kernel: [  234.203417]  [<c143ba03>] net_rx_action=
+0x1f3/0x220
Dec 17 19:20:55 flux kernel: [  234.203567]  [<c104e570>] ? local_bh_en=
able_ip+0x90/0x90
Dec 17 19:20:55 flux kernel: [  234.203725]  [<c104e5f1>] __do_softirq+=
0x81/0x1a0
Dec 17 19:20:55 flux kernel: [  234.203868]  [<c104e570>] ? local_bh_en=
able_ip+0x90/0x90
Dec 17 19:20:55 flux kernel: [  234.204041]  <IRQ>  [<c104e559>] ? loca=
l_bh_enable_ip+0x79/0x90
Dec 17 19:20:55 flux kernel: [  234.204244]  [<c152dbd6>] ? _raw_spin_u=
nlock_bh+0x16/0x20
Dec 17 19:20:55 flux kernel: [  234.204411]  [<f98430a4>] ? pktgen_xmit=
+0x144/0x270 [pktgen]
Dec 17 19:20:55 flux kernel: [  234.204623]  [<f80479c0>] ? rtl8169_clo=
se+0x210/0x210 [r8169]
Dec 17 19:20:55 flux kernel: [  234.204795]  [<f984007b>] ? pktgen_chan=
ge_name+0x7b/0xa0 [pktgen]
Dec 17 19:20:55 flux kernel: [  234.204974]  [<f98432c4>] ? pktgen_thre=
ad_worker+0xf4/0x370 [pktgen]
Dec 17 19:20:55 flux kernel: [  234.205167]  [<c1066380>] ? add_wait_qu=
eue+0x50/0x50
Dec 17 19:20:55 flux kernel: [  234.205316]  [<c1066380>] ? add_wait_qu=
eue+0x50/0x50
Dec 17 19:20:55 flux kernel: [  234.205467]  [<f98431d0>] ? pktgen_xmit=
+0x270/0x270 [pktgen]
Dec 17 19:20:55 flux kernel: [  234.205634]  [<c1065b7d>] ? kthread+0x6=
d/0x80
Dec 17 19:20:55 flux kernel: [  234.205767]  [<c1065b10>] ? flush_kthre=
ad_worker+0x80/0x80
Dec 17 19:20:55 flux kernel: [  234.205931]  [<c153517e>] ? kernel_thre=
ad_helper+0x6/0x10
Dec 17 19:20:55 flux kernel: [  234.217422] ---[ end trace 7229c628b96d=
dd29 ]---
Dec 17 19:20:55 flux kernel: [  234.229519] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:20:56 flux kernel: [  234.604219] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:00 flux kernel: [  238.592202] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:03 flux kernel: [  241.848236] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:05 flux kernel: [  244.144217] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:07 flux kernel: [  245.540217] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:14 flux kernel: [  253.228245] r8169 0000:02:00.0: eth0: l=
ink up
Dec 17 19:21:14 flux kernel: [  253.260220] r8169 0000:02:00.0: eth0: l=
ink up

Please let me know if I'm reporting this to the right place, or if ther=
e's any other helpful info I can provide.

thanks,

Matt
