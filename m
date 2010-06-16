From: Pedro Garcia <pedro.netdev@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Wed, 16 Jun 2010 10:49:27 +0200
Message-ID: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <1276466190.14011.223.camel@localhost> <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com> <1276534945.2074.11.camel@achroite.uk.solarflarecom.com> <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:58819
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754820Ab0FPItc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 04:49:32 -0400
In-Reply-To: <1276542772.2444.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jun 2010 21:12:52 +0200, Eric Dumazet <eric.dumazet@gmail.co=
m>
wrote:
> Le lundi 14 juin 2010 =C3=A0 19:11 +0200, Patrick McHardy a =C3=A9cri=
t :
>> Ben Hutchings wrote:
>> > On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
>> >  =20
>> >> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
>> >> <bhutchings@solarflare.com> wrote:
>> >>    =20
>> >>> I have no particular opinion on this change, but you need to rea=
d and
>> >>> follow Documentation/SubmittingPatches.
>> >>>
>> >>> Ben.
>> >>>      =20
>> >> Sorry, first kernel patch, and I did not know about it. I resubmi=
t
>> >> with
>> >> the correct style / format:
>> >>    =20
>> > [...]
>> >
>> > Sorry, no you haven't.
>> >
>> > - Networking changes go through David Miller's net-next-2.6 tree s=
o you
>> > need to use that as the baseline, not 2.6.26
>> > - Patches should be applicable with -p1, not -p0 (so if you use di=
ff,
>> > you should run it from one directory level up)
>> > - The patch was word-wrapped
>>=20
>> Additionally:
>>=20
>> - please use the proper comment style, meaning each line begins
>>   with a '*'
>>=20
>> - the pr_debug statements may be useful for debugging, but are
>>   a bit excessive for the final version
>>=20
>> - + /* 2010-06-13: Pedro Garcia
>>=20
>>    We have changelogs for this, simply explaining what the code
>>    does is enough.
>>=20
>> - Please CC the maintainer (which is me)
>> --
>=20
> Pedro, we have two kind of vlan setups :
>=20
> accelerated and non accelerated ones.
>=20
> Your patch address non accelated ones only, since you only touch
> vlan_skb_recv()
>=20
> Accelerated vlan can follow these paths :
>=20
> 1) NAPI devices
>=20
> vlan_gro_receive() -> vlan_gro_common()
>=20
> 2) non NAPI devices
>=20
> __vlan_hwaccel_rx()=20
>=20
> So you might also patch __vlan_hwaccel_rx() and vlan_gro_common()
>=20
> Please merge following bits to your patch submission :
>=20
> http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868
>=20
>=20
> Good luck for your first patch !

Here it is again. I added the modifications in http://kerneltrap.org/ma=
ilarchive/linux-netdev/2010/5/23/6277868 for HW accelerated incoming pa=
ckets (it did not apply cleanly on the last version of
the kernel, so I applied manually). Now, if the VLAN 0 is not explicitl=
y created by the user, VLAN 0 packets will be treated as no VLAN (802.1=
p packets), instead of dropping them.

The patch is now for two files: vlan_core (accel) and vlan_dev (non acc=
el)

I can not test on HW accelerated devices, so if someone can check it I =
will appreciate (even though in the thread above it looked like yes). F=
or non accel I tessted in 2.6.26. Now the patch is for
net-next-2.6, and it compiles OK, but I a have to setup a test environm=
ent to check it is still OK (should, but better to test).

Signed-off-by: Pedro Garcia <pedro.netdev@dondevamos.com>
--
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 50f58f5..daaca31 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -8,6 +8,9 @@
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
                      u16 vlan_tci, int polling)
 {
+       struct net_device *vlan_dev;
+       u16 vlan_id;
+
        if (netpoll_rx(skb))
                return NET_RX_DROP;
=20
@@ -16,10 +19,14 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct v=
lan_group *grp,
=20
        skb->skb_iif =3D skb->dev->ifindex;
        __vlan_hwaccel_put_tag(skb, vlan_tci);
-       skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MAS=
K);
+       vlan_id =3D vlan_tci & VLAN_VID_MASK;
+       vlan_dev =3D vlan_group_get_device(grp, vlan_id);
=20
-       if (!skb->dev)
-               goto drop;
+       if (vlan_dev)
+               skb->dev =3D vlan_dev;
+       else
+               if (vlan_id)
+                       goto drop;
=20
        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
=20
@@ -82,16 +89,22 @@ vlan_gro_common(struct napi_struct *napi, struct vl=
an_group *grp,
                unsigned int vlan_tci, struct sk_buff *skb)
 {
        struct sk_buff *p;
+       struct net_device *vlan_dev;
+       u16 vlan_id;
=20
        if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
                skb->deliver_no_wcard =3D 1;
=20
        skb->skb_iif =3D skb->dev->ifindex;
        __vlan_hwaccel_put_tag(skb, vlan_tci);
-       skb->dev =3D vlan_group_get_device(grp, vlan_tci & VLAN_VID_MAS=
K);
-
-       if (!skb->dev)
-               goto drop;
+       vlan_id =3D vlan_tci & VLAN_VID_MASK;
+       vlan_dev =3D vlan_group_get_device(grp, vlan_id);
+
+       if (vlan_dev)
+               skb->dev =3D vlan_dev;
+       else
+               if (vlan_id)
+                       goto drop;
=20
        for (p =3D napi->gro_list; p; p =3D p->next) {
                NAPI_GRO_CB(p)->same_flow =3D
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5298426..65512c3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -142,6 +142,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_d=
evice *dev,
 {
        struct vlan_hdr *vhdr;
        struct vlan_rx_stats *rx_stats;
+       struct net_device *vlan_dev;
        u16 vlan_id;
        u16 vlan_tci;
=20
@@ -157,8 +158,18 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_=
device *dev,
        vlan_id =3D vlan_tci & VLAN_VID_MASK;
=20
        rcu_read_lock();
-       skb->dev =3D __find_vlan_dev(dev, vlan_id);
-       if (!skb->dev) {
+       vlan_dev =3D __find_vlan_dev(dev, vlan_id);
+
+       /* If the VLAN device is defined, we use it.
+        * If not, and the VID is 0, it is a 802.1p packet (not
+        * really a VLAN), so we will just netif_rx it later to the
+        * original interface, but with the skb->proto set to the
+        * wrapped proto: we do nothing here.
+        */
+
+       if (vlan_dev) {
+               skb->dev =3D vlan_dev;
+       } else if (vlan_id) {
                pr_debug("%s: ERROR: No net_device for VID: %u on dev: =
%s\n",
                         __func__, vlan_id, dev->name);
                goto err_unlock;


