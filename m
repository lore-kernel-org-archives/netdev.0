From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]  netfilter: use per-CPU recursive lock {XIV}
Date: Fri, 24 Apr 2009 17:33:00 +0200
Message-ID: <49F1DBAC.8090101@trash.net>
References: <20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>	<20090420160121.268a8226@nehalam>	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>	<20090421111541.228e977a@nehalam>	<20090421193924.GA24404@elte.hu>	<20090421143927.52d7d89d@nehalam>	<alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49F146FF.5050200@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> In days of old in 2.6.29, netfilter did locketh using a=20
>> lock of the reader kind when doing its table business, and do
>> a writer when with pen in hand like a overworked accountant
>> did replace the tables. This sucketh and caused the single
>> lock to fly back and forth like a poor errant boy.
>>
>> But then netfilter was blessed with RCU and the performance
>> was divine, but alas there were those that suffered for
>> trying to replace their many rules one at a time.
>>
>> So now RCU must be vanquished from the scene, and better
>> chastity belts be placed upon this valuable asset most dear.
>> The locks that were but one are now replaced by one per suitor.
>>
>> The repair was made after much discussion involving
>> Eric the wise, and Linus the foul. With flowers springing
>> up amid the thorns some peace has finally prevailed and
>> all is soothed. This patch and purple prose was penned by
>> in honor of "Talk like Shakespeare" day.

Hehe.

>>  static int __init xt_init(void)
>>  {
>> -	int i, rv;
>> +	unsigned int i;
>> +	int rv;
>> +	static struct lock_class_key xt_lock_key[NR_CPUS];
>=20
> Could we avoid this [NR_CPUS] thing ?
>=20
>> +
>> +	for_each_possible_cpu(i) {
>> +		rwlock_t *lock =3D &per_cpu(xt_info_locks, i);
>> +
>> +		rwlock_init(lock);
>> +		lockdep_set_class(lock, xt_lock_key+i);
>> +	}
>=20
>=20
> Did you tried :
>=20
> static DECLARE_PER_CPU(struct lock_class_key, xt_locks_key);

Either way is fine with me, I'll wait for Stephen to state his opinion.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
