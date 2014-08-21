From: Zhu Yanjun <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] ipv4: net namespace does not inherit network configurations
Date: Thu, 21 Aug 2014 10:32:01 +0800
Message-ID: <1408588321-13537-2-git-send-email-Yanjun.Zhu@windriver.com>
References: <1408588321-13537-1-git-send-email-Yanjun.Zhu@windriver.com>
Cc: Zhu Yanjun <Yanjun.Zhu@windriver.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	zyjzyj2000@gmail.com, Yue.Tao@windriver.com,
	alexandre.dietsch@windriver.com, davem@davemloft.net,
	honkiko@gmail.com, cwang@twopensource.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408588321-13537-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ipv4 net namespace requires a similar logic change as commit c900a800
[ipv6: fix bad free of addrconf_init_net] introduces for newer kernels.

Since a net namespace is independent to another. That is, there
is no any relationship between the net namespaces. So a new net
namespace should not inherit network configurations from another
net namespace including the host.

CC: Hong Zhiguo <honkiko@gmail.com>
CC: David S. Miller <davem@davemloft.net>
Suggested-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
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
