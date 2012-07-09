From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v2] cgroup: fix panic in netprio_cgroup
Date: Mon, 09 Jul 2012 08:16:51 +0800
Message-ID: <4FFA22F3.9000704@cn.fujitsu.com>
References: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com> <1341777043.3265.1786.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tj@kernel.org, lizefan@huawei.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341777043.3265.1786.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8809=E6=97=A5 03:50, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Thu, 2012-07-05 at 17:28 +0800, Gao feng wrote:
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
>> index 5b8aa2f..aa907ed 100644
>> --- a/net/core/netprio_cgroup.c
>> +++ b/net/core/netprio_cgroup.c
>> @@ -49,8 +49,9 @@ static int get_prioidx(u32 *prio)
>>  		return -ENOSPC;
>>  	}
>>  	set_bit(prioidx, prioidx_map);
>> +	if (atomic_read(&max_prioidx) < prioidx)
>> +		atomic_set(&max_prioidx, prioidx);
>>  	spin_unlock_irqrestore(&prioidx_map_lock, flags);
>> -	atomic_set(&max_prioidx, prioidx);
>>  	*prio =3D prioidx;
>>  	return 0;
>>  }
>=20
> This patch seems fine to me.
>=20
> Acked-by: Eric Dumazet <edumazet@google.com>
>=20
> Neil, looking at this file, I believe something is wrong.
>=20
> dev->priomap is allocated by extend_netdev_table() called from
> update_netdev_tables(). And this is only called if write_priomap() is
> called.
>=20
> But if write_priomap() is not called, it seems we can have out of bou=
nds
> accesses in cgrp_destroy() and read_priomap()

Agree,and the function skb_update_prio has the same problem.
