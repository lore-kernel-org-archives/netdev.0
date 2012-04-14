From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: error path in __ip_vs_init()
Date: Sat, 14 Apr 2012 12:55:45 +0200
Message-ID: <1334400945.5300.10050.camel@edumazet-glaptop>
References: <201204141942.DAF34354.VSLMOtQJOFHFFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46817 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab2DNKzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 06:55:49 -0400
Received: by wejx9 with SMTP id x9so2409423wej.19
        for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 03:55:48 -0700 (PDT)
In-Reply-To: <201204141942.DAF34354.VSLMOtQJOFHFFO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-04-14 at 19:42 +0900, Tetsuo Handa wrote:
> Line 1880 cannot become true because net_generic() cannot return NULL.
> Redundant check?
> 
> include/net/netns/generic.h:
>  34 static inline void *net_generic(const struct net *net, int id)
>  35 {
>  36         struct net_generic *ng;
>  37         void *ptr;
>  38 
>  39         rcu_read_lock();
>  40         ng = rcu_dereference(net->gen);
>  41         BUG_ON(id == 0 || id > ng->len);
>  42         ptr = ng->ptr[id - 1];
>  43         rcu_read_unlock();
>  44 
>  45         BUG_ON(!ptr);
>  46         return ptr;
>  47 }
> 
> net/netfilter/ipvs/ip_vs_core.c:
> 1875 static int __net_init __ip_vs_init(struct net *net)
> 1876 {
> 1877         struct netns_ipvs *ipvs;
> 1878 
> 1879         ipvs = net_generic(net, ip_vs_net_id);
> 1880         if (ipvs == NULL)
> 1881                 return -ENOMEM;
> --

Yep, because the BUG_ON(!ptr) was added very recently :

commit 5ee4433efe99b9f39f6eff5052a177bbcfe72cea
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Thu Jan 26 14:02:55 2012 +0000

    netns: Fail conspicously if someone uses net_generic at an inappropriate time.
    
    By definition net_generic should never be called when it can return
    NULL.  Fail conspicously with a BUG_ON to make it clear when people mess
    up that a NULL return should never happen.
    
    Recently there was a bug in the CAIF subsystem where it was registered
    with register_pernet_device instead of register_pernet_subsys.  It was
    erroneously concluded that net_generic could validly return NULL and
    that net_assign_generic was buggy (when it was just inefficient).
    Hopefully this BUG_ON will prevent people to coming to similar erroneous
    conclusions in the futrue.
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Tested-by: Sasha Levin <levinsasha928@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


So feel free to submit a patch ;)
