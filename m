From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: include/linux/pcounter.h
Date: Sat, 16 Feb 2008 11:26:18 -0800
Message-ID: <20080216112618.ec450f9b.akpm@linux-foundation.org>
References: <20080204014402.1c55d3fe.akpm@linux-foundation.org>
	<20080215193711.2e3d41f3.akpm@linux-foundation.org>
	<47B6B5E1.90705@cosmosbay.com>
	<20080216025051.751b4a86.akpm@linux-foundation.org>
	<47B6D12A.3090401@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42728 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755679AbYBPT1x convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2008 14:27:53 -0500
In-Reply-To: <47B6D12A.3090401@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 16 Feb 2008 13:03:54 +0100 Eric Dumazet <dada1@cosmosbay.com> w=
rote:

> Andrew Morton a =E9crit :
> > On Sat, 16 Feb 2008 11:07:29 +0100 Eric Dumazet <dada1@cosmosbay.co=
m> wrote:
> >=20
> >> Andrew, pcounter is a temporary abstraction.
> >=20
> > It's buggy!  Main problems are a) possible return of negative numbe=
rs b)
> > some of the API can't be from preemptible code c) excessive interru=
pt-off
> > time on some machines if used from irq-disabled sections.

This is starting to get tiresome.  Please do not waste my time and ever=
yone
else's by defending the indefensible.

> a) We dont care of possibly off values when reading /proc/net/socksta=
t

So take the damn thing out of ./lib/ and hide it down in networking
somewhere.

>     Same arguments apply for percpu_counters.

No it does not, Not at all.  Callers regularly use percpu_counters to c=
ount
the number of some object.  These counts never go negative!

And how the heck can you say that we don't care if /proc/net/sockstat g=
oes
negative?  You don't know that.  Someone's system-monitoring app might =
very
well take drastic action if it sees connection-related statistics go
negative, or around 4 gigaconnections.

> b) It is called from network parts where preemption is disabled.

It's in ./lib/

> net/ipv4/inet_timewait_sock.c:94:=20
> sock_prot_inuse_add(sk->sk_prot, -1);
> net/ipv4/inet_hashtables.c:291: sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv4/inet_hashtables.c:335: sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv4/inet_hashtables.c:357: sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv4/inet_hashtables.c:390:         sock_prot_inuse_add(sk->sk_pr=
ot, -1);
> net/ipv4/raw.c:95:      sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv4/raw.c:104:             sock_prot_inuse_add(sk->sk_prot, -1);
> net/ipv4/udp.c:235:             sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv6/ipv6_sockglue.c:271:=20
> sock_prot_inuse_add(sk->sk_prot, -1);
> net/ipv6/ipv6_sockglue.c:272:=20
> sock_prot_inuse_add(&tcp_prot, 1);
> net/ipv6/ipv6_sockglue.c:285:=20
> sock_prot_inuse_add(sk->sk_prot, -1);
> net/ipv6/ipv6_sockglue.c:286:=20
> sock_prot_inuse_add(prot, 1);
> net/ipv6/inet6_hashtables.c:46: sock_prot_inuse_add(sk->sk_prot, 1);
> net/ipv6/inet6_hashtables.c:207:        sock_prot_inuse_add(sk->sk_pr=
ot, 1);
>=20
> c) No need to play with irq games here.

It's in ./lib/

> >=20
> >> It is temporaty because it will vanish as soon as Christoph Clamet=
er (or=20
> >> somebody else) provides real cheap per cpu counter implementation.
> >=20
> > numbers?
> >=20
> > most of percpu_counter_add() is only executed once per FBC_BATCH ca=
lls.
>=20
>=20
>=20
> >=20
> >> At time I introduced it in network tree (locally, not meant to inv=
ade kernel=20
> >> land and makes you unhappy :) ), the goals were :
> >=20
> > Well maybe as a temporary networking-only thing OK, based upon
> > performance-tested results.  But I don't think the present code is =
suitable
> > as part of the kernel-wide toolkit.
> >=20
> >> Some counters (total sockets count) were a single integer, that we=
re doing=20
> >> ping-pong between cpus (SMP/NUMA). As they are basically lazy valu=
es (as we=20
> >> dont really need to read their value), using plain atomic_t was ov=
erkill.
> >>
> >> Using a plain percpu_counters was expensive (NR_CPUS*(32+sizeof(vo=
id *))=20
> >> instead of num_possible_cpus()*4).
> >=20
> > No, percpu_counters use alloc_percpu(), which is O(num_possible_cpu=
s), not
> > O(NR_CPUS).
>=20
> You are playing with words.

I assumed the comment was comparing with percpu_counters.

Seems that it was comparing with some hand-rolled static array of NR_CP=
US
entries or something.

> >=20
> >>  We want really fast write side. Real fast.
> >=20
> > eh?  It's called on a per-connection basis, not on a per-packet bas=
is?
>=20
> Yes, per connection basis. Some workloads want to open/close more tha=
n 1000=20
> sockets per second.

ie: slowpath

> You are right we also need to reduce all atomic inc/dec done per pack=
et :)
>=20
> A pcounter/perc_cpu for the device refcounter would be a very nice wi=
n, but as=20
> number of devices in the system might be very big, David said no to a=
 percpu=20
