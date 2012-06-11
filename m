From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net 3/3] bonding:force to use primary slave
Date: Mon, 11 Jun 2012 14:17:21 -0700
Message-ID: <32118.1339449441@death.nxdomain>
References: <cover.1339404887.git.wpan@redhat.com> <19a50a970bfa4eab890a39293fa505f90fbfc5e4.1339404887.git.wpan@redhat.com> <4FD64BDB.3060003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Weiping Pan <wpan@redhat.com>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:39967 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab2FKVRe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 17:17:34 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Mon, 11 Jun 2012 15:17:33 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 7D1DD3E40049
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 21:17:23 +0000 (WET)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5BLHNsj218214
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 15:17:23 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5BLIFhu013284
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 15:18:15 -0600
In-reply-to: <4FD64BDB.3060003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 11/06/2012 11:00, Weiping Pan a =C3=A9crit :
>> When we set primary slave with module parameters, bond will always u=
se this
>> primary slave as active slave.
>>
>> But when we modify primary slave via sysfs, it will call
>> bond_should_change_active() and take into account primary_reselect.
>>
>> And I think we should use the new primary slave as the new active sl=
ave
>> regardless of the value of primary_reselect.
>> Thus the behavior is the same with module parameters and meets the
>> administrator's expectation.
>>
>> Signed-off-by: Weiping Pan<wpan@redhat.com>
>> ---
>>   drivers/net/bonding/bond_sysfs.c |    1 +
>>   1 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/=
bond_sysfs.c
>> index 1b0f3cd..7256ae4 100644
>> --- a/drivers/net/bonding/bond_sysfs.c
>> +++ b/drivers/net/bonding/bond_sysfs.c
>> @@ -1077,6 +1077,7 @@ static ssize_t bonding_store_primary(struct de=
vice *d,
>>   				bond->dev->name, slave->dev->name);
>>   			bond->primary_slave =3D slave;
>>   			strcpy(bond->params.primary, slave->dev->name);
>> +			bond->force_primary =3D true;
>>   			bond_select_active_slave(bond);
>>   			goto out;
>>   		}
>
>Not sure this is the right behavior. One may want to change the primar=
y
>without causing a switch to this primary if another slave is already
>active, and setup primary_reselect to failure or better for that
>reason. The administrator still have the option to write into
>active_slave, to force the new active slave after changing the primary=
=2E
>
>Arguably, this should be documented.

	I suspect it is obeying the documented behavior, at least for
the behaviors that are documented.

	The documentation already says that "When initially enslaved,
the primary slave is always made the active slave."  That's probably
what covers the "module param" case, because the options are all set
prior to any slaves being added, so when the primary slave is later
enslaved, it is made the active slave immediately.

	Now, the documentation for the primary option itself also says:

	"The specified device will always be the active slave while it
	is available.  Only when the primary is off-line will alternate
	devices be used."

	Which is the old behavior, prior to primary_reselect being added
(although it is still the default behavior).  This should probably
change to reflect the actual behavior, i.e., that changing the primary
option in real time results in a reselection of the primary according t=
o
the policy specified by primary_reselect.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
