From: Jason Wang <jasowang@redhat.com>
Subject: Re: Use-after-free in TUNSETIFF
Date: Wed, 11 Sep 2013 00:45:16 -0400 (EDT)
Message-ID: <136460103.12094119.1378874716755.JavaMail.root@redhat.com>
References: <522FACCB.1040707@epitech.eu> <522FB273.1030506@epitech.eu> <20130911044355.GB13891@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wannes Rombouts <wannes.rombouts@epitech.eu>, davem@davemloft.net,
	edumazet@google.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	Kevin Soules <kevin.soules@epitech.eu>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:36011 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752665Ab3IKEpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 00:45:53 -0400
In-Reply-To: <20130911044355.GB13891@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> On Wed, Sep 11, 2013 at 01:59:47AM +0200, Wannes Rombouts wrote:
> > (I sent this email to security@kernel.org but they told me I should=
 send
> > it to you guys, so here you go.)
> >=20
> > Hi,
> >=20
> > I would like to report what I believe could be a potential CAP_NET_=
ADMIN
> > to ring0 privilege escalation.
> >=20
> > The bug is in the way tuntap interfaces are initialized, when given=
 an
> > invalid name they cause a use after free. Also software like vmware
> > allows for at least a freeze or kernel panic by a simple user but m=
ight
> > also allow privilege escalation.
> >=20
> > Very simple to test, this causes a crash:
> > # ip tuntap add dev %% mode tap
> > If it doesn't crash immediately wait a few seconds and try again.
> >=20
> >=20
> > We haven't managed to exploit the use after free yet, but we are st=
ill
> > working on it. At least it crashes even with the latest kernel 3.11=
 and
> > on different distros. (tested on Debian, Ubuntu and Arch) Looking a=
t the
> > source the bug seems quite old.
> >=20
> >=20
> > Here is our analysis:
> >=20
> > A user with CAP_NET_ADMIN calls ioctl with TUNSETIFF and an invalid=
 name
> > for example "%d%d".
> >=20
> > tun_set_iff starts to initialize the tun_struct.
> > http://lxr.free-electrons.com/source/drivers/net/tun.c#L1589
> >=20
> > It calls tun_flow_init which starts a timer with tun_flow_cleanup a=
s
> > callback. http://lxr.free-electrons.com/source/drivers/net/tun.c#L8=
52
> >=20
> > After this tun_set_iff calls register_netdevice which returns an er=
ror
> > because of the invalid name.
> >=20
> > This error causes the goto err_free_dev and the call to free_netdev=
=2E
> > This will free the tun_struct.
> >=20
> > Later, once the callback gets called it uses bad memory. Sometimes =
it
> > doesn=E2=80=99t get called because the timer_list has been compromi=
sed and we
> > get a kernel panic at:
> > http://lxr.free-electrons.com/source/kernel/timer.c?v=3D2.6.33#L949
> >=20
> > But it is possible to get some memory from userland that overlaps o=
nly
> > the beginning of the tun_struct without overwriting the timer_list
> > because there is a big array before it. Then it might be possible t=
o
> > exploit tun_flow_cleanup when it is called, but we didn't succeed y=
et.
> >=20
> > -------------------------------------------------------------------=
-----
> >=20
> >=20
> > This is the first time we try to exploit the kernel so we basically=
 suck
> > at this. I don't know if someone more skilled could do this easily =
or
> > not, but we'll keep trying and I'll let you know if we manage it.
> >=20
> > In the mean time please let us know what you think of this and of c=
ourse
> > we are very interested in the way this is patched. Please keep us i=
n the
> > loop.
> >=20
> > Of course we will be happy to assist in any way we can, feel free t=
o
> > ask! Also we would like to know when you think it would be reasonab=
le to
> > disclose and talk about this bug.
> >=20
> > Regards,
> >=20
> > Wannes 'wapiflapi' Rombouts
> > Kevin 'eax64' Soules
> >=20
> >=20
> >
>=20
> Thanks a lot for the report. So this one is easy to fix I think.
> Does the below patch help?
> However, looking at the error handling in that function,
> it looks like it could leak resources in many other ways.
> We probably need more patches on top to fix it properly.
>=20

True, I'm working on a patch to solve all of them. Will post soon
