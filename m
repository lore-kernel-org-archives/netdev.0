From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: 2.6.31.6: Intel 82574L devices spontaneously dropping off PCIe?
Date: Sun, 13 Dec 2009 12:37:58 -0800
Message-ID: <4B2550A6.8030705@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753366AbZLMUiC@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a Supermicro X8SIL-F system, which has a couple of on-board 
82574L gigabit interfaces.  I'm running the stock F12 kernel on it 
(2.6.31.6-166.fc12.x86_64).   This is a new machine, so I'm trying to 
work out if this is a hardware problem I should RMA the board for, if 
this is some kind of driver bug.

The interfaces come up and apparently work fine - for a while.  But 
after a bit of load (say, a ~9GB of incoming TCP traffic from another 
machine on the same switch) the hardware appears to disappear from 
PCIe.  ifconfig starts showing junk:

eth1      Link encap:Ethernet  HWaddr 00:30:48:DD:EB:67
           inet6 addr: fe80::230:48ff:fedd:eb67/64 Scope:Link
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:7910754 errors:532687613729670 dropped:88781268954945 overruns:0 frame:355125075819780
           TX packets:4104172 errors:177562537909890 dropped:0 overruns:0 carrier:177562537909890
           collisions:88781268954945 txqueuelen:1000
           RX bytes:9589212936 (8.9 GiB)  TX bytes:271851778 (259.2 MiB)
           Memory:fafe0000-fb000000


and lspci shows that the config space is all 0xff:

[root@lilith ~]# lspci -s 04:00.0 -x
04:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection (rev ff)
00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

[root@lilith ~]# lspci -s 05:00.0 -x
05:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection (rev ff)
00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff


This seems to happen quietly without the kernel noticing; the only 
side-effect is the dev watchdog triggering:

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:246 dev_watchdog+0xf3/0x164() (Not tainted)
Hardware name: X8SIL
NETDEV WATCHDOG: eth1 (e1000e): transmit queue 0 timed out
Modules linked in: ip6table_filter ip6_tables bridge stp llc sunrpc xt_physdev ip6t_REJECT nf_conntrack_ipv6 ipv6 cpufreq_ondemand acpi_cpufreq freq_table dm_multipath kvm_intel kvm uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_midi_event snd_seq_midi_emul snd_emu10k1 snd_rawmidi snd_ac97_codec ac97_bus snd_seq snd_pcm snd_seq_device snd_timer snd_page_alloc snd_util_mem snd_hwdep snd e1000e i2c_i801 soundcore emu10k1_gp gameport i2c_core joydev cryptd aes_x86_64 aes_generic xts gf128mul dm_crypt raid10 [last unloaded: ip6_tables]
Pid: 0, comm: swapper Not tainted 2.6.31.6-166.fc12.x86_64 #1
Call Trace:
  <IRQ>   [<ffffffff810516f4>] warn_slowpath_common+0x84/0x9c
  [<ffffffff81051763>] warn_slowpath_fmt+0x41/0x43
  [<ffffffff8138e831>] ? netif_tx_lock+0x44/0x6d
  [<ffffffff8138e99b>] dev_watchdog+0xf3/0x164
  [<ffffffff8105bc52>] ? internal_add_timer+0xcf/0xd1
  [<ffffffff8105bd0b>] ? cascade+0x6a/0x84
  [<ffffffff8105bec4>] run_timer_softirq+0x19f/0x21c
  [<ffffffff8106ae47>] ? hrtimer_interrupt+0x13c/0x153
  [<ffffffff81057614>] __do_softirq+0xdd/0x1ad
  [<ffffffff81026936>] ? apic_write+0x16/0x18
  [<ffffffff81012eac>] call_softirq+0x1c/0x30
  [<ffffffff810143fb>] do_softirq+0x47/0x8d
  [<ffffffff81057326>] irq_exit+0x44/0x86
  [<ffffffff8141ecf5>] do_IRQ+0xa5/0xbc
  [<ffffffff810126d3>] ret_from_intr+0x0/0x11
  <EOI>   [<ffffffff812679dd>] ? acpi_idle_enter_bm+0x281/0x2b5
  [<ffffffff812679d6>] ? acpi_idle_enter_bm+0x27a/0x2b5
  [<ffffffff81353b7f>] ? cpuidle_idle_call+0x99/0xce
  [<ffffffff81010c60>] ? cpu_idle+0xa6/0xe9
  [<ffffffff81405db7>] ? rest_init+0x6b/0x6d
  [<ffffffff81714dc9>] ? start_kernel+0x3ef/0x3fa
  [<ffffffff817142a1>] ? x86_64_start_reservations+0xac/0xb0
  [<ffffffff8171439d>] ? x86_64_start_kernel+0xf8/0x107
---[ end trace f271bce88fe9d682 ]---
0000:05:00.0: eth1: Error reading PHY register
e1000e: eth1 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX


A reboot seems to recover the devices:

[root@lilith ~]# lspci -s 04:00.0 -x
04:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
00: 86 80 d3 10 07 04 10 00 00 00 00 02 10 00 00 00
10: 00 00 ee fa 00 00 00 00 01 cc 00 00 00 c0 ed fa
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 05 06
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0a 01 00 00

[root@lilith ~]# lspci -s 05:00.0 -x
05:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
00: 86 80 d3 10 07 04 10 00 00 00 00 02 10 00 00 00
10: 00 00 fe fa 00 00 00 00 01 dc 00 00 00 c0 fd fa
20: 00 00 00 00 00 00 00 00 00 00 00 00 d9 15 05 06
30: 00 00 00 00 c8 00 00 00 00 00 00 00 0b 01 00 00




Any clues?

Thanks,
     J
