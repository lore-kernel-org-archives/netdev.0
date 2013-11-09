From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 0/10] bonding: rebuild the lock use for bond
 monitor
Date: Sat, 09 Nov 2013 16:03:12 +0800
Message-ID: <527DEC40.4020407@gmail.com>
References: <527C4768.3010909@huawei.com> <527D120E.3080706@redhat.com>
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
Received: from mail-pb0-f52.google.com ([209.85.160.52]:40113 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab3KIIOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 03:14:00 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr4so3120369pbb.39
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 00:13:59 -0800 (PST)
In-Reply-To: <527D120E.3080706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/9 0:32, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:07 AM, Ding Tianhong wrote:
>> Now the bond slave list is not protected by bond lock, only by RTNL,
>> but the monitor still use the bond lock to protect the slave list,
>> it is useless, according to the Veaceslav's opinion, there were
>> three way to fix the protect problem:
>>
>> 1. add bond_master_upper_dev_link() and bond_upper_dev_unlink()
>>     in bond->lock, but it is unsafe to call call_netdevice_notifiers=
()
>>     in write lock.
>> 2. remove unused bond->lock for monitor function, only use the exist
>>     rtnl lock(), it will take performance loss in fast path.
>> 3. use RCU to protect the slave list, of course, performance is bett=
er,
>>     but in slow path, it is ignored.
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
>>
>> v2. accept the Jay Vosburgh's opinion, remove the RTNL and replace w=
ith RCU,
>>      also add some rcu function for bond use, so the patch set reach=
 10.
>>
>> Best Regards
>> Ding Tianhong
>>
> Hi,
> I've left my comments from a quick overview of the patches, my opinio=
n on the
> patchset is that it wasn't tested thoroughly enough (or at all). Ther=
e're
> multiple places that use a weaker compiler barrier instead of directl=
y using
> rcu_dereference() or rcu_access_pointer(), also there're multiple pla=
ces which
> can directly use macros already present in the RCU API.
>
> Cheers,
>   Nik

Thanks, Nik, for overview the long patches, point out the problem, I=20
will review the
details which your point out and fix it.

Best Regards
Ding

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
