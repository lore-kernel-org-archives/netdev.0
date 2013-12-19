From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 18 Dec 2013 19:44:10 -0800
Message-ID: <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
		 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
		 <52B24D7D.6060902@windriver.com>
	 <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B26553.9070103@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=E7=8E=8B=E8=81=AA?= <xiyou.wangcong@gmail.com>,
	steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32996 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LSDn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 22:43:59 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so548955pde.20
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 19:43:59 -0800 (PST)
In-Reply-To: <52B26553.9070103@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 11:17 +0800, Fan Du wrote:
> 

> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
> index 1006a26..22f4f90 100644
> --- a/include/net/netns/xfrm.h
> +++ b/include/net/netns/xfrm.h
> @@ -58,9 +58,9 @@ struct netns_xfrm {
>   	struct dst_ops		xfrm6_dst_ops;
>   #endif
>   	spinlock_t xfrm_state_lock;
> -	spinlock_t xfrm_policy_sk_bundle_lock;
>   	rwlock_t xfrm_policy_lock;
>   	struct mutex xfrm_cfg_mutex;
> +	struct llist_head xp_sk_bundles_list;
>   };
> 
>   #endif
> diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> index 59f5d0a..05296ab 100644
> --- a/include/net/xfrm.h
> +++ b/include/net/xfrm.h
> @@ -957,6 +957,7 @@ struct xfrm_dst {
>   	u32 child_mtu_cached;
>   	u32 route_cookie;
>   	u32 path_cookie;
> +	struct llist_node       xdst_llist;
>   };
> 

Hmm... Thats not very nice.

Please reuse the storage adding a llist_node in the union ?

diff --git a/include/net/dst.h b/include/net/dst.h
index 44995c13e941..3f604f47cc58 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -14,6 +14,7 @@
 #include <linux/rcupdate.h>
 #include <linux/bug.h>
 #include <linux/jiffies.h>
+#include <linux/llist.h>
 #include <net/neighbour.h>
 #include <asm/processor.h>
 
@@ -103,6 +104,7 @@ struct dst_entry {
 		struct rtable __rcu	*rt_next;
 		struct rt6_info		*rt6_next;
 		struct dn_route __rcu	*dn_next;
+		struct llist_node	llist;
 	};
 };
 
