From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] cgroup: fix panic in netprio_cgroup
Date: Thu, 05 Jul 2012 17:10:14 +0800
Message-ID: <4FF559F6.1040007@cn.fujitsu.com>
References: <1341477102-16988-1-git-send-email-gaofeng@cn.fujitsu.com> <1341477809.2583.3437.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nhorman@tuxdriver.com, tj@kernel.org,
	lizefan@huawei.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341477809.2583.3437.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8805=E6=97=A5 16:43, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Thu, 2012-07-05 at 16:31 +0800, Gao feng wrote:
>> we set max_prioidx to the first zero bit index of prioidx_map in
>> function get_prioidx.
>>
>> So when we delete the low index netprio cgroup and adding a new
>> netprio cgroup again,the max_prioidx will be set to the low index.
>>
>> when we set the high index cgroup's net_prio.ifpriomap,the function
>> write_priomap will call update_netdev_tables to alloc memory which
>> size is sizeof(struct netprio_map) + sizeof(u32) * (max_prioidx + 1)=
,
>> so the size of array that map->priomap point to is max_prioidx +1,
>> which is low than what we actually need.
>>
>> fix this by adding check in get_prioidx,only set max_prioidx when
>> max_prioidx low than the new prioidx.
>>
>> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
>> ---
>>  net/core/netprio_cgroup.c |    3 ++-
>>  1 files changed, 2 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
>> index 5b8aa2f..586f7d9 100644
>> --- a/net/core/netprio_cgroup.c
>> +++ b/net/core/netprio_cgroup.c
>> @@ -50,7 +50,8 @@ static int get_prioidx(u32 *prio)
>>  	}
>>  	set_bit(prioidx, prioidx_map);
>>  	spin_unlock_irqrestore(&prioidx_map_lock, flags);
>> -	atomic_set(&max_prioidx, prioidx);
>> +	if (atomic_read(&max_prioidx) < prioidx)
>> +		atomic_set(&max_prioidx, prioidx);
>>  	*prio =3D prioidx;
>>  	return 0;
>>  }
>=20
> This is still racy.
>=20
> Please do this before the=20
> spin_unlock_irqrestore(&prioidx_map_lock, flags);
>=20

Thanks Eric,you are right
I will fix and resent it.
