From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net-next v3] net_sched: move the empty tp check from ->destroy()
 to ->delete()
Date: Wed, 19 Apr 2017 01:55:01 +0200
Message-ID: <58F6A755.2000306@iogearbox.net>
References: <1492453840-15816-1-git-send-email-xiyou.wangcong@gmail.com> <58F64669.1080608@iogearbox.net> <CAM_iQpV14UyknX8DywDxQGA4xRNspqWzag+t49wW9-N2W=cgmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>, lucasb@mojatatu.com
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37642 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754025AbdDRXzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 19:55:04 -0400
In-Reply-To: <CAM_iQpV14UyknX8DywDxQGA4xRNspqWzag+t49wW9-N2W=cgmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 10:55 PM, Cong Wang wrote:
> On Tue, Apr 18, 2017 at 10:01 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> Hi Cong,
>>
>> sorry for the late reply. Generally the patch looks good to me, just
>> a few comments inline:
>>
>> On 04/17/2017 08:30 PM, Cong Wang wrote:
>>>
>>> Roi reported we could have a race condition where in ->classify() path
>>> we dereference tp->root and meanwhile a parallel ->destroy() makes it
>>> a NULL.
>>
>> Correct.
>>
>>> This is possible because ->destroy() could be called when deleting
>>> a filter to check if we are the last one in tp, this tp is still
>>> linked and visible at that time.
>>>
>>> Daniel fixed this in commit d936377414fa
>>> ("net, sched: respect rcu grace period on cls destruction"), but
>>> the root cause of this problem is the semantic of ->destroy(), it
>>> does two things (for non-force case):
>>>
>>> 1) check if tp is empty
>>> 2) if tp is empty we could really destroy it
>>>
>>> and its caller, if cares, needs to check its return value to see if
>>> it is really destroyed. Therefore we can't unlink tp unless we know
>>> it is empty.
>>>
>>> As suggested by Daniel, we could actually move the test logic to
>>> ->delete()
>>> so that we can safely unlink tp after ->delete() tells us the last one is
>>> just deleted and before ->destroy().
>>>
>>> What's more, even we unlink it before ->destroy(), it could still have
>>> readers since we don't wait for a grace period here, we should not modify
>>> tp->root in ->destroy() either.
>>
>> Here seems to be a bit of a mixup in this analysis, imo. The issue
>> that Roi reported back then was exactly the one that d936377414fa ("net,
>> sched: respect rcu grace period on cls destruction") fixed, which
>> affected flower and other classifiers:
>>
>>      Roi reported a crash in flower where tp->root was NULL in ->classify()
>>      callbacks. Reason is that in ->destroy() tp->root is set to NULL via
>>      RCU_INIT_POINTER(). It's problematic for some of the classifiers,
>> because
>>      this doesn't respect RCU grace period for them, and as a result, still
>>      outstanding readers from tc_classify() will try to blindly dereference
>>      a NULL tp->root.
>>
>> The ->delete() callback was never used by Roi back then, he said that
>> he just removed the ingress qdisc in his test, which implicitly purges
>> all cls attached to it via tcf_destroy_chain(). So the above description
>> with regards to the "root cause" of Roi's reported issue is not correct.
>
> Hmm, thanks for clarifying this, I will remove this part, together with the
> Reported-by of Roi.
>
>> The issue that this patch fixes is an _independent_ race that we found
>> while auditing the code when looking into Roi's report back then. It
>> fixes commit 1e052be69d04 ("net_sched: destroy proto tp when all filters
>> are gone"), which added the RCU_INIT_POINTER() after the tcf_destroy() in
>> RTM_DELTFILTER case. That part of the description looks good, where you
>> describe that "[...] we need to move the test logic to ->delete(), so
>> that we can safely unlink tp after ->delete() tells us the last one is
>> just deleted and before ->destroy()."
>
> OK.
>
>> Please also add Fixes tag, so it can be better tracked for backports.
>>
>> Fixes: 1e052be69d04 ("net_sched: destroy proto tp when all filters are
>> gone")
>
> Actually I intentionally remove the Fixes tag because I don't think we
> need to backport it to stable as no one reports a _real_ crash so far,
> right? Or you saw a real one?
>
> (Not to mention its size does not fit for -stable either.)

I don't think anyone reported a crash on this. I think net-next is
fine, but still the Fixes tag helps keeping track of bug fixes (we
usually do this for net-next too when applicable, it certainly doesn't
hurt and helps identifying follow-ups to a certain commit), f.e. for
others backporting this to their kernels (outside of the scope of
upstream stable).

>> The above three RCU_INIT_POINTER(tp->root, NULL) are independent
>> of the fix and actually do no harm right now. I described that in
>> d936377414fa ("net, sched: respect rcu grace period on cls destruction")
>> as well, meaning that they each handle tp->root being NULL in ->classify()
>> path (for historic reasons), so this is handled gracefully, readers use
>> rcu_dereference_bh(tp->root) and test for this being NULL.
>>
>> But I agree that this could be cleaned up along with the check in the
>> ->classify() callbacks for these three (not sure if really worth it,
>> though). However, such cleanup should be a separate patch and not
>> included in this fix.
>
> Agreed. I will make it a separated patch and send them together.

Okay, sounds good thanks!
