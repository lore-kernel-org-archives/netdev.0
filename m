From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.34-rc1] CPU stalls when closing TCP sockets.
Date: Tue, 09 Mar 2010 12:19:06 +0900
Message-ID: <201003090319.o293J6WF026448@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Below program sometimes triggers CPU stall at (8).

----- test program -----
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>

int main(int argc, char *argv[])
{
	struct sockaddr_in saddr = { };
	struct sockaddr_in caddr = { };
	socklen_t size = sizeof(saddr);
	int fd1 = socket(PF_INET, SOCK_STREAM, 0);
	int fd2 = socket(PF_INET, SOCK_STREAM, 0);
	int fd3 = EOF;
	saddr.sin_family = AF_INET;
	saddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	saddr.sin_port = htons(0);
	fprintf(stderr, "(1) Binding TCP 127.0.0.1 0 = ");
	fprintf(stderr, "%d\n", bind(fd1, (struct sockaddr *) &saddr,
				     sizeof(saddr)));
	fprintf(stderr, "(2) Getting server name = ");
	fprintf(stderr, "%d\n", getsockname(fd1, (struct sockaddr *) &saddr,
					    &size));
	fprintf(stderr, "(3) Listening TCP 127.0.0.1 %d = ",
		ntohs(saddr.sin_port));
	fprintf(stderr, "%d\n", listen(fd1, 5));
	fprintf(stderr, "(4) Connecting TCP 127.0.0.1 %d = ",
		ntohs(saddr.sin_port));
	fprintf(stderr, "%d\n", connect(fd2, (struct sockaddr *) &saddr,
					sizeof(saddr)));
	fprintf(stderr, "(5) Getting client name = ");
	fprintf(stderr, "%d\n", getsockname(fd2, (struct sockaddr *) &caddr,
					    &size));
	fprintf(stderr, "(6) Accepting TCP 127.0.0.1 %d = ",
		ntohs(caddr.sin_port));
	fd3 = accept(fd1, (struct sockaddr *) &caddr, &size);
	fprintf(stderr, "%d\n", fd3);
	fprintf(stderr, "(7) Closing %d = ", fd3);
	fprintf(stderr, "%d\n", close(fd3));
	fprintf(stderr, "(8) Closing %d = ", fd2);
	fprintf(stderr, "%d\n", close(fd2));
	fprintf(stderr, "(9) Closing %d = ", fd1);
	fprintf(stderr, "%d\n", close(fd1));
	return 0;
}
----- test program -----

