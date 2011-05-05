From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 05 May 2011 17:34:43 +0800
Message-ID: <4DC26F33.8010700@cn.fujitsu.com>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au> <20110504232854.GA11687@rere.qmqm.pl> <20110505084428.GB17647@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56305 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752545Ab1EEJmp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 05:42:45 -0400
In-Reply-To: <20110505084428.GB17647@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote, at 05/05/2011 04:44 PM:
> On Thu, May 05, 2011 at 01:28:54AM +0200, Micha=C5=82 Miros=C5=82aw w=
rote:
>> On Thu, May 05, 2011 at 08:34:15AM +1000, Herbert Xu wrote:
>>> On Wed, May 04, 2011 at 09:18:14PM +0300, Michael S. Tsirkin wrote:
>>>> BTW, I just noticed that net-next spits out
>>>> many of the following when I run any VMs:
>>>>
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Features changed: 0x401b4849 -> 0x40004040
>>>> device msttap0 entered promiscuous mode
>>>> br0: Dropping NETIF_F_GSO since no SG feature.
>>>> br0: port 1(msttap0) entering forwarding state
>>>> br0: port 1(msttap0) entering forwarding state
>>>> tap0: Features changed: 0x40004040 -> 0x40024849
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Features changed: 0x40024849 -> 0x40004040
>>>> br0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Features changed: 0x40004040 -> 0x401b4849
>>>> tap0: Dropping NETIF_F_SG since no checksum feature.
>>>> tap0: Dropping NETIF_F_GSO since no SG feature.
>>>> tap0: Features changed: 0x401b4849 -> 0x40004040
>>>> br0: Dropping NETIF_F_GSO since no SG feature.
>>>>
>>>> My problem is not primarily with warnings:
>>>>
>>>> will that linearize all packets and disable GSO
>>>> for tap and bridge? If yes it can't be good
>>>> for performance...
>>> I think so.  So the question is why is checksum off?
>>
>> Whatever application is creating the tap0 device is not calling
>> ioctl(TUNSETOFFLOAD) with TUN_F_CSUM set. This is userspace bug/feat=
ure
>> exposed by recent changes to netdev features handling.
>>
>> Best Regards,
>> Micha=C5=82 Miros=C5=82aw
>=20
> No, I think it's not a bug in userspace. Here is what it does:
>=20
>     /* Check if our kernel supports TUNSETOFFLOAD */
>     if (ioctl(fd, TUNSETOFFLOAD, 0) !=3D 0 && errno =3D=3D EINVAL) {
>         return;
>     }
>=20
>     if (csum) {
>         offload |=3D TUN_F_CSUM;
>         if (tso4)
>             offload |=3D TUN_F_TSO4;
>         if (tso6)
>             offload |=3D TUN_F_TSO6;
>         if ((tso4 || tso6) && ecn)
>             offload |=3D TUN_F_TSO_ECN;
>         if (ufo)
>             offload |=3D TUN_F_UFO;
>     }
>=20
>     if (ioctl(fd, TUNSETOFFLOAD, offload) !=3D 0) {
>         offload &=3D ~TUN_F_UFO;
>         if (ioctl(fd, TUNSETOFFLOAD, offload) !=3D 0) {
>             fprintf(stderr, "TUNSETOFFLOAD ioctl() failed: %s\n",
>                     strerror(errno));
>         }
>     }
>=20
> The first call is just to check that ioctl works.
> When checking for ioctl in this way, userspace clears checksum.
> This will clear SG and thus GSO; later userspace enables checksum.
> checksum is on but SG is by now disabled so GSO gets cleared again to=
o.
>=20
>=20
> It's also likely a problem that
> userspace can trigger warnings in log for what used to be
> a legal way to check for ioctl and/or disable checksum offloading,
> but that is more minor.

Maybe it's a kernel bug. Can you try following changes?

TUN_F_TSO4, TUN_F_TSO6, TUN_F_TSO_ECN, TUN_F_UFO these features are=20
depend on NETIF_F_SG. If NETIF_F_SG is not set, these features are not =
be
enabled and  warnings are printed in netdev_fix_features().


diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0636f70..eea92e0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1178,7 +1178,7 @@ static int set_offload(struct tun_struct *tun, un=
signed long arg)
        u32 features =3D 0;
=20
        if (arg & TUN_F_CSUM) {
-               features |=3D NETIF_F_HW_CSUM;
+               features |=3D NETIF_F_HW_CSUM | NETIF_F_SG;
                arg &=3D ~TUN_F_CSUM;
=20
                if (arg & (TUN_F_TSO4|TUN_F_TSO6)) {


--=20
Best Regards
-----
Shan Wei
