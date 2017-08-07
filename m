From: John Stultz <john.stultz@linaro.org>
Subject: unregister_netdevice: waiting for eth0 to become free. Usage count = 1
Date: Mon, 7 Aug 2017 14:05:48 -0700
Message-ID: <CALAqxLWVYgnTnwAwm7uNQ6P_Z8xFd96NQ+G_j1qT+h5F6habag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: lkml <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux USB List <linux-usb@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Felipe Balbi <felipe.balbi@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33929 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdHGVFt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:05:49 -0400
Received: by mail-qk0-f179.google.com with SMTP id u139so9709400qka.1
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 14:05:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, with recent testing with my HiKey board, I've been noticing some
quirky behavior with my USB eth adapter.

Basically, pluging the usb eth adapter in and then removing it, when
plugging it back in I often find that its not detected, and the system
slowly spits out the following message over and over:
  unregister_netdevice: waiting for eth0 to become free. Usage count = 1

I've tried to go through and bisect it, but apparently the issue isn't
always reproducible, as I'm apparently getting lots of false negatives
(where I can't always reproduce boot to boot the issue on the same
kernel).

I've done three bisection passes (always restarting with the "first
bad commit" from the previous bisection as the initial bad commit for
the following pass), and it does seem to keep moving back. But it
seems much easier to trigger with newer kernels then older (and so far
I've not seen it with 4.12).

Wanted to see if anyone had any ideas what might be going wrong, and
how I should further debug this.

The last bisect log I generated was:

# good: [6f7da290413ba713f0cdd9ff1a2a9bb129ef4f6c] Linux 4.12
git bisect good 6f7da290413ba713f0cdd9ff1a2a9bb129ef4f6c
# bad: [98fdd857a3bd6a3bf0003d3f68f07c25c85dcde3] net: ethernet: ti:
cpsw: move skb timestamp to packet_submit
git bisect bad 98fdd857a3bd6a3bf0003d3f68f07c25c85dcde3
# good: [48b6bbef9a1789f0365c1a385879a1fea4460016] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good 48b6bbef9a1789f0365c1a385879a1fea4460016
# good: [a2e8bbd2ef5457485f00b6b947bbbfa2778e5b1e] bpf: Fix
test_obj_id.c for llvm 5.0
git bisect good a2e8bbd2ef5457485f00b6b947bbbfa2778e5b1e
# good: [273889e306256e95ea55d5ebaef99310cf589def] Merge tag
'mlx5-updates-2017-06-16' of
git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux
git bisect good 273889e306256e95ea55d5ebaef99310cf589def
# bad: [8f46d46715a12f509e13200033a1ed4d6cf335ff] cxgb4: Use Firmware
params to get buffer-group map
git bisect bad 8f46d46715a12f509e13200033a1ed4d6cf335ff
# bad: [f5c306470ed0a8f03ba7017f397da2555b5800d4] Merge tag
'mlx5-updates-2017-06-20' of
git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux
git bisect bad f5c306470ed0a8f03ba7017f397da2555b5800d4
# bad: [e289ef0ded13021db292be9aef134451546e7c60] net: dsa: mv88e6xxx:
clarify SMI PHY functions
git bisect bad e289ef0ded13021db292be9aef134451546e7c60
# bad: [836d57e5c08e13bb206dcd559d96ee9355e8316e] liquidio: implement
vlan filter enable and disable
git bisect bad 836d57e5c08e13bb206dcd559d96ee9355e8316e
# bad: [ad65a2f05695aced349e308193c6e2a6b1d87112] ipv6: call
dst_hold_safe() properly
git bisect bad ad65a2f05695aced349e308193c6e2a6b1d87112
# good: [0830106c53900181d336350581119af09e123bf3] ipv4: take
dst->__refcnt when caching dst in fib
git bisect good 0830106c53900181d336350581119af09e123bf3
# good: [b838d5e1c5b6e57b10ec8af2268824041e3ea911] ipv4: mark DST_NOGC
and remove the operation of dst_free()
git bisect good b838d5e1c5b6e57b10ec8af2268824041e3ea911
# bad: [9514528d92d4cbe086499322370155ed69f5d06c] ipv6: call
dst_dev_put() properly
git bisect bad 9514528d92d4cbe086499322370155ed69f5d06c
# good: [1cfb71eeb12047bcdbd3e6730ffed66e810a0855] ipv6: take
dst->__refcnt for insertion into fib6 tree
git bisect good 1cfb71eeb12047bcdbd3e6730ffed66e810a0855
# first bad commit: [9514528d92d4cbe086499322370155ed69f5d06c] ipv6:
call dst_dev_put() properly


But again, reverting the "ipv6: call dst_dev_put() properly" commit
doesn't seem to completely resolve the issue on newer kernels (though
it may make it harder to trigger), and I suspect with further
bisection passes I might move further back.

Ideas?  I don't seem to have similar issues with USB mass storage
devices, so it seems to be networking specific.

thanks
-john
