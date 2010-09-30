From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 11:16:55 +0200
Message-ID: <1285838215.2615.126.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48280 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840Ab0I3JRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 05:17:06 -0400
Received: by fxm4 with SMTP id 4so538347fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 02:17:05 -0700 (PDT)
In-Reply-To: <20100930080703.GA10827@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 10:07 +0200, Roger Luethi a =C3=A9cri=
t :
> On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
> > On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wrot=
e:
> > > I noticed packets for unknown VLANs getting silently dropped even=
 in
> > > promiscuous mode (this is true only for the hardware accelerated =
path).
> > > netif_nit_deliver was introduced specifically to prevent that, bu=
t the
> > > function gets called only _after_ packets from unknown VLANs have=
 been
> > > dropped.
> >=20
> > Some drivers are fixing this on a case by case basis by disabling
> > hardware accelerated VLAN stripping when in promiscuous mode, i.e.:
> > http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;=
a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
> >=20
> > However, at this point it is more or less random which drivers do
> > this.  It would obviously be much better if it were consistent.
>=20
> My understanding is this. Hardware VLAN tagging and stripping can alw=
ays be
> enabled. The kernel passes 802.1Q information along with the stripped
> header to libpcap which reassembles the original header where necessa=
ry.
> Works for me.
>=20
> Hardware VLAN filtering, on the other hand, must be disabled in promi=
scuous
> mode. But doing that in the driver makes no difference now as the cur=
rent
> VLAN code drops the packets so preserved before they are passed to th=
e pcap
> interface. That appears to be a bug.

Agreed

Could you try following patch, based on net-next-2.6 ?

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 0eb486d..fabdedb 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -101,7 +101,7 @@ vlan_gro_common(struct napi_struct *napi, struct vl=
an_group *grp,
=20
 	if (vlan_dev)
 		skb->dev =3D vlan_dev;
-	else if (vlan_id)
+	else if (vlan_id && !(skb->dev->flags & IFF_PROMISC))
 		goto drop;
=20
 	for (p =3D napi->gro_list; p; p =3D p->next) {