[   59.024080] INFO: RCU detected CPU 0 stall (t=2500 jiffies)
[   59.024080] sending NMI to all CPUs:
[   59.024080] NMI backtrace for cpu 0
[   59.024080] Modules linked in: ipv6 pcnet32
[   59.024080] 
[   59.024080] Pid: 2720, comm: a.out Not tainted 2.6.34-rc1 #2 440BX Desktop Reference Platform/VMware Virtual Platform
[   59.024080] EIP: 0060:[<c101e719>] EFLAGS: 00000046 CPU: 0
[   59.024080] EIP is at default_send_IPI_mask_logical+0xa9/0x140
[   59.024080] EAX: fffff000 EBX: 01000000 ECX: 00000000 EDX: 00000c00
[   59.024080] ESI: 00000c00 EDI: 00000046 EBP: c2400efc ESP: c2400ee0
[   59.024080]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   59.024080] Process a.out (pid: 2720, ti=c2400000 task=debb60e0 task.ti=df324000)
[   59.024080] Stack:
[   59.024080]  0000000d be1bfc96 0000000d 00000002 00000000 c1464980 c1464980 c2400f08
[   59.024080] <0> c101e8d1 00000000 c2400f18 c101f1d7 c13c1569 c1464980 c2400f34 c108d637
[   59.024080] <0> c13d8620 00000000 000009c4 00000000 c1464980 c2400f44 c108d6b8 c2545b00
[   59.024080] Call Trace:
[   59.024080]  [<c101e8d1>] ? default_send_IPI_all+0x81/0x90
[   59.024080]  [<c101f1d7>] ? arch_trigger_all_cpu_backtrace+0x37/0x60
[   59.024080]  [<c108d637>] ? print_cpu_stall+0x47/0x90
[   59.024080]  [<c108d6b8>] ? check_cpu_stall+0x38/0x60
[   59.024080]  [<c108e665>] ? __rcu_pending+0x25/0xb0
[   59.024080]  [<c108e71e>] ? rcu_pending+0x2e/0x70
[   59.024080]  [<c108e04b>] ? rcu_check_callbacks+0x1b/0xb0
[   59.024080]  [<c1053b6d>] ? update_process_times+0x3d/0x70
[   59.024080]  [<c106ed1a>] ? tick_periodic+0x2a/0x80
[   59.024080]  [<c106ed8e>] ? tick_handle_periodic+0x1e/0x80
[   59.024080]  [<c1005e83>] ? timer_interrupt+0x23/0x50
[   59.024080]  [<c108a125>] ? handle_IRQ_event+0x45/0x130
[   59.024080]  [<c108c098>] ? handle_level_irq+0x88/0x100
[   59.024080]  [<c108c010>] ? handle_level_irq+0x0/0x100
[   59.024080]  <IRQ> 
[   59.024080]  [<c12e969a>] ? do_IRQ+0x4a/0xc0
[   59.024080]  [<c100324e>] ? common_interrupt+0x2e/0x34
[   59.024080]  [<c12a3c84>] ? tcp_v4_rcv+0x154/0x670
[   59.024080]  [<c12873ab>] ? ip_local_deliver_finish+0xcb/0x1b0
[   59.024080]  [<c1287316>] ? ip_local_deliver_finish+0x36/0x1b0
[   59.024080]  [<c12874c5>] ? ip_local_deliver+0x35/0x40
[   59.024080]  [<c12875db>] ? ip_rcv_finish+0x10b/0x2d0
[   59.024080]  [<c1287906>] ? ip_rcv+0x166/0x240
[   59.024080]  [<c1269d83>] ? netif_receive_skb+0x273/0x300
[   59.024080]  [<c1269c1d>] ? netif_receive_skb+0x10d/0x300
[   59.024080]  [<c1074f06>] ? trace_hardirqs_on_caller+0xa6/0x160
[   59.024080]  [<c126a6d2>] ? process_backlog+0x82/0xb0
[   59.024080]  [<c126aa0f>] ? net_rx_action+0x11f/0x190
[   59.024080]  [<c104acd0>] ? __do_softirq+0x50/0x1c0
[   59.024080]  [<c104ad2b>] ? __do_softirq+0xab/0x1c0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ac80>] ? __do_softirq+0x0/0x1c0
[   59.024080]  <IRQ> 
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ab6e>] ? local_bh_enable+0x8e/0xd0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c126950e>] ? dev_queue_xmit+0xee/0x370
[   59.024080]  [<c1289f7f>] ? ip_finish_output+0x10f/0x270
[   59.024080]  [<c128a271>] ? ip_output+0x51/0x60
[   59.024080]  [<c1289c5d>] ? ip_local_out+0x1d/0x20
[   59.024080]  [<c128a48f>] ? ip_queue_xmit+0x20f/0x3e0
[   59.024080]  [<c1066dd5>] ? sched_clock_local+0x15/0x170
[   59.024080]  [<c10272f6>] ? __change_page_attr+0x106/0x1b0
[   59.024080]  [<c10274df>] ? __change_page_attr_set_clr+0x2f/0x70
[   59.024080]  [<c12a2a82>] ? tcp_v4_send_check+0x52/0xe0
[   59.024080]  [<c129df10>] ? tcp_transmit_skb+0x2d0/0x420
[   59.024080]  [<c10db72a>] ? poison_obj+0x2a/0x50
[   59.024080]  [<c10ddc15>] ? __kmalloc_track_caller+0x185/0x1e0
[   59.024080]  [<c129f3af>] ? tcp_write_xmit+0x13f/0x290
[   59.024080]  [<c129f536>] ? __tcp_push_pending_frames+0x36/0xf0
[   59.024080]  [<c12a0044>] ? tcp_send_fin+0x54/0xc0
[   59.024080]  [<c12938b4>] ? tcp_close+0x2f4/0x370
[   59.024080]  [<c107509b>] ? trace_hardirqs_off+0xb/0x10
[   59.024080]  [<c12b15fe>] ? inet_release+0x4e/0x60
[   59.024080]  [<c12598d6>] ? sock_release+0x66/0x80
[   59.024080]  [<c125a677>] ? sock_close+0x17/0x30
[   59.024080]  [<c10e3dee>] ? __fput+0x16e/0x1b0
[   59.024080]  [<c10e3bee>] ? fput+0x1e/0x20
[   59.024080]  [<c10e23ff>] ? filp_close+0x3f/0x70
[   59.024080]  [<c10e2498>] ? sys_close+0x68/0xb0
[   59.024080]  [<c12e8de1>] ? syscall_call+0x7/0xb
[   59.024080] Code: f6 c4 10 75 ed c1 e3 18 89 9a 10 c3 ff ff 8b 55 f0 a1 8c 01 46 c1 09 f2 81 ce 00 04 00 00 83 7d f0 02 0f 44 d6 89 90 00 c3 ff ff <89> f8 c1 e8 09 83 f0 01 a8 01 74 0f 57 9d e8 64 69 05 00 83 c4 
[   59.024080] Call Trace:
[   59.024080]  [<c101e8d1>] default_send_IPI_all+0x81/0x90
[   59.024080]  [<c101f1d7>] arch_trigger_all_cpu_backtrace+0x37/0x60
[   59.024080]  [<c108d637>] print_cpu_stall+0x47/0x90
[   59.024080]  [<c108d6b8>] check_cpu_stall+0x38/0x60
[   59.024080]  [<c108e665>] __rcu_pending+0x25/0xb0
[   59.024080]  [<c108e71e>] rcu_pending+0x2e/0x70
[   59.024080]  [<c108e04b>] rcu_check_callbacks+0x1b/0xb0
[   59.024080]  [<c1053b6d>] update_process_times+0x3d/0x70
[   59.024080]  [<c106ed1a>] tick_periodic+0x2a/0x80
[   59.024080]  [<c106ed8e>] tick_handle_periodic+0x1e/0x80
[   59.024080]  [<c1005e83>] timer_interrupt+0x23/0x50
[   59.024080]  [<c108a125>] handle_IRQ_event+0x45/0x130
[   59.024080]  [<c108c098>] handle_level_irq+0x88/0x100
[   59.024080]  [<c108c010>] ? handle_level_irq+0x0/0x100
[   59.024080]  <IRQ>  [<c12e969a>] ? do_IRQ+0x4a/0xc0
[   59.024080]  [<c100324e>] ? common_interrupt+0x2e/0x34
[   59.024080]  [<c12a3c84>] ? tcp_v4_rcv+0x154/0x670
[   59.024080]  [<c12873ab>] ? ip_local_deliver_finish+0xcb/0x1b0
[   59.024080]  [<c1287316>] ? ip_local_deliver_finish+0x36/0x1b0
[   59.024080]  [<c12874c5>] ? ip_local_deliver+0x35/0x40
[   59.024080]  [<c12875db>] ? ip_rcv_finish+0x10b/0x2d0
[   59.024080]  [<c1287906>] ? ip_rcv+0x166/0x240
[   59.024080]  [<c1269d83>] ? netif_receive_skb+0x273/0x300
[   59.024080]  [<c1269c1d>] ? netif_receive_skb+0x10d/0x300
[   59.024080]  [<c1074f06>] ? trace_hardirqs_on_caller+0xa6/0x160
[   59.024080]  [<c126a6d2>] ? process_backlog+0x82/0xb0
[   59.024080]  [<c126aa0f>] ? net_rx_action+0x11f/0x190
[   59.024080]  [<c104acd0>] ? __do_softirq+0x50/0x1c0
[   59.024080]  [<c104ad2b>] ? __do_softirq+0xab/0x1c0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ac80>] ? __do_softirq+0x0/0x1c0
[   59.024080]  <IRQ>  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ab6e>] ? local_bh_enable+0x8e/0xd0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c126950e>] ? dev_queue_xmit+0xee/0x370
[   59.024080]  [<c1289f7f>] ? ip_finish_output+0x10f/0x270
[   59.024080]  [<c128a271>] ? ip_output+0x51/0x60
[   59.024080]  [<c1289c5d>] ? ip_local_out+0x1d/0x20
[   59.024080]  [<c128a48f>] ? ip_queue_xmit+0x20f/0x3e0
[   59.024080]  [<c1066dd5>] ? sched_clock_local+0x15/0x170
[   59.024080]  [<c10272f6>] ? __change_page_attr+0x106/0x1b0
[   59.024080]  [<c10274df>] ? __change_page_attr_set_clr+0x2f/0x70
[   59.024080]  [<c12a2a82>] ? tcp_v4_send_check+0x52/0xe0
[   59.024080]  [<c129df10>] ? tcp_transmit_skb+0x2d0/0x420
[   59.024080]  [<c10db72a>] ? poison_obj+0x2a/0x50
[   59.024080]  [<c10ddc15>] ? __kmalloc_track_caller+0x185/0x1e0
[   59.024080]  [<c129f3af>] ? tcp_write_xmit+0x13f/0x290
[   59.024080]  [<c129f536>] ? __tcp_push_pending_frames+0x36/0xf0
[   59.024080]  [<c12a0044>] ? tcp_send_fin+0x54/0xc0
[   59.024080]  [<c12938b4>] ? tcp_close+0x2f4/0x370
[   59.024080]  [<c107509b>] ? trace_hardirqs_off+0xb/0x10
[   59.024080]  [<c12b15fe>] ? inet_release+0x4e/0x60
[   59.024080]  [<c12598d6>] ? sock_release+0x66/0x80
[   59.024080]  [<c125a677>] ? sock_close+0x17/0x30
[   59.024080]  [<c10e3dee>] ? __fput+0x16e/0x1b0
[   59.024080]  [<c10e3bee>] ? fput+0x1e/0x20
[   59.024080]  [<c10e23ff>] ? filp_close+0x3f/0x70
[   59.024080]  [<c10e2498>] ? sys_close+0x68/0xb0
[   59.024080]  [<c12e8de1>] ? syscall_call+0x7/0xb
[   59.024080] Pid: 2720, comm: a.out Not tainted 2.6.34-rc1 #2
[   59.024080] Call Trace:
[   59.024080]  [<c100a997>] ? show_regs+0x27/0x30
[   59.024080]  [<c101ef39>] nmi_watchdog_tick+0x189/0x240
[   59.024080]  [<c1003bdf>] default_do_nmi+0x5f/0x180
[   59.024080]  [<c1003d89>] do_nmi+0x89/0xa0
[   59.024080]  [<c12e9541>] nmi_stack_correct+0x28/0x2d
[   59.024080]  [<c101e719>] ? default_send_IPI_mask_logical+0xa9/0x140
[   59.024080]  [<c101e8d1>] default_send_IPI_all+0x81/0x90
[   59.024080]  [<c101f1d7>] arch_trigger_all_cpu_backtrace+0x37/0x60
[   59.024080]  [<c108d637>] print_cpu_stall+0x47/0x90
[   59.024080]  [<c108d6b8>] check_cpu_stall+0x38/0x60
[   59.024080]  [<c108e665>] __rcu_pending+0x25/0xb0
[   59.024080]  [<c108e71e>] rcu_pending+0x2e/0x70
[   59.024080]  [<c108e04b>] rcu_check_callbacks+0x1b/0xb0
[   59.024080]  [<c1053b6d>] update_process_times+0x3d/0x70
[   59.024080]  [<c106ed1a>] tick_periodic+0x2a/0x80
[   59.024080]  [<c106ed8e>] tick_handle_periodic+0x1e/0x80
[   59.024080]  [<c1005e83>] timer_interrupt+0x23/0x50
[   59.024080]  [<c108a125>] handle_IRQ_event+0x45/0x130
[   59.024080]  [<c108c098>] handle_level_irq+0x88/0x100
[   59.024080]  [<c108c010>] ? handle_level_irq+0x0/0x100
[   59.024080]  <IRQ>  [<c12e969a>] ? do_IRQ+0x4a/0xc0
[   59.024080]  [<c100324e>] ? common_interrupt+0x2e/0x34
[   59.024080]  [<c12a3c84>] ? tcp_v4_rcv+0x154/0x670
[   59.024080]  [<c12873ab>] ? ip_local_deliver_finish+0xcb/0x1b0
[   59.024080]  [<c1287316>] ? ip_local_deliver_finish+0x36/0x1b0
[   59.024080]  [<c12874c5>] ? ip_local_deliver+0x35/0x40
[   59.024080]  [<c12875db>] ? ip_rcv_finish+0x10b/0x2d0
[   59.024080]  [<c1287906>] ? ip_rcv+0x166/0x240
[   59.024080]  [<c1269d83>] ? netif_receive_skb+0x273/0x300
[   59.024080]  [<c1269c1d>] ? netif_receive_skb+0x10d/0x300
[   59.024080]  [<c1074f06>] ? trace_hardirqs_on_caller+0xa6/0x160
[   59.024080]  [<c126a6d2>] ? process_backlog+0x82/0xb0
[   59.024080]  [<c126aa0f>] ? net_rx_action+0x11f/0x190
[   59.024080]  [<c104acd0>] ? __do_softirq+0x50/0x1c0
[   59.024080]  [<c104ad2b>] ? __do_softirq+0xab/0x1c0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ac80>] ? __do_softirq+0x0/0x1c0
[   59.024080]  <IRQ>  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c104ab6e>] ? local_bh_enable+0x8e/0xd0
[   59.024080]  [<c1269629>] ? dev_queue_xmit+0x209/0x370
[   59.024080]  [<c126950e>] ? dev_queue_xmit+0xee/0x370
[   59.024080]  [<c1289f7f>] ? ip_finish_output+0x10f/0x270
[   59.024080]  [<c128a271>] ? ip_output+0x51/0x60
[   59.024080]  [<c1289c5d>] ? ip_local_out+0x1d/0x20
[   59.024080]  [<c128a48f>] ? ip_queue_xmit+0x20f/0x3e0
[   59.024080]  [<c1066dd5>] ? sched_clock_local+0x15/0x170
[   59.024080]  [<c10272f6>] ? __change_page_attr+0x106/0x1b0
[   59.024080]  [<c10274df>] ? __change_page_attr_set_clr+0x2f/0x70
[   59.024080]  [<c12a2a82>] ? tcp_v4_send_check+0x52/0xe0
[   59.024080]  [<c129df10>] ? tcp_transmit_skb+0x2d0/0x420
[   59.024080]  [<c10db72a>] ? poison_obj+0x2a/0x50
[   59.024080]  [<c10ddc15>] ? __kmalloc_track_caller+0x185/0x1e0
[   59.024080]  [<c129f3af>] ? tcp_write_xmit+0x13f/0x290
[   59.024080]  [<c129f536>] ? __tcp_push_pending_frames+0x36/0xf0
[   59.024080]  [<c12a0044>] ? tcp_send_fin+0x54/0xc0
[   59.024080]  [<c12938b4>] ? tcp_close+0x2f4/0x370
[   59.024080]  [<c107509b>] ? trace_hardirqs_off+0xb/0x10
[   59.024080]  [<c12b15fe>] ? inet_release+0x4e/0x60
[   59.024080]  [<c12598d6>] ? sock_release+0x66/0x80
[   59.024080]  [<c125a677>] ? sock_close+0x17/0x30
[   59.024080]  [<c10e3dee>] ? __fput+0x16e/0x1b0
[   59.024080]  [<c10e3bee>] ? fput+0x1e/0x20
[   59.024080]  [<c10e23ff>] ? filp_close+0x3f/0x70
[   59.024080]  [<c10e2498>] ? sys_close+0x68/0xb0
[   59.024080]  [<c12e8de1>] ? syscall_call+0x7/0xb

Full log is at http://I-love.SAKURA.ne.jp/tmp/dmesg-2.6.34-rc1.txt
Config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.34-rc1

Regards.
