From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Getting a handle on all these new NIC features
Date: Wed, 18 Jan 2017 01:43:44 +0200
Message-ID: <CALzJLG_x_fpKAzFAfZLbuCRskqmMN-pnXhM7GbEQMxuyiUWRhw@mail.gmail.com>
References: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34512 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdAQXoa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:44:30 -0500
Received: by mail-qk0-f179.google.com with SMTP id a20so125434039qkc.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:44:05 -0800 (PST)
In-Reply-To: <CALx6S37YLY7-9YUTWBCBuLCWxbQL1=YURzqFZ00S1pb=2W9kFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 12:05 AM, Tom Herbert <tom@herbertland.com> wrote:
> There was some discussion about the problems of dealing with the
> explosion of NIC features in the mlx directory restructuring proposal,
> but I think the is a deeper issue here that should be discussed.
>
> It's hard not to notice that there has been quite a proliferation of
> NIC features in several drivers. This trend had resulted in very
> complex driver code that may or may not segment individual features.
> One visible manifestation of this is number of ndo functions which is
> somewhere around seventy-five now.
>
> I suspect the vast majority of these advances NIC features (e.g.
> bridging, UDP offloads, tc offload, etc.) are only relevant to some of
> the people some of the time. The problem we have, in this case those
> of us that are attempting to deploy and maintain NICs at scale, is
> when we have to deal with the ramifications of these features being
> intertwined with core driver functionality that is relevant to
> everyone. This becomes very obvious when we need to backport drivers
> from later versions of kernel.
>
> I realize that backports of a driver is not a specific concern of the
> Linux kernel, but nevertheless this is a real problem and a fact of
> life for many users. Rebasing the full kernel is still a major effort
> and it seems the best we could ever do is one rebase per year. In the
> interim we need to occasionally backport drivers. Backporting drivers
> is difficult precisely because of new features or API changes to
> existing ones. These sort of changes tend to have a spiderweb of
> dependencies in other parts of the stack so that the number of patches
> we need to cherry-pick goes way beyond those that touch the driver we
> are interested in.
>

I think backporting is not the only concern here, the other main issue
 is a pure software
design related that cannot just be ignored, device drivers are getting
smarter and
are doing lots of offloads and logic, they are not as thin as they
used to be, which is also a justification for why we should take a
second (stop coding for a while :-) ) and give this issue some
attention.

> Currently we (FB) need to backport two NIC drivers. I've already gave
> details of backporting mlx5 on the thread to restructure the driver
> directories. The other driver being backporting seems to suffer from
> the same type of feature complexity.
>

Can you share some more about the most complex stuff you faced while
backporting?
What would have made it simpler if we designed the driver differently ?

> In short, I would like to ask if driver maintainers to start to
> modularize driver features. If something being added is obviously a
> narrow feature that only a subset of users will need can we allow
> config options to #ifdef those out somehow? Furthermore can the file
> and directory structure of drivers reflect that; our lives would be
> _so_ much simpler to maintain drivers in production if we have such
> modularity and the ability to build drivers with the features of our
> choosing.
>

Before we do this or define the plan, there are some questions to be asked:
1. Can we allow ourselves to have kconfig or even an internal
compilation flag per device driver feature ?
2. What about previous features ? i mean in order to have a clean and
clear way to do have this isolation for new features, some kind of
restructuring or core reorganizing is required, it is ugly to have
driver with a hybrid structuring.
3. in case if we decide to do a restructuring phase as we suggested in
the mlx5 patch, what is the plan for older kernels who still backport
fixes to the previous structure.
4. What is the concrete plan ? is there a design reference or
guidelines known to someone that every one can follow ?

Anyway I would like to contribute some thoughts and design techniques
to achieve this moularization and features isolation by design ( at
least for new features):

Device initialization and netdev registration:
     - most of the device drivers have main.c which handles driver
initialization and netdev registration.
     - but today this file provide much more than the above.
     - I suggest to keep it as thin as possible and dedicated to what
it should do.
     - keep HAL (Hardware Abstraction Layer) separated from main.c and
main should call entry points exposed by the HAL layer.
     - basic netdev features RX/TX and most basic ndos for basic
Ethernet functionality can still be in main.c
      - Advanced features (eswitch,TC offloads, vxlan and tunneling
offloads, XDP, etc..) such features can go to separate file(s) with
full logic implementation and clear code locality wrapped by #ifdef
compilation or kconfig flag to have easy control on them and to give
the reviewer/developer a chance to logically understand the code and
distinguish between the different features by looking at the Makefile
or the c file including those features. ( just keep the feature logic
out of main.c)

I've been partially following the above technique, but this resulted
in a driver flat directory full of files (45 c files) in mlx5 !, which
is why we need restructuring and directory separation per sub driver
modules (eg. main,HAL,protocol, sriov, offloads).

I can back up my above suggestion with the example of sriov
implementation of mlx5:
mlx5 sriov is broken to 3 layers/files (sriov.c, eswitch.c and
eswitch_offloads.c)
sriov.c: Pure PCI sriov logic that serves both IB and ethernet link layers
eswitch.c: Ethernet eswitch sriov logic.
eswitch_offloads: New eswitch mode for switchdev offloads.

those 3 files together define the mlx5 sriov sub module. and such
break down give us the flexibility to extend each module functionality
separately and creates a modular isolation and one way dependency,
also it is pretty simple to pack them up with 1-2 kconfig flag to
disable sriov at all or even choose to specifically compile out
eswitch or eswitch_offladas.

I would be really glad to get some feedback of what others think on
the matter and some concrete suggestion of what we can do and if it is
possible to start refactoring the current code to achieve the above
and separate current advanced features from the basic driver code.

For your request Tom, I am totally in, and I would do my best to provide.

Thanks,
-Saeed.

> Thanks,
> Tom
