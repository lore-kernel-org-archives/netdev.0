From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 20:00:50 -0400
Message-ID: <20090525000050.GJ24757@kvack.org>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com> <20090524221240.GI24757@kvack.org> <4A19CE8B.3070302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49452 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751984AbZEYAAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 20:00:49 -0400
Content-Disposition: inline
In-Reply-To: <4A19CE8B.3070302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2009 at 12:47:39AM +0200, Eric Dumazet wrote:
> There is a strong dependancy against HZ
> BTW, I am using TREE_RCU

I'm using CLASSIC_RCU.  The bisect just completed, and it points to RCU.  
It makes some degree of sense since I'm testing on an otherwise idle 
machine.  That said, where is fixing it going to make sense?  I'm not 
opposed to having device unregister take a few timer ticks, but there 
has to be some way of exposing parallelism to the system, and since the 
synchronize_net() calls are done under rntl_lock(), none is possible at 
present.  Hrm.

		-ben

bf51935f3e988e0ed6f34b55593e5912f990750a is first bad commit
commit bf51935f3e988e0ed6f34b55593e5912f990750a
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Tue Feb 17 06:01:30 2009 -0800

    x86, rcu: fix strange load average and ksoftirqd behavior
    
    Damien Wyart reported high ksoftirqd CPU usage (20%) on an
    otherwise idle system.
    
    The function-graph trace Damien provided:
...
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c

index a546f55..bd4da2a 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -104,9 +104,6 @@ void cpu_idle(void)
 			check_pgt_cache();
 			rmb();
 
-			if (rcu_pending(cpu))
-				rcu_check_callbacks(cpu, 0);
-
 			if (cpu_is_offline(cpu))
 				play_dead();
 

