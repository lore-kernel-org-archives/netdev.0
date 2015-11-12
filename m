From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Is ndo_do_ioctl still acceptable?
Date: Thu, 12 Nov 2015 05:59:03 +0100
Message-ID: <CAHmME9puHv8uaUKX4AOjEaTNN6bHqNKqvaCqubc5erk+jnDOEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David & Folks,

Soon I will submit a virtual tunnel device driver to LKML for review.
It uses rtnl_link_register to create a virtual network interface,
which then handles encryption, authentication, and some other things,
amongst various configured peers.

Right now the device is configurable via Netlink. It receives new
peers and configuration via a rtnl_link_ops->changelink function, and
it reports information back to userspace via a
rtnl_link_ops->fill_info function.

Configuration works fine, though it is rather cumbersome to do this
all via Netlink.

Reporting information back to userspace does not work fine. The reason
is that sometimes there's too much information to report back to
userspace than what can fit in a single preallocated Netlink skb. And
since rtnl_link_ops->fill_info doesn't receive any information from
userspace, I'm unable to use it to send back information in smaller
pieces.

I realize I could register a whole new rtnl packet family and related
set of functions with rtnl_register, such as what's done at the bottom
of `net/core/rtnetlink.c`. This is extremely cumbersome and invasive
though. It would require adding a new protocol family (like the
already existing rtnl_register-ified functions for PF_UNSPEC and
PF_BRIDGE), and I don't have enough clout to confidently submit a
patch that augments `include/linux/socket.h` with a new PF/AF define.
This seems very invasive and not appropriate for my driver.

What I'd really like to do is just implement ndo_do_ioctl. It seems to
me that this gives me a precise interface to do exactly what I want in
the cleanest and easiest to read possible way. I could have differing
ioctls for differing things. I could write memory back to userspace in
proper chunks, with the proper size. It's clear and straightforward
how to do it, and what the completed result looks like. It doesn't
require invasive changes into other parts of the kernel, as this would
be self-contained. It's hard to imagine a better interface to use than
ndo_do_ioctl.

But. But the word on the street is that kernel hipsters hate ioctls
and espouse the use of netlink everywhere with religious fervor, and
will burn at the stake any submissions I might send that go anywhere
near using ndo_do_ioctl rather than (the most likely ill-fitting for
the task) netlink. That, and the maintainers of the `ip` tool will be
upset too (even though they do already make use of several ioctls
instead of netlink). I'm told everybody will leer and jeer at me if I
use ndo_do_ioctl instead of netlink.

Except ndo_do_ioctl is *so* perfectly fitting here for my use case!

So what's the verdict on this? Do these aforementioned kernel hipsters
not really matter so much, and ndo_do_ioctl is actually perfectly
fine? Or must I really affix netlink onto my forthcoming submission?

Thanks,
Jason
