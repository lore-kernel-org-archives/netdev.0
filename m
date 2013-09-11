From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Use-after-free in TUNSETIFF
Date: Tue, 10 Sep 2013 17:32:57 -0700
Message-ID: <20130910173257.47e2dc08@nehalam.linuxnetplumber.net>
References: <522FACCB.1040707@epitech.eu>
	<522FB273.1030506@epitech.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <jasowang@redhat.com>, <mst@redhat.com>,
	<edumazet@google.com>, <nhorman@tuxdriver.com>,
	<netdev@vger.kernel.org>, Kevin Soules <kevin.soules@epitech.eu>
To: Wannes Rombouts <wannes.rombouts@epitech.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:53172 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab3IKAdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 20:33:03 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj1so8496638pad.14
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 17:33:01 -0700 (PDT)
In-Reply-To: <522FB273.1030506@epitech.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Sep 2013 01:59:47 +0200
Wannes Rombouts <wannes.rombouts@epitech.eu> wrote:

> (I sent this email to security@kernel.org but they told me I should s=
end
> it to you guys, so here you go.)
>=20
> Hi,
>=20
> I would like to report what I believe could be a potential CAP_NET_AD=
MIN
> to ring0 privilege escalation.
>=20
> The bug is in the way tuntap interfaces are initialized, when given a=
n
> invalid name they cause a use after free. Also software like vmware
> allows for at least a freeze or kernel panic by a simple user but mig=
ht
> also allow privilege escalation.
>=20
> Very simple to test, this causes a crash:
> # ip tuntap add dev %% mode tap
> If it doesn't crash immediately wait a few seconds and try again.
>=20
>=20
> We haven't managed to exploit the use after free yet, but we are stil=
l
> working on it. At least it crashes even with the latest kernel 3.11 a=
nd
> on different distros. (tested on Debian, Ubuntu and Arch) Looking at =
the
> source the bug seems quite old.
>=20
>=20
> Here is our analysis:
>=20
> A user with CAP_NET_ADMIN calls ioctl with TUNSETIFF and an invalid n=
ame
> for example "%d%d".
>=20
> tun_set_iff starts to initialize the tun_struct.
> http://lxr.free-electrons.com/source/drivers/net/tun.c#L1589
>=20
> It calls tun_flow_init which starts a timer with tun_flow_cleanup as
> callback. http://lxr.free-electrons.com/source/drivers/net/tun.c#L852
>=20
> After this tun_set_iff calls register_netdevice which returns an erro=
r
> because of the invalid name.
>=20
> This error causes the goto err_free_dev and the call to free_netdev.
> This will free the tun_struct.
>=20
> Later, once the callback gets called it uses bad memory. Sometimes it
> doesn=92t get called because the timer_list has been compromised and =
we
> get a kernel panic at:
> http://lxr.free-electrons.com/source/kernel/timer.c?v=3D2.6.33#L949
>=20
> But it is possible to get some memory from userland that overlaps onl=
y
> the beginning of the tun_struct without overwriting the timer_list
> because there is a big array before it. Then it might be possible to
> exploit tun_flow_cleanup when it is called, but we didn't succeed yet=
=2E
>=20
> ---------------------------------------------------------------------=
---
>=20
>=20
> This is the first time we try to exploit the kernel so we basically s=
uck
> at this. I don't know if someone more skilled could do this easily or
> not, but we'll keep trying and I'll let you know if we manage it.
>=20
> In the mean time please let us know what you think of this and of cou=
rse
> we are very interested in the way this is patched. Please keep us in =
the
> loop.
>=20
> Of course we will be happy to assist in any way we can, feel free to
> ask! Also we would like to know when you think it would be reasonable=
 to
> disclose and talk about this bug.

Thank you for the bug report.

I wouldn't go all security crazy, if you want to spend hours making an =
exploit
have fun, but it is a waste of time[1]. It is a simple bug introduced i=
n 3.8

commit c8d68e6be1c3b242f1c598595830890b65cea64a
Author: Jason Wang <jasowang@redhat.com>
Date:   Wed Oct 31 19:46:00 2012 +0000

    tuntap: multiqueue support


The fix isn't that hard, why don't you make a patch.

[1] A user with CAP_NET_ADMIN can basically hose the system many other =
ways.
Capabilities are a failed security model.
Almost all distro's limit CAP_NET_ADMIN to root anyway.
