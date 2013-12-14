From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v5 0/11] bonding: rebuild the lock use for bond
 monitor
Date: Sat, 14 Dec 2013 18:02:25 +0800
Message-ID: <52AC2CB1.9090102@gmail.com>
References: <52A7F148.6000302@huawei.com> <20131214.020149.2022684556057698333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, nikolay@redhat.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:62987 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab3LNKOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 05:14:05 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so3583236pbc.35
        for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 02:14:04 -0800 (PST)
In-Reply-To: <20131214.020149.2022684556057698333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/14 15:01, David Miller =E5=86=99=E9=81=93:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Wed, 11 Dec 2013 12:59:52 +0800
>=20
>> Now the bond slave list is not protected by bond lock, only by RTNL,
>> but the monitor still use the bond lock to protect the slave list,
>> it is useless, according to the Veaceslav's opinion, there were
>> three way to fix the protect problem:
>>
>> 1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
>>    in bond->lock, but it is unsafe to call call_netdevice_notifiers(=
)
>>    in write lock.
>> 2. remove unused bond->lock for monitor function, only use the exist
>>    rtnl lock(), it will take performance loss in fast path.
>> 3. use RCU to protect the slave list, of course, performance is bett=
er,
>>    but in slow path, it is ignored.
>>
>> obviously the solution 1 is not fit here, I will consider the 2 and =
3
>> solution. My principle is simple, if in fast path, RCU is better,
>> otherwise in slow path, both is well, but according to the Jay Vosbu=
rgh's
>> opinion, the monitor will loss performace if use RTNL to protect the=
 all
>> slave list, so remove the bond lock and replace with RCU.
>>
>> The second problem is the curr_slave_lock for bond, it is too old an=
d
>> unwanted in many place, because the curr_active_slave would only be
>> changed in 3 place:
>>
>> 1. enslave slave.
>> 2. release slave.
>> 3. change active slave.
>>
>> all above were already holding bond lock, RTNL and curr_slave_lock
>> together, it is tedious and no need to add so mach lock, when change
>> the curr_active_slave, you have to hold the RTNL and curr_slave_lock
>> together, and when you read the curr_active_slave, RTNL or curr_slav=
e_lock,
>> any one of them is no problem.
>>
>> for the stability, I did not change the logic for the monitor,
>> all change is clear and simple, I have test the patch set for lockde=
p,
>> it work well and stability.
>=20
> Series applied, thanks.
> --

Hi David:

The last version of the patchset is v6, and the v6 is a little differen=
t from v5,
I think you have missed the last version, and found you applied the v5 =
patchset.

Regards
Ding

> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
