From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH] [bonding]: clear header_ops when last slave detached
Date: Mon, 17 Nov 2014 17:38:49 -0800
Message-ID: <866.1416274729@famine>
References: <1415845156-15461-1-git-send-email-wen.gang.wang@oracle.com> <54694D09.4080304@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wengang <wen.gang.wang@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41010 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbaKRBiz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 20:38:55 -0500
In-reply-to: <54694D09.4080304@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wengang <wen.gang.wang@oracle.com> wrote:

>Hi,
>
>Could anybody please review this patch?

	I don't see that the original of this ever came through netdev.

>thanks,
>wengang
>
>=E4=BA=8E 2014=E5=B9=B411=E6=9C=8813=E6=97=A5 10:19, Wengang Wang =E5=86=
=99=E9=81=93:
>> When last slave of a bonding master is removed, the bonding then doe=
s not work.
>> When packet_snd is called against with a master net_device, it acces=
ses
>> header_ops. In case the header_ops is not valid any longer(say modul=
e unloaded)
>> it will then access an invalid memory address.
>> This patch try to fix this issue by clearing header_ops when last sl=
ave
>> detached.

	Am I correct in presuming that this behavior is limited to ipoib
slaves only?  I don't see that this could occur with ethernet slaves, a=
s
eth_header_ops isn't part of a module.  This needs to be mentioned in
the commit log.

>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>>   drivers/net/bonding/bond_main.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index c9ac06c..84a34fc 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1728,6 +1728,8 @@ static int __bond_release_one(struct net_devic=
e *bond_dev,
>>   	unblock_netpoll_tx();
>>   	synchronize_rcu();
>>   	bond->slave_cnt--;
>> +	if (!bond->slave_cnt)
>> +		bond->dev->header_ops =3D NULL;
>>     	if (!bond_has_slaves(bond)) {
>>   		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);

	I believe your addition could be moved into the block for the
next if, as "!bond->slave_cnt" is essentially "!bond_has_slaves()".

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
