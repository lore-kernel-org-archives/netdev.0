From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 15 Nov 2010 08:52:54 -0800 (PST)
Message-ID: <20101115.085254.104057401.davem@davemloft.net>
References: <20101115114651.8e6bad6c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101115114651.8e6bad6c.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 15 Nov 2010 11:46:51 +1100

> Caused by commit 1d7138de878d1d4210727c1200193e69596f93b3 ("igmp: RCU
> conversion of in_dev->mc_list").  The for_each_pmc_rtnl and
> for_each_pmc_rcu definitions are protected by  CONFIG_IP_MULTICAST, but
> the uses are not ...

Thanks for the report, I've pushed the following fix:

--------------------
ipv4: Fix build with multicast disabled.

net/ipv4/igmp.c: In function 'ip_mc_inc_group':
net/ipv4/igmp.c:1228: error: implicit declaration of function 'for_each_pmc_rtnl'
net/ipv4/igmp.c:1228: error: expected ';' before '{' token
net/ipv4/igmp.c: In function 'ip_mc_unmap':
net/ipv4/igmp.c:1333: error: expected ';' before 'igmp_group_dropped'
 ...

Move for_each_pmc_rcu and for_each_pmc_rtnl macro definitions
outside of multicast ifdef protection.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/igmp.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 0f0e0f0..a1bf2f4 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -163,6 +163,16 @@ static void ip_ma_put(struct ip_mc_list *im)
 	}
 }
 
+#define for_each_pmc_rcu(in_dev, pmc)				\
+	for (pmc = rcu_dereference(in_dev->mc_list);		\
+	     pmc != NULL;					\
+	     pmc = rcu_dereference(pmc->next_rcu))
+
+#define for_each_pmc_rtnl(in_dev, pmc)				\
+	for (pmc = rtnl_dereference(in_dev->mc_list);		\
+	     pmc != NULL;					\
+	     pmc = rtnl_dereference(pmc->next_rcu))
+
 #ifdef CONFIG_IP_MULTICAST
 
 /*
@@ -502,16 +512,6 @@ empty_source:
 	return skb;
 }
 
-#define for_each_pmc_rcu(in_dev, pmc)				\
-	for (pmc = rcu_dereference(in_dev->mc_list);		\
-	     pmc != NULL;					\
-	     pmc = rcu_dereference(pmc->next_rcu))
-
-#define for_each_pmc_rtnl(in_dev, pmc)				\
-	for (pmc = rtnl_dereference(in_dev->mc_list);		\
-	     pmc != NULL;					\
-	     pmc = rtnl_dereference(pmc->next_rcu))
-
 static int igmpv3_send_report(struct in_device *in_dev, struct ip_mc_list *pmc)
 {
 	struct sk_buff *skb = NULL;
-- 
1.7.3.2
