From: "Jann Traschewski" <jann@gmx.de>
Subject: [BUG][AX25] mkiss and ax25_route lockdep warning
Date: Mon, 11 Feb 2008 09:56:27 +0100
Message-ID: <000d01c86c8b$fd9e67d0$453c822c@dg8ngn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:52655 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752966AbYBKI4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 03:56:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

After using "Lock debugging: prove locking correctness" with the Kernel I
got this warning:

=================================
[ INFO: inconsistent lock state ]
2.6.24-dg8ngn-p02 #1
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-R} usage.
linuxnet/3046 [HC0[0]:SC1[2]:HE1:SE0] takes:
 (ax25_route_lock){--.+}, at: [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
{softirq-on-W} state was registered at:
  [<c013a340>] __lock_acquire+0x464/0xb7b
  [<c01398d8>] mark_held_locks+0x39/0x53
  [<c0124d35>] local_bh_enable_ip+0xcd/0xd5
  [<c0139aaf>] trace_hardirqs_on+0x11a/0x13d
  [<c013ae58>] lock_acquire+0x5f/0x77
  [<f8a0d381>] ax25_rt_ioctl+0x66/0x325 [ax25]
  [<c0299ce7>] _write_lock+0x29/0x34
  [<f8a0d381>] ax25_rt_ioctl+0x66/0x325 [ax25]
  [<f8a0d381>] ax25_rt_ioctl+0x66/0x325 [ax25]
  [<f8a0f699>] ax25_ioctl+0x1b6/0x5b8 [ax25]
  [<c0161280>] fd_install+0x1e/0x46
  [<c0299c7a>] _spin_lock+0x29/0x34
  [<c022e75d>] sock_ioctl+0x1bb/0x1e0
  [<c022e5a2>] sock_ioctl+0x0/0x1e0
  [<c016c76f>] do_ioctl+0x1f/0x62
  [<c016c9d2>] vfs_ioctl+0x220/0x232
  [<c0139aaf>] trace_hardirqs_on+0x11a/0x13d
  [<c016ca17>] sys_ioctl+0x33/0x4c
  [<c0103ea2>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 120000
hardirqs last  enabled at (120000): [<c0124d35>]
local_bh_enable_ip+0xcd/0xd5
hardirqs last disabled at (119999): [<c0124cc3>]
local_bh_enable_ip+0x5b/0xd5
softirqs last  enabled at (119892): [<f89fd53d>]
mkiss_receive_buf+0x2a5/0x394 [mkiss]
softirqs last disabled at (119893): [<c01249f0>] do_softirq+0x37/0x4d

other info that might help us debug this:
5 locks held by linuxnet/3046:
 #0:  (&tty->atomic_write_lock){--..}, at: [<c01ded5e>]
tty_write_lock+0x11/0x37
 #1:  (rcu_read_lock){..--}, at: [<c023a8d2>] net_rx_action+0x4e/0x1c4
 #2:  (rcu_read_lock){..--}, at: [<c0238579>] netif_receive_skb+0xe6/0x3d6
 #3:  (rcu_read_lock){..--}, at: [<c025549d>]
ip_local_deliver_finish+0x2d/0x1f7
 #4:  (slock-AF_INET){-+..}, at: [<c0274e43>] icmp_send+0x10e/0x37a

stack backtrace:
Pid: 3046, comm: linuxnet Not tainted 2.6.24-dg8ngn-p02 #1
 [<c0138e13>] print_usage_bug+0x138/0x142
 [<c013961f>] mark_lock+0x1ca/0x44a
 [<c013a2d9>] __lock_acquire+0x3fd/0xb7b
 [<c01398d8>] mark_held_locks+0x39/0x53
 [<c0124d35>] local_bh_enable_ip+0xcd/0xd5
 [<c013ae58>] lock_acquire+0x5f/0x77
 [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
 [<c0299dc7>] _read_lock+0x29/0x34
 [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
 [<f8a0cfb7>] ax25_get_route+0x18/0xb7 [ax25]
 [<f89fda29>] ax_header+0x0/0x1a [mkiss]
 [<f8a0c3f6>] ax25_rebuild_header+0x30/0x202 [ax25]
 [<f89fda29>] ax_header+0x0/0x1a [mkiss]
 [<c023f90c>] neigh_compat_output+0x7b/0x97
 [<c0258bd6>] ip_finish_output+0x1da/0x204
 [<c0259a26>] ip_output+0x74/0x89
 [<c0257831>] ip_push_pending_frames+0x2d8/0x33a
 [<c025742c>] dst_output+0x0/0x7
 [<c0275039>] icmp_send+0x304/0x37a
 [<c013a353>] __lock_acquire+0x477/0xb7b
 [<c0270c05>] __udp4_lib_lookup+0xec/0xf6
 [<c0271a48>] __udp4_lib_rcv+0x586/0x771
 [<c02555ae>] ip_local_deliver_finish+0x13e/0x1f7
 [<c025549d>] ip_local_deliver_finish+0x2d/0x1f7
 [<c0255451>] ip_rcv_finish+0x2c1/0x2e0
 [<c025591c>] ip_rcv+0x1f0/0x22b
 [<c0255190>] ip_rcv_finish+0x0/0x2e0
 [<c0238808>] netif_receive_skb+0x375/0x3d6
 [<c0238579>] netif_receive_skb+0xe6/0x3d6
 [<c023adc4>] process_backlog+0x6c/0xcd
 [<c023a940>] net_rx_action+0xbc/0x1c4
 [<c023a8d2>] net_rx_action+0x4e/0x1c4
 [<c0124944>] __do_softirq+0x69/0xde
 [<f89fd53d>] mkiss_receive_buf+0x2a5/0x394 [mkiss]
 [<c01249f0>] do_softirq+0x37/0x4d
 [<c0124d15>] local_bh_enable_ip+0xad/0xd5
 [<f89fd53d>] mkiss_receive_buf+0x2a5/0x394 [mkiss]
 [<c029a042>] _spin_unlock_irqrestore+0x34/0x39
 [<c01e3233>] pty_write+0x2f/0x39
 [<c01e1233>] write_chan+0x22d/0x2a1
 [<c01191e7>] default_wake_function+0x0/0x8
 [<c01def37>] tty_write+0x14d/0x1c2
 [<c01e1006>] write_chan+0x0/0x2a1
 [<c01dedea>] tty_write+0x0/0x1c2
 [<c0162f28>] vfs_write+0x8a/0x10c
 [<c01634a4>] sys_write+0x41/0x67
 [<c0103ea2>] syscall_call+0x7/0xb
 =======================


--
Jann Traschewski, Drosselstr.1, D-90513 Zirndorf, Germany
Tel.: +49-911-696971, Mobile: +49-170-1045937, EMail: jann@gmx.de
Ham: DG8NGN / DB0VOX, http://www.qsl.net/db0fhn, ICQ UIN: 4130182 

