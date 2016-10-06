From: Krister Johansen <kjlx@templeofstupid.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Wed, 5 Oct 2016 23:11:50 -0700
Message-ID: <20161006061150.GA2525@templeofstupid.com>
References: <20161002031349.GB2635@templeofstupid.com>
 <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com>
 <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krister Johansen <kjlx@templeofstupid.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sub5.mail.dreamhost.com ([208.113.200.129]:49289 "EHLO
        homiemail-a59.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751562AbcJFGLx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 02:11:53 -0400
Received: from homiemail-a59.g.dreamhost.com (localhost [127.0.0.1])
        by homiemail-a59.g.dreamhost.com (Postfix) with ESMTP id 595316000F3C
        for <netdev@vger.kernel.org>; Wed,  5 Oct 2016 23:11:52 -0700 (PDT)
Received: from kmjvbox (c-73-202-117-160.hsd1.ca.comcast.net [73.202.117.160])
        (using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
        (No client certificate requested)
        (Authenticated sender: kjlx@templeofstupid.com)
        by homiemail-a59.g.dreamhost.com (Postfix) with ESMTPSA id E23D96002442
        for <netdev@vger.kernel.org>; Wed,  5 Oct 2016 23:11:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2016 at 11:01:38AM -0700, Cong Wang wrote:
> On Tue, Oct 4, 2016 at 11:52 PM, Krister Johansen
> <kjlx@templeofstupid.com> wrote:
> > On Mon, Oct 03, 2016 at 11:22:33AM -0700, Cong Wang wrote:
> >> Please try the attached patch. I also convert the read path to RCU
> >> to avoid a possible deadlock. A quick test shows no lockdep splat.
> >
> > I tried this patch, but it doesn't solve the problem.  I got a panic on
> > my very first try:
> 
> Thanks for testing it.

Absolutely; thanks for helping to try to simplify this fix.

> > The problem here is the same as before: by using RCU the race isn't
> > fixed because the module is still discoverable from act_base before the
> > pernet initialization is completed.
> >
> > You can see from the trap frame that the first two arguments to
> > tcf_hash_check were 0.  It couldn't look up the correct per-subsystem
> > pointer because the id hadn't yet been registered.
> 
> I thought the problem is that we don't do pernet ops registration and
> action ops registration atomically therefore chose to use mutex+RCU,
> but I was wrong, the problem here is just ordering, we need to finish
> the pernet initialization before making action ops visible.
> 
> If so, why not just reorder them? Does the attached patch make any
> sense now? Our pernet init doesn't rely on act_base, so even we have
> some race, the worst case is after we initialize the pernet netns for an
> action but its ops still not visible, which seems fine (at least no crash).
> 
> Or I still miss something here?

I'm not sure.  The reason I didn't take this approach from the outset is
that all of TC's callers of tcf_register_action pass a pointer to a
static structure as their *ops argument.  The existence of code that
checks the action for uniqueness suggests that it's possible for
tcf_register_action to get passed two identical tc_action_ops.  If that
happens in the current code base, we'll also get passed a duplicate
pernet_operations pointer.  The code in register_pernet_subsys() makes
no attempt to check for duplicates.  If we add a pointer that's already
in the list, and subsequently call unregister, the results seem
undefined.  It looks like we'll remove the pernet_operations for the
existing action, assuming we don't corrupt the list in the process.

Is this actually safe?  If so, what corner case is the act->type /
act->kind protecting us from?

> (Sorry that I don't have the environment to reproduce your bug)

I'm sorry that I didn't do a good job of explaining how we end up in
this situation in the first place.  I can give a few more details,
because it may explain some of my concern about the request_module()
call.

The system that encounters this bug launches a bunch of containers from
systemd on boot.  Each container creates a new user, net, pid, and mount
namespace and begins its setup.  When the networking in all of these
containers, each in a new netns, try to configure TC and no modules are
loaded we end up with this race.

I can also reproduce by unloading the modules, and then launching a
bunch of processes that configure tc in new namespaces.

Part of the desire to inhibit extra modprobe calls is that if hundreds
of these all start at once on boot, it's really unnecessary to have all
of the rest of them wait while lots of extra modprobe calls are forked
by the kernel.

> Thanks for your patience and testing!

Thank you for taking the time to look through the fix and discuss
alternatives.

-K
