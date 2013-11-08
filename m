From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net] net: sch_red: Fix race between timer and red_destroy()
Date: Fri, 8 Nov 2013 13:59:19 -0800
Message-ID: <CAGK4HS8SoXAGM-zgbofQp+Cy19Z0doQafvYceePt_kM9CEchYQ@mail.gmail.com>
References: <1383617296-20273-1-git-send-email-subramanian.vijay@gmail.com>
	<20131105.221633.636594084725891709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:62570 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757926Ab3KHV7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 16:59:19 -0500
Received: by mail-ve0-f170.google.com with SMTP id oy12so1908823veb.15
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 13:59:19 -0800 (PST)
In-Reply-To: <20131105.221633.636594084725891709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> del_timer_sync() waits for all instances of the timer handler which
> are running to complete, and then it deletes the timer from any of
> the scheduled timer lists.
>
> Your patch is making the mod_timer() in the timer handler conditional,
> and this really shouldn't be necessary.
>
> The whole point of del_timer_sync() is to address these kinds of
> situations.


Thanks for the explanation Dave. I am trying to reconcile your
explanation with the text above del_timer_sync()
vim +1013 kernel/timer.c

" * This function only differs from del_timer() on SMP: besides deactivating
 * the timer it also makes sure the handler has finished executing on other
 * CPUs.
 *
 * Synchronization rules: Callers must prevent restarting of the timer,
 * otherwise this function is meaningless.  ..."

This seems to suggest simply calling del_timer_sync() is not enough.
In fact, for the same reason  I was recently pointed towards
commit 980c478ddbb72 (sch_sfq: use del_timer_sync() in sfq_destroy() )
and I based the patch on how q->perturb_period is reset in
sfq_destroy() and used in sfq_perturbation().

Based on your explanation , I think we do not need (in sched/sch_sfq.c)
q->perturb_period = 0;  in sfq_destroy() and just del_timer_sync()
should be enough.

Thanks,
Vijay
