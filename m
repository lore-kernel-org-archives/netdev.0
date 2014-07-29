From: zhuyj <zyjzyj2000@gmail.com>
Subject: ipv4: net namespace does not inherit network configurations
Date: Tue, 29 Jul 2014 17:29:32 +0800
Message-ID: <53D7697C.6020103@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050905080402070203080408"
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, zhuyj <zyjzyj2000@gmail.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	Alexandre Dietsch <alexandre.dietsch@windriver.com>
To: "David S. Miller" <davem@davemloft.net>,
	Hong Zhiguo <honkiko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050905080402070203080408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,all

I did a test on kernel3.16 rc6:

root@qemu1:~# echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
root@qemu1:~# echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
root@qemu1:~# ip netns list
root@qemu1:~# ip netns add fib1
root@qemu1:~# ip netns exec fib1 bash
root@qemu1:~# cat /proc/sys/net/ipv6/conf/all/forwarding
0
root@qemu1:~# cat /proc/sys/net/ipv4/conf/all/forwarding
1

The behavior of ipv4 and ipv6 is very inconsistent. I checked
the kernel source code. I found that from this patch
[ipv6: fix bad free of addrconf_init_net], the above difference
appeared.

Since a net namespace is independent to another. That is, there
is no any relationship between the net namespaces. So the behavior
of ipv4 is not correct.

Based on this patch [ipv6: fix bad free of addrconf_init_net], I made
a new patch to fix this problem on ipv4.

Any reply is appreciated.

Zhu Yanjun

--------------050905080402070203080408
Content-Type: text/x-patch;
 name="0001-ipv4-net-namespace-does-not-inherit-network-configur.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ipv4-net-namespace-does-not-inherit-network-configur.pa";
 filename*1="tch"

>From f3a68831d7c58b185d57f30130217b22a8e2c71f Mon Sep 17 00:00:00 2001
From: Zhu Yanjun <zyjzyj2000@gmail.com>
Date: Tue, 29 Jul 2014 17:23:10 +0800
Subject: [PATCH 1/1] ipv4: net namespace does not inherit network
 configurations

Ipv4 net namespace requires a similar logic change as commit c900a800
[ipv6: fix bad free of addrconf_init_net] introduces for newer kernels.

Since a net namespace is independent to another. That is, there
is no any relationship between the net namespaces. So a new net
namespace should not inherit network configurations from another
net namespace including the host.

CC: Hong Zhiguo <honkiko@gmail.com>
CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 net/ipv4/devinet.c | 29 ++++++++++++-----------------
 1 file changed, 12 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index e944937..a16aa39 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -2220,28 +2220,23 @@ static __net_init int devinet_init_net(struct net *net)
 #endif
 
 	err = -ENOMEM;
-	all = &ipv4_devconf;
-	dflt = &ipv4_devconf_dflt;
 
-	if (!net_eq(net, &init_net)) {
-		all = kmemdup(all, sizeof(ipv4_devconf), GFP_KERNEL);
-		if (all == NULL)
-			goto err_alloc_all;
-
-		dflt = kmemdup(dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
-		if (dflt == NULL)
-			goto err_alloc_dflt;
+	all = kmemdup(&ipv4_devconf, sizeof(ipv4_devconf), GFP_KERNEL);
+	if (all == NULL)
+		goto err_alloc_all;
 
+	dflt = kmemdup(&ipv4_devconf_dflt, sizeof(ipv4_devconf_dflt), GFP_KERNEL);
+	if (dflt == NULL)
+		goto err_alloc_dflt;
 #ifdef CONFIG_SYSCTL
-		tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
-		if (tbl == NULL)
-			goto err_alloc_ctl;
+	tbl = kmemdup(tbl, sizeof(ctl_forward_entry), GFP_KERNEL);
+	if (tbl == NULL)
+		goto err_alloc_ctl;
 
-		tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
-		tbl[0].extra1 = all;
-		tbl[0].extra2 = net;
+	tbl[0].data = &all->data[IPV4_DEVCONF_FORWARDING - 1];
+	tbl[0].extra1 = all;
+	tbl[0].extra2 = net;
 #endif
-	}
 
 #ifdef CONFIG_SYSCTL
 	err = __devinet_sysctl_register(net, "all", all);
-- 
1.9.1


--------------050905080402070203080408--
