From: Wannes Rombouts <wannes.rombouts@epitech.eu>
Subject: Use-after-free in TUNSETIFF
Date: Wed, 11 Sep 2013 01:59:47 +0200
Message-ID: <522FB273.1030506@epitech.eu>
References: <522FACCB.1040707@epitech.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Soules <kevin.soules@epitech.eu>
To: <davem@davemloft.net>, <jasowang@redhat.com>, <mst@redhat.com>,
	<edumazet@google.com>, <nhorman@tuxdriver.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe001.messaging.microsoft.com ([216.32.180.184]:19225
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750879Ab3IKAAQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 20:00:16 -0400
In-Reply-To: <522FACCB.1040707@epitech.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(I sent this email to security@kernel.org but they told me I should sen=
d
it to you guys, so here you go.)

Hi,

I would like to report what I believe could be a potential CAP_NET_ADMI=
N
to ring0 privilege escalation.

The bug is in the way tuntap interfaces are initialized, when given an
invalid name they cause a use after free. Also software like vmware
allows for at least a freeze or kernel panic by a simple user but might
also allow privilege escalation.

Very simple to test, this causes a crash:
# ip tuntap add dev %% mode tap
If it doesn't crash immediately wait a few seconds and try again.


We haven't managed to exploit the use after free yet, but we are still
working on it. At least it crashes even with the latest kernel 3.11 and
on different distros. (tested on Debian, Ubuntu and Arch) Looking at th=
e
source the bug seems quite old.


Here is our analysis:

A user with CAP_NET_ADMIN calls ioctl with TUNSETIFF and an invalid nam=
e
for example "%d%d".

tun_set_iff starts to initialize the tun_struct.
http://lxr.free-electrons.com/source/drivers/net/tun.c#L1589

It calls tun_flow_init which starts a timer with tun_flow_cleanup as
callback. http://lxr.free-electrons.com/source/drivers/net/tun.c#L852

After this tun_set_iff calls register_netdevice which returns an error
because of the invalid name.

This error causes the goto err_free_dev and the call to free_netdev.
This will free the tun_struct.

Later, once the callback gets called it uses bad memory. Sometimes it
doesn=92t get called because the timer_list has been compromised and we
get a kernel panic at:
http://lxr.free-electrons.com/source/kernel/timer.c?v=3D2.6.33#L949

But it is possible to get some memory from userland that overlaps only
the beginning of the tun_struct without overwriting the timer_list
because there is a big array before it. Then it might be possible to
exploit tun_flow_cleanup when it is called, but we didn't succeed yet.

-----------------------------------------------------------------------=
-


This is the first time we try to exploit the kernel so we basically suc=
k
at this. I don't know if someone more skilled could do this easily or
not, but we'll keep trying and I'll let you know if we manage it.

In the mean time please let us know what you think of this and of cours=
e
we are very interested in the way this is patched. Please keep us in th=
e
loop.

Of course we will be happy to assist in any way we can, feel free to
ask! Also we would like to know when you think it would be reasonable t=
o
disclose and talk about this bug.

Regards,

Wannes 'wapiflapi' Rombouts
Kevin 'eax64' Soules
