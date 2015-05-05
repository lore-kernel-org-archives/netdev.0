From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next 0/5] replace skb tc_verd member with 3 dedicated
 bit flags
Date: Tue, 05 May 2015 07:39:36 -0400
Message-ID: <5548ABF8.5080806@mojatatu.com>
References: <1430765318-13788-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34947 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758425AbbEELjo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:39:44 -0400
Received: by oign205 with SMTP id n205so142535562oig.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 04:39:43 -0700 (PDT)
In-Reply-To: <1430765318-13788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian,

Initial feedback on the series:
- Can you keep the macros around? eg SET_TC_NCLS is more readable
than skb->tc_nocls = 1 also hides the bit details.
Those macros are not used in user space (there was need earlier but
it is no longer necessary; dont worry about out of tree code).
So this is an opportunity to redefine them. Move them to 
include/net/pkt_cls.h and redefine them so readability is better. Maybe 
use set_bit
instead of the complex ones that exist there.
I think the ones that are no longer needed should just be deleted
as opposed to what you and Alexei did earlier.
- We need two bits for the location (ingress, egress, from stack)
from stack being 0 i.e when it is not set implicitly it is from the
host stack then we can check for ingress or egress when we choose.
Please keep the two bits.

cheers,
jamal

On 05/04/15 14:48, Florian Westphal wrote:
> This series removes the tc_verd member from sk_buff
> and uses 3 new flag bits instead.  It is on top of
> http://patchwork.ozlabs.org/patch/467186/
> (tc: remove unused redirect ttl) from Alexei.
>
> The patch set tries to not affect tc inner workings.
> I tested a few scenarios, namely:
>
> - htb on egress
> - netem attached to ifb with mirred redirect from ingress
>    qdisc
> - mirred to different device
> - bogus packet reclassify loop
>
> All of that works as expected (i.e. in last case most packets
> are dropped).
>
> motivation is two-fold:
> 1) provide better documentation as to what tc_verd is
>     used for and try to move some flag set/clear operations
>     into sch_ingress
>
> 2) provide a way to reduce skb size by 8 bytes
>     (s/u16 mac_len/u8 mac_len/ would result in
>      two 2 byte and one 4 byte hole, i.e. 8 byte reduction with
>      minor reshuffling).
>
> Florian Westphal (5):
>        net: sched: replace NCLS macro with tc_nocls bit flag
>        net: sched: use counter to break reclassify loops
>        net: sched: remove FROM INGRESS/EGRESS
>        net: sched: remove AT INGRESS/EGRESS
>        skbuff: remove tc_verd member
>
> Documentation/networking/tc-actions-env-rules.txt |    4 ----
>   drivers/net/ifb.c                                 |   15 +++++----------
>   drivers/staging/octeon/ethernet-tx.c              |    4 +++-
>   include/linux/skbuff.h                            |   17 +++++++++++------
>   include/net/sch_generic.h                         |   15 ---------------
>   include/uapi/linux/pkt_cls.h                      |    4 +---
>   net/core/dev.c                                    |   10 ++--------
>   net/core/skbuff.c                                 |    3 ---
>   net/sched/act_api.c                               |    4 ++--
>   net/sched/act_mirred.c                            |    9 ++++-----
>   net/sched/sch_api.c                               |   12 +++---------
>   net/sched/sch_ingress.c                           |    2 ++
>   net/sched/sch_netem.c                             |    2 +-
>   13 files changed, 34 insertions(+), 67 deletions(-)
>
