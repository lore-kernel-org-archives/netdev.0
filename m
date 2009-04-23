From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] bonding: bond_slave_info_query() fix
Date: Thu, 23 Apr 2009 15:39:04 +0200
Message-ID: <49F06F78.4030601@cosmosbay.com>
References: <49F04FD7.7080508@cosmosbay.com> <20090423121121.GG29268@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52379 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbZDWNjY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 09:39:24 -0400
In-Reply-To: <20090423121121.GG29268@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> Thu, Apr 23, 2009 at 01:24:07PM CEST, dada1@cosmosbay.com wrote:
>> bond_slave_info_query() should keep a read lock while accessing slav=
e info,
>> or risk accessing stale data and corruption.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 63369b6..66697db 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2213,33 +2213,27 @@ static int bond_slave_info_query(struct net_=
device *bond_dev, struct ifslave *in
>> {
>> 	struct bonding *bond =3D netdev_priv(bond_dev);
>> 	struct slave *slave;
>> -	int i, found =3D 0;
>> +	int i, ret =3D -ENODEV;
>>
>> -	if (info->slave_id < 0) {
>> +	if (info->slave_id < 0)
>> 		return -ENODEV;
>=20
> You can return ret; here since -ENODEV is there, but I don't know if =
it isn't
> against policy. Patch looks good anyway.
>

Yes, we can just delete this extra test, since requested slave_id wont
be found anyway if negative.

Thanks

[PATCH] bonding: bond_slave_info_query() fix

bond_slave_info_query() should keep a read lock while accessing slave i=
nfo,
or risk accessing stale data and corruption.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 63369b6..67515b7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2213,33 +2213,24 @@ static int bond_slave_info_query(struct net_dev=
ice *bond_dev, struct ifslave *in
 {
 	struct bonding *bond =3D netdev_priv(bond_dev);
 	struct slave *slave;
-	int i, found =3D 0;
-
-	if (info->slave_id < 0) {
-		return -ENODEV;
-	}
+	int i, res =3D -ENODEV;
=20
 	read_lock(&bond->lock);
=20
 	bond_for_each_slave(bond, slave, i) {
 		if (i =3D=3D (int)info->slave_id) {
-			found =3D 1;
+			res =3D 0;
+			strcpy(info->slave_name, slave->dev->name);
+			info->link =3D slave->link;
+			info->state =3D slave->state;
+			info->link_failure_count =3D slave->link_failure_count;
 			break;
 		}
 	}
=20
 	read_unlock(&bond->lock);
=20
-	if (found) {
-		strcpy(info->slave_name, slave->dev->name);
-		info->link =3D slave->link;
-		info->state =3D slave->state;
-		info->link_failure_count =3D slave->link_failure_count;
-	} else {
-		return -ENODEV;
-	}
-
-	return 0;
+	return res;
 }
=20
 /*-------------------------------- Monitoring ------------------------=
-------*/

