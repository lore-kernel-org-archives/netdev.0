From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: bond_slave_info_query() fix
Date: Thu, 23 Apr 2009 07:51:36 -0700
Message-ID: <12275.1240498296@death.nxdomain.ibm.com>
References: <49F04FD7.7080508@cosmosbay.com> <20090423121121.GG29268@psychotron.englab.brq.redhat.com> <49F06F78.4030601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:46600 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbZDWOvd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 10:51:33 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3NEf9j5027659
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 10:41:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3NEpVoT190150
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 10:51:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3NEpUgU021681
	for <netdev@vger.kernel.org>; Thu, 23 Apr 2009 10:51:31 -0400
In-reply-to: <49F06F78.4030601@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:

>Jiri Pirko a =C3=A9crit :
>> Thu, Apr 23, 2009 at 01:24:07PM CEST, dada1@cosmosbay.com wrote:
>>> bond_slave_info_query() should keep a read lock while accessing sla=
ve info,
>>> or risk accessing stale data and corruption.
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>
>>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/=
bond_main.c
>>> index 63369b6..66697db 100644
>>> --- a/drivers/net/bonding/bond_main.c
>>> +++ b/drivers/net/bonding/bond_main.c
>>> @@ -2213,33 +2213,27 @@ static int bond_slave_info_query(struct net=
_device *bond_dev, struct ifslave *in
>>> {
>>> 	struct bonding *bond =3D netdev_priv(bond_dev);
>>> 	struct slave *slave;
>>> -	int i, found =3D 0;
>>> +	int i, ret =3D -ENODEV;
>>>
>>> -	if (info->slave_id < 0) {
>>> +	if (info->slave_id < 0)
>>> 		return -ENODEV;
>>=20
>> You can return ret; here since -ENODEV is there, but I don't know if=
 it isn't
>> against policy. Patch looks good anyway.
>>
>
>Yes, we can just delete this extra test, since requested slave_id wont
>be found anyway if negative.
>
>Thanks
>
>[PATCH] bonding: bond_slave_info_query() fix
>
>bond_slave_info_query() should keep a read lock while accessing slave =
info,
>or risk accessing stale data and corruption.

	I don't think that's actually true, since changes to the data
being referenced are (should be) protected by RTNL, and
bond_slave_info_query runs via ioctl, and is holding RTNL.

	Nevertheless, the patch does make the function cleaner, so I
have no objections.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bon=
d_main.c
>index 63369b6..67515b7 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -2213,33 +2213,24 @@ static int bond_slave_info_query(struct net_de=
vice *bond_dev, struct ifslave *in
> {
> 	struct bonding *bond =3D netdev_priv(bond_dev);
> 	struct slave *slave;
>-	int i, found =3D 0;
>-
>-	if (info->slave_id < 0) {
>-		return -ENODEV;
>-	}
>+	int i, res =3D -ENODEV;
>
> 	read_lock(&bond->lock);
>
> 	bond_for_each_slave(bond, slave, i) {
> 		if (i =3D=3D (int)info->slave_id) {
>-			found =3D 1;
>+			res =3D 0;
>+			strcpy(info->slave_name, slave->dev->name);
>+			info->link =3D slave->link;
>+			info->state =3D slave->state;
>+			info->link_failure_count =3D slave->link_failure_count;
> 			break;
> 		}
> 	}
>
> 	read_unlock(&bond->lock);
>
>-	if (found) {
>-		strcpy(info->slave_name, slave->dev->name);
>-		info->link =3D slave->link;
>-		info->state =3D slave->state;
>-		info->link_failure_count =3D slave->link_failure_count;
>-	} else {
>-		return -ENODEV;
>-	}
>-
>-	return 0;
>+	return res;
> }
>
> /*-------------------------------- Monitoring -----------------------=
--------*/
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
