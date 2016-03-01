From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: Fix race condition when removing qdisc
Date: Tue, 01 Mar 2016 15:56:52 -0800
Message-ID: <1456876612.648.108.camel@edumazet-ThinkPad-T530>
References: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brakmo@fb.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36315 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756121AbcCAX4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 18:56:55 -0500
Received: by mail-pf0-f179.google.com with SMTP id l6so24468247pfl.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 15:56:54 -0800 (PST)
In-Reply-To: <1456874197-3036009-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On mar., 2016-03-01 at 15:16 -0800, Tom Herbert wrote:
> We are seeing a number of softlockups occurring with HTB upon removing
> the qdisc. We are still attempting to repro the exact circumstances,
> however looking at the code I'm very suspicious of this block in
> net_tx_action and its interaction with dev_deactivate (called through
> tc_modify_qdisc):
> 
>        if (!test_bit(__QDISC_STATE_DEACTIVATED,
> 		     &q->state)) {
> 	       __netif_reschedule(q);
>        } else {
> 	       smp_mb__before_atomic();
> 	       clear_bit(__QDISC_STATE_SCHED,
> 			 &q->state);
>        }
> 
> I think the following scenario could lead to badness:
> 
> 0) net_tx_action spin_trylock fails, taking non-locked block
> 1) net_tx_action checks for __QDISC_STATE_DEACTIVATED, it's not set
>    at this point
> 2) dev_deactive has lock and sets __QDISC_STATE_DEACTIVATED
> 3) dev_deactivate_many performs some_qdisc_is_busy(dev), neither
>    __QDISC_STATE_SCHED nor __QDISC_STATE_BUSY are set at this
>   point, so some_qdisc_busy fails (not seen as busy)

But __QDISC_STATE_SCHED should be set.

It is cleared only if __QDISC_STATE_DEACTIVATED has been caught in
net_tx_action()

> 4) net_tx_action sets __QDISC_STATE_SCHED

When qdisc is put again in output_queue, __QDISC_STATE_SCHED is left as
-is (set)


> 
> At this point dev_deactivate_many finishes so the qdisc may
> be freed in the tc_modify_qdisc path, however the qdisc is
> also "successfully" rescheduled to run by net_tx_action.
> 
> The propsed fix for this is to eliminate the spin_trylock in
> net_tx_action and always take the lock.


I know why you want to get rid of this trylock(), it is only the
changelog I find confusing. I do not see how it is going to help your
softlockups.
