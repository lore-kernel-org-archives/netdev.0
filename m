From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Kernel WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Date: Tue, 22 Jul 2008 11:39:39 -0500
Message-ID: <48860D4B.8070003@lwfinger.net>
References: <4885104A.2070201@lwfinger.net>	<20080721.161517.27161039.davem@davemloft.net>	<48857F74.2040406@lwfinger.net> <20080722.043220.247312412.davem@davemloft.net> <4885DA49.50703@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4885DA49.50703-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David and Patrick,

Here is the latest on this problem.

I pulled from Linus's tree this morning and now have git-05752-g93ded9b. The 
kernel WARNING from __netif_schedule and the lockdep warning are present with or 
without the patches from yesterday.

As I stated earlier, the kernel WARNING (it was a BUG then) was introduced in 
commit 37437bb2 when the BUG statement was entered.

The lockdep warning started with the next commit (16361127).

I am not using any network traffic shaping. Is it correct that the faulty 
condition is not that q == &noop_qdisc, but that __netif_schedule was called 
when that condition exists?


The lockdep warning is:

=============================================
[ INFO: possible recursive locking detected ]
2.6.26-Linus-git-05752-g93ded9b #49
---------------------------------------------
NetworkManager/2611 is trying to acquire lock:
  (&dev->addr_list_lock){-...}, at: [<ffffffff803a2ad1>] dev_mc_sync+0x19/0x57

but task is already holding lock:
  (&dev->addr_list_lock){-...}, at: [<ffffffff8039e909>] dev_set_rx_mode+0x19/0x2e

other info that might help us debug this:
2 locks held by NetworkManager/2611:
  #0:  (rtnl_mutex){--..}, at: [<ffffffff803a8488>] rtnetlink_rcv+0x12/0x27
  #1:  (&dev->addr_list_lock){-...}, at: [<ffffffff8039e909>] 
dev_set_rx_mode+0x19/0x2e

stack backtrace:
Pid: 2611, comm: NetworkManager Not tainted 2.6.26-Linus-git-05752-g93ded9b #49

Call Trace:
  [<ffffffff80251b02>] __lock_acquire+0xb7b/0xecc
  [<ffffffff80251ea4>] lock_acquire+0x51/0x6a
  [<ffffffff803a2ad1>] dev_mc_sync+0x19/0x57
  [<ffffffff8040b3fc>] _spin_lock_bh+0x23/0x2c
  [<ffffffff803a2ad1>] dev_mc_sync+0x19/0x57
  [<ffffffff8039e911>] dev_set_rx_mode+0x21/0x2e
  [<ffffffff803a04da>] dev_open+0x8e/0xb0
  [<ffffffff8039fe84>] dev_change_flags+0xa6/0x163
  [<ffffffff803a7591>] do_setlink+0x286/0x349
  [<ffffffff803a849d>] rtnetlink_rcv_msg+0x0/0x1ec
  [<ffffffff803a849d>] rtnetlink_rcv_msg+0x0/0x1ec
  [<ffffffff803a849d>] rtnetlink_rcv_msg+0x0/0x1ec
  [<ffffffff803a77de>] rtnl_setlink+0x10b/0x10d
  [<ffffffff803a849d>] rtnetlink_rcv_msg+0x0/0x1ec
  [<ffffffff803b416f>] netlink_rcv_skb+0x34/0x7d
  [<ffffffff803a8497>] rtnetlink_rcv+0x21/0x27
  [<ffffffff803b3c6f>] netlink_unicast+0x1f0/0x261
  [<ffffffff8039a58d>] __alloc_skb+0x66/0x12a
  [<ffffffff803b3f48>] netlink_sendmsg+0x268/0x27b
  [<ffffffff80393cb9>] sock_sendmsg+0xcb/0xe3
  [<ffffffff80246aab>] autoremove_wake_function+0x0/0x2e
  [<ffffffff8039b2d8>] verify_iovec+0x46/0x82
  [<ffffffff80393ee8>] sys_sendmsg+0x217/0x28a
  [<ffffffff80393642>] sockfd_lookup_light+0x1a/0x52
  [<ffffffff80250990>] trace_hardirqs_on_caller+0xef/0x113
  [<ffffffff8040af74>] trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8020be9b>] system_call_after_swapgs+0x7b/0x80
========================================================


The logged data for the WARNING is as follows:

------------[ cut here ]------------
WARNING: at net/core/dev.c:1330 __netif_schedule+0x2c/0x98()
Modules linked in: af_packet nfs lockd nfs_acl rfkill_input sunrpc 
cpufreq_conservative cpufreq_userspace cpufreq_powersave powernow_k8 fuse loop 
dm_mod arc4 ecb crypto_blkcipher b43 firmware_class rfkill mac80211 cfg80211 
led_class input_polldev battery ac button ssb serio_raw forcedeth sr_mod cdrom 
k8temp hwmon sg sd_mod ehci_hcd ohci_hcd usbcore edd fan thermal processor ext3 
mbcache jbd pata_amd ahci libata scsi_mod dock
Pid: 1990, comm: b43 Not tainted 2.6.26-Linus-git-05752-g93ded9b #49

Call Trace:
  [<ffffffff80233f6d>] warn_on_slowpath+0x51/0x8c
  [<ffffffff8039d937>] __netif_schedule+0x2c/0x98
  [<ffffffffa015445d>] ieee80211_scan_completed+0x26b/0x2f1 [mac80211]
  [<ffffffffa01546de>] ieee80211_sta_scan_work+0x0/0x1b8 [mac80211]
  [<ffffffff8024325e>] run_workqueue+0xf0/0x1f2
  [<ffffffff8024343b>] worker_thread+0xdb/0xea
  [<ffffffff80246aab>] autoremove_wake_function+0x0/0x2e
  [<ffffffff80243360>] worker_thread+0x0/0xea
  [<ffffffff8024678b>] kthread+0x47/0x73
  [<ffffffff8040af74>] trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8020cea9>] child_rip+0xa/0x11
  [<ffffffff8020c4df>] restore_args+0x0/0x30
  [<ffffffff8024671f>] kthreadd+0x188/0x1ad
  [<ffffffff80246744>] kthread+0x0/0x73
  [<ffffffff8020ce9f>] child_rip+0x0/0x11

---[ end trace 42d234b678daea7a ]---

Other info I have found. The call to __netif_schedule from 
ieee80211_scan_completed is through the following code from 
include/linux/netdevice.h:

/**
  *      netif_wake_queue - restart transmit
  *      @dev: network device
  *
  *      Allow upper layers to call the device hard_start_xmit routine.
  *      Used for flow control when transmit resources are available.
  */
static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
{
#ifdef CONFIG_NETPOLL_TRAP
         if (netpoll_trap()) {
                 clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
                 return;
         }
#endif
         if (test_and_clear_bit(__QUEUE_STATE_XOFF, &dev_queue->state))
                 __netif_schedule(dev_queue->qdisc);
}

It doesn't make any difference if CONFIG_NETPOLL_TRAP is defined or not.

Please let me know if I can provide any further information,

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