> conversion. We will reconsider this when new percpu stuff can go in, =
so that=20
> the memory cost will be minimal (4 bytes per cpu per device)
>=20
> >=20
> >> Read side is when you do a "cat /proc/net/sockstat".
> >> That is ... once in a while...
> >=20
> > For the current single caller.  But it's in ./lib/.
> >=20
> > And there's always someone out there who does whatever we don't exp=
ect them
> > to do.
> >=20
> >> Now when we allocate a new socket, code to increment the "socket c=
ount" is :
> >>
> >> c03a74a8 <tcp_pcounter_add>:
> >> c03a74a8:   b8 90 26 5f c0          mov    $0xc05f2690,%eax
> >> c03a74ad:   64 8b 0d 10 f1 5e c0    mov    %fs:0xc05ef110,%ecx
> >> c03a74b4:   01 14 01                add    %edx,(%ecx,%eax,1)
> >> c03a74b7:   c3                      ret
> >=20
> > I can't find that code.  I suspect that's the DEFINE_PER_CPU flavou=
r, which
> > isn't used anywhere afaict.  Plus this omits the local_irq_save/res=
tore (or
> > preempt_disable/enable) and the indirect function call, which can b=
e
> > expensive.
>=20
> Please do : nm vmlinux | grep tcp_pcounter_add
>=20
> c03a74a8 t tcp_pcounter_add
>=20
> It should be there, even if its a static function
>=20

Probably - the macros hide it well.  And the function itself doesn't te=
ll
the whole story: callers must still do preempt_dsable or local_irq_enab=
le
and must wear the cost of an indirect call.

> >=20
> >> It is even clearly stated at the top of include/linux/pcounter.h
> >>
> >> /*
> >>   * Using a dynamic percpu 'int' variable has a cost :
> >>   * 1) Extra dereference
> >>   * Current per_cpu_ptr() implementation uses an array per 'percpu=
 variable'.
> >>   * 2) memory cost of NR_CPUS*(32+sizeof(void *)) instead of num_p=
ossible_cpus()*4
> >>   *
> >>   * This pcounter implementation is an abstraction to be able to u=
se
> >>   * either a static or a dynamic per cpu variable.
> >>   * One dynamic per cpu variable gets a fast & cheap implementatio=
n, we can
> >>   * change pcounter implementation too.
> >>   */
> >>
> >>
> >> We all agree.
> >>
> >=20
> > No we don't.  That comment is afaict wrong about the memory consump=
tion and
> > the abstraction *isn't useful*.
>=20
> Fact is that we need percpu 32bits counters, and we need to have poin=
ters to them.
>=20
> Current percpu_counters cannot cope that.

yes they can.

> >=20
> > Why do we want some abstraction which makes alloc_percpu() storage =
and
> > DEFINE_PERCPU storage "look the same"?  What use is there in that? =
 One is
> > per-object storage and one is singleton storage - they're quite dif=
ferent
> > things and they are used in quite different situations and they are
> > basically never interchangeable.  Yet we add this pretend-they're-t=
he-same
> > wrapper around them which costs us an indirect function call on the
> > fastpath.
>=20
> I believe all 'pcounter' are in fact statically allocated 'one per st=
ruct=20
> proto' to track inuse count. (search for DEFINE_PROTO_INUSE() uses)
>=20
> # find net include|xargs grep -n DEFINE_PROTO_INUSE
> net/dccp/ipv6.c:1105:DEFINE_PROTO_INUSE(dccp_v6)
> net/dccp/ipv4.c:920:DEFINE_PROTO_INUSE(dccp_v4)
> net/ipv6/udp.c:1001:DEFINE_PROTO_INUSE(udpv6)
> net/ipv6/udplite.c:43:DEFINE_PROTO_INUSE(udplitev6)
> net/ipv6/raw.c:1187:DEFINE_PROTO_INUSE(rawv6)
> net/ipv6/tcp_ipv6.c:2108:DEFINE_PROTO_INUSE(tcpv6)
> net/ipv4/udp.c:1477:DEFINE_PROTO_INUSE(udp)
> net/ipv4/udplite.c:47:DEFINE_PROTO_INUSE(udplite)
> net/ipv4/tcp_ipv4.c:2406:DEFINE_PROTO_INUSE(tcp)
> net/ipv4/raw.c:828:DEFINE_PROTO_INUSE(raw)
> net/sctp/socket.c:6461:DEFINE_PROTO_INUSE(sctp)
> net/sctp/socket.c:6495:DEFINE_PROTO_INUSE(sctpv6)
> include/net/sock.h:624:# define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUN=
TER(NAME)
> include/net/sock.h:644:# define DEFINE_PROTO_INUSE(NAME)
>=20
> So pcounter_alloc()/pcounter_free() could just be deleted from pcount=
er.h

Well if you do that and if pcounters become helpers functions around
DEFINE_PERCPU memory then things are starting to get a bit more sensibl=
e.=20
We can then remove the indirect function call.

Yes, a general wrapper around a DEFINE_PERCPU'ed counter could be a use=
ful
thing to have.  It could use raw_smp_processor_id() and local_add().

Problem is the read side will still be far too inefficient for it to be
presentable as a general-purpose library - it really will need to do al=
l
the batching which experience told us was needed in percpu_counters.

The read side should also present two interfaces: one which returns a +=
ve
or -ve value and one which returns a never-negative value.

> indirect functions calls are everywhere in kernel, network, fs, every=
where.

That doesn't make them fast.

> As soon we can put in 'struct pcounter' the address of a percpu varia=
ble, we=20
> wont need anymore pointers to the pcounter_add()/getval() function.
>=20
> mov  0(pcounter),%eax  # get the address of a percpuvar
> add  %edx,fs:%eax
>=20
> This just need the percpu work done by SGI guys to be finished.

So...  I need to keep watching the tree to make sure that nobody actual=
ly
uses this code in ./lib/?

