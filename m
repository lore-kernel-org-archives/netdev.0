From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: 3.17-rc1 oops during network interface configuration
Date: Mon, 18 Aug 2014 14:18:32 +0200
Message-ID: <53F1EF18.7010909@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

Has anyone else already tried to boot kernel 3.17-rc1 on an IB system ? The
following call trace is triggered during boot on a system on which kernel
3.16 runs fine:

BUG: unable to handle kernel paging request at ffff88090000007e
IP: __dev_queue_xmit+0x519
Call Trace:
? __dev_queue_xmit+0x49
dev_queue_xmit+0x10
neigh_connected_output
? ip_finish_output
ip_finish_output
? ip_finish_output
? netif_rx_ni
ip_mc_output
ip_local_out_sk
ip_send_skb
udp_send_skb
udp_sendmsg
? ip_reply_glue_bits
? __lock_is_held
inet_sendmsg
? inet_sendmsg
sock_sendmsg
? might_fault
? might_fault
? move_addr_to_kernel.part.38
SYSC_sendto
? sysret_check
? trace_hardirqs_on_caller
? trace_hardirqs_on_thunk
SyS_sendto
system_call_fastpath

Kernel panic - not syncing: Fatal exception in interrupt
Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
drm_kms_helper: panic occurred, switching back to text console

A screenshot of this kernel oops can be found here:
https://drive.google.com/file/d/0B1YQOreL3_FxVDB5UTNwekF6LVU/

gdb translates the crash address into the following (not sure this makes sense
since offset 0x519 is past the end of __dev_queue_xmit()):

(gdb) list *(__dev_queue_xmit+0x519) 
0xffffffff8136bc89 is in netdev_adjacent_rename_links (net/core/dev.c:5167).
5162    void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
5163    {
5164            struct netdev_adjacent *iter;
5165
5166            list_for_each_entry(iter, &dev->adj_list.upper, list) {
5167                    netdev_adjacent_sysfs_del(iter->dev, oldname,
5168                                              &iter->dev->adj_list.lower);
5169                    netdev_adjacent_sysfs_add(iter->dev, dev,
5170                                              &iter->dev->adj_list.lower);
5171            }

And the address __dev_queue_xmit+0x49 is translated by gdb into:

(gdb) list *(__dev_queue_xmit+0x49)
0xffffffff8136b7b9 is in __dev_queue_xmit (./arch/x86/include/asm/preempt.h:75).
70       * The various preempt_count add/sub methods
71       */
72
73      static __always_inline void __preempt_count_add(int val)
74      {
75              raw_cpu_add_4(__preempt_count, val);
76      }
77
78      static __always_inline void __preempt_count_sub(int val)
79      {

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
