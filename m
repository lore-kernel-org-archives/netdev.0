From: Andrew Zabolotny <zap@homelink.ru>
Subject: Problems with the sky2 driver
Date: Mon, 19 Feb 2007 00:38:52 +0300
Message-ID: <20070219003852.7f91a221@zap.ozerki.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.homelink.ru ([81.9.33.123]:40997 "EHLO eltel.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752404AbXBRW4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Feb 2007 17:56:41 -0500
Received: from [85.249.170.16] (account zap@homelink.ru HELO zap.ozerki.lan)
  by eltel.net (CommuniGate Pro SMTP 4.2.10)
  with ESMTP-TLS id 57816784 for netdev@vger.kernel.org; Mon, 19 Feb 2007 00:56:40 +0300
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

I've seen the thread "sky2 problems on Intel Mac Mini" on this list and
subscribed to continue the discussion :)

I'm getting absolutely same problems as reported by Chris Lightfoot
here: http://www.mail-archive.com/netdev@vger.kernel.org/msg30466.html

I'm running Fedora Core 6, stock kernel 2.6.19-1.2911.fc6 (with
soft-lockups detect enabled) on a Core Duo2 platform (CPU E6600),
Gigabyte P865 DS4 motherboard with an on-board Marvell gigabit ethernet
controller, identified as:

03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053
PCI-E Gigabit Ethernet Controller (rev 22)

or as:

sky2 v1.10 addr 0xf8000000 irq 16 Yukon-EC (0xb6) rev 2

