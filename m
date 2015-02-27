From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] netns: correct gfp flags for alloc_netid()
Date: Thu, 26 Feb 2015 18:34:21 -0800
Message-ID: <1425004461.5565.183.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424998490-9565-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425001791.5565.180.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpV=wjuOfWvqRYbr+J9mA1Fa6YG9QvY9P0gnd9LYOeVGYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:37247 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882AbbB0CeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 21:34:23 -0500
Received: by iecrl12 with SMTP id rl12so24619296iec.4
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 18:34:22 -0800 (PST)
In-Reply-To: <CAM_iQpV=wjuOfWvqRYbr+J9mA1Fa6YG9QvY9P0gnd9LYOeVGYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 18:19 -0800, Cong Wang wrote:

> 
> LOL, it has been changed back and forth.
> 
> I thought rcu read lock was introduced to optimize dumping
> performance, if it were really important, we should solve the
> deadlock you mentioned in commit 2907c35ff647080?
> 
> Otherwise, as you said, completely revert to using rtnl lock.

Dumping is so fat nowadays, it makes sense to remove rcu_read_lock() to
allow cond_resched() eventually.

rcu_read_lock() made sense _if_ RTNL mutex could be avoided, but
unfortunately this could not be done easily.

Please try this patch instead :

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1385de0fa080..74ce25d2cded 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1300,7 +1300,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
 
-	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
 	/* A hack to preserve kernel<->userspace interface.
@@ -1322,7 +1321,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
-		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+		hlist_for_each_entry(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
 			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
@@ -1344,7 +1343,6 @@ cont:
 		}
 	}
 out:
-	rcu_read_unlock();
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
