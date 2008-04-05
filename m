From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL net-2.6.26] [IPV6] MROUTE: Support multicast routing.
Date: Sat, 05 Apr 2008 22:46:23 +0900 (JST)
Message-ID: <20080405.224623.15818365.yoshfuji@linux-ipv6.org>
References: <20080403.114333.77827256.yoshfuji@linux-ipv6.org>
	<b25312890804050348w24bcba83y7391c89b1a9b25bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: roszenrami@gmail.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:60358 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847AbYDENos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2008 09:44:48 -0400
In-Reply-To: <b25312890804050348w24bcba83y7391c89b1a9b25bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <b25312890804050348w24bcba83y7391c89b1a9b25bc@mail.gmail.com> (at Sat, 5 Apr 2008 13:48:30 +0300), "Rami Rosen" <roszenrami@gmail.com> says:

> It seems to me that there is an error in this patch, when building on
> 64 machines.
:
> ...
> net/ipv6/ip6mr.c: In function 'ip6mr_cache_resolve':
> net/ipv6/ip6mr.c:736: error: invalid operands to binary -
> net/ipv6/ip6mr.c: In function 'ip6mr_fill_mroute':
> net/ipv6/ip6mr.c:1565: warning: initialization makes pointer from
> integer without a cast
> net/ipv6/ip6mr.c:1585: error: invalid operands to binary -
> make[2]: *** [net/ipv6/ip6mr.o] Error 1
> make[1]: *** [net/ipv6] Error 2
> make: *** [net] Error 2
> ...
> ...
:
> It seems to me that this could be solved by calling skb_tail_pointer(), thus:
> nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;

Good point, thanks.

I've pushed the following fix into the tree:
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-mroute-20080405
on top of current net-2.6.26 tree.

Regards,

--yoshfuji
---------------
Subject: [IPV6] MROUTE: Use skb_tail_pointer(skb) instead of skb->tail.

This bug resulted in compilation error on 64bit machines.
Pointed out by Rami Rosen <roszenrami@gmail.com>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6mr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2b70774..da673ef 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -733,7 +733,7 @@ static void ip6mr_cache_resolve(struct mfc6_cache *uc, struct mfc6_cache *c)
 			struct nlmsghdr *nlh = (struct nlmsghdr *)skb_pull(skb, sizeof(struct ipv6hdr));
 
 			if (ip6mr_fill_mroute(skb, c, NLMSG_DATA(nlh)) > 0) {
-				nlh->nlmsg_len = skb->tail - (u8 *)nlh;
+				nlh->nlmsg_len = skb_tail_pointer(skb) - (u8 *)nlh;
 			} else {
 				nlh->nlmsg_type = NLMSG_ERROR;
 				nlh->nlmsg_len = NLMSG_LENGTH(sizeof(struct nlmsgerr));
@@ -1562,7 +1562,7 @@ ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm)
 	int ct;
 	struct rtnexthop *nhp;
 	struct net_device *dev = vif6_table[c->mf6c_parent].dev;
-	u8 *b = skb->tail;
+	u8 *b = skb_tail_pointer(skb);
 	struct rtattr *mp_head;
 
 	if (dev)
@@ -1582,7 +1582,7 @@ ip6mr_fill_mroute(struct sk_buff *skb, struct mfc6_cache *c, struct rtmsg *rtm)
 		}
 	}
 	mp_head->rta_type = RTA_MULTIPATH;
-	mp_head->rta_len = skb->tail - (u8 *)mp_head;
+	mp_head->rta_len = skb_tail_pointer(skb) - (u8 *)mp_head;
 	rtm->rtm_type = RTN_MULTICAST;
 	return 1;
 
-- 
1.4.4.4

