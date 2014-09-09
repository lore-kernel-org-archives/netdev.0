From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 02/15] net: rcu-ify tcf_proto
Date: Tue, 09 Sep 2014 08:20:22 -0700
Message-ID: <1410276022.7106.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	  <20140909055437.2071.86430.stgit@nitbit.x32>
	 <1410265257.11872.154.camel@edumazet-glaptop2.roam.corp.google.com>
	 <540F1975.2080303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:40463 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620AbaIIPUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 11:20:24 -0400
Received: by mail-pa0-f53.google.com with SMTP id rd3so4887174pab.26
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 08:20:24 -0700 (PDT)
In-Reply-To: <540F1975.2080303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-09 at 08:15 -0700, John Fastabend wrote:

> 
> You mean RCU_INIT_POINTER() correct?

Right, I got this correct for other reviews ;)

> 
> And to be clear which special case in rcupdate.h:999 applies here,
> 	
>   * 1.   This use of RCU_INIT_POINTER() is NULLing out the pointer -or-
>   * 2.   The caller has taken whatever steps are required to prevent
>   *      RCU readers from concurrently accessing this pointer -or-
>   * 3.   The referenced data structure has already been exposed to
>   *      readers either at compile time or via rcu_assign_pointer() -and-
>   *      a.      You have not made -any- reader-visible changes to
>   *              this structure since then -or-
>   *      b.      It is OK for readers accessing this structure from its
>   *              new location to see the old state of the structure. (For
>   *              example, the changes were to statistical counters or to
>   *             other state where exact synchronization is not required.)
> 

In fact, everytime we remove an item from rcu protected list, its fine
to use RCU_INIT_POINTER

RCU_INIT_POINTER(*pprev, item->next);

Because we do not touch chain starting from item->next

> 
> Its only NULLing out the pointer in special cases (case 1), with the
> qdisc lock dropped like in the last patch for ingress qdisc we may have
> concurrent readers (case 2) doing classification which will be walking
> the filter list, and with the tcf_ops change() its not clear to me that
> we can guarantee the structure has not been updated as stated in (case
> 3a).
> 
> So the case here is 3b we are just updating the list structure to skip
> an entry and any old state is correct.
