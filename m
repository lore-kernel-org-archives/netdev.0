From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: include/linux/pcounter.h
Date: Sat, 16 Feb 2008 13:03:54 +0100
Message-ID: <47B6D12A.3090401@cosmosbay.com>
References: <20080204014402.1c55d3fe.akpm@linux-foundation.org>	<20080215193711.2e3d41f3.akpm@linux-foundation.org>	<47B6B5E1.90705@cosmosbay.com> <20080216025051.751b4a86.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757703AbYBPMEp@vger.kernel.org>
In-Reply-To: <20080216025051.751b4a86.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton a =E9crit :
> On Sat, 16 Feb 2008 11:07:29 +0100 Eric Dumazet <dada1@cosmosbay.com>=
 wrote:
>=20
>> Andrew, pcounter is a temporary abstraction.
>=20
> It's buggy!  Main problems are a) possible return of negative numbers=
 b)
> some of the API can't be from preemptible code c) excessive interrupt=
-off
> time on some machines if used from irq-disabled sections.

a) We dont care of possibly off values when reading /proc/net/sockstat
    Same arguments apply for percpu_counters.

b) It is called from network parts where preemption is disabled.

net/ipv4/inet_timewait_sock.c:94:=20
sock_prot_inuse_add(sk->sk_prot, -1);
net/ipv4/inet_hashtables.c:291: sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv4/inet_hashtables.c:335: sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv4/inet_hashtables.c:357: sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv4/inet_hashtables.c:390:         sock_prot_inuse_add(sk->sk_prot=
, -1);
net/ipv4/raw.c:95:      sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv4/raw.c:104:             sock_prot_inuse_add(sk->sk_prot, -1);
net/ipv4/udp.c:235:             sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv6/ipv6_sockglue.c:271:=20
sock_prot_inuse_add(sk->sk_prot, -1);
net/ipv6/ipv6_sockglue.c:272:=20
sock_prot_inuse_add(&tcp_prot, 1);
net/ipv6/ipv6_sockglue.c:285:=20
sock_prot_inuse_add(sk->sk_prot, -1);
net/ipv6/ipv6_sockglue.c:286:=20
sock_prot_inuse_add(prot, 1);
net/ipv6/inet6_hashtables.c:46: sock_prot_inuse_add(sk->sk_prot, 1);
net/ipv6/inet6_hashtables.c:207:        sock_prot_inuse_add(sk->sk_prot=
, 1);

c) No need to play with irq games here.

>=20
>> It is temporaty because it will vanish as soon as Christoph Clameter=
 (or=20
>> somebody else) provides real cheap per cpu counter implementation.
>=20
> numbers?
>=20
> most of percpu_counter_add() is only executed once per FBC_BATCH call=
s.



>=20
>> At time I introduced it in network tree (locally, not meant to invad=
e kernel=20
>> land and makes you unhappy :) ), the goals were :
>=20
> Well maybe as a temporary networking-only thing OK, based upon
> performance-tested results.  But I don't think the present code is su=
itable
> as part of the kernel-wide toolkit.
>=20
>> Some counters (total sockets count) were a single integer, that were=
 doing=20
>> ping-pong between cpus (SMP/NUMA). As they are basically lazy values=
 (as we=20
>> dont really need to read their value), using plain atomic_t was over=
kill.
>>
>> Using a plain percpu_counters was expensive (NR_CPUS*(32+sizeof(void=
 *))=20
>> instead of num_possible_cpus()*4).
>=20
> No, percpu_counters use alloc_percpu(), which is O(num_possible_cpus)=
, not
> O(NR_CPUS).

You are playing with words.

The array was exacly sizeof(void *) * NR_CPUS  (at least when pcounter =
were=20
added in network tree, commit b3242151906372f30f57feaa43b4cac96a23edb1 =
was=20
done only ten days ago). Then it needed 32 bytes per possible cpu (mayb=
e less=20
now with SLUB)


>=20
>> Using 'online' instead of 'possible' stuff is not really needed for =
a=20
>> temporary thing.
>=20
> This was put in ./lib/!
>=20
>> - We dont care of read sides.
>=20
> Well the present single caller in networking might not care.  But thi=
s was
> put in ./lib/ and was exported to modules.  That is an invitation to =
all
> kernel developers to use it in new code.  Which may result in truly a=
wful
> performance on high-cpu-count machines.

>=20
>>  We want really fast write side. Real fast.
>=20
> eh?  It's called on a per-connection basis, not on a per-packet basis=
?

Yes, per connection basis. Some workloads want to open/close more than =
1000=20
sockets per second.

