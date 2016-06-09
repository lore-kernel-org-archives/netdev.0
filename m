From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 2/4] net: vrf: call netdev_lockdep_set_classes()
Date: Wed, 8 Jun 2016 21:58:58 -0700
Message-ID: <CANn89iKprT4CZBpnSZTvp=BmK+zjffFqhxArLkUU73xGkV+x8A@mail.gmail.com>
References: <1465442964-5786-1-git-send-email-edumazet@google.com>
 <1465442964-5786-2-git-send-email-edumazet@google.com> <c067a755-d414-60b9-a2f0-215c2b41bc6f@cumulusnetworks.com>
 <CANn89i+3m=6jNJPs2Ns+0uYqx7B-4pKENQ3Oi3dibFuTqaErzg@mail.gmail.com> <0231E33E-1C1A-4B32-992C-9BFC7470E7E0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:35124 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932812AbcFIE7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 00:59:00 -0400
Received: by mail-yw0-f173.google.com with SMTP id z186so9269210ywd.2
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 21:58:59 -0700 (PDT)
In-Reply-To: <0231E33E-1C1A-4B32-992C-9BFC7470E7E0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 9:35 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>
>> On Jun 8, 2016, at 10:01 PM, Eric Dumazet <edumazet@google.com> wrote:
>>
>>> On Wed, Jun 8, 2016 at 8:41 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>>> On 6/8/16 9:29 PM, Eric Dumazet wrote:
>>>>
>>>> In case a qdisc is used on a vrf device, we need to use different
>>>> lockdep classes to avoid false positives.
>>>>
>>>> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a
>>>> seqcount")
>>>> Reported-by: David Ahern <dsa@cumulusnetworks.com>
>>>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>>>
>>>
>>> same result with this patch set.
>>
>> Are you stacking multiple vrf devices ?
>
> No. You can also look at ipvlan. It shows the same trace. For me it is 3 commands that create the vrf, add eth1, run ping.


Okay, lockdep is hard ;)

I will send a v3 after some sleep, adding the following :

(I might have to add a new seqcount api instead of hard coding it)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c4f5749342ec..d53ecfc1d60e 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -104,7 +104,11 @@ static inline bool qdisc_run_begin(struct Qdisc *qdisc)
 {
        if (qdisc_is_running(qdisc))
                return false;
-       write_seqcount_begin(&qdisc->running);
+       /* Variant of write_seqcount_begin() telling lockdep a trylock
+        * was attempted.
+        */
+       raw_write_seqcount_begin(&qdisc->running);
+       seqcount_acquire(&qdisc->running.dep_map, 0, 1, _RET_IP_);
        return true;
 }

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cebea73e70ac..cad810b45e31 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -137,10 +137,10 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,

                HARD_TX_UNLOCK(dev, txq);
        } else {
-               spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
+               spin_lock(root_lock);
                return qdisc_qlen(q);
        }
-       spin_lock_nested(root_lock, SINGLE_DEPTH_NESTING);
+       spin_lock(root_lock);

        if (dev_xmit_complete(ret)) {
                /* Driver sent out skb successfully or skb was consumed */
