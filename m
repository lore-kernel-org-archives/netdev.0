From: "Liu, Wei" <lw1a2.jing@gmail.com>
Subject: i40e nics are down when we use them on Dual CPU
Date: Mon, 29 Sep 2014 11:04:43 +0800
Message-ID: <CAO2W35uu9rFQFo_-g=x9VTJPM857dB+DAdh1WifjgL3aCuQYDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:60133 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaI2DOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 23:14:45 -0400
Received: by mail-ie0-f178.google.com with SMTP id rl12so3486676iec.9
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 20:14:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

When we use netperf to generate traffic, i40e nics are down very soon(
the throughput is about 76Gbps).

CPU: "Intel(R) Xeon(R) CPU E5-2670 v2 @ 2.50GHz" X2

TOPO:
port5, port6, port11, port12 are i40e interfaces.
port6 and port12 are in a net namespace.
port5<--->port6: port5 is connected port6 directly.
port11<--->port12: port11 is connected port12 directly.

nics interrupt bind cpu:
port5: 0, 1, 2, 3, 4 (CPU0)
port6: 10, 11, 12, 13, 14 (CPU1)
port11: 5, 6, 7, 8, 9(CPU0)
port12: 15, 16, 17, 18, 19 (CPU1)

kernel: 3.13.11
driver: i40e stable
1.0.15(http://sourceforge.net/projects/e1000/files/i40e%20stable/1.0.15/):
version: 1.0.15
firmware-version: f4.1 a1.1 n04.10 e800010e0
bus-info: 0000:09:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no
We also tried latest kernel 3.16.3 (with its own driver), it has the same issue.

netperf cmd:
netperf -T 14,19 -L 15.3.2.1 -H 15.3.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 13,18 -L 15.5.2.1 -H 15.5.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 12,17 -L 15.2.2.1 -H 15.2.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 11,16 -L 15.1.2.1 -H 15.1.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 10,15 -L 15.4.2.1 -H 15.4.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 4,9 -L 14.4.2.1 -H 14.4.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 3,8 -L 14.1.2.1 -H 14.1.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 2,7 -L 14.5.2.1 -H 14.5.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 1,6 -L 14.2.2.1 -H 14.2.1.100 -f m -D 1 -l 600 >/dev/null &
netperf -T 0,5 -L 14.3.2.1 -H 14.3.1.100 -f m -D 1 -l 600 >/dev/null &

dmesg:
...
i40e 0000:09:00.1 port6: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
i40e 0000:09:00.0 port5: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
IPv6: ADDRCONF(NETDEV_CHANGE): port6: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): port5: link becomes ready
i40e 0000:8a:00.0 port11: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
i40e 0000:8a:00.1 port12: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
IPv6: ADDRCONF(NETDEV_CHANGE): port11: link becomes ready
IPv6: ADDRCONF(NETDEV_CHANGE): port12: link becomes ready
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:254 dev_watchdog+0x174/0x1da()
Hardware name: To be filled by O.E.M.
NETDEV WATCHDOG: port5 (i40e): transmit queue 3 timed out
Modules linked in: khttpc(O) khttpd(O) i40e(O) ixgbe(O)
Pid: 883, comm: kworker/0:1 Tainted: G           O 3.8.4+ #1
Call Trace:
<IRQ>  [<ffffffff8022d914>] ? warn_slowpath_common+0x76/0x8a
[<ffffffff8022d96f>] ? warn_slowpath_fmt+0x47/0x49
[<ffffffff802373b5>] ? mod_timer+0x107/0x11b
[<ffffffff80549ec7>] ? dev_watchdog+0x174/0x1da
[<ffffffff80549d53>] ? dev_graft_qdisc+0x61/0x61
[<ffffffff802375e8>] ? call_timer_fn.isra.35+0x1c/0x6f
[<ffffffff8023779e>] ? run_timer_softirq+0x163/0x182
[<ffffffff80232f11>] ? __do_softirq+0xa0/0x13d
[<ffffffff8066260c>] ? call_softirq+0x1c/0x26
[<ffffffff802032b5>] ? do_softirq+0x2a/0x64
[<ffffffff8023306f>] ? irq_exit+0x3d/0x5a
[<ffffffff80218af2>] ? smp_apic_timer_interrupt+0x81/0x8d
[<ffffffff8066200a>] ? apic_timer_interrupt+0x6a/0x70
<EOI>  [<ffffffffa003e220>] ? i40e_do_reset_safe+0xcd2/0xd84 [i40e]
[<ffffffffa003dff5>] ? i40e_do_reset_safe+0xaa7/0xd84 [i40e]
[<ffffffff803af706>] ? delay_tsc+0x20/0x44
[<ffffffffa0042412>] ? i40e_asq_send_command+0x316/0x441 [i40e]
[<ffffffffa0043546>] ? i40e_aq_get_link_info+0x47/0x123 [i40e]
[<ffffffffa0043d64>] ? i40e_get_link_status+0x20/0x28 [i40e]
[<ffffffffa0036e45>] ? i40e_ioctl+0x1858/0x1a0b [i40e]
[<ffffffffa003e228>] ? i40e_do_reset_safe+0xcda/0xd84 [i40e]
[<ffffffff802370ca>] ? internal_add_timer+0xd/0x28
[<ffffffff802373b5>] ? mod_timer+0x107/0x11b
[<ffffffff8023f37e>] ? process_one_work+0x1d6/0x2d8
[<ffffffff8023f6a4>] ? worker_thread+0x201/0x2eb
[<ffffffff8023f4a3>] ? process_scheduled_works+0x23/0x23
[<ffffffff80243034>] ? kthread+0xa9/0xb1
[<ffffffff80242f8b>] ? kthread_stop+0x49/0x49
[<ffffffff8066146c>] ? ret_from_fork+0x7c/0xb0
[<ffffffff80242f8b>] ? kthread_stop+0x49/0x49
---[ end trace bdce93fbb0280b12 ]---
i40e 0000:09:00.0 port5: tx_timeout recovery level 1
i40e 0000:09:00.0: i40e_vsi_control_tx: VSI seid 518 Tx ring 3 disable timeout
i40e 0000:09:00.0: i40e_ptp_init: added PHC on port5
i40e 0000:09:00.0 port5: adding 00:90:0b:38:4f:7c vid=0
i40e 0000:09:00.0 port5: set fc fail, aq_err -7
i40e 0000:09:00.0 port5: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
i40e 0000:09:00.0 port5: NIC Link is Down
i40e 0000:09:00.1 port6: NIC Link is Down
i40e 0000:09:00.1 port6: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
i40e 0000:09:00.0 port5: NIC Link is Up 40 Gbps Full Duplex, Flow Control: None
