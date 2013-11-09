From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 7/10] bonding: rebuild the lock use for bond_3ad_state_machine_handler()
Date: Sat, 09 Nov 2013 21:54:17 +0800
Message-ID: <527E3E89.8060506@gmail.com>
References: <527C4788.9090508@huawei.com> <527D0692.8000401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:63613 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663Ab3KIOFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 09:05:08 -0500
Received: by mail-pa0-f51.google.com with SMTP id ld10so3430044pab.24
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 06:05:07 -0800 (PST)
In-Reply-To: <527D0692.8000401@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/8 23:43, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:08 AM, Ding Tianhong wrote:
>> The bond_3ad_state_machine_handler() use the bond lock to protect
>> the bond slave list and slave port, so as the before patch said,
>> I remove bond lock and replace with RCU.
>>
>> The nots in the function is still too old, clean up the nots.
>>
>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/bonding/bond_3ad.c | 21 ++++++++++-----------
>>   1 file changed, 10 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bo=
nd_3ad.c
>> index 187b1b7..09edccf61 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2068,18 +2068,18 @@ void bond_3ad_state_machine_handler(struct w=
ork_struct *work)
>>   	struct slave *slave;
>>   	struct port *port;
>>  =20
>> -	read_lock(&bond->lock);
>> +	rcu_read_lock();
>>  =20
>> -	//check if there are any slaves
>> -	if (!bond_has_slaves(bond))
>> +	/* check if there are any slaves */
>> +	if (!bond_has_slaves_rcu(bond))
>>   		goto re_arm;
>>  =20
>> -	// check if agg_select_timer timer after initialize is timed out
>> +	/* check if agg_select_timer timer after initialize is timed out *=
/
>>   	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond)=
=2Eagg_select_timer)) {
>> -		slave =3D bond_first_slave(bond);
>> +		slave =3D bond_first_slave_rcu(bond);
>>   		port =3D slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
>>  =20
>> -		// select the active aggregator for the bond
>> +		/* select the active aggregator for the bond */
>>   		if (port) {
>>   			if (!port->slave) {
>>   				pr_warning("%s: Warning: bond's first port is uninitialized\n"=
,
> This continues to execute:
> aggregator =3D __get_first_agg(port);
> ad_agg_selection_logic(aggregator)
> And neither ad_agg_selection_logic nor __get_first_agg are RCU-safe.
>
yes, I miss it, thanks a lot.

Regards.
Ding


> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
