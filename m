From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] Panic when tc_lookup_action_n finds a partially
 initialized action.
Date: Tue, 11 Oct 2016 10:51:04 -0700
Message-ID: <CAM_iQpUitQOD4v03zAC48HhXBRodVyx5htU3W1yd3+N3hc9yZg@mail.gmail.com>
References: <20161002031349.GB2635@templeofstupid.com> <CAM_iQpX1a1=3PmMAwMRDXpL3qjAskQ990FdxgyCg4T5p4=8G7Q@mail.gmail.com>
 <20161005065244.GA2245@templeofstupid.com> <CAM_iQpUya1ORUUNC9-spLKHjsjNyj6xHO79kvoDGaZcWT_mEwg@mail.gmail.com>
 <20161011092805.GA7837@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35649 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754160AbcJKSD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 14:03:58 -0400
Received: by mail-it0-f65.google.com with SMTP id l13so2087097itl.2
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 11:03:13 -0700 (PDT)
In-Reply-To: <20161011092805.GA7837@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 2:28 AM, Krister Johansen
<kjlx@templeofstupid.com> wrote:
> On Wed, Oct 05, 2016 at 11:01:38AM -0700, Cong Wang wrote:
>> Does the attached patch make any sense now? Our pernet init doesn't
>> rely on act_base, so even we have some race, the worst case is after
>> we initialize the pernet netns for an action but its ops still not
>> visible, which seems fine (at least no crash).
>
> I tried to reproduce the panic with this latest patch, but I am unable
> to do so.  The one difference I notice between this patch, and the one I

Nice, so the crash is fixed. I will send out my patch formally.

> sent to the list, is that with yours it takes much longer before we get
> any output from the simultaneous launch of these containers.  Presumably
> that's the extra latency added by allowing many extra modprobe calls to
> get spawned by request_module().

This is a different problem. When we register a pernet ops, the ops->init()
will be called on each container to initialize its pernet data structures,
this is why request_module() blocks on waiting for register_pernet_subsys()
to finish. As we discussed earlier, this could be solved or workaround by
loading modules prior to creating containers. Or if this really needs to be
fixed, it should be in register_pernet_subsys(), since it is not specific to
tc actions, we have so many places loading modules at run-time in
networking subsystem.

Thanks for testing!
