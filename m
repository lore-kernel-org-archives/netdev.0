From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Wed, 18 Dec 2013 18:15:08 -0800
Message-ID: <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
	 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
	 <52B24D7D.6060902@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?=E7=8E=8B=E8=81=AA?= <xiyou.wangcong@gmail.com>,
	steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:45764 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab3LSCO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 21:14:59 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so480414pbc.38
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 18:14:58 -0800 (PST)
In-Reply-To: <52B24D7D.6060902@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-19 at 09:35 +0800, Fan Du wrote:
> Hi, Eric and Cong
> 

> Here is my understanding about llist_add_batch, assume when add one single
> entry into list, i.e., new_last equates new_first.
> 
>    1         do {
>    2                 new->next = first = ACCESS_ONCE(head->first);
>    3         } while (cmpxchg(&head->first, first, new) != first);
> 
> 
> Caller 1:Add new1 into head                          Caller 2:Add new2 into head
>       line 2: Link head into new1
>                                                       line 2: Link head into new2
>                                                       line 3: Make the cmpxchg, then succeed.
> 
>                                                       After this, new2 -> old_head
>       line 3: Make the cmpxchg, failed, try
>               again will succeed, after this
>               new1 -> new2 -> old_head
> 
> So in order to not use locks, try again if cmpxchg found out someone else
> has update the head. For the case involved in the patch, the problem is, after
> xchg, assign the old head to the new->next will race with the delete part when
> saving the head for deleting after setting the head to NULL, as the traverse
> of saved head probably not see a consistent list, that's a broken one.
> 
> I think an analogy of llist_add_batch for the updating part will be ok for this:
> 
>                          struct dst_entry *first;
>                          do {
>                                  xdst->u.dst.next = first = ACCESS_ONCE(xfrm_policy_sk_bundles);
>                          } while (cmpxchg(&xfrm_policy_sk_bundles, first, &xdst->u.dst) != first);
> 
> 
> And the deleting part:
> 
>                          head = xchg(&net->xfrm.xfrm_policy_sk_bundles, NULL);
> 
> 

The point is to _use_ the helpers, so that code review is easy.

llist.h is safe, it was extensively discussed and adopted.

If you want to get rid of the spinlock, then use llist_del_all() for the
deleting, and llist_add() for the addition.

Really, its that simple.
