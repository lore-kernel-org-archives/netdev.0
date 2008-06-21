From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: Don't receive new packets in a dead network namespace.
Date: Fri, 20 Jun 2008 17:17:05 -0700
Message-ID: <m1k5gjej5q.fsf@frodo.ebiederm.org>
References: <20080620204943.GA5068@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, den@openvz.org, xemul@openvz.org,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53433 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbYFUAVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 20:21:19 -0400
In-Reply-To: <20080620204943.GA5068@martell.zuzino.mipt.ru> (Alexey Dobriyan's
	message of "Sat, 21 Jun 2008 00:49:43 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexey Dobriyan <adobriyan@gmail.com> writes:
> Subject: ICMP sockets destruction vs ICMP packets oops

> After icmp_sk_exit() nuked ICMP sockets, we get an interrupt.
> icmp_reply() wants ICMP socket.
>
> Steps to reproduce:
>
> 	launch shell in new netns
> 	move real NIC to netns
> 	setup routing
> 	ping -i 0
> 	exit from shell
>
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000000
> IP: [<ffffffff803fce17>] icmp_sk+0x17/0x30
> PGD 17f3cd067 PUD 17f3ce067 PMD 0 
> Oops: 0000 [1] PREEMPT SMP DEBUG_PAGEALLOC
> CPU 0 
> Modules linked in: usblp usbcore
> Pid: 0, comm: swapper Not tainted 2.6.26-rc6-netns-ct #4
> RIP: 0010:[<ffffffff803fce17>]  [<ffffffff803fce17>] icmp_sk+0x17/0x30
> RSP: 0018:ffffffff8057fc30  EFLAGS: 00010286
> RAX: 0000000000000000 RBX: 0000000000000000 RCX: ffff81017c7db900
> RDX: 0000000000000034 RSI: ffff81017c7db900 RDI: ffff81017dc41800
> RBP: ffffffff8057fc40 R08: 0000000000000001 R09: 000000000000a815
> R10: 0000000000000000 R11: 0000000000000001 R12: ffffffff8057fd28
> R13: ffffffff8057fd00 R14: ffff81017c7db938 R15: ffff81017dc41800
> FS:  0000000000000000(0000) GS:ffffffff80525000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> CR2: 0000000000000000 CR3: 000000017fcda000 CR4: 00000000000006e0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process swapper (pid: 0, threadinfo ffffffff8053a000, task ffffffff804fa4a0)
> Stack:  0000000000000000 ffff81017c7db900 ffffffff8057fcf0 ffffffff803fcfe4
>  ffffffff804faa38 0000000000000246 0000000000005a40 0000000000000246
>  000000000001ffff ffff81017dd68dc0 0000000000005a40 0000000055342436
> Call Trace:
>  <IRQ>  [<ffffffff803fcfe4>] icmp_reply+0x44/0x1e0
>  [<ffffffff803d3a0a>] ? ip_route_input+0x23a/0x1360
>  [<ffffffff803fd645>] icmp_echo+0x65/0x70
>  [<ffffffff803fd300>] icmp_rcv+0x180/0x1b0
>  [<ffffffff803d6d84>] ip_local_deliver+0xf4/0x1f0
>  [<ffffffff803d71bb>] ip_rcv+0x33b/0x650
>  [<ffffffff803bb16a>] netif_receive_skb+0x27a/0x340
>  [<ffffffff803be57d>] process_backlog+0x9d/0x100
>  [<ffffffff803bdd4d>] net_rx_action+0x18d/0x250
>  [<ffffffff80237be5>] __do_softirq+0x75/0x100
>  [<ffffffff8020c97c>] call_softirq+0x1c/0x30
>  [<ffffffff8020f085>] do_softirq+0x65/0xa0
>  [<ffffffff80237af7>] irq_exit+0x97/0xa0
>  [<ffffffff8020f198>] do_IRQ+0xa8/0x130
>  [<ffffffff80212ee0>] ? mwait_idle+0x0/0x60
>  [<ffffffff8020bc46>] ret_from_intr+0x0/0xf
>  <EOI>  [<ffffffff80212f2c>] ? mwait_idle+0x4c/0x60
>  [<ffffffff80212f23>] ? mwait_idle+0x43/0x60
>  [<ffffffff8020a217>] ? cpu_idle+0x57/0xa0
>  [<ffffffff8040f380>] ? rest_init+0x70/0x80
> Code: 10 5b 41 5c 41 5d 41 5e c9 c3 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 53
> 48 83 ec 08 48 8b 9f 78 01 00 00 e8 2b c7 f1 ff 89 c0 <48> 8b 04 c3 48 83 c4 08
> 5b c9 c3 66 66 66 66 66 2e 0f 1f 84 00
> RIP  [<ffffffff803fce17>] icmp_sk+0x17/0x30
>  RSP <ffffffff8057fc30>
> CR2: 0000000000000000
> ---[ end trace ea161157b76b33e8 ]---
> Kernel panic - not syncing: Aiee, killing interrupt handler!

Receiving packets while we are cleaning up a network namespace is a
racy proposition. It is possible when the packet arrives that we have
removed some but not all of the state we need to fully process it.  We
have the choice of either playing wack-a-mole with the cleanup routines
or simply dropping packets when we don't have a network namespace to
handle them.

Since the check looks inexpensive in netif_receive_skb let's just
drop the incoming packets.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/net_namespace.h |   11 +++++++++++
 net/core/dev.c              |    4 ++++
 net/core/net_namespace.c    |    3 +++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index aa540e6..d9dd0f7 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -95,6 +95,11 @@ extern struct list_head net_namespace_list;
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
 
+static inline int net_alive(struct net *net)
+{
+	return net && atomic_read(&net->count);
+}
+
 static inline struct net *get_net(struct net *net)
 {
 	atomic_inc(&net->count);
@@ -125,6 +130,12 @@ int net_eq(const struct net *net1, const struct net *net2)
 	return net1 == net2;
 }
 #else
+
+static inline int net_alive(struct net *net)
+{
+	return 1;
+}
+
 static inline struct net *get_net(struct net *net)
 {
 	return net;
diff --git a/net/core/dev.c b/net/core/dev.c
index 670abad..9271aa3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2059,6 +2059,10 @@ int netif_receive_skb(struct sk_buff *skb)
 
 	rcu_read_lock();
 
+	/* Don't receive packets in an exiting network namespace */
+	if (!net_alive(dev_net(skb->dev)))
+		goto out;
+
 #ifdef CONFIG_NET_CLS_ACT
 	if (skb->tc_verd & TC_NCLS) {
 		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 72b4c18..7c52fe2 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -140,6 +140,9 @@ static void cleanup_net(struct work_struct *work)
 	struct pernet_operations *ops;
 	struct net *net;
 
+	/* Be very certain incoming network packets will not find us */
+	rcu_barrier();
+
 	net = container_of(work, struct net, work);
 
 	mutex_lock(&net_mutex);
-- 
1.5.3.rc6.17.g1911

