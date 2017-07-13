From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH] datapath: Fix for force/commit action failures
Date: Thu, 13 Jul 2017 16:08:46 -0700
Message-ID: <CAPWQB7FVCCyXL2j49vgGPEgN6tDMgLu7csbdJPdbQ6j1Ozuzww@mail.gmail.com>
References: <1499963124-7841-1-git-send-email-gvrose8192@gmail.com>
 <CAPWQB7EvfsMCddisznPgfNQPtHMboKz2hoTiH6uknmTwx+B5Dw@mail.gmail.com>
 <4a063b92-1e36-db6f-d6cc-4f215637f549@gmail.com> <CAPWQB7GzQ4qm9dJjuzUm7nO2HHiNq9M+B4c00NNKqOzx9_O48g@mail.gmail.com>
 <0d78303a-31b2-f59c-2b47-0e684ff0f629@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        Pravin Shalar <pshelar@nicira.com>
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:46728 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752012AbdGMXJK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 19:09:10 -0400
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 6E9C5C5A46
        for <netdev@vger.kernel.org>; Fri, 14 Jul 2017 01:09:08 +0200 (CEST)
Received: by mail-oi0-f43.google.com with SMTP id x187so58743220oig.3
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 16:09:08 -0700 (PDT)
In-Reply-To: <0d78303a-31b2-f59c-2b47-0e684ff0f629@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 July 2017 at 15:38, Greg Rose <gvrose8192@gmail.com> wrote:
> On 07/13/2017 11:03 AM, Joe Stringer wrote:
>>
>> On 13 July 2017 at 11:01, Greg Rose <gvrose8192@gmail.com> wrote:
>>>
>>> On 07/13/2017 10:46 AM, Joe Stringer wrote:
>>>>
>>>>
>>>> On 13 July 2017 at 09:25, Greg Rose <gvrose8192@gmail.com> wrote:
>>>>>
>>>>>
>>>>> When there is an established connection in direction A->B, it is
>>>>> possible to receive a packet on port B which then executes
>>>>> ct(commit,force) without first performing ct() - ie, a lookup.
>>>>> In this case, we would expect that this packet can delete the existing
>>>>> entry so that we can commit a connection with direction B->A. However,
>>>>> currently we only perform a check in skb_nfct_cached() for whether
>>>>> OVS_CS_F_TRACKED is set and OVS_CS_F_INVALID is not set, ie that a
>>>>> lookup previously occurred. In the above scenario, a lookup has not
>>>>> occurred but we should still be able to statelessly look up the
>>>>> existing entry and potentially delete the entry if it is in the
>>>>> opposite direction.
>>>>>
>>>>> This patch extends the check to also hint that if the action has the
>>>>> force flag set, then we will lookup the existing entry so that the
>>>>> force check at the end of skb_nfct_cached has the ability to delete
>>>>> the connection.
>>>>>
>>>>> CC: dev@openvswitch.org
>>>>> CC: Pravin Shalar <pshelar@nicira.com>
>>>>> Signed-off-by: Joe Stringer <joe@ovn.org>
>>>>> Signed-off-by: Greg Rose <gvrose8192@gmail.com>
>>>>> ---
>>>>
>>>>
>>>>
>>>> A couple more administrative notes, on netdev the module name in the
>>>> patch subject for openvswitch is "openvswitch" rather than datapath;
>>>
>>>
>>>
>>> Right you are.
>>>
>>>> and patches rather than having just "PATCH" as the subject prefix
>>>> should state the tree. In this case, it's a bugfix so it should be
>>>> "PATCH net".
>>>
>>>
>>>
>>> I knew that... forgot the format patch option to add it.  Net-next
>>> is closed so that would be mandatory.
>>>
>>>   Furthermore, if you're able to figure out which commit
>>>>
>>>>
>>>> introduced the issue (I believe it's introduced by the force commit
>>>> patch), then you should place the "Fixes: " tag. I can give you some
>>>> pointers off-list on how to do this (git blame and some basic
>>>> formatting of the targeted patch should do the trick - this tag
>>>> expects a 12-digit hash).
>>>>
>>>> For reference, I ended up looking it up during review, this is the
>>>> line you'd add:
>>>> Fixes: dd41d33f0b03 ("openvswitch: Add force commit.")
>>>
>>>
>>>
>>> Oh, thanks!
>>>
>>>
>>>>
>>>>>    net/openvswitch/conntrack.c | 12 ++++++++----
>>>>>    1 file changed, 8 insertions(+), 4 deletions(-)
>>>>>
>>>>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>>>>> index 08679eb..9041cf8 100644
>>>>> --- a/net/openvswitch/conntrack.c
>>>>> +++ b/net/openvswitch/conntrack.c
>>>>> @@ -641,17 +641,21 @@ static bool skb_nfct_cached(struct net *net,
>>>>>           ct = nf_ct_get(skb, &ctinfo);
>>>>>           /* If no ct, check if we have evidence that an existing
>>>>> conntrack entry
>>>>>            * might be found for this skb.  This happens when we lose a
>>>>> skb->_nfct
>>>>> -        * due to an upcall.  If the connection was not confirmed, it
>>>>> is
>>>>> not
>>>>> -        * cached and needs to be run through conntrack again.
>>>>> +        * due to an upcall, or if the direction is being forced.  If
>>>>> the
>>>>> +        * connection was not confirmed, it is not cached and needs to
>>>>> be
>>>>> run
>>>>> +        * through conntrack again.
>>>>>            */
>>>>> -       if (!ct && key->ct_state & OVS_CS_F_TRACKED &&
>>>>> +       if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
>>>>>               !(key->ct_state & OVS_CS_F_INVALID) &&
>>>>> -           key->ct_zone == info->zone.id) {
>>>>> +            key->ct_zone == info->zone.id) ||
>>>>> +            (!key->ct_state && info->force)) {
>>>>>                   ct = ovs_ct_find_existing(net, &info->zone,
>>>>> info->family, skb,
>>>>>                                             !!(key->ct_state
>>>>>                                                & OVS_CS_F_NAT_MASK));
>>>>>                   if (ct)
>>>>>                           nf_ct_get(skb, &ctinfo);
>>>>> +               else
>>>>> +                       return false;
>>>>>           }
>>>>>           if (!ct)
>>>>>                   return false;
>>>>
>>>>
>>>>
>>>> I was just wondering if this has the potential to prevent
>>>> nf_conntrack_in() from being called at all in this case, which is also
>>>> not quite right. In the original case of (!ct && (key->ct_state &
>>>> OVS_CS_F_TRACKED) && !(key->ct_state & OVS_CS_F_TRACKED)), which I'll
>>>> refer to as "ct_executed", we explicitly want to avoid running
>>>> nf_conntrack_in() if we already ran it, because the connection tracker
>>>> doesn't expect to see the same packet twice (there's also things like
>>>> stats/accounting, and potentially L4 state machines that could get
>>>> messed up by multiple calls). By the time the info->force and
>>>> direction check happens at the end of the function, "ct_executed" is
>>>> implied to be true. However, in this new case, ct_executed is actually
>>>> false - because there was no ct() before the ct(force,commit). In this
>>>> case, we only want to look up the existing entry to see if it should
>>>> be deleted; if it should not be deleted, then we still haven't yet
>>>> done the nf_conntrack_in() call so we should return false and the
>>>> caller, __ovs_ct_lookup() should make the call to nf_conntrack_in().
>>>>
>>>> What I mean is something like the following incremental on your patch:
>>>>
>>>> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
>>>> index 9041cf8b822f..98783f114824 100644
>>>> --- a/net/openvswitch/conntrack.c
>>>> +++ b/net/openvswitch/conntrack.c
>>>> @@ -637,6 +637,7 @@ static bool skb_nfct_cached(struct net *net,
>>>> {
>>>>          enum ip_conntrack_info ctinfo;
>>>>          struct nf_conn *ct;
>>>> +       bool ct_executed;
>>>>
>>>>          ct = nf_ct_get(skb, &ctinfo);
>>>>          /* If no ct, check if we have evidence that an existing
>>>> conntrack
>>>> entry
>>>> @@ -645,10 +646,10 @@ static bool skb_nfct_cached(struct net *net,
>>>>           * connection was not confirmed, it is not cached and needs to
>>>> be
>>>> run
>>>>           * through conntrack again.
>>>>           */
>>>> -       if ((!ct && (key->ct_state & OVS_CS_F_TRACKED) &&
>>>> -           !(key->ct_state & OVS_CS_F_INVALID) &&
>>>> -            key->ct_zone == info->zone.id) ||
>>>> -            (!key->ct_state && info->force)) {
>>>> +       ct_executed = key->ct_state & OVS_CS_F_TRACKED &&
>>>> +                     !(key->ct_state & OVS_CS_F_INVALID) &&
>>>> +                     key->ct_zone == info->zone.id;
>
>
> This part seems fine - I'm OK with setting a boolean on all the complex
> conditionals *but* we shouldn't be doing that if ct is set.  And this is
> fast path right?  So this code is losing the 'if (!ct...)' and that is
> one of the first things checked.  When I was debugging ct would often
> be set because of the first pass through ovs_ct_execute had done the
> ovs_ct_lookup() call.  I'm not very comfortable with executing the
> code to set the ct_executed variable without first checking if ct
> was set in the call to nf_ct_get().
>
> I'll incorporate your suggestion but include something to skip all the
> conditionals if ct is set unless you can see some reason not to.

OK, fair enough. I wasn't overly careful in my incremental about the
specific ordering of these checks. Thanks for looking it over.
