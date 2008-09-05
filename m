From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: netns : fix kernel panic in timewait socket destruction
Date: Fri, 05 Sep 2008 10:37:09 +0200
Message-ID: <48C0EFB5.6080503@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020901010402090001070209"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"deni >> \"Denis V. Lunev\"" <den@openvz.org>,
	"eric >> \"Eric W. Biederman\"" <ebiederm@xmission.com>
To: "dave >> David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:56361 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029AbYIEIiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 04:38:23 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m858bI5m558322
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 08:37:18 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m858bIW42043998
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 10:37:18 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m858bEKS019728
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 10:37:14 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020901010402090001070209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------020901010402090001070209
Content-Type: text/x-diff;
 name="inet_timewait-purge-timewait-sockets.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet_timewait-purge-timewait-sockets.patch"

Subject: netns : fix kernel panic in timewait socket destruction
From: Daniel Lezcano <dlezcano@fr.ibm.com>

How to reproduce ?
 - create a network namespace
 - use tcp protocol and get timewait socket
 - exit the network namespace
 - after a moment (when the timewait socket is destroyed), the kernel
   panics.

# BUG: unable to handle kernel NULL pointer dereference at
0000000000000007
IP: [<ffffffff821e394d>] inet_twdr_do_twkill_work+0x6e/0xb8
PGD 119985067 PUD 11c5c0067 PMD 0
Oops: 0000 [1] SMP
CPU 1
Modules linked in: ipv6 button battery ac loop dm_mod tg3 libphy ext3 jbd
edd fan thermal processor thermal_sys sg sata_svw libata dock serverworks
sd_mod scsi_mod ide_disk ide_core [last unloaded: freq_table]
Pid: 0, comm: swapper Not tainted 2.6.27-rc2 #3
RIP: 0010:[<ffffffff821e394d>] [<ffffffff821e394d>]
inet_twdr_do_twkill_work+0x6e/0xb8
RSP: 0018:ffff88011ff7fed0 EFLAGS: 00010246
RAX: ffffffffffffffff RBX: ffffffff82339420 RCX: ffff88011ff7ff30
RDX: 0000000000000001 RSI: ffff88011a4d03c0 RDI: ffff88011ac2fc00
RBP: ffffffff823392e0 R08: 0000000000000000 R09: ffff88002802a200
R10: ffff8800a5c4b000 R11: ffffffff823e4080 R12: ffff88011ac2fc00
R13: 0000000000000001 R14: 0000000000000001 R15: 0000000000000000
FS: 0000000041cbd940(0000) GS:ffff8800bff839c0(0000)
knlGS:0000000000000000
CS: 0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000007 CR3: 00000000bd87c000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff8800bff9e000, task
ffff88011ff76690)
Stack: ffffffff823392e0 0000000000000100 ffffffff821e3a3a
0000000000000008
0000000000000000 ffffffff821e3a61 ffff8800bff7c000 ffffffff8203c7e7
ffff88011ff7ff10 ffff88011ff7ff10 0000000000000021 ffffffff82351108
Call Trace:
<IRQ> [<ffffffff821e3a3a>] ? inet_twdr_hangman+0x0/0x9e
[<ffffffff821e3a61>] ? inet_twdr_hangman+0x27/0x9e
[<ffffffff8203c7e7>] ? run_timer_softirq+0x12c/0x193
[<ffffffff820390d1>] ? __do_softirq+0x5e/0xcd
[<ffffffff8200d08c>] ? call_softirq+0x1c/0x28
[<ffffffff8200e611>] ? do_softirq+0x2c/0x68
[<ffffffff8201a055>] ? smp_apic_timer_interrupt+0x8e/0xa9
[<ffffffff8200cad6>] ? apic_timer_interrupt+0x66/0x70
<EOI> [<ffffffff82011f4c>] ? default_idle+0x27/0x3b
[<ffffffff8200abbd>] ? cpu_idle+0x5f/0x7d


Code: e8 01 00 00 4c 89 e7 41 ff c5 e8 8d fd ff ff 49 8b 44 24 38 4c 89 e7
65 8b 14 25 24 00 00 00 89 d2 48 8b 80 e8 00 00 00 48 f7 d0 <48> 8b 04 d0
48 ff 40 58 e8 fc fc ff ff 48 89 df e8 c0 5f 04 00
RIP [<ffffffff821e394d>] inet_twdr_do_twkill_work+0x6e/0xb8
RSP <ffff88011ff7fed0>
CR2: 0000000000000007

