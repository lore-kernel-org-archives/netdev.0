From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: error path in __ip_vs_init()
Date: Sat, 14 Apr 2012 19:42:31 +0900
Message-ID: <201204141942.DAF34354.VSLMOtQJOFHFFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:49610 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784Ab2DNKmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 06:42:33 -0400
Received: from www262.sakura.ne.jp (ksav52.sakura.ne.jp [219.94.192.132])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id q3EAgW3H048052
	for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 19:42:32 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from CLAMP (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id q3EAgVox048049
	for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 19:42:31 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Line 1880 cannot become true because net_generic() cannot return NULL.
Redundant check?

include/net/netns/generic.h:
 34 static inline void *net_generic(const struct net *net, int id)
 35 {
 36         struct net_generic *ng;
 37         void *ptr;
 38 
 39         rcu_read_lock();
 40         ng = rcu_dereference(net->gen);
 41         BUG_ON(id == 0 || id > ng->len);
 42         ptr = ng->ptr[id - 1];
 43         rcu_read_unlock();
 44 
 45         BUG_ON(!ptr);
 46         return ptr;
 47 }

net/netfilter/ipvs/ip_vs_core.c:
1875 static int __net_init __ip_vs_init(struct net *net)
1876 {
1877         struct netns_ipvs *ipvs;
1878 
1879         ipvs = net_generic(net, ip_vs_net_id);
1880         if (ipvs == NULL)
1881                 return -ENOMEM;
