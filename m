From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Inconsistent lock  state and possible irq lock inversion dependency
 detected in ax25.ko
Date: Wed, 21 Nov 2007 23:13:31 +0100
Message-ID: <4744AD8B.2000908@ccr.jussieu.fr>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050601050908080509090703"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:58417 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbXKUWKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 17:10:24 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix2-g20.free.fr (Postfix) with ESMTP id AE6C91F25F6B
	for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 21:08:04 +0100 (CET)
In-Reply-To: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050601050908080509090703
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

I am practicing intensively AX25 packet radio that uses ax25.ko together 
with mkiss, crc16, netrom, and rose modules using two PIII CPU Linux 
machines with 2.6.23.8 kernel.

On the first Linux machine I did not validate kernel hacking and AX25 
applications are running 100% of the time without serious problems.

On the second machine I validated kernel hacking and sooner or later I 
get exactly the same message after a connect timeout expires :

[ INFO: inconsistent lock state ]

The error seems to reside around ax25_disconnect+0x46/0xaf [ax25] that 
is called when an AX25 connect timeout or a connection failure occurs.
Connect timeout is probably activating
ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]

The message is only displayed once on a boot session.

Ralf Baechle explained to me that ax25 code is very buggy and spinlocks 
difficult to trace.
However, as the cause of error is clearlHowever, as the cause of error 
is clearly identified and the y identified and the reported address is 
constant I suspect that an experienced programmer (which I am not) could 
trace the problem.

Moreover, I had the opportunity to catch a different message, that was 
longer than usual, and seem more explicit :

[ INFO: possible irq lock inversion dependency detected ]

Although the symptom is different it is related to the same origin :

fpac/4933 just changed the state of lock:
  (slock-AF_AX25){--..}, at: [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]

Whatever the running application is the inconsistent lock state could be 
observed with ax25_call, flexd, fpac ax25 application programms.

Please find attached a few reports captured from dmesg after each event.

Could someone look at the listing and identify the origin of the problem 
,if unique ?

Thanks.

Bernard Pidoux



--------------050601050908080509090703
Content-Type: text/plain;
 name="inconsistent_locks_report"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inconsistent_locks_report"


