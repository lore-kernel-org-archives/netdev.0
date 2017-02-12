From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Fw: [Bug 193911] New: net_prio.ifpriomap is not aware of the network namespace, and discloses all network interface
Date: Mon, 13 Feb 2017 08:04:57 +1300
Message-ID: <87mvdrkz6u.fsf@xmission.com>
References: <20170203155330.06edece4@xeon-e3>
        <CAM_iQpVB_OvJy4Yz97MeOh9hNwm-mTG9aM1FWBpaaOmjroWvVw@mail.gmail.com>
        <20170206204728.GA23737@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        xgao01@email.wm.edu
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:36647 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdBLTJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 14:09:26 -0500
In-Reply-To: <20170206204728.GA23737@htj.duckdns.org> (Tejun Heo's message of
        "Mon, 6 Feb 2017 15:47:28 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <tj@kernel.org> writes:

> Hello,
>
> On Sun, Feb 05, 2017 at 11:05:36PM -0800, Cong Wang wrote:
>> > To be more specific, the read operation of net_prio.ifpriomap is handled by the
>> > function read_priomap. Tracing from this function, we can find it invokes
>> > for_each_netdev_rcu and set the first parameter as the address of init_net. It
>> > iterates all network devices of the host regardless of the network namespace.
>> > Thus, from the view of a container, it can read the names of all network
>> > devices of the host.
>> 
>> I think that is probably because cgroup files don't provide a net pointer
>> for the context, if so we probably need some API similar to
>> class_create_file_ns().
>
> Yeah, the whole thing never considered netns or delegation.  Maybe the
> read function itself should probably filter on the namespace of the
> reader?  I'm not completely sure whether trying to fix it won't cause
> some of existing use cases to break.  Eric, what do you think?

Apologies for the delay I just made it back from vacation.

There are cases where we do look at the reader/opener of the  file, and
it is a pain, almost always the best policy is to have the context fixed
at mount time.

I don't see an obvious answer of what better semantics for this file
should be.  Perhaps Docker can mount over this file on older kernels?

The namespace primitives that people build containers out of were never
guaranteed not to leak the fact that you are in a container.  So a small
essentially harmless information leak is not something I panic about.
It is the setting up of the container itself that must know what the
primitives do to ensure that leaks don't happen, if you want to avoid leaks.

That said if this controller/file does not consider netns and delegation
I suspect the right thing to do is put it under CONFIG_BROKEN or
possibly
CONFIG_I_REALLY_NEED_THIS_SILLY_CODE_FOR_BACKWARDS_COMPATIBILITY
aka CONFIG_STAGING and let the code age out of the kernel there.

If someone actually cares about this code and wants to fix it to do the
something reasonable and is willing to dig through all of the subtleties
I can help with that.  I may be wrong but the code feels like something
that just isn't interesting enough to make it worth fixing.

Eric
