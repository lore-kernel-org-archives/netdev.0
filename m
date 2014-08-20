From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: 3.17-rc1 oops during network interface configuration
Date: Wed, 20 Aug 2014 13:31:51 +0300
Message-ID: <53F47917.8080003@mellanox.com>
References: <53F1EF18.7010909@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Saeed Mahameed" <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53F1EF18.7010909-HInyCGIudOg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18/08/2014 15:18, Bart Van Assche wrote:
> Has anyone else already tried to boot kernel 3.17-rc1 on an IB system ? The
> following call trace is triggered during boot on a system on which kernel
> 3.16 runs fine:

Yep, I see it on my systems too.

I narrowed this down a bit to happen only when the port link type (these 
nodes have ConnectX) is IB and IPoIB gets to load.

I reverted (below) all the IPoIB changes since 3.16 (except for the 
trivial commit c835a67) and the crash still exists.

I guess this needs to go through systematic bisection.

Or.

> net.git]# git log --oneline --no-merges v3.16.. drivers/infiniband/ulp/ipoib/
> 8a118a4 Revert "IB/ipoib: Use P_Key change event instead of P_Key polling mechanism"
> 90e6f39 Revert "IB/ipoib: Avoid flushing the workqueue from worker context"
> 030ade7 Revert "IB/ipoib: Avoid multicast join attempts with invalid P_key"
> 97ba2ff Revert "IPoIB: Remove unnecessary test for NULL before debugfs_remove()"
> e42fa20 IPoIB: Remove unnecessary test for NULL before debugfs_remove()
> dd57c93 IB/ipoib: Avoid multicast join attempts with invalid P_key
> 4eae374 IB/ipoib: Avoid flushing the workqueue from worker context
> db84f88 IB/ipoib: Use P_Key change event instead of P_Key polling mechanism
> c835a67 net: set name_assign_type in alloc_netdev()


> BUG: unable to handle kernel paging request at ffff88090000007e
> IP: __dev_queue_xmit+0x519
> Call Trace:
> ? __dev_queue_xmit+0x49
> dev_queue_xmit+0x10
> neigh_connected_output
> ? ip_finish_output
> ip_finish_output
> ? ip_finish_output
> ? netif_rx_ni
> ip_mc_output
> ip_local_out_sk
> ip_send_skb
> udp_send_skb
> udp_sendmsg
> ? ip_reply_glue_bits
> ? __lock_is_held
> inet_sendmsg
> ? inet_sendmsg
> sock_sendmsg
> ? might_fault
> ? might_fault
> ? move_addr_to_kernel.part.38
> SYSC_sendto
> ? sysret_check
> ? trace_hardirqs_on_caller
> ? trace_hardirqs_on_thunk
> SyS_sendto
> system_call_fastpath
>
> Kernel panic - not syncing: Fatal exception in interrupt
> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)
> drm_kms_helper: panic occurred, switching back to text console
>
> A screenshot of this kernel oops can be found here:
> https://drive.google.com/file/d/0B1YQOreL3_FxVDB5UTNwekF6LVU/
>
> gdb translates the crash address into the following (not sure this makes sense
> since offset 0x519 is past the end of __dev_queue_xmit()):
>
> (gdb) list *(__dev_queue_xmit+0x519)
> 0xffffffff8136bc89 is in netdev_adjacent_rename_links (net/core/dev.c:5167).
> 5162    void netdev_adjacent_rename_links(struct net_device *dev, char *oldname)
> 5163    {
> 5164            struct netdev_adjacent *iter;
> 5165
> 5166            list_for_each_entry(iter, &dev->adj_list.upper, list) {
> 5167                    netdev_adjacent_sysfs_del(iter->dev, oldname,
> 5168                                              &iter->dev->adj_list.lower);
> 5169                    netdev_adjacent_sysfs_add(iter->dev, dev,
> 5170                                              &iter->dev->adj_list.lower);
> 5171            }
>
> And the address __dev_queue_xmit+0x49 is translated by gdb into:
>
> (gdb) list *(__dev_queue_xmit+0x49)
> 0xffffffff8136b7b9 is in __dev_queue_xmit (./arch/x86/include/asm/preempt.h:75).
> 70       * The various preempt_count add/sub methods
> 71       */
> 72
> 73      static __always_inline void __preempt_count_add(int val)
> 74      {
> 75              raw_cpu_add_4(__preempt_count, val);
> 76      }
> 77
> 78      static __always_inline void __preempt_count_sub(int val)
> 79      {

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
