From: Huang Qiang <h.huangqiang@huawei.com>
Subject: [PATCH] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Mon, 9 Jul 2012 14:05:09 +0800
Message-ID: <4FFA7495.5070702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <containers@lists.linux-foundation.org>,
	<yangzhenzhang@huawei.com>
To: <davem@davemloft.net>, <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:64521 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab2GIGIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 02:08:54 -0400
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

It's because inet_init() (net/ipv4/af_inet.c)initialize the
tcp_prot.sysctl_mem:
tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;

So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
it's own net namespace.
This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
the protocol type is TCP.

Signed-off-by: Yang Zhenzhang <yangzhenzhang@huawei.com>
---
 include/net/sock.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 4a45216..b62a8d9 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -59,6 +59,7 @@
 #include <linux/static_key.h>
 #include <linux/aio.h>
 #include <linux/sched.h>
+#include <linux/in.h>

 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -1062,7 +1063,12 @@ static inline void sk_enter_memory_pressure(struct sock *sk)

 static inline long sk_prot_mem_limits(const struct sock *sk, int index)
 {
+	struct net *net = sock_net(sk);
 	long *prot = sk->sk_prot->sysctl_mem;
+	
+	if (sk->protocol == IPPROTO_TCP)
+		prot = net->ipv4.sysctl_tcp_mem;
+
 	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
 		prot = sk->sk_cgrp->sysctl_mem;
 	return prot[index];
-- 
1.7.1