This patch provides a function to purge all timewait sockets related
to a network namespace. The timewait sockets life cycle is not tied with
the network namespace, that means the timewait sockets stay alive while
the network namespace dies. The timewait sockets are for avoiding to
receive a duplicate packet from the network, if the network namespace is
freed, the network stack is removed, so no chance to receive any packets
from the outside world. Furthermore, having a pending destruction timer
on these sockets with a network namespace freed is not safe and will lead
to an oops if the timer callback which try to access data belonging to 
the namespace like for example in:
	inet_twdr_do_twkill_work
		-> NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITED);

Purging the timewait sockets at the network namespace destruction will:
 1) speed up memory freeing for the namespace
 2) fix kernel panic on asynchronous timewait destruction

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Denis V. Lunev <den@openvz.org>
Acked-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/inet_timewait_sock.h |    3 +++
 net/ipv4/inet_timewait_sock.c    |   35 +++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c              |    1 +
 net/ipv6/tcp_ipv6.c              |    1 +
 4 files changed, 40 insertions(+)

Index: net-2.6/net/ipv4/inet_timewait_sock.c
===================================================================
--- net-2.6.orig/net/ipv4/inet_timewait_sock.c
+++ net-2.6/net/ipv4/inet_timewait_sock.c
@@ -409,3 +409,38 @@ out:
 }
 
 EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
+
+void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
+		     struct inet_timewait_death_row *twdr, int family)
+{
+	struct inet_timewait_sock *tw;
+	struct sock *sk;
+	struct hlist_node *node;
+	int h;
+
+	local_bh_disable();
+	for (h = 0; h < (hashinfo->ehash_size); h++) {
+		struct inet_ehash_bucket *head =
+			inet_ehash_bucket(hashinfo, h);
+		rwlock_t *lock = inet_ehash_lockp(hashinfo, h);
+restart:
+		write_lock(lock);
+		sk_for_each(sk, node, &head->twchain) {
+
+			tw = inet_twsk(sk);
+			if (!net_eq(twsk_net(tw), net) ||
+			    tw->tw_family != family)
+				continue;
+
+			atomic_inc(&tw->tw_refcnt);
+			write_unlock(lock);
+			inet_twsk_deschedule(tw, twdr);
+			inet_twsk_put(tw);
+
+			goto restart;
+		}
+		write_unlock(lock);
+	}
+	local_bh_enable();
+}
+EXPORT_SYMBOL_GPL(inet_twsk_purge);
Index: net-2.6/include/net/inet_timewait_sock.h
===================================================================
--- net-2.6.orig/include/net/inet_timewait_sock.h
+++ net-2.6/include/net/inet_timewait_sock.h
@@ -208,6 +208,9 @@ extern void inet_twsk_schedule(struct in
 extern void inet_twsk_deschedule(struct inet_timewait_sock *tw,
 				 struct inet_timewait_death_row *twdr);
 
+extern void inet_twsk_purge(struct net *net, struct inet_hashinfo *hashinfo,
+			    struct inet_timewait_death_row *twdr, int family);
+
 static inline
 struct net *twsk_net(const struct inet_timewait_sock *twsk)
 {
Index: net-2.6/net/ipv4/tcp_ipv4.c
===================================================================
--- net-2.6.orig/net/ipv4/tcp_ipv4.c
+++ net-2.6/net/ipv4/tcp_ipv4.c
@@ -2376,6 +2376,7 @@ static int __net_init tcp_sk_init(struct
 static void __net_exit tcp_sk_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
+	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET);
 }
 
 static struct pernet_operations __net_initdata tcp_sk_ops = {
Index: net-2.6/net/ipv6/tcp_ipv6.c
===================================================================
--- net-2.6.orig/net/ipv6/tcp_ipv6.c
+++ net-2.6/net/ipv6/tcp_ipv6.c
@@ -2148,6 +2148,7 @@ static int tcpv6_net_init(struct net *ne
 static void tcpv6_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.tcp_sk);
+	inet_twsk_purge(net, &tcp_hashinfo, &tcp_death_row, AF_INET6);
 }
 
 static struct pernet_operations tcpv6_net_ops = {

--------------020901010402090001070209--