You are right we also need to reduce all atomic inc/dec done per packet=
 :)

A pcounter/perc_cpu for the device refcounter would be a very nice win,=
 but as=20
number of devices in the system might be very big, David said no to a p=
ercpu=20
conversion. We will reconsider this when new percpu stuff can go in, so=
 that=20
the memory cost will be minimal (4 bytes per cpu per device)

>=20
>> Read side is when you do a "cat /proc/net/sockstat".
>> That is ... once in a while...
>=20
> For the current single caller.  But it's in ./lib/.
>=20
> And there's always someone out there who does whatever we don't expec=
t them
> to do.
>=20
>> Now when we allocate a new socket, code to increment the "socket cou=
nt" is :
>>
>> c03a74a8 <tcp_pcounter_add>:
>> c03a74a8:   b8 90 26 5f c0          mov    $0xc05f2690,%eax
>> c03a74ad:   64 8b 0d 10 f1 5e c0    mov    %fs:0xc05ef110,%ecx
>> c03a74b4:   01 14 01                add    %edx,(%ecx,%eax,1)
>> c03a74b7:   c3                      ret
>=20
> I can't find that code.  I suspect that's the DEFINE_PER_CPU flavour,=
 which
> isn't used anywhere afaict.  Plus this omits the local_irq_save/resto=
re (or
> preempt_disable/enable) and the indirect function call, which can be
> expensive.

Please do : nm vmlinux | grep tcp_pcounter_add

c03a74a8 t tcp_pcounter_add

It should be there, even if its a static function


>=20
>> That is 4 instructions. I could be two in the future, thanks to curr=
ent work=20
>> on fs/gs based percpu variables.
>>
>> Current percpu_counters implementation is more expensive :
>>
>> c021467b <__percpu_counter_add>:
>> c021467b:       55                      push   %ebp
>> c021467c:       57                      push   %edi
>> c021467d:       89 c7                   mov    %eax,%edi
>> c021467f:       56                      push   %esi
>> c0214680:       53                      push   %ebx
>> c0214681:       83 ec 04                sub    $0x4,%esp
>> c0214684:       8b 40 14                mov    0x14(%eax),%eax
>> c0214687:       64 8b 1d 08 f0 5e c0    mov    %fs:0xc05ef008,%ebx
>> c021468e:       8b 6c 24 18             mov    0x18(%esp),%ebp
>> c0214692:       f7 d0                   not    %eax
>> c0214694:       8b 1c 98                mov    (%eax,%ebx,4),%ebx
>> c0214697:       89 1c 24                mov    %ebx,(%esp)
>> c021469a:       8b 03                   mov    (%ebx),%eax
>> c021469c:       89 c3                   mov    %eax,%ebx
>> c021469e:       89 c6                   mov    %eax,%esi
>> c02146a0:       c1 fe 1f                sar    $0x1f,%esi
>> c02146a3:       89 e8                   mov    %ebp,%eax
>> c02146a5:       01 d3                   add    %edx,%ebx
>> c02146a7:       11 ce                   adc    %ecx,%esi
>> c02146a9:       99                      cltd
>> c02146aa:       39 d6                   cmp    %edx,%esi
>> c02146ac:       7f 15                   jg     c02146c3=20
>> <__percpu_counter_add+0x48>
>> c02146ae:       7c 04                   jl     c02146b4=20
>=20
> One of the above two branches is taken ((FBC_BATCH-1)/FBC_BATCH)ths o=
f the
> time.
>=20
>=20
>> <__percpu_counter_add+0x39>
>> c02146b0:       39 eb                   cmp    %ebp,%ebx
>> c02146b2:       73 0f                   jae    c02146c3=20
>> <__percpu_counter_add+0x48>
>> c02146b4:       f7 dd                   neg    %ebp
>> c02146b6:       89 e8                   mov    %ebp,%eax
>> c02146b8:       99                      cltd
>> c02146b9:       39 d6                   cmp    %edx,%esi
>> c02146bb:       7f 20                   jg     c02146dd=20
>> <__percpu_counter_add+0x62>
>> c02146bd:       7c 04                   jl     c02146c3=20
>> <__percpu_counter_add+0x48>
>> c02146bf:       39 eb                   cmp    %ebp,%ebx
>> c02146c1:       77 1a                   ja     c02146dd=20
>> <__percpu_counter_add+0x62>
>> c02146c3:       89 f8                   mov    %edi,%eax
>> c02146c5:       e8 04 cc 1f 00          call   c04112ce <_spin_lock>
>> c02146ca:       01 5f 04                add    %ebx,0x4(%edi)
>> c02146cd:       11 77 08                adc    %esi,0x8(%edi)
>> c02146d0:       8b 04 24                mov    (%esp),%eax
>> c02146d3:       c7 00 00 00 00 00       movl   $0x0,(%eax)
>> c02146d9:       fe 07                   incb   (%edi)
>> c02146db:       eb 05                   jmp    c02146e2=20
>> <__percpu_counter_add+0x67>
>> c02146dd:       8b 04 24                mov    (%esp),%eax
>> c02146e0:       89 18                   mov    %ebx,(%eax)
>> c02146e2:       58                      pop    %eax
>> c02146e3:       5b                      pop    %ebx
>> c02146e4:       5e                      pop    %esi
>> c02146e5:       5f                      pop    %edi
>> c02146e6:       5d                      pop    %ebp
>> c02146e7:       c3                      ret
>>
>>
>> Once it is better, just make pcounter vanish.
>=20
> Some of the stuff in there is from the __percpu_disguise() thing whic=
h we
> probably can live without.
>=20
> But I'd be surprised if benchmarking reveals that the pcounter code i=
s
> justifiable in its present networking application or indeed in any fu=
ture
> ones.