=========================================================
[ INFO: possible irq lock inversion dependency detected ]
2.6.23.1 #1
---------------------------------------------------------
fpac/4933 just changed the state of lock:
 (slock-AF_AX25){--..}, at: [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
but this lock was taken by another, soft-irq-safe lock in the past:
 (ax25_list_lock){-+..}

and interrupts could create inverse lock ordering between them.


other info that might help us debug this:
no locks held by fpac/4933.

the first lock's dependencies:
-> (slock-AF_AX25){--..} ops: 410 {
   initial-use  at:
                        [<c012f448>] mark_lock+0x5b/0x44b
                        [<c0130358>] __lock_acquire+0x4c2/0xc02
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c02462e0>] sock_fasync+0x61/0x116
                        [<c024727f>] sock_close+0x22/0x2f
                        [<c015c78b>] __fput+0xbc/0x172
                        [<c015a256>] filp_close+0x51/0x58
                        [<c0119daf>] put_files_struct+0x5e/0xa6
                        [<c011ae59>] do_exit+0x22e/0x6d9
                        [<c0103cc6>] sysenter_past_esp+0x8f/0x99
                        [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                        [<c011b36f>] sys_exit_group+0x0/0xd
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   softirq-on-W at:
                        [<c0130a50>] __lock_acquire+0xbba/0xc02
                        [<c0130343>] __lock_acquire+0x4ad/0xc02
                        [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                        [<c02a37c2>] _spin_lock+0x29/0x34
                        [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                        [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                        [<d8be50c0>] ax25_release+0x9d/0x182 [ax25]
                        [<c0246e79>] sock_release+0x14/0x56
                        [<c0247287>] sock_close+0x2a/0x2f
                        [<c015c78b>] __fput+0xbc/0x172
                        [<c015a256>] filp_close+0x51/0x58
                        [<c015b284>] sys_close+0x66/0x9d
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c012f448>] mark_lock+0x5b/0x44b
                        [<c013031e>] __lock_acquire+0x488/0xc02
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c024886b>] lock_sock_nested+0x26/0xcc
                        [<c02462e0>] sock_fasync+0x61/0x116
                        [<c024727f>] sock_close+0x22/0x2f
                        [<c015c78b>] __fput+0xbc/0x172
                        [<c015a256>] filp_close+0x51/0x58
                        [<c0119daf>] put_files_struct+0x5e/0xa6
                        [<c011ae59>] do_exit+0x22e/0x6d9
                        [<c0103cc6>] sysenter_past_esp+0x8f/0x99
                        [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                        [<c011b36f>] sys_exit_group+0x0/0xd
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<c05db598>] af_family_slock_keys+0x18/0x120

the second lock's dependencies:
-> (ax25_list_lock){-+..} ops: 24485 {
   initial-use  at:
                        [<c0130358>] __lock_acquire+0x4c2/0xc02
                        [<c011c823>] local_bh_enable+0xfe/0x105
                        [<c012f871>] mark_held_locks+0x39/0x53
                        [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<d8be569d>] ax25_bind+0x129/0x14b [ax25]
                        [<c0247668>] sys_bind+0x75/0xa0
                        [<c02a37c2>] _spin_lock+0x29/0x34
                        [<c02a371a>] _spin_unlock+0x14/0x1c
                        [<c024694e>] sock_map_fd+0x41/0x4a
                        [<c0247df4>] sys_socketcall+0x93/0x261
                        [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   in-softirq-W at:
                        [<c012f5cb>] mark_lock+0x1de/0x44b
                        [<c01302cc>] __lock_acquire+0x436/0xc02
                        [<c0130a50>] __lock_acquire+0xbba/0xc02
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<d8be4450>] ax25_find_cb+0x18/0xc6 [ax25]
                        [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                        [<d8be4450>] ax25_find_cb+0x18/0xc6 [ax25]
                        [<d8be4450>] ax25_find_cb+0x18/0xc6 [ax25]
                        [<d8be0bf9>] ax25_kiss_rcv+0x37d/0x712 [ax25]
                        [<c012f871>] mark_held_locks+0x39/0x53
                        [<c024a6af>] sock_queue_rcv_skb+0xd6/0xf3
                        [<c02a36d9>] _read_unlock+0x14/0x1c
                        [<c024a6af>] sock_queue_rcv_skb+0xd6/0xf3
                        [<c0250250>] netif_receive_skb+0x22d/0x289
                        [<c012fa48>] trace_hardirqs_on+0x109/0x148
                        [<c0252113>] process_backlog+0x7b/0xeb
                        [<c02521da>] net_rx_action+0x57/0xfd
                        [<c011c515>] __do_softirq+0x40/0x90
                        [<c0171866>] seq_read+0x1d1/0x277
                        [<c011c58c>] do_softirq+0x27/0x3d
                        [<c011c8c7>] local_bh_enable_ip+0x9d/0xc5
                        [<c0171866>] seq_read+0x1d1/0x277
                        [<c0171695>] seq_read+0x0/0x277
                        [<c0185922>] proc_reg_read+0x64/0x77
                        [<c01858be>] proc_reg_read+0x0/0x77
                        [<c015c0d0>] vfs_read+0xa6/0x12e
                        [<c015c3fe>] sys_read+0x41/0x67
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
   hardirq-on-W at:
                        [<c013031e>] __lock_acquire+0x488/0xc02
                        [<c011c823>] local_bh_enable+0xfe/0x105
                        [<c012f871>] mark_held_locks+0x39/0x53
                        [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
                        [<c0130b06>] lock_acquire+0x6e/0x87
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<d8be3c0c>] ax25_cb_add+0xd/0x39 [ax25]
                        [<d8be569d>] ax25_bind+0x129/0x14b [ax25]
                        [<c0247668>] sys_bind+0x75/0xa0
                        [<c02a37c2>] _spin_lock+0x29/0x34
                        [<c02a371a>] _spin_unlock+0x14/0x1c
                        [<c024694e>] sock_map_fd+0x41/0x4a
                        [<c0247df4>] sys_socketcall+0x93/0x261
                        [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                        [<c0103c96>] sysenter_past_esp+0x5f/0x99
                        [<ffffffff>] 0xffffffff
 }
 ... key      at: [<d8beaf70>] ax25_list_lock+0x10/0xffffbf0f [ax25]
 -> (slock-AF_AX25){--..} ops: 410 {
    initial-use  at:
                          [<c012f448>] mark_lock+0x5b/0x44b
                          [<c0130358>] __lock_acquire+0x4c2/0xc02
                          [<c0130b06>] lock_acquire+0x6e/0x87
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c02462e0>] sock_fasync+0x61/0x116
                          [<c024727f>] sock_close+0x22/0x2f
                          [<c015c78b>] __fput+0xbc/0x172
                          [<c015a256>] filp_close+0x51/0x58
                          [<c0119daf>] put_files_struct+0x5e/0xa6
                          [<c011ae59>] do_exit+0x22e/0x6d9
                          [<c0103cc6>] sysenter_past_esp+0x8f/0x99
                          [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                          [<c011b36f>] sys_exit_group+0x0/0xd
                          [<c0103c96>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    softirq-on-W at:
                          [<c0130a50>] __lock_acquire+0xbba/0xc02
                          [<c0130343>] __lock_acquire+0x4ad/0xc02
                          [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
                          [<c0130b06>] lock_acquire+0x6e/0x87
                          [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                          [<c02a37c2>] _spin_lock+0x29/0x34
                          [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                          [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
                          [<d8be50c0>] ax25_release+0x9d/0x182 [ax25]
                          [<c0246e79>] sock_release+0x14/0x56
                          [<c0247287>] sock_close+0x2a/0x2f
                          [<c015c78b>] __fput+0xbc/0x172
                          [<c015a256>] filp_close+0x51/0x58
                          [<c015b284>] sys_close+0x66/0x9d
                          [<c0103c96>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                          [<c012f448>] mark_lock+0x5b/0x44b
                          [<c013031e>] __lock_acquire+0x488/0xc02
                          [<c0130b06>] lock_acquire+0x6e/0x87
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c02a37fb>] _spin_lock_bh+0x2e/0x39
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c024886b>] lock_sock_nested+0x26/0xcc
                          [<c02462e0>] sock_fasync+0x61/0x116
                          [<c024727f>] sock_close+0x22/0x2f
                          [<c015c78b>] __fput+0xbc/0x172
                          [<c015a256>] filp_close+0x51/0x58
                          [<c0119daf>] put_files_struct+0x5e/0xa6
                          [<c011ae59>] do_exit+0x22e/0x6d9
                          [<c0103cc6>] sysenter_past_esp+0x8f/0x99
                          [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
                          [<c011b36f>] sys_exit_group+0x0/0xd
                          [<c0103c96>] sysenter_past_esp+0x5f/0x99
                          [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c05db598>] af_family_slock_keys+0x18/0x120
 ... acquired at:
   [<c012df48>] add_lock_to_list+0x68/0x8b
   [<c01308ab>] __lock_acquire+0xa15/0xc02
   [<d8be3f06>] ax25_info_show+0x23e/0x2aa [ax25]
   [<c0130b06>] lock_acquire+0x6e/0x87
   [<d8be3f06>] ax25_info_show+0x23e/0x2aa [ax25]
   [<c02a37c2>] _spin_lock+0x29/0x34
   [<d8be3f06>] ax25_info_show+0x23e/0x2aa [ax25]
   [<d8be3f06>] ax25_info_show+0x23e/0x2aa [ax25]
   [<d8be0030>] ax2asc+0x30/0x5a [ax25]
   [<c017182a>] seq_read+0x195/0x277
   [<c0171695>] seq_read+0x0/0x277
   [<c0185922>] proc_reg_read+0x64/0x77
   [<c01858be>] proc_reg_read+0x0/0x77
   [<c015c0d0>] vfs_read+0xa6/0x12e
   [<c015c3fe>] sys_read+0x41/0x67
   [<c0103c96>] sysenter_past_esp+0x5f/0x99
   [<ffffffff>] 0xffffffff


stack backtrace:
 [<c012ec45>] print_irq_inversion_bug+0x10b/0x115
 [<c012f323>] check_usage_backwards+0x3c/0x41
 [<c012f6a5>] mark_lock+0x2b8/0x44b
 [<c0130a50>] __lock_acquire+0xbba/0xc02
 [<c0130343>] __lock_acquire+0x4ad/0xc02
 [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
 [<c0130b06>] lock_acquire+0x6e/0x87
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<c02a37c2>] _spin_lock+0x29/0x34
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be50c0>] ax25_release+0x9d/0x182 [ax25]
 [<c0246e79>] sock_release+0x14/0x56
 [<c0247287>] sock_close+0x2a/0x2f
 [<c015c78b>] __fput+0xbc/0x172
 [<c015a256>] filp_close+0x51/0x58
 [<c015b284>] sys_close+0x66/0x9d
 [<c0103c96>] sysenter_past_esp+0x5f/0x99
 =======================

=================================
[ INFO: inconsistent lock state ]
2.6.23.1 #1
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
ax25_call/4005 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (slock-AF_AX25){-+..}, at: [<d8b79312>] ax25_disconnect+0x46/0xaf [ax25]
{in-softirq-W} state was registered at:
  [<c0130a50>] __lock_acquire+0xbba/0xc02
  [<c01302cc>] __lock_acquire+0x436/0xc02
  [<c0130a50>] __lock_acquire+0xbba/0xc02
  [<c0130b06>] lock_acquire+0x6e/0x87
  [<d8b78f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8b79797>] ax25_heartbeat_expiry+0x0/0x29 [ax25]
  [<c02a37c2>] _spin_lock+0x29/0x34
  [<d8b78f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8b78f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<c011f4db>] run_timer_softirq+0xee/0x14a
  [<c011c506>] __do_softirq+0x31/0x90
  [<c012fa48>] trace_hardirqs_on+0x109/0x148
  [<c011c515>] __do_softirq+0x40/0x90
  [<c011c58c>] do_softirq+0x27/0x3d
  [<c0106768>] do_IRQ+0x58/0x6c
  [<c0104cee>] common_interrupt+0x2e/0x40
  [<d8a9a63f>] acpi_processor_idle+0x262/0x3cf [processor]
  [<c0102342>] cpu_idle+0x3c/0x51
  [<c0382a0c>] start_kernel+0x272/0x277
  [<c0382323>] unknown_bootoption+0x0/0x195
  [<ffffffff>] 0xffffffff
irq event stamp: 1663
hardirqs last  enabled at (1663): [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
hardirqs last disabled at (1661): [<c011c885>] local_bh_enable_ip+0x5b/0xc5
softirqs last  enabled at (1662): [<d8b79300>] ax25_disconnect+0x34/0xaf [ax25]
softirqs last disabled at (1656): [<c02a37d8>] _spin_lock_bh+0xb/0x39

other info that might help us debug this:
no locks held by ax25_call/4005.

stack backtrace:
 [<c012ed8a>] print_usage_bug+0x13b/0x145
 [<c012f662>] mark_lock+0x275/0x44b
 [<c0130a50>] __lock_acquire+0xbba/0xc02
 [<c0130343>] __lock_acquire+0x4ad/0xc02
 [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
 [<c0130b06>] lock_acquire+0x6e/0x87
 [<d8b79312>] ax25_disconnect+0x46/0xaf [ax25]
 [<c02a37c2>] _spin_lock+0x29/0x34
 [<d8b79312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8b79312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8b7b0c0>] ax25_release+0x9d/0x182 [ax25]
 [<c0246e79>] sock_release+0x14/0x56
 [<c0247287>] sock_close+0x2a/0x2f
 [<c015c78b>] __fput+0xbc/0x172
 [<c015a256>] filp_close+0x51/0x58
 [<c0119daf>] put_files_struct+0x5e/0xa6
 [<c011ae59>] do_exit+0x22e/0x6d9
 [<c02a3a6d>] _spin_unlock_irq+0x20/0x23
 [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
 [<c011b36f>] sys_exit_group+0x0/0xd
 [<c0121c1e>] get_signal_to_deliver+0x3c6/0x3ea
 [<c02475c8>] sys_connect+0x82/0xad
 [<c0103475>] do_notify_resume+0x81/0x5fe
 [<c02a3a6d>] _spin_unlock_irq+0x20/0x23
 [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
 [<c02a3a6d>] _spin_unlock_irq+0x20/0x23
 [<c0247e0d>] sys_socketcall+0xac/0x261
 [<c012fa5e>] trace_hardirqs_on+0x11f/0x148
 [<c0103ded>] work_notifysig+0x13/0x26
 =======================

Linux version 2.6.23.1 (root@bernard) (gcc version 4.1.2 20070302 (prerelease) (4.1.2-1mdv2007.1)) #1 Thu Oct 18 21:45:24 CEST 2007

Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 992 kB
 per task-struct memory footprint: 1200 bytes

=================================
[ INFO: inconsistent lock state ]
2.6.23.1 #1
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
flexd/3005 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (slock-AF_AX25){-+..}, at: [<d8be6312>] ax25_disconnect+0x46/0xaf [ax25]
{in-softirq-W} state was registered at:
  [<c0130a50>] __lock_acquire+0xbba/0xc02
  [<c01302cc>] __lock_acquire+0x436/0xc02
  [<c0130a50>] __lock_acquire+0xbba/0xc02
  [<c0130b06>] lock_acquire+0x6e/0x87
  [<d8be5f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8be6797>] ax25_heartbeat_expiry+0x0/0x29 [ax25]
  [<c02a37c2>] _spin_lock+0x29/0x34
  [<d8be5f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8be5f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<c011f4db>] run_timer_softirq+0xee/0x14a
  [<c011c506>] __do_softirq+0x31/0x90
  [<c012fa48>] trace_hardirqs_on+0x109/0x148
  [<c011c515>] __do_softirq+0x40/0x90
  [<c011c58c>] do_softirq+0x27/0x3d
  [<c0106768>] do_IRQ+0x58/0x6c
  [<c0104cee>] common_interrupt+0x2e/0x40
  [<d8a91364>] acpi_safe_halt+0x19/0x25 [processor]
  [<d8a91523>] acpi_processor_idle+0x146/0x3cf [processor]
  [<c0102342>] cpu_idle+0x3c/0x51
  [<c0382a0c>] start_kernel+0x272/0x277
  [<c0382323>] unknown_bootoption+0x0/0x195
  [<ffffffff>] 0xffffffff
irq event stamp: 519
hardirqs last  enabled at (519): [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
hardirqs last disabled at (517): [<c011c885>] local_bh_enable_ip+0x5b/0xc5
softirqs last  enabled at (518): [<d8be6300>] ax25_disconnect+0x34/0xaf [ax25]
softirqs last disabled at (512): [<c02a37d8>] _spin_lock_bh+0xb/0x39

other info that might help us debug this:
no locks held by flexd/3005.

stack backtrace:
 [<c012ed8a>] print_usage_bug+0x13b/0x145
 [<c012f662>] mark_lock+0x275/0x44b
 [<c0130a50>] __lock_acquire+0xbba/0xc02
 [<c0130343>] __lock_acquire+0x4ad/0xc02
 [<c011c8e7>] local_bh_enable_ip+0xbd/0xc5
 [<c0130b06>] lock_acquire+0x6e/0x87
 [<d8be6312>] ax25_disconnect+0x46/0xaf [ax25]
 [<c02a37c2>] _spin_lock+0x29/0x34
 [<d8be6312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be6312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be80c0>] ax25_release+0x9d/0x182 [ax25]
 [<c0246e79>] sock_release+0x14/0x56
 [<c0247287>] sock_close+0x2a/0x2f
 [<c015c78b>] __fput+0xbc/0x172
 [<c015a256>] filp_close+0x51/0x58
 [<c015b284>] sys_close+0x66/0x9d
 [<c0103c96>] sysenter_past_esp+0x5f/0x99
 =======================

Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
... MAX_LOCKDEP_SUBCLASSES:    8
... MAX_LOCK_DEPTH:          30
... MAX_LOCKDEP_KEYS:        2048
... CLASSHASH_SIZE:           1024
... MAX_LOCKDEP_ENTRIES:     8192
... MAX_LOCKDEP_CHAINS:      16384
... CHAINHASH_SIZE:          8192
 memory used by lock dependency info: 992 kB
 per task-struct memory footprint: 1200 bytes

=================================
[ INFO: inconsistent lock state ]
2.6.23.8 #2
---------------------------------
inconsistent {in-softirq-W} -> {softirq-on-W} usage.
flexd/4679 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (slock-AF_AX25){-+..}, at: [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
{in-softirq-W} state was registered at:
  [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
  [<c01302c6>] __lock_acquire+0x418/0xbe6
  [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
  [<c0130b02>] lock_acquire+0x6e/0x87
  [<d8be2f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8be3797>] ax25_heartbeat_expiry+0x0/0x29 [ax25]
  [<c02a3922>] _spin_lock+0x29/0x34
  [<d8be2f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<d8be2f62>] ax25_std_heartbeat_expiry+0x19/0xd3 [ax25]
  [<c011f4f3>] run_timer_softirq+0xee/0x14a
  [<c011c51e>] __do_softirq+0x31/0x90
  [<c012fa60>] trace_hardirqs_on+0x109/0x148
  [<c011c52d>] __do_softirq+0x40/0x90
  [<c011c5a4>] do_softirq+0x27/0x3d
  [<c0106768>] do_IRQ+0x58/0x6c
  [<c0104cee>] common_interrupt+0x2e/0x40
  [<d8a9963f>] acpi_processor_idle+0x262/0x3cf [processor]
  [<c0102342>] cpu_idle+0x3c/0x51
  [<c0382a0c>] start_kernel+0x272/0x277
  [<c0382323>] unknown_bootoption+0x0/0x195
  [<ffffffff>] 0xffffffff
irq event stamp: 601
hardirqs last  enabled at (601): [<c011c8ff>] local_bh_enable_ip+0xbd/0xc5
hardirqs last disabled at (599): [<c011c89d>] local_bh_enable_ip+0x5b/0xc5
softirqs last  enabled at (600): [<d8be3300>] ax25_disconnect+0x34/0xaf [ax25]
softirqs last disabled at (594): [<c02a3938>] _spin_lock_bh+0xb/0x39

other info that might help us debug this:
no locks held by flexd/4679.

stack backtrace:
 [<c012eda2>] print_usage_bug+0x13b/0x145
 [<c012f67a>] mark_lock+0x275/0x44b
 [<c0130a4c>] __lock_acquire+0xb9e/0xbe6
 [<c013032d>] __lock_acquire+0x47f/0xbe6
 [<c012f889>] mark_held_locks+0x39/0x53
 [<c011c8ff>] local_bh_enable_ip+0xbd/0xc5
 [<c0130b02>] lock_acquire+0x6e/0x87
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<c02a3922>] _spin_lock+0x29/0x34
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be3312>] ax25_disconnect+0x46/0xaf [ax25]
 [<d8be50c0>] ax25_release+0x9d/0x182 [ax25]
 [<c0246f15>] sock_release+0x14/0x56
 [<c0247327>] sock_close+0x2a/0x2f
 [<c015c7ab>] __fput+0xbc/0x172
 [<c015a27a>] filp_close+0x51/0x58
 [<c015b2a8>] sys_close+0x66/0x9d
 [<c0103c96>] sysenter_past_esp+0x5f/0x99
 =======================


--------------050601050908080509090703--
