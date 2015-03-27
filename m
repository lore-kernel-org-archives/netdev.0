From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next] fib: move fib_rules_cleanup_ops() under rtnl lock
Date: Fri, 27 Mar 2015 12:25:28 -0700
Message-ID: <CAHA+R7MJTz1-F2v1c+ZEkVQ_JX0Ey5dGAmCjR_N8rvVPbuM0Tg@mail.gmail.com>
References: <1427403769-31208-1-git-send-email-xiyou.wangcong@gmail.com>
	<55147E5D.2070600@redhat.com>
	<CAHA+R7P4-y4o5WuUwzfwd+LrrkdRdo2=UfXzYdgTrJ63qkaTVg@mail.gmail.com>
	<55148576.1010303@redhat.com>
	<CAHA+R7Na0BO=rQwFNy-M6pa=TfUXuMDiiwNzsevPpt5CUF=mqQ@mail.gmail.com>
	<CAHA+R7MKNcOOiAsV7iQ2WT=sXCmaM0FuJ0OuY_S8reP2K8hN=w@mail.gmail.com>
	<55149A99.6040704@redhat.com>
	<20150327120135.GC12265@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:36740 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753889AbbC0TZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 15:25:29 -0400
Received: by igbud6 with SMTP id ud6so29327507igb.1
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 12:25:28 -0700 (PDT)
In-Reply-To: <20150327120135.GC12265@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 5:01 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 03/26/15 at 04:47pm, Alexander Duyck wrote:
>> On 03/26/2015 04:05 PM, Cong Wang wrote:
>> >On Thu, Mar 26, 2015 at 3:32 PM, Cong Wang <cwang@twopensource.com> wrote:
>> >>On the other hand, the name rules_mod_lock already tells it is
>> >>just a protection for ops (module) register.
>> >I even doubt we really need rules_mod_lock, it is per netns,
>> >which is newly allocated when registering pernet and upper
>> >layer should guarantee no concurrent unregistering, so we
>> >probably only need to take rtnl lock.
>>
>> I'm adding Thomas as he was the original author for the code and might have
>> a better idea of what needs to be rtnl locked and what doesn't.  You should
>> probably CC him as well on the v2 patch.
>>
>> As far as why I am so focused on moving fib4_rules_exit it is because we
>> don't want to call that delete function until after the table has been
>> cleared.  Otherwise you end up triggering the external_flush and unmerge
>> code on a full table instead of an empty one.  The result is you end up
>> allocating a bunch of memory before you then turn around and free it.  So
>> even if you retain the rtnl_lock changes it would still be best to move
>> fib4_rules_exit call to the region after you have freed the FIB tables, but
>> before you free fib_table_hash.
>
> I agree with Alex. Reordering fib4_rules_exit() makes sense. Not only
> to fix this issue but also for the purpose of correct ordering of
> allocation and releasing.

I am surprised you guys only care this one issue, there are more
for me.

$subject already says this is net-next, nothing needs to worry
about backport.

>
> It is definitely also safe to move fib_rules_cleanup_ops() out of
> rules_mod_lock. It is the responsibility of whoever registers the
> rules that no rule is in use he calls fib_rules_unregister().
>
> I don't see why fib_rules should hold rtnl_lock upon delete for the
> caller. If the caller requires this protection it's up to him to
> provide it.

If not rtnl lock, then what prevents the race between netns unregistering
with rule add/del via netlink?

I know ops is removed from the list at that point, but ops->rules might be
still being traversed under rtnl lock:

                                         ops = lookup_rules_ops();
list_del_rcu(&ops->list);
                                         list_for_each_entry(ops->rules) {
fib_rules_cleanup_ops(ops);
