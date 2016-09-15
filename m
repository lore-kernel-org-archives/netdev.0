From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/5] Make /sys/class/net per net namespace objects belong to container
Date: Thu, 15 Sep 2016 18:26:08 -0500
Message-ID: <87r38k219r.fsf@x220.int.ebiederm.org>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
        <20160819.165917.2302741905893802825.davem@davemloft.net>
        <87zinvpx5s.fsf@x220.int.ebiederm.org>
        <CAKdAkRTUjukVkXhMSPQ1YObRRVj0Fzvqivky_q34VCD9XRJdow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36686 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbcIOXjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:39:46 -0400
In-Reply-To: <CAKdAkRTUjukVkXhMSPQ1YObRRVj0Fzvqivky_q34VCD9XRJdow@mail.gmail.com>
        (Dmitry Torokhov's message of "Wed, 14 Sep 2016 20:24:09 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Torokhov <dmitry.torokhov@gmail.com> writes:

> On Mon, Aug 29, 2016 at 5:38 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
>>> Date: Tue, 16 Aug 2016 15:33:10 -0700
>>>
>>>> There are objects in /sys hierarchy (/sys/class/net/) that logically belong
>>>> to a namespace/container. Unfortunately all sysfs objects start their life
>>>> belonging to global root, and while we could change ownership manually,
>>>> keeping tracks of all objects that come and go is cumbersome. It would
>>>> be better if kernel created them using correct uid/gid from the beginning.
>>>>
>>>> This series changes kernfs to allow creating object's with arbitrary
>>>> uid/gid, adds get_ownership() callback to ktype structure so subsystems
>>>> could supply their own logic (likely tied to namespace support) for
>>>> determining ownership of kobjects, and adjusts sysfs code to make use of
>>>> this information. Lastly net-sysfs is adjusted to make sure that objects in
>>>> net namespace are owned by the root user from the owning user namespace.
>>>>
>>>> Note that we do not adjust ownership of objects moved into a new namespace
>>>> (as when moving a network device into a container) as userspace can easily
>>>> do it.
>>>
>>> I need some domain experts to review this series please.
>>
>> I just came back from vacation and I will aim to take a look shortly.
>>
>> The big picture idea seems sensible.  Having a better ownship of sysfs
>> files that are part of a network namespace.  I will have to look at the
>> details to see if the implementation is similarly sensible.
>
> Eric,
>
> Did you find anything objectionable in the series or should I fix up
> the !CONFIG_SYSFS error in networking patch and resubmit?

Thank you for the ping, I put this patchset down and forgot to look
back.

The notion of a get_ownership call seems sensible.

At some level I am not a fan of setting the uids and gids on the sysfs
nodes as that requires allocation of an additional data structure and it
will increase the code of sysfs nodes.   Certainly I don't think we
should incur that cost if we are not using user namespaces.  sysfs nodes
can be expensive data wise because we sometimes have so many of them.
So skipping the setattr when uid == GLOBAL_ROOT_UID and gid ==
GLOBAL_ROOT_GID seems very desirable.  Perhaps that is just an
optimization in setattr, but it should be somewhere.

I would very much prefer it if we can find a way not to touch all of the
layers, in the stack.  As I recall it is the code in drivers/base/core.c
that creates the attributes.  So my gut feel says we want to export a
sysfs_setattr modeled after sysfs_chmod from sysfs.h and then just have
the driver core level perform the setattr calls for non-default uids and
gids.

Symlinks we don't need to worry about changing their ownership they are
globally read, write, execute.

As long as the chattr happens before the uevent is triggered the code
should be essentially race free in dealing with userspace.

I think that will lead to a simpler more comprehensible and more
maintainable implementation.  Hooking in where or near where the
namespace bits hook in seems excessively complicated (although there may
be a good reason for it) that I am forgetting.

Eric
