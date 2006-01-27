From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 23:30:23 +0100
Message-ID: <43DA9EFF.1020200@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain>	<20060126190357.GE3651@localhost.localdomain>	<43D9DFA1.9070802@cosmosbay.com>	<20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751570AbWA0Wai@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060127121602.18bc3f25.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton a =E9crit :
> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>> On Fri, Jan 27, 2006 at 09:53:53AM +0100, Eric Dumazet wrote:
>>> Ravikiran G Thirumalai a =E9crit :
>>>> Change the atomic_t sockets_allocated member of struct proto to a=20
>>>> per-cpu counter.
>>>>
>>>> Signed-off-by: Pravin B. Shelar <pravins@calsoftinc.com>
>>>> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
>>>> Signed-off-by: Shai Fultheim <shai@scalex86.org>
>>>>
>>> Hi Ravikiran
>>>
>>> If I correctly read this patch, I think there is a scalability prob=
lem.
>>>
>>> On a big SMP machine, read_sockets_allocated() is going to be a rea=
l killer.
>>>
>>> Say we have 128 Opterons CPUS in a box.
>> read_sockets_allocated is being invoked when when /proc/net/protocol=
s is read,
>> which can be assumed as not frequent. =20
>> At sk_stream_mem_schedule(), read_sockets_allocated() is invoked onl=
y=20
>> certain conditions, under memory pressure -- on a large CPU count ma=
chine,=20
>> you'd have large memory, and I don't think read_sockets_allocated wo=
uld get=20
>> called often.  It did not atleast on our 8cpu/16G box.  So this shou=
ld be OK=20
>> I think.
>=20
> That being said, the percpu_counters aren't a terribly successful con=
cept
> and probably do need a revisit due to the high inaccuracy at high CPU
> counts.  It might be better to do some generic version of vm_acct_mem=
ory()
> instead.

There are several issues here :

alloc_percpu() current implementation is a a waste of ram. (because it =
uses=20
slab allocations that have a minimum size of 32 bytes)

Currently we cannot use per_cpu(&some_object, cpu), so a generic versio=
n of=20
vm_acct_memory() would need a rework of percpu.h and maybe this is not=20
possible on every platform ?

#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offse=
t[cpu]))

-->

#define per_cpu_name(var) per_cpu__##var
#define per_cpu_addr(var) &per_cpu_name(var)
#define per_cpu(var, cpu) (*RELOC_HIDE(per_cpu_addr(var), __per_cpu_off=
set[cpu])


But this could render TLS migration difficult...

Eric
