From: Chris J Arges <chris.j.arges@canonical.com>
Subject: unregister_netdevice warnings when creating/destroying netns
Date: Mon, 22 Jun 2015 14:45:02 -0500
Message-ID: <20150622194501.GA8366@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, pablo@netfilter.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36744 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbbFVTpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 15:45:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Occasionally starting and stopping many containers with network traffic may
result in new containers being unable to start due to the inability to create
new network namespaces.

This has been reported to happen in kernels up to 4.0.

A reproducer for this issue has been posted here:
  https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1403152
To summarize, containers are created in parallel that create a file on an NFS
mount. After this is done, the containers are destroyed. After 10-15 iterations
using 5 worker threads the problem occurs.

Kernel bugzilla entry:
  https://bugzilla.kernel.org/show_bug.cgi?id=81211

The following message repeats in the kernel log until reboot.

  unregister_netdevice: waiting for lo to become free. Usage count = 1

Eventually when creating a new container this hung task backtrace occurs:

  schedule_preempt_disabled+0x29/0x70
  __mutex_lock_slowpath+0x135/0x1b0
  ? __kmalloc+0x1e9/0x230
  mutex_lock+0x1f/0x2f
  copy_net_ns+0x71/0x130
  create_new_namespaces+0xf9/0x180
  copy_namespaces+0x73/0xa0
  copy_process.part.26+0x9a6/0x16b0
  do_fork+0xd5/0x340
  ? call_rcu_sched+0x1d/0x20
  SyS_clone+0x16/0x20
  stub_clone+0x69/0x90
  ? system_call_fastpath+0x1a/0x1f

The following conditions I've been able to test:
- If CONFIG_BRIDGE_NETFILTER is disabled this problem does not occur.
- If net.bridge.bridge-nf-call-iptables is disabled, this problem does not occur.
- This problem can happen on single processor machines
- This problem can happen with IPv6 disabled
- This problem can happen with xt_conntrack disabled.
- If NFS uses UDP instead of TCP the problem does not occur.

The unregister_netdevice warning always waits on lo. It always has reg_state
set to NETREG_UNREGISTERING. This follows that the device has been through the
unregister_netdevice_many path and is being unregistered. This path is ultimately
where net_mutex is locked and thus prevents copy_net_ns from executing.

In addition, when the unregister netdevice warning happens, a crashdump reveals
the dst_busy_list always contains a dst_entry that references the device above.
This dst_entry has already been through ___dst_free since it has already been
marked DST_OBSOLETE_DEAD. 'dst->ops' is always set to ipv4_dst_ops.
dst->callback_head.next is NULL, and the next pointer is NULL. Use is also zero.

We can trace where the dst_entry is trying to be freed. When free_fib_info_rcu
is called, if nh_rth_input is set, it eventually calls dst_free. Because there
is still a refcnt held, it does not get immediately destroyed and continues on
to __dst_free. This puts the dst into the dst_garbage list, which is then
examined periodically by the dst_gc_work worker thread. Each time it tries to
clean it up it fails because it still has a non-zero refcnt.

The faulty dst_entry is being allocated via ip_rcv..ip_route_input_noref. In
addition this dst is most likely being held in response to a new packet via the
ip_rcv..inet_sk_rx_dst_set path.

At the time of first hitting the 'unregister_netdevice' warning, there are two
sockets that reference dst. Found via 'crash> search <dst_entry addr>'.

Example of sockets that reference the faulty dst entries:

struct inet_sock ffff88036584f800
  tcp
  rx_dst_ifindex = 150
  skc_state = TCP_CLOSE
  sk_rx_dst = 0xffff88034a0f5000
  skc_refcnt = 0
  sk_lock.owned = 0
  sk_shutdown = 3
  sk_flags = 17163

struct sock ffff880427d1fc00
  udp
  skc_state = 1
  sk_rx_dst = 0xffff88034a0f5000
  skc_refcnt = 0
  sk_lock.owned = 0

Hopefully this gives some context into the issue. I'm happy to do any
additional experiments/debugging since I can reproduce this at will. 

Thanks,
--chris j arges
