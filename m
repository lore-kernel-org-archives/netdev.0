From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Tue, 29 Apr 2014 13:09:52 -0400
Message-ID: <535FDCE0.80803@gmail.com>
References: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com> <1398775161.3881.9.camel@deadeye.wl.decadent.org.uk> <C5551D9AAB213A418B7FD5E4A6F30A0784A4DA91@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:46640 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491AbaD2RJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 13:09:55 -0400
Received: by mail-qc0-f181.google.com with SMTP id x3so560018qcv.26
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 10:09:55 -0700 (PDT)
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A0784A4DA91@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/29/2014 12:10 PM, Rose, Gregory V wrote:
>=20
>> -----Original Message-----
>> From: Ben Hutchings [mailto:ben@decadent.org.uk]
>> Sent: Tuesday, April 29, 2014 5:39 AM
>> To: Kirsher, Jeffrey T
>> Cc: davem@davemloft.net; Rose, Gregory V; netdev@vger.kernel.org;
>> gospo@redhat.com; sassmann@redhat.com
>> Subject: Re: [net-next] vxlan: Advertise SCTP checksum offloads
>>
>> On Mon, 2014-04-28 at 12:52 -0700, Jeff Kirsher wrote:
>>> From: Greg Rose <gregory.v.rose@intel.com>
>>>
>>> Some HW can offload encapsulated SCTP checksums.  Advertise the
>>> capability for such cases.
>>
>> Don't we need a software fallback on the output path before doing th=
is?
>=20
> I believe that the vxlan driver will compare offload features with th=
e lower device hw_enc_feature flags and if the HW doesn't have the offl=
oad then it won't be advertised to the sctp driver.  In that case the s=
ctp driver will do its own checksumming.  At least that is the behavior=
 I saw.
>=20

I've been looking at this and can't see vxlan doing any feature
comparisons/disabling...

At the time SCTP tries to do checksum, it will see hw offload
support and set checksum as partial.  That will be propagated
all the way to vxlan which will set encapsulation and pass it on.
At next dev_hard_start_xmit(), we'll look at hw_enc_features,
but it won't matter since SCTP packets are never GSO.

So, we'll use the non-gso code path and still send with partial
checksum set.  Now, if the driver supports encapsulated SCTP,
then it will work.  If it doesn't, the udp checksum will be computed,
but not the sctp one.

-vlad

> I'm adding Joseph Gasparakis.  He might have a better answer.
>=20
> - Greg
>=20
>>
>> Ben.
>>
>>> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>>> Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
>>> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
>>> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>  drivers/net/vxlan.c | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c index
>>> 1dfee9a..988208f 100644
>>> --- a/drivers/net/vxlan.c
>>> +++ b/drivers/net/vxlan.c
>>> @@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_device *de=
v)
>>>  	dev->features	|=3D NETIF_F_SG | NETIF_F_HW_CSUM;
>>>  	dev->features   |=3D NETIF_F_RXCSUM;
>>>  	dev->features   |=3D NETIF_F_GSO_SOFTWARE;
>>> +	dev->features   |=3D NETIF_F_SCTP_CSUM;
>>>
>>>  	dev->vlan_features =3D dev->features;
>>>  	dev->features |=3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG=
_TX;
>>
>> --
>> Ben Hutchings
>> Q.  Which is the greater problem in the world today, ignorance or ap=
athy?
>> A.  I don't know and I couldn't care less.
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5
>=20
