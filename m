From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Mon, 30 Mar 2015 16:47:05 -0700
Message-ID: <CAHA+R7OC4dcOZaM1HJ_Z8xbkj0ic+P5APC91=dJnw9EXq3eu2Q@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
	<CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
	<55149A99.6040704@redhat.com>
	<20150327120135.GC12265@casper.infradead.org>
	<CAHA+R7MJTz1-F2v1c+ZEkVQ_JX0Ey5dGAmCjR_N8rvVPbuM0Tg@mail.gmail.com>
	<5515C6C4.4080200@redhat.com>
	<CAHA+R7Puss-BUG0gFdw+FnbaiXE6Rx=FJ8ccJ2JyJdNMz7H2bQ@mail.gmail.com>
	<5515D5E0.2060800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33727 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760AbbC3XrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 19:47:05 -0400
Received: by iecxy8 with SMTP id xy8so811202iec.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 16:47:05 -0700 (PDT)
In-Reply-To: <5515D5E0.2060800@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 3:12 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> On 03/27/2015 02:17 PM, Cong Wang wrote:
>>
>> On Fri, Mar 27, 2015 at 2:08 PM, Alexander Duyck
>> <alexander.h.duyck@redhat.com> wrote:
>>>
>>> This locking issue, if present, is separate from the original issue you
>>> reported.  I'm going to submit a patch to fix your original issue and you
>>> can chase this locking issue down separately if that is what you want to
>>> do.
>>
>> Make sure you really read my changelog, in case you don't:
>>
>> "
>> ops->rules_list is protected by rtnl_lock + RCU,
>> there is no reason to take net->rules_mod_lock here.
>> Also, ops->delete() needs to be called with rtnl_lock
>> too. The problem exists before, just it is exposed
>> recently due to the fib local/main table change.
>> "
>>
>> Sometimes people more easily miss the most obvious thing,
>> which is the first sentences of my changelog.
>
>
> I got that, but you are arguing in circles.  In the case of fib4 we already
> held the rtnl lock when all of this was called.  The delete bit only really
> applies to fib4 since that is the only rules setup that seems to implement
> that function.  As I said your "fix" was obscuring the original issue.  The
> original issue was that we were allocating in a cleanup path.  That is the
> first thing that needs to be fixed.

I never said it is a fib4-only issue, ops->rules_list is generic.
I know you don't care about anything beyond fib4, I do. :)


>
> The rtnl_lock or not is a secondary issue.  It may be a fix but it doesn't
> really address the original problem which was allocating in a cleanup path.
>

Unless you understand there are two original problems...


>>
>>> This way if someone ever decides to backport it they can actually fix the
>>> original issue without pulling in speculative fixes for the rtnl locking
>>> problem since we were already holding the lock for fib4.
>>>
>> Backporting is my guess of Thomas's point, you go too far beyond it.
>
>
> Backporting wasn't his issue.  From what I can tell he was okay with pulling
> the fib_rules_cleanup_ops outside of the rules_mode_lock, I am as well since
> I believe that is only there because that used to be in a loop that would
> walk through a list looking for ops in order to delete it.  Since the list
> walk is gone you could just hold the lock for the list_del_rcu and you are
> good.


Quote from my previous reply:
"
I know ops is removed from the list at that point, but ops->rules might be
still being traversed under rtnl lock:

                                         ops = lookup_rules_ops();
list_del_rcu(&ops->list);
                                         list_for_each_entry(ops->rules) {
fib_rules_cleanup_ops(ops);
"

Pulling it out of mod_lock is one step, move it under rtnl lock is the second.

>
> The point he was trying to get at is that you should not make the rtnl_lock
> a part of fib_rules_unregster.  If someone is calling it in clean-up and
> requires it they should be taking the rtnl_lock like we did in fib4.  The
> issue is fib_rules_unregister is also called in the exception path for init
> and the rtnl_lock isn't necessary in that path.

This is trivial to solve, you are free to invent __fib_rules_unregister()
if you want.


>
>> Also, you have a different definition of original issue.
>
>
> Yes.  You reported a sleeping function called from invalid context, and you
> were fixing it by splitting up the rtnl_lock/unlock section in fib4
> unnecessarily which opens us up to other possible races, and left the
> function expensive and bloated as it was performing allocations in a
> clean-up path.

Sounds like it is me who called fib_unmerge(), ouch. ;)


>
> I've submitted patches for the issue I cared about so once those patches are
> applied feel free to try and address the rtnl_lock issue separately, however
> I would prefer it if you didn't split up the locking between the table
> freeing and the unregister as it should really all be done as one
> transaction without having to release and reacquire the RTNL lock in the
> middle of it.

As long as we agree rtnl lock should be taken, you already take my point
here ($subject says so).

It is just API change to move rtnl_lock up to caller or whatever appropriate.