I have no benchmarks, but real workloads where it matters, and where us=
erland=20
eats icache/dcache all the time.

>=20
>> It is even clearly stated at the top of include/linux/pcounter.h
>>
>> /*
>>   * Using a dynamic percpu 'int' variable has a cost :
>>   * 1) Extra dereference
>>   * Current per_cpu_ptr() implementation uses an array per 'percpu v=
ariable'.
>>   * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_pos=
sible_cpus()*4
>>   *
>>   * This pcounter implementation is an abstraction to be able to use
>>   * either a static or a dynamic per cpu variable.
>>   * One dynamic per cpu variable gets a fast & cheap implementation,=
 we can
>>   * change pcounter implementation too.
>>   */
>>
>>
>> We all agree.
>>
>=20
> No we don't.  That comment is afaict wrong about the memory consumpti=
on and
> the abstraction *isn't useful*.

=46act is that we need percpu 32bits counters, and we need to have poin=
ters to them.

Current percpu_counters cannot cope that.

>=20
> Why do we want some abstraction which makes alloc_percpu() storage an=
d
> DEFINE_PERCPU storage "look the same"?  What use is there in that?  O=
ne is
> per-object storage and one is singleton storage - they're quite diffe=
rent
> things and they are used in quite different situations and they are
> basically never interchangeable.  Yet we add this pretend-they're-the=
-same
> wrapper around them which costs us an indirect function call on the
> fastpath.

I believe all 'pcounter' are in fact statically allocated 'one per stru=
ct=20
proto' to track inuse count. (search for DEFINE_PROTO_INUSE() uses)

# find net include|xargs grep -n DEFINE_PROTO_INUSE
net/dccp/ipv6.c:1105:DEFINE_PROTO_INUSE(dccp_v6)
net/dccp/ipv4.c:920:DEFINE_PROTO_INUSE(dccp_v4)
net/ipv6/udp.c:1001:DEFINE_PROTO_INUSE(udpv6)
net/ipv6/udplite.c:43:DEFINE_PROTO_INUSE(udplitev6)
net/ipv6/raw.c:1187:DEFINE_PROTO_INUSE(rawv6)
net/ipv6/tcp_ipv6.c:2108:DEFINE_PROTO_INUSE(tcpv6)
net/ipv4/udp.c:1477:DEFINE_PROTO_INUSE(udp)
net/ipv4/udplite.c:47:DEFINE_PROTO_INUSE(udplite)
net/ipv4/tcp_ipv4.c:2406:DEFINE_PROTO_INUSE(tcp)
net/ipv4/raw.c:828:DEFINE_PROTO_INUSE(raw)
net/sctp/socket.c:6461:DEFINE_PROTO_INUSE(sctp)
net/sctp/socket.c:6495:DEFINE_PROTO_INUSE(sctpv6)
include/net/sock.h:624:# define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTE=
R(NAME)
include/net/sock.h:644:# define DEFINE_PROTO_INUSE(NAME)

So pcounter_alloc()/pcounter_free() could just be deleted from pcounter=
=2Eh

indirect functions calls are everywhere in kernel, network, fs, everywh=
ere.

As soon we can put in 'struct pcounter' the address of a percpu variabl=
e, we=20
wont need anymore pointers to the pcounter_add()/getval() function.

mov  0(pcounter),%eax  # get the address of a percpuvar
add  %edx,fs:%eax

This just need the percpu work done by SGI guys to be finished.
