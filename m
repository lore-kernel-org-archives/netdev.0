From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 19:57:09 +0200
Message-ID: <49ECB775.6030202@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com> <alpine.DEB.1.10.0904201305360.1585@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46680 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211AbZDTR56 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 13:57:58 -0400
In-Reply-To: <alpine.DEB.1.10.0904201305360.1585@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Sat, 18 Apr 2009, Eric Dumazet wrote:
>=20
>> I did my tests with 3 machines, trying to reproduce your results and=
 failed.
>=20
> Ow.... Where are the results? Seems that you only included the result=
s of
> traces? The numbers would be much higher with udpping since it measur=
es
> the full round trip time from user space of one machine to the other =
and
> back. The code segment that you are tracing may not be relevant.
>=20
>> I only took traces on receivers to rule out different coalescing del=
ays
>> of NIC that could depend on firmware or version
>=20
> Hmmm... Okay there could be a firmware influence....
>=20
>> bnx2 driver statically included in vmlinux.
>> (on newkernel, its "disable_msi" set to 1 (because this is the only =
way my BCM5708S can
>>  have interrupt affinities set by the admin used by the hardware on =
2.6.28+)
>=20
> Here bnx2 is a module and MSI is enabled after it became available
> (2.6.27+). Affinities seem to be effective after resetting the driver=
=2E

Hmm, I am not sure I can do that, I would loose my ssh connection...

>=20
>> If I force udpping to same cpu than IRQS (CPU0) I get : 7us, 8us, 7u=
s, 7us
>> And yes, this is very good and expected IMHO :)
>=20
> Sounds very good. If I just knew what you are measuring.

Rephrasing my email, I was measuring latencies on the receiving machine=
,
by using tcpdump and doing substraction of 'answer_time' and 'request_t=
ime'
Thing is that timestamps dont care about hardware delays.
(we note time when RX interrupt delivers the packet, and time right bef=
ore giving frame to hardware)


21:04:23.780421 IP 192.168.20.112.9001 > 192.168.20.110.9000: UDP, leng=
th 300   (request)
21:04:23.780428 IP 192.168.20.110.9000 > 192.168.20.112.9001: UDP, leng=
th 300   (answer)

Here, [21:04:23.780428 - 21:04:23.780421] =3D 7 us

So my results are extensively published :)


>=20
>> In conclusion, something might be wrong in your methodology, or your=
 hardware, or...
>=20
> Cannot really say since the results are not published? We can retry t=
his
> by making sure that udpping runs on the same processor as the IRQ.
>=20
>> Please Christoph, would you mind posting more information on your co=
nfig ?
>=20
> Sure.
>=20
> Dell PowerEdge 1950
> http://www1.ap.dell.com/content/products/productdetails.aspx/pedge_19=
50?c=3Dau&cs=3Daubsd1&l=3Den&s=3Dbsd
>=20
>> Any chance you have CONFIG_PREEMT enabled or any expensive kernel de=
bug thing ?
>=20
> Nope. Even if so: Would that not be offset by running the same kernel
> version?

I dont know, it was a random thought of mine, since I had in the past b=
ad results
if this one was enabled. This might had changed.

>=20
> CONFIG_HPET_TIMER=3Dy
> CONFIG_HPET_EMULATE_RTC=3Dy
> CONFIG_NR_CPUS=3D32
> CONFIG_SCHED_SMT=3Dy

OK, I had "# CONFIG_SCHED_SMT is not set"
I'll try with this option set

> CONFIG_SCHED_MC=3Dy
> CONFIG_PREEMPT_NONE=3Dy
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> # CONFIG_PREEMPT_BKL is not set
> CONFIG_X86_LOCAL_APIC=3Dy
>=20
> #
> # Kernel hacking
> #
> CONFIG_TRACE_IRQFLAGS_SUPPORT=3Dy
> # CONFIG_PRINTK_TIME is not set
> CONFIG_ENABLE_MUST_CHECK=3Dy
> CONFIG_MAGIC_SYSRQ=3Dy
> CONFIG_UNUSED_SYMBOLS=3Dy
> # CONFIG_DEBUG_FS is not set
> # CONFIG_HEADERS_CHECK is not set
> CONFIG_DEBUG_KERNEL=3Dy
> # CONFIG_DEBUG_SHIRQ is not set
> CONFIG_DETECT_SOFTLOCKUP=3Dy
> # CONFIG_SCHEDSTATS is not set
> # CONFIG_TIMER_STATS is not set
> # CONFIG_DEBUG_SLAB is not set
> # CONFIG_DEBUG_RT_MUTEXES is not set
> # CONFIG_RT_MUTEX_TESTER is not set
> # CONFIG_DEBUG_SPINLOCK is not set
> # CONFIG_DEBUG_MUTEXES is not set
> # CONFIG_DEBUG_LOCK_ALLOC is not set
> # CONFIG_PROVE_LOCKING is not set
> # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> # CONFIG_DEBUG_KOBJECT is not set
> # CONFIG_DEBUG_HIGHMEM is not set
> CONFIG_DEBUG_BUGVERBOSE=3Dy
> # CONFIG_DEBUG_INFO is not set
> # CONFIG_DEBUG_VM is not set
> # CONFIG_DEBUG_LIST is not set
> # CONFIG_FRAME_POINTER is not set
> # CONFIG_FORCED_INLINING is not set
> # CONFIG_RCU_TORTURE_TEST is not set
> # CONFIG_LKDTM is not set
> # CONFIG_FAULT_INJECTION is not set
> CONFIG_EARLY_PRINTK=3Dy
> CONFIG_DEBUG_STACKOVERFLOW=3Dy
> # CONFIG_DEBUG_STACK_USAGE is not set
> # CONFIG_DEBUG_RODATA is not set
> # CONFIG_4KSTACKS is not set
> CONFIG_X86_FIND_SMP_CONFIG=3Dy
> CONFIG_X86_MPPARSE=3Dy
> CONFIG_DOUBLEFAULT=3Dy
>=20

Are you running a 32 or 64 bits kernel ?

Thanks


