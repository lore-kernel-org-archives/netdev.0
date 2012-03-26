From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net/vlan: withdraw VLAN ID attribute from GVRP on VLAN
 device stop
Date: Mon, 26 Mar 2012 09:38:43 -0400
Message-ID: <4F707163.2000209@ll.mit.edu>
References: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
 <1332715437-16278-2-git-send-email-david.ward@ll.mit.edu>
 <4F705329.10208@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jorge@dti2.net" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:37317 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757421Ab2CZOBc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 10:01:32 -0400
In-Reply-To: <4F705329.10208@dti2.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/03/12 07:29, Jorge Boncompte [DTI2] wrote:
> El 26/03/2012 0:43, David Ward escribi=F3:
>> When a VLAN device is stopped which has VLAN_FLAG_GVRP set, the VLAN
>> ID attribute that was previously declared by GVRP must be withdrawn.
>>
> 	Hmm, maybe I am missing something but I think it only makes sense to=
 withdrawn
> the attribute when you delete the interface, and vlan_dev_stop() it's=
 called if
> you just put the interface down. It's better for the network converge=
nce to not
> signal the switches just for this. IMHO.

If I bring a VLAN interface down, then I stop participating in the=20
VLAN.  If my NIC still receives traffic for the VLAN, I drop it.  So to=
=20
remove unnecessary load on the (potentially shared) network link and=20
remove unnecessary local processing by the kernel of packets I know I a=
m=20
going to drop, I should tell the switch that I am no longer interested=20
in receiving the VLAN traffic.  Which is the whole point of GVRP.  Righ=
t?

In any case, we currently register the attribute when the interface is=20
brought up, not when it is created.  However we do it, the attribute=20
declaration/withdrawal should be symmetric.

>
>> Signed-off-by: David Ward<david.ward@ll.mit.edu>
>> ---
>>   net/8021q/vlan_dev.c |    3 +++
>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index 9988d4a..df86dd0 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -319,6 +319,9 @@ static int vlan_dev_stop(struct net_device *dev)
>>   	struct vlan_dev_priv *vlan =3D vlan_dev_priv(dev);
>>   	struct net_device *real_dev =3D vlan->real_dev;
>>
>> +	if (vlan->flags&  VLAN_FLAG_GVRP)
>> +		vlan_gvrp_request_leave(dev);
>> +
>>   	dev_mc_unsync(real_dev, dev);
>>   	dev_uc_unsync(real_dev, dev);
>>   	if (dev->flags&  IFF_ALLMULTI)