From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Use-after-free in TUNSETIFF
Date: Wed, 11 Sep 2013 07:43:55 +0300
Message-ID: <20130911044355.GB13891@redhat.com>
References: <522FACCB.1040707@epitech.eu>
 <522FB273.1030506@epitech.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	Kevin Soules <kevin.soules@epitech.eu>
To: Wannes Rombouts <wannes.rombouts@epitech.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754933Ab3IKEmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 00:42:23 -0400
Content-Disposition: inline
In-Reply-To: <522FB273.1030506@epitech.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 01:59:47AM +0200, Wannes Rombouts wrote:
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
> doesn=E2=80=99t get called because the timer_list has been compromise=
d and we
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
>=20
> Regards,
>=20
> Wannes 'wapiflapi' Rombouts
> Kevin 'eax64' Soules
>=20
>=20
>

Thanks a lot for the report. So this one is easy to fix I think.
Does the below patch help?
However, looking at the error handling in that function,
it looks like it could leak resources in many other ways.
We probably need more patches on top to fix it properly.

-->

tun: cleanup flow on set_iff error path

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index b7c457a..c0470c1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1660,11 +1660,11 @@ static int tun_set_iff(struct net *net, struct =
file *file, struct ifreq *ifr)
 		INIT_LIST_HEAD(&tun->disabled);
 		err =3D tun_attach(tun, file);
 		if (err < 0)
-			goto err_free_dev;
+			goto err_free_flow;
=20
 		err =3D register_netdevice(tun->dev);
 		if (err < 0)
-			goto err_free_dev;
+			goto err_free_flow;
=20
 		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
@@ -1708,7 +1708,9 @@ static int tun_set_iff(struct net *net, struct fi=
le *file, struct ifreq *ifr)
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
=20
- err_free_dev:
+err_free_flow:
+	tun_flow_uninit(dev);
+err_free_dev:
 	free_netdev(dev);
 	return err;
 }
=20
