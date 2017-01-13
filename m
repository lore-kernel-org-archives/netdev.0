From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Patch net] atm: remove an unnecessary loop
Date: Fri, 13 Jan 2017 14:23:46 +0100
Message-ID: <20170113132346.GA19220@electric-eye.fr.zoreil.com>
References: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mhocko@kernel.org, 3chas3@gmail.com,
        andreyknvl@google.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40432 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751602AbdAMNXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 08:23:51 -0500
Content-Disposition: inline
In-Reply-To: <CAM_iQpX2TipBW2Pm-OHRobfZaVoV9_D8Se8u9oKryt96SZFRkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> :
[...]
> alloc_skb(GFP_KERNEL) itself is sleeping, so the new wait api is still
> needed.

The task state change warning is the symptom.

The deeply nested alloc_skb is the problem.

Diagnosis: nesting is wrong. It makes zero sense. Fix it and the
implicit task state change problem automagically goes away.

alloc_skb() does not need to be in the "while" loop.

alloc_skb() does not need to be in the {prepare_to_wait/add_wait_queue ...
finish_wait/remove_wait_queue} block.

alloc_tx() is not correctly named: given its original content, it deserves
to be called something like:

"wait_for_decent_tx_drain_and_alloc_by_hand_coz_i_dont_trust_the_mm_subsystem_and_i_dont_know_what_i_want"

I claim that:
- alloc_tx() should only perform the "wait_for_decent_tx_drain" part
- alloc_skb() ought to be done directly in vcc_sendmsg
- alloc_skb() failure can be handled gracefully in vcc_sendmsg
- alloc_skb() may use a (m->msg_flags & MSG_DONTWAIT) dependant
  GFP_{KERNEL / ATOMIC} flag
- most of it can be done in a longterm maintenance pain minimizing
  way. Call it a side-effect: I don't claim that it *must* be done
  this way.

-- 
Ueimor
