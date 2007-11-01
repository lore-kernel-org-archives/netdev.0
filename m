From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 18:54:24 +0100
Message-ID: <472A12D0.4070401@cosmosbay.com>
References: <4729A774.9030409@cosmosbay.com> <20071101091456.26248ce0@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37664 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355AbXKARyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 13:54:54 -0400
In-Reply-To: <20071101091456.26248ce0@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> On Thu, 01 Nov 2007 11:16:20 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> As done two years ago on IP route cache table (commit=20
>> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one l=
ock per=20
>> hash bucket for the huge TCP/DCCP hash tables.
>>
>> On a typical x86_64 platform, this saves about 2MB or 4MB of ram, fo=
r litle=20
>> performance differences. (we hit a different cache line for the rwlo=
ck, but=20
>> then the bucket cache line have a better sharing factor among cpus, =
since we=20
>> dirty it less often)
>>
>> Using a 'small' table of hashed rwlocks should be more than enough t=
o provide=20
>> correct SMP concurrency between different buckets, without using too=
 much=20
>> memory. Sizing of this table depends on NR_CPUS and various CONFIG s=
ettings.
>>
>> This patch provides some locking abstraction that may ease a future =
work using=20
>>   a different model for TCP/DCCP table.
>>
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>
>>   include/net/inet_hashtables.h |   40 ++++++++++++++++++++++++++++-=
---
>>   net/dccp/proto.c              |   16 ++++++++++--
>>   net/ipv4/inet_diag.c          |    9 ++++---
>>   net/ipv4/inet_hashtables.c    |    7 +++--
>>   net/ipv4/inet_timewait_sock.c |   13 +++++-----
>>   net/ipv4/tcp.c                |   11 +++++++-
>>   net/ipv4/tcp_ipv4.c           |   11 ++++----
>>   net/ipv6/inet6_hashtables.c   |   19 ++++++++-------
>>   8 files changed, 89 insertions(+), 37 deletions(-)
>>
>=20
> Longterm is there any chance of using rcu for this? Seems like
> it could be a big win.
>=20

This was discussed in the past, and I even believe some patch was propo=
sed,=20
but some guys (including David) complained that RCU is well suited for =
'mostly=20
  read' structures.

On some web server workloads, TCP hash table is constantly accessed in =
write=20
mode (socket creation, socket move to timewait state, socket  deleted..=
=2E), and=20
RCU added overhead and poor cache re-use (because sockets must be place=
d on=20
RCU queue before reuse)

On these typical workload, hash table without RCU is still the best.

Longterm changes would rather be based on Robert Olsson suggestion last=
 year=20
(trie based lookups and unified IP/TCP cache)

Short term changes would be to be able to resize the TCP hash table (be=
ing=20
small at boot, and be able to grow it if necessary). Its current size o=
n=20
modern machines is just insane.

