From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 17:14:18 +0200
Message-ID: <4F7087CA.5010804@dti2.net>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu> <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu> <4F705329.10208@dti2.net> <4F707163.2000209@ll.mit.edu>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:64855 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932502Ab2CZPOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 11:14:25 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.2)
	with ESMTP id md50021709766.msg
	for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 17:14:23 +0200
In-Reply-To: <4F707163.2000209@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 26/03/2012 15:38, Ward, David - 0663 - MITLL escribi=F3:
> On 26/03/12 07:29, Jorge Boncompte [DTI2] wrote:
>> El 26/03/2012 0:43, David Ward escribi=F3:
>>> When a VLAN device is stopped which has VLAN_FLAG_GVRP set, the VLA=
N
>>> ID attribute that was previously declared by GVRP must be withdrawn=
=2E
>>>
>> 	Hmm, maybe I am missing something but I think it only makes sense t=
o withdrawn
>> the attribute when you delete the interface, and vlan_dev_stop() it'=
s called if
>> you just put the interface down. It's better for the network converg=
ence to not
>> signal the switches just for this. IMHO.
>=20
> If I bring a VLAN interface down, then I stop participating in the=20
> VLAN.  If my NIC still receives traffic for the VLAN, I drop it.  So =
to=20
> remove unnecessary load on the (potentially shared) network link and=20
> remove unnecessary local processing by the kernel of packets I know I=
 am=20
> going to drop, I should tell the switch that I am no longer intereste=
d=20
> in receiving the VLAN traffic.  Which is the whole point of GVRP.  Ri=
ght?

	In the non-GVRP case, as far as i can see, you still receive the traff=
ic for
that VLAN and the kernel drops it. Maybe is that I think that a downed =
interface
it's more a transient state, and administratively choosen one. If you d=
on't want
to participate in that VLAN, you always can disable GVRP on it or delet=
e the
interface.

> In any case, we currently register the attribute when the interface i=
s=20
> brought up, not when it is created.

	And that makes sense to me, if you have never uped the interface you h=
ave never
participated in that VLAN.

>  However we do it, the attribute
> declaration/withdrawal should be symmetric.
>=20
>>
>>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>>> ---
>>>   net/8021q/vlan_dev.c |    3 +++
>>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>>> index 9988d4a..df86dd0 100644
>>> --- a/net/8021q/vlan_dev.c
>>> +++ b/net/8021q/vlan_dev.c
>>> @@ -319,6 +319,9 @@ static int vlan_dev_stop(struct net_device *dev=
)
>>>   	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
>>>   	struct net_device *real_dev =3D vlan->real_dev;
>>>
>>> +	if (vlan->flags&  VLAN_FLAG_GVRP)
>>> +		vlan_gvrp_request_leave(dev);
>>> +
>>>   	dev_mc_unsync(real_dev, dev);
>>>   	dev_uc_unsync(real_dev, dev);
>>>   	if (dev->flags&  IFF_ALLMULTI)--
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
