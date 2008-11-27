From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: Re: [PATCH 4/6] fs: Introduce a per_cpu nr_inodes
Date: Thu, 27 Nov 2008 11:01:14 +0100
Message-ID: <492E6FEA.70307@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com>	 <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com>	 <20081121.010508.40225532.davem@davemloft.net>	 <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>	 <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com>	 <20081121153453.GA23713@elte.hu>  <492DDC91.3020503@cosmosbay.com> <1227778377.4454.1299.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, travis <travis-sJ/iWh9BUns@public.gmane.org>
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1227778377.4454.1299.camel@twins>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Peter Zijlstra a =E9crit :
> On Thu, 2008-11-27 at 00:32 +0100, Eric Dumazet wrote:
>> Avoids cache line ping pongs between cpus and prepare next patch,
>> because updates of nr_inodes metric dont need inode_lock anymore.
>>
>> (socket8 bench result : 25s to 20.5s)
>>
>> Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
>> ---
>=20
>> @@ -96,9 +96,40 @@ static DEFINE_MUTEX(iprune_mutex);
>>   * Statistics gathering..
>>   */
>>  struct inodes_stat_t inodes_stat;
>> +static DEFINE_PER_CPU(int, nr_inodes);
>> =20
>>  static struct kmem_cache * inode_cachep __read_mostly;
>> =20
>> +int get_nr_inodes(void)
>> +{
>> +	int cpu;
>> +	int counter =3D 0;
>> +
>> +	for_each_possible_cpu(cpu)
>> +	    counter +=3D per_cpu(nr_inodes, cpu);
>> +	if (counter < 0)
>> +		counter =3D 0;
>> +	return counter;
>> +}
>=20
> It would be good to get a cpu hotplug handler here and move to
> for_each_online_cpu(). People are wanting distro's to be build with
> NR_CPUS=3D4096.

Hum, I guess we can use regular percpu_counter for this...
