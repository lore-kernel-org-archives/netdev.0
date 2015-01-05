From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: NULL pointer dereference at skb_queue_tail()
Date: Mon, 5 Jan 2015 21:50:33 +0900
Message-ID: <201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
References: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:59461 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbbAEMuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 07:50:37 -0500
Received: from fsav302.sakura.ne.jp (fsav302.sakura.ne.jp [153.120.85.133])
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t05CoZw0088485
	for <netdev@vger.kernel.org>; Mon, 5 Jan 2015 21:50:35 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from AQUA (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.14.5/8.14.5) with ESMTP id t05CoZGa088482
	for <netdev@vger.kernel.org>; Mon, 5 Jan 2015 21:50:35 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
In-Reply-To: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tetsuo Handa wrote:
> I can reproduce below oops when testing Linux 3.18 with memory allocation
> failure injection module at https://lkml.org/lkml/2014/12/25/64 .

I can reliably reproduce this oops with current linux.git using memory
allocation failure injection module. There is a possibility of memory
corruption since this oops always occurs immediately after memory
allocation failure within GPU/DRM code. I want to check whether
fields of structures have expected values or not.

> void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk)
> {
>         unsigned long flags;
> 

Could you tell me what are expected values (i.e. what BUG_ON() test
should I try) at this location?

>         spin_lock_irqsave(&list->lock, flags);
>         __skb_queue_tail(list, newsk);
>         spin_unlock_irqrestore(&list->lock, flags);
> }
> 
> static inline void __skb_queue_tail(struct sk_buff_head *list,
>                                    struct sk_buff *newsk)
> {
>         __skb_queue_before(list, (struct sk_buff *)list, newsk);
> }
> 
> static inline void __skb_queue_before(struct sk_buff_head *list,
>                                       struct sk_buff *next,
>                                       struct sk_buff *newsk)
> {
>         __skb_insert(newsk, next->prev, next, list);
> }
> 
> static inline void __skb_insert(struct sk_buff *newsk,
>                                 struct sk_buff *prev, struct sk_buff *next,
>                                 struct sk_buff_head *list)
> {
>         newsk->next = next;
>         newsk->prev = prev;
>         next->prev  = prev->next = newsk; // <= ffffffff81535e27 is here.
>         list->qlen++;
> }
> 
