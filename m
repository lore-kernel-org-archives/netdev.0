From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Tue, 31 Mar 2015 09:47:09 -0700
Message-ID: <CAHA+R7Pg6K2horjg1wCCxyVqAcb0L7T3v=mnDnpb2Vqa-8VEfg@mail.gmail.com>
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
	<CAHA+R7OC4dcOZaM1HJ_Z8xbkj0ic+P5APC91=dJnw9EXq3eu2Q@mail.gmail.com>
	<5519E40F.6090708@redhat.com>
	<CAHA+R7MRhvwUcDqAPFRpO8JiEizp_EhUwKyK31MbfMOV=YpW7w@mail.gmail.com>
	<551A101C.8080005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:38665 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbbCaQrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 12:47:10 -0400
Received: by igbqf9 with SMTP id qf9so22631689igb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 09:47:09 -0700 (PDT)
In-Reply-To: <551A101C.8080005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 8:10 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
>
> On 03/30/2015 05:12 PM, Cong Wang wrote:
>>
>> On Mon, Mar 30, 2015 at 5:02 PM, Alexander Duyck
>> <alexander.h.duyck@redhat.com> wrote:
>>>
>>> On 03/30/2015 04:47 PM, Cong Wang wrote:
>>>>
>>>> As long as we agree rtnl lock should be taken, you already take my point
>>>> here ($subject says so).
>>>
>>>
>>> Yes, I agree lock can be held.  For fib4 it was already holding the RTNL
>>> lock when it made that call.  You can update the other users of
>>> fib_rules_unregister so that they call it with the RTNL lock held as
>>> well.
>>>
>>>> It is just API change to move rtnl_lock up to caller or whatever
>>>> appropriate.
>>>
>>>
>>> Right, so like I said for fib4 this is resolved.  That just leaves ipmr,
>>> ip6mr, fib6, and dn_rules that need to be updated so that they correctly
>>> handle the RTNL locking in their exit/cleanup paths. Since you already
>>> have
>>> some related patches out for these I will let you take them otherwise I
>>> might try to go through and clean them up next week.
>>>
>> Ok, then we are finally on the same page. We need two patches:
>>
>> 1) move unregister under rtnl lock (as what this patch intended to do)
>
>
> Yes I think the only disagreement was on how to do it.  Your original patch
> placed it in fib_rules_cleanup_ops, and the preference of myself and Thomas
> was to hold the lock before you even call fib_rules_unregister.  So the IPv4
> code is fine with the patch I submitted, it is the other callers of
> fib_rules_unregister which must be updated.

I never say your patch is not fine (except on the ops->delete issue which is
not related here) to fix it, as I said your patch only fixes one of the problems
I saw, that is it.

>
>> 2) remove the unnecessary rules_mod_lock
>>
>> Thanks.
>
>
> Please define "unnecessary" as we have had a bit of back and forth on how
> our views can differ there.  As far as I know it still has to be held for
> the fib_rule_ops list manipulation, specifically the call to list_del_rcu.
> However, it doesn't need to be held when we call fib_rules_cleanup_ops.
>

Look at where rules_mod_lock are held: either when the net is initialized
or when unregistering, neither of them really needs this per netns lock:
new netns is not ready to expose;
concurrent unregistering is prevented by upper layer locking,
readers (lookup_rules_ops) hold RCU but we already should hold rtnl lock
(after patch of course).