by the sky2 driver. My machine is connected to a large 100 megabit
LAN of my Internet provider. Now one observation I have made while
reading similar reports on the net is that they all were running at
100Mbit speed. Also it doesn't happen because of high-volume traffic,
it happens for me quite often on low traffic as well (perhaps 10k/s to
1Mb/s, usually I don't have more).

Now I tried the sk98lin driver fixed for 2.6.19+ that Stephen Hemminger
posted here:
http://www.mail-archive.com/netdev@vger.kernel.org/msg28373.html

and it seems to work fine without any lockups. I also don't see any of
the "noisy reset notifications" he was talking about, but perhaps the
driver just has been changed in the meantime.

If I enable debug=12 and above, it locks up the computer so hard that
I hardly can enter 'ifconfig eth0 down', after which the lockups vanish.
Basically it's absolutely locked up for 10-30 seconds, after that
soft-lockup logic kicks the driver, then 1-2 seconds it kind of reacts
to user input and then locks up again. The network has about 10
kilobits of 'background' traffic such as arps and other wayward traffic
flowing, so I think they are the cause of these lockups.

Now sometimes after machine lockups there are two scenarios for what
happens further: it either recovers and continues to work fine, or
sometimes it can't recover from the error condition and I have to stop
the network, then rmmod the sky2 driver, then start the network again,
after which it works fine again.

By the way, one of the things that often cause a lockup is running
tcpdump. I can't see a regularity here but quite often when I run
or quit (with Ctrl+C) tcpdump it locks up for ~30 seconds, until
kernel watchdog kicks it.

By looking at kernel logs with debug=12 it seems that the transmitter
locks up from time to time. Here's a typical lockup sequence:

sky2 eth0: rx slot 80 status 0x3c0300 len 60
sky2 eth0: rx slot 81 status 0x3c0300 len 60
sky2 eth0: rx slot 82 status 0x5ea0100 len 1514
eth0: tx queued, slot 44, len 66
sky2 eth0: rx slot 83 status 0x5ea0100 len 1514
eth0: tx queued, slot 45, len 66
sky2 eth0: rx slot 84 status 0x3c0300 len 60
sky2 eth0: rx slot 85 status 0x3c0300 len 60
sky2 eth0: rx slot 86 status 0x3c0300 len 60
# and here rx slots are allocated one after other, without tx's
#...skipped...
sky2 eth0: rx slot 153 status 0x3c0300 len 60
sky2 eth0: rx slot 154 status 0x3c0300 len 60
sky2 eth0: rx slot 155 status 0x3c0300 len 60
sky2 eth0: rx slot 156 status 0x3c0300 len 60
sky2 eth0: rx slot 157 status 0x3c0300 len 60
sky2 eth0: rx slot 158 status 0x3c0300 len 60
sky2 eth0: rx slot 159 status 0x3c0300 len 60
BUG: soft lockup detected on CPU#0!

Call Trace:
 [<ffffffff8026999a>] show_trace+0x34/0x47
 [<ffffffff802699bf>] dump_stack+0x12/0x17
 [<ffffffff802b6ced>] softlockup_tick+0xdb/0xf6
 [<ffffffff80293c2f>] update_process_times+0x42/0x68
 [<ffffffff802749d9>] smp_local_timer_interrupt+0x34/0x55
 [<ffffffff8027508d>] smp_apic_timer_interrupt+0x51/0x69
 [<ffffffff8025ccf6>] apic_timer_interrupt+0x66/0x70
 [<ffffffff8020c531>] _raw_read_lock+0x20/0x29
 [<ffffffff80450dab>] fn_hash_lookup+0x23/0xc8
 [<ffffffff80451cd5>] fib4_rule_action+0x43/0x50
 [<ffffffff8042260d>] fib_rules_lookup+0x4a/0x76
 [<ffffffff80451d1c>] fib_lookup+0x30/0x3f
 [<ffffffff80236e18>] ip_route_input+0x4a8/0xc6d
 [<ffffffff80446523>] arp_process+0x180/0x56b
 [<ffffffff80446a0e>] arp_rcv+0x100/0x122
 [<ffffffff802207b4>] netif_receive_skb+0x350/0x3da
 [<ffffffff880e9bf1>] :sky2:sky2_poll+0x81e/0xac9
 [<ffffffff8020c37c>] net_rx_action+0xa4/0x1a7
 [<ffffffff80211ee5>] __do_softirq+0x55/0xc4
 [<ffffffff8025d24c>] call_softirq+0x1c/0x30
 [<ffffffff8026aa2f>] do_softirq+0x2c/0x97
 [<ffffffff80275092>] smp_apic_timer_interrupt+0x56/0x69
 [<ffffffff8025ccf6>] apic_timer_interrupt+0x66/0x70
 [<ffffffff80216f1c>] release_console_sem+0x192/0x208
 [<ffffffff8039b115>] do_con_write+0x1733/0x1767
 [<ffffffff8039b189>] con_write+0xf/0x20
 [<ffffffff80219d41>] write_chan+0x212/0x305
 [<ffffffff8022915d>] tty_write+0x177/0x20e
 [<ffffffff802d5039>] do_loop_readv_writev+0x37/0x69
 [<ffffffff802d568b>] do_readv_writev+0xea/0x1a4
 [<ffffffff802d57cc>] sys_writev+0x45/0x93
 [<ffffffff8025c11e>] system_call+0x7e/0x83
 [<00002aaaaad8c5ac>]

BUG: soft lockup detected on CPU#1!

Call Trace:
sky2 eth0: rx slot 160 status 0x3c0300 len 60
 [<ffffffff8026999a>] show_trace+0x34/0x47
sky2 eth0: rx slot 161 status 0x3c0300 len 60
 [<ffffffff802699bf>] dump_stack+0x12/0x17
 [<ffffffff802b6ced>] softlockup_tick+0xdb/0xf6
sky2 eth0: rx slot 162 status 0x3c0300 len 60
 [<ffffffff80293c2f>] update_process_times+0x42/0x68
 [<ffffffff802749d9>] smp_local_timer_interrupt+0x34/0x55
sky2 eth0: rx slot 163 status 0x3c0300 len 60
 [<ffffffff8027508d>] smp_apic_timer_interrupt+0x51/0x69
sky2 eth0: rx slot 164 status 0x3c0300 len 60
 [<ffffffff8025ccf6>] apic_timer_interrupt+0x66/0x70
sky2 eth0: rx slot 165 status 0x3c0300 len 60
 [<ffffffff802690f2>] mwait_idle_with_hints+0x44/0x45
sky2 eth0: rx slot 166 status 0x3c0300 len 60
 [<ffffffff80255543>] mwait_idle+0xc/0x20
sky2 eth0: rx slot 167 status 0x3c0300 len 60
 [<ffffffff802476d0>] cpu_idle+0x8b/0xae
 [<ffffffff802747e6>] start_secondary+0x462/0x471

sky2 eth0: rx slot 0 status 0x3c0300 len 60
sky2 eth0: rx slot 1 status 0x3c0300 len 60
sky2 eth0: rx slot 2 status 0x3c0300 len 60
sky2 eth0: rx slot 3 status 0x5ea0100 len 1514
eth0: tx done 37
eth0: tx done 38
eth0: tx done 39
eth0: tx done 40
eth0: tx done 41
eth0: tx done 42
eth0: tx done 43
eth0: tx done 44
eth0: tx done 45
sky2 eth0: rx slot 4 status 0x5ea0100 len 1514
eth0: tx queued, slot 46, len 66
sky2 eth0: rx slot 5 status 0x5ea0100 len 1514
sky2 eth0: rx slot 6 status 0x5ea0100 len 1514
sky2 eth0: rx slot 7 status 0x5ea0100 len 1514
sky2 eth0: rx slot 8 status 0x5ea0100 len 1514
sky2 eth0: rx slot 9 status 0x5ea0100 len 1514
sky2 eth0: rx slot 10 status 0x5ea0100 len 1514
eth0: tx queued, slot 47, len 66
sky2 eth0: rx slot 11 status 0x5ea0100 len 1514
eth0: tx queued, slot 48, len 66

I packet the whole dmesg and put it here:
http://cs.ozerki.net/zap/sky2-dmesg.txt.gz (11k) in the case somebody is
interested. It contains just two soft-lockups because the rest was
pushed out of the kernel log before I could capture it, but they all
are pretty much the same.

-- 
Andrew
