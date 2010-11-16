From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next-2.6 PATCH] net: zero kobject in rx_queue_release
Date: Tue, 16 Nov 2010 00:12:28 -0800
Message-ID: <4CE23CEC.7020707@intel.com>
References: <20101116065906.31611.36938.stgit@jf-dev1-dcblab> <1289893125.3364.234.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:21392 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757215Ab0KPIMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 03:12:30 -0500
In-Reply-To: <1289893125.3364.234.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2010 11:38 PM, Eric Dumazet wrote:
> Le lundi 15 novembre 2010 =C3=A0 22:59 -0800, John Fastabend a =C3=A9=
crit :
>> netif_set_real_num_rx_queues() can decrement and increment
>> the number of rx queues. For example ixgbe does this as
>> features and offloads are toggled. Presumably this could
>> also happen across down/up on most devices if the available
>> resources changed (cpu offlined).
>>
>> The kobject needs to be zero'd in this case so that the
>> state is not preserved across kobject_put()/kobject_init_and_add().
>>
>> This resolves the following error report.
>>
>> ixgbe 0000:03:00.0: eth2: NIC Link is Up 10 Gbps, Flow Control: RX/T=
X
>> kobject (ffff880324b83210): tried to init an initialized object, som=
ething is seriously wrong.
>> Pid: 1972, comm: lldpad Not tainted 2.6.37-rc18021qaz+ #169
>> Call Trace:
>>  [<ffffffff8121c940>] kobject_init+0x3a/0x83
>>  [<ffffffff8121cf77>] kobject_init_and_add+0x23/0x57
>>  [<ffffffff8107b800>] ? mark_lock+0x21/0x267
>>  [<ffffffff813c6d11>] net_rx_queue_update_kobjects+0x63/0xc6
>>  [<ffffffff813b5e0e>] netif_set_real_num_rx_queues+0x5f/0x78
>>  [<ffffffffa0261d49>] ixgbe_set_num_queues+0x1c6/0x1ca [ixgbe]
>>  [<ffffffffa0262509>] ixgbe_init_interrupt_scheme+0x1e/0x79c [ixgbe]
>>  [<ffffffffa0274596>] ixgbe_dcbnl_set_state+0x167/0x189 [ixgbe]
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>
>>  net/core/net-sysfs.c |    9 +++++++--
>>  1 files changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
>> index 3ba526b..960c075 100644
>> --- a/net/core/net-sysfs.c
>> +++ b/net/core/net-sysfs.c
>> @@ -711,13 +711,18 @@ static void rx_queue_release(struct kobject *k=
obj)
>> =20
>>
>>  	map =3D rcu_dereference_raw(queue->rps_map);
>> -	if (map)
>> +	if (map) {
>> +		rcu_assign_pointer(queue->rps_map, NULL);
>=20
> Hmm, yes this works, but I am not sure queue->rps_map can be read by
> other cpus at this point.

Why not? Sorry not sure I follow.

>=20
> rcu_assign_pointer() is a documented interface with implied semantic =
: I
> put a NULL pointer on a RCU protected variable, and avoid a memory
> barrier because NULL is special.
>=20
> If this patch is for current kernel, I advise using RCU_INIT_POINTER(=
)
> instead to make clear we only want to set the pointer to NULL, and av=
oid
> sparse warnings :)
>=20

OK, avoiding sparse warnings is good changed to RCU_INIT_POINTER().

>=20
>=20
>=20
>>  		call_rcu(&map->rcu, rps_map_release);
>> +	}
>> =20
>>  	flow_table =3D rcu_dereference_raw(queue->rps_flow_table);
>> -	if (flow_table)
>> +	if (flow_table) {
>> +		rcu_assign_pointer(queue->rps_flow_table, NULL);
>=20
>=20
> same here ?

changed here as well.

>=20
>>  		call_rcu(&flow_table->rcu, rps_dev_flow_table_release);
>> +	}
>> =20
>> +	memset(kobj, 0, sizeof(*kobj));
>=20
> Is it the regular way to perform this, no kobject_{clear|del|deinit}(=
) ?

None that I can see. kobject_del() unlinks the koject but does not do a=
ny clear.

>=20
>>  	dev_put(queue->dev);
>>  }
>> =20
>>
>=20
> Thanks=20
>=20
>=20

