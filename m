From: Huang Qiang <h.huangqiang@huawei.com>
Subject: [PATCH v2] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Thu, 12 Jul 2012 17:33:34 +0800
Message-ID: <4FFE99EE.70003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <containers@lists.linux-foundation.org>,
	<yangzhenzhang@huawei.com>
To: David Miller <davem@davemloft.net>, <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46544 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757298Ab2GLJgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 05:36:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Zhenzhang <yangzhenzhang@huawei.com>

Now, kernel allows each net namespace to independently set up its levels
for tcp memory pressure thresholds.

But it seems there is a bug, as using the following steps:

[root@host socket]# lxc-start -n test -f config /bin/bash
[root@net-test socket]# ip route add default via 192.168.58.2
[root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
[root@net-test socket]# scp root@192.168.58.174:/home/tcp_mem_test .

and it still can transport the "tcp_mem_test" file which we hope it
would not.

It's because inet_init() (net/ipv4/af_inet.c)initialize the tcp_prot.sysctl_mem:
tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;

So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
it's own net namespace.
This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
the protocol type is TCP.

Signed-off-by: Yang Zhenzhang <yangzhenzhang@huawei.com>
Signed-off-by: Huang Qiang <h.huangqiang@huawei.com>
---
 include/net/sock.h |   24 ++++++++++++++++--------
 1 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4a45216..ee85d8b 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -59,6 +59,7 @@
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
+#include <linux/in.h>

 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -1060,14 +1061,6 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
 	sk->sk_prot->enter_memory_pressure(sk);
 }

-static inline long sk_prot_mem_limits(const struct sock *sk, int index)
-{
-	long *prot = sk->sk_prot->sysctl_mem;
-	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
-		prot = sk->sk_cgrp->sysctl_mem;
-	return prot[index];
-}
-
 static inline void memcg_memory_allocated_add(struct cg_proto *prot,
 					      unsigned long amt,
 					      int *parent_status)
@@ -2150,6 +2143,21 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
 	sock_net_set(sk, hold_net(net));
 }

+static inline long sk_prot_mem_limits(const struct sock *sk, int index)
+{
+	long *prot = sk->sk_prot->sysctl_mem;
+
+	if (sk->sk_protocol == IPPROTO_TCP) {
+		struct net *net = sock_net(sk);
+		prot = net->ipv4.sysctl_tcp_mem;
+	}
+
+	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
+		prot = sk->sk_cgrp->sysctl_mem;
+
+	return prot[index];
+}
+
 static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 {
 	if (unlikely(skb->sk)) {
-- 
1.7.1
