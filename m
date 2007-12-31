From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] [UDP]: add udp_mem, udp_rmem_min and udp_wmem_min
Date: Mon, 31 Dec 2007 09:54:32 +0100
Message-ID: <4778AE48.1040701@cosmosbay.com>
References: <47775D8C.5010104@redhat.com>	<47775E7A.60708@redhat.com> <20071231.001925.151533664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: haoki@redhat.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:53482 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbXLaIzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 03:55:45 -0500
In-Reply-To: <20071231.001925.151533664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Hideo AOKI <haoki@redhat.com>
> Date: Sun, 30 Dec 2007 04:01:46 -0500
>=20
>> diff -pruN net-2.6.25-t12t19m-p4/net/ipv4/proc.c net-2.6.25-t12t19m-=
p5/net/ipv4/proc.c
>> --- net-2.6.25-t12t19m-p4/net/ipv4/proc.c	2007-12-27 10:19:02.000000=
000 -0500
>> +++ net-2.6.25-t12t19m-p5/net/ipv4/proc.c	2007-12-29 21:09:21.000000=
000 -0500
>> @@ -56,7 +56,8 @@ static int sockstat_seq_show(struct seq_
>>  		   sock_prot_inuse(&tcp_prot), atomic_read(&tcp_orphan_count),
>>  		   tcp_death_row.tw_count, atomic_read(&tcp_sockets_allocated),
>>  		   atomic_read(&tcp_memory_allocated));
>> -	seq_printf(seq, "UDP: inuse %d\n", sock_prot_inuse(&udp_prot));
>> +	seq_printf(seq, "UDP: inuse %d mem %d\n", sock_prot_inuse(&udp_pro=
t),
>> +		   atomic_read(&udp_memory_allocated));
>>  	seq_printf(seq, "UDPLITE: inuse %d\n", sock_prot_inuse(&udplite_pr=
ot));
>>  	seq_printf(seq, "RAW: inuse %d\n", sock_prot_inuse(&raw_prot));
>>  	seq_printf(seq,  "FRAG: inuse %d memory %d\n",
>=20
> More careless patch creation.  :-/
>=20
> This breaks the build because udp_memory_allocated is not added until
> patch 2.
>=20
> Once again I'll combine all three patches into one but I am extremely
> angry about how careless and broken these two patch submissions were.

I am a litle bit concerned about performance of IVR servers
using SIP protocol.

On those servers, each active channel typically emits/receives 50 UDP/R=
TP=20
frames per second. With G729 codec, each packet contains 10 bytes of pa=
yload,=20
and about 40 bytes of IP/UDP/RTP encapsulation. (So these messages are =
very
small)

As I am currently enjoying hollidays at home, I am not able to test on =
my=20
server farm the performance impact of this new UDP receive accounting.

If I understand well the patch, each time a packet is received (on a so=
cket
with no previous message available in its receive queue), we are going =
to=20
atomic_inc(&some_global_var). Then the user thread that will transfert =
this
message to user land will atomic_dec(&some_global_var). (Granted server=
 is
in normal condition, ie each UDP socket holds at most one message in it=
s
receive or transmit queue)

I have some machines with 400 active SIP channels, so that new hot cach=
e line
will probably slow down our SMP servers, because of cache line ping pon=
g.

I will probably setup a test next week and let you know the results.

Maybe I read the patch incorrectly, or we could add some new sysctl so =
that
we not try to uncharge memory if a socket 'forward_alloc' is beyond a g=
iven=20
limit (say 2 pages), so that number of atomic_inc/dec on udp_memory_all=
ocated=20
(or tcp_memory_allocated) is reduced.

Thank you
