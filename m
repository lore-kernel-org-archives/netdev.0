From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: net-next tree broken with CONFIG_NETFILTER_INGRESS=n
Date: Wed, 5 Oct 2016 09:48:42 +0200
Message-ID: <57588F77-89EA-4BAF-8B11-E45D22B49968@holtmann.org>
References: <E3004E95-F774-457E-9BA8-FA29A72BE035@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 10.0 \(3226\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
To: Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Aaron Conole <aconole@bytheb.org>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:40803 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbcJEHso (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 03:48:44 -0400
In-Reply-To: <E3004E95-F774-457E-9BA8-FA29A72BE035@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> the net-next tree is broken since a few days now when CONFIG_NETFILTER_INGRESS=n is set.
> 
>  CC      net/netfilter/core.o
> In file included from ./include/linux/linkage.h:4:0,
>                 from ./include/linux/kernel.h:6,
>                 from net/netfilter/core.c:10:
> net/netfilter/core.c: In function ‘nf_set_hooks_head’:
> net/netfilter/core.c:96:30: error: ‘struct net_device’ has no member named ‘nf_hooks_ingress’
>   rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
>                              ^
> ./include/linux/compiler.h:299:17: note: in definition of macro ‘WRITE_ONCE’
>  union { typeof(x) __val; char __c[1]; } __u = \

I really wonder what is going on here. Normally if you break the build, you fix it. However it seems nobody really cares enough. If I am not mistaken, then this patch broke it:

commit e3b37f11e6e4e6b6f02cc762f182ce233d2c1c9d
Author: Aaron Conole <aconole@bytheb.org>
Date:   Wed Sep 21 11:35:07 2016 -0400

    netfilter: replace list_head with single linked list
    
    The netfilter hook list never uses the prev pointer, and so can be trimmed to
    be a simple singly-linked list.

It is funny that it would have been obvious to test CONFIG_NETFILTER_INGRESS=n since there is an ifdef right in the first hunk of the patch.

        struct netdev_queue __rcu *ingress_queue;
 #ifdef CONFIG_NETFILTER_INGRESS
-       struct list_head        nf_hooks_ingress;
+       struct nf_hook_entry __rcu *nf_hooks_ingress;
 #endif

Regards

Marcel
