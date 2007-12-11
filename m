From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH] [NET]: Fix Ooops of napi net_rx_action.
Date: Tue, 11 Dec 2007 18:13:34 +0900
Message-ID: <001801c83bd6$2001d410$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752257AbXLKJOl@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Fix Ooops of napi net_rx_action.
Before doing list_move_tail napi poll_list, it should be ensured

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
diff --git a/net/core/dev.c b/net/core/dev.c
index 86d6261..74bd5ab 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2207,7 +2207,8 @@ static void net_rx_action(struct softirq_action *h)
 		 * still "owns" the NAPI instance and therefore can
 		 * move the instance around on the list at-will.
 		 */
-		if (unlikely(work == weight))
+		if (unlikely((test_bit(NAPI_STATE_SCHED, &n->state))
+				&& (work == weight)))
 			list_move_tail(&n->poll_list, list);
 
 		netpoll_poll_unlock(have);
---

I was able to make it real oops on 2.6.24-rc4 + e1000 napi + smp.
eth0 of my laptop is connected directly to a packet generator.
The packet generator is making unicast udp packets to laptop (approximately 70000pps).
At that time, if the interface is went down, Ooops occurred.

Thanks.
Joonwoo


root@joonwpark-laptop:~# ifconfig eth0 down
BUG: unable to handle kernel paging request at virtual address 00100104
printing eip: c42ecc35 *pdpt = 000000001fc89001 *pde = 0000000000000000
Ooops: 0002 [#1] SMP
Modules linked in:

Pid: 4, comm:ksoftirqd/0 Not tainted (2.6.24-rc4 #27)
EIP: 0060:[<c42ecc35>] EFLAGS: 00010046 CPU: 0
EIP is at net_rx_action+0x1d5/0x1f0
EAX: 00100100 EBX: f77c965c ECX: 00000000 EDX: 00200200
ESI: 00000040 EDI: f77c965c EBP: f7c6df94 ESP: f7c6df64
 DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
 Process ksoftirqd/0 (pid: 4, ti=f7c6c000 task=f7c68ab0 task.ti=f7c6c000)
Stack: 00000002 00000001 c42ecabe c4598f40 c1d0f5cc 0000c7da 000000ac f77c965c
       00000040 00000001 c4543b18 c4598f40 f7c6dfb0 c4032a07 00000004 00000000
       00000246 00000000 c4032f60 f7c6dfbc c4032ad7 c459ba80 f6c6dfcc c4032fb9
Call Trace:
 [<c40053ca>] show_trace_log_lvl+0x1a/0x30
 [<c4005489>] show_stack_log_lvl+0xa9/0xd0
 [<c400557a>] show_registers+0xca/0x1c0
 [<c4005785>] die+0x115/0x230
 [<c4020f0c>] do_page_fault+0x34c/0x7f0
 [<c43c9cea>] error_code+0x72/0x78
 [<c4032a07>] __do_softirq+0x87/0x60
 [<c4032ad7>] do_softirq+0x57/0xe0
 [<c4041ee2>] kthread+0x42/0x70
 [<c4004fc3>] kernel_thread_helper+0x7/0x14
 
gdb outputs
(gdb)  info line *net_rx_action+0x1d5
Line 157 of "include/linux/list.h"
   starts at address 0xc42ecc35 <net_rx_action+469>
   and ends at 0xc42ecc38 <net_rx_action+472>.
(gdb) l include/linux/list.h:157
152      * This is only for internal list manipulation where we know
153      * the prev/next entries already!
154      */
155     static inline void __list_del(struct list_head * prev, struct list_head * next)
156     {
157             next->prev = prev;
158             prev->next = next;
159     }
160
161     /**
(gdb) info line *__do_softirq+0x87
Line 130 of "include/linux/rcupdate.h"
   starts at address 0xc4032a07 <__do_softirq+135>
   and ends at 0xc4032a0a <__do_softirq+138>.
(gdb) l include/linux/rcupdate.h:130
125             struct rcu_data *rdp = &per_cpu(rcu_data, cpu);
126             rdp->passed_quiesc = 1;
127     }
128     static inline void rcu_bh_qsctr_inc(int cpu)
129     {
130             struct rcu_data *rdp = &per_cpu(rcu_bh_data, cpu);
131             rdp->passed_quiesc = 1;
132     }
133
134     extern int rcu_pending(int cpu);
(gdb) info line *do_softirq+0x57
Line 269 of "kernel/softirq.c" starts at address 0xc4032ad2 <do_softirq+82>
   and ends at 0xc4032ae0 <tasklet_kill>.
(gdb) l kernel/softirq.c:269
264             local_irq_save(flags);
265
266             pending = local_softirq_pending();
267
268             if (pending)
269                     __do_softirq();
270
271             local_irq_restore(flags);
272     }
273

