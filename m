From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Thu, 6 Oct 2016 12:01:15 -0700
Message-ID: <CAM_iQpX7fC0HWz2X2R7uZNeiD_rEAe4QcSQiK+YZEHF8jkGBBA@mail.gmail.com>
References: <20161002031349.GB2635@templeofstupid.com> <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com> <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
 <20161006061150.GA2525@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36675 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbcJFTBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 15:01:38 -0400
Received: by mail-it0-f67.google.com with SMTP id o19so2265336ito.3
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2016 12:01:37 -0700 (PDT)
In-Reply-To: <20161006061150.GA2525@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 5, 2016 at 11:11 PM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
>
> I'm not sure.  The reason I didn't take this approach from the outset is
> that all of TC's callers of tcf_register_action pass a pointer to a
> static structure as their *ops argument.  The existence of code that
> checks the action for uniqueness suggests that it's possible for
> tcf_register_action to get passed two identical tc_action_ops.  If that
> happens in the current code base, we'll also get passed a duplicate

Each tc action module has its own unique ops, and kernel doesn't allow
one module to register twice (either in parallel or not, see
add_unformed_module()), so we should not have a duplicated case.


> pernet_operations pointer.  The code in register_pernet_subsys() makes
> no attempt to check for duplicates.  If we add a pointer that's already
> in the list, and subsequently call unregister, the results seem
> undefined.  It looks like we'll remove the pernet_operations for the
> existing action, assuming we don't corrupt the list in the process.
>
> Is this actually safe?  If so, what corner case is the act->type /
> act->kind protecting us from?

ops->type and ops->kind should be unique too, user-space already
relies on this (tc action ls action xxx). The code exists probably just
for sanity check.

So please give that patch a try, let's see if we miss any other problem.

>
>> (Sorry that I don't have the environment to reproduce your bug)
>
> I'm sorry that I didn't do a good job of explaining how we end up in
> this situation in the first place.  I can give a few more details,
> because it may explain some of my concern about the request_module()
> call.
>
> The system that encounters this bug launches a bunch of containers from
> systemd on boot.  Each container creates a new user, net, pid, and mount
> namespace and begins its setup.  When the networking in all of these
> containers, each in a new netns, try to configure TC and no modules are
> loaded we end up with this race.
>
> I can also reproduce by unloading the modules, and then launching a
> bunch of processes that configure tc in new namespaces.
>
> Part of the desire to inhibit extra modprobe calls is that if hundreds
> of these all start at once on boot, it's really unnecessary to have all
> of the rest of them wait while lots of extra modprobe calls are forked
> by the kernel.

You can tell systemd to load these modules before starting these
containers to avoid blocking, no?

Thanks.
