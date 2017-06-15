From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix calling in6_ifa_hold incorrectly for dad
 work
Date: Thu, 15 Jun 2017 10:58:03 -0400 (EDT)
Message-ID: <20170615.105803.1464863749922308353.davem@davemloft.net>
References: <2d710ef288455604efab24f72f4476ec5edb13bb.1497515638.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752791AbdFOO6F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 10:58:05 -0400
In-Reply-To: <2d710ef288455604efab24f72f4476ec5edb13bb.1497515638.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 15 Jun 2017 16:33:58 +0800

> Now when starting the dad work in addrconf_mod_dad_work, if the dad work
> is idle and queued, it needs to hold ifa.
> 
> The problem is there's one gap in [1], during which if the pending dad work
> is removed elsewhere. It will miss to hold ifa, but the dad word is still
> idea and queue.
> 
>         if (!delayed_work_pending(&ifp->dad_work))
>                 in6_ifa_hold(ifp);
>                     <--------------[1]
>         mod_delayed_work(addrconf_wq, &ifp->dad_work, delay);
> 
> An use-after-free issue can be caused by this.
> 
> Chen Wei found this issue when WARN_ON(!hlist_unhashed(&ifp->addr_lst)) in
> net6_ifa_finish_destroy was hit because of it.
> 
> As Hannes' suggestion, this patch is to fix it by holding ifa first in
> addrconf_mod_dad_work, then calling mod_delayed_work and putting ifa if
> the dad_work is already in queue.
> 
> Note that this patch did not choose to fix it with:
> 
>   if (!mod_delayed_work(delay))
>           in6_ifa_hold(ifp);
> 
> As with it, when delay == 0, dad_work would be scheduled immediately, all
> addrconf_mod_dad_work(0) callings had to be moved under ifp->lock.
> 
> Reported-by: Wei Chen <weichen@redhat.com>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thank you.
