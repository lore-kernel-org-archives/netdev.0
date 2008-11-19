From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/3] udp: Use hlist_nulls in UDP RCU code
Date: Wed, 19 Nov 2008 18:53:08 +0100
Message-ID: <49245284.60002@cosmosbay.com>
References: <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org> <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org> <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com> <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com> <4909D551.9080309@cosmosbay.com> <491C2867.5030807@cosmosbay.com> <20081119172910.GC6753@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Corey Minyard <minyard@acm.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46316 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbYKSRyL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 12:54:11 -0500
In-Reply-To: <20081119172910.GC6753@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney a =E9crit :
> On Thu, Nov 13, 2008 at 02:15:19PM +0100, Eric Dumazet wrote:
>> This is a straightforward patch, using hlist_nulls infrastructure.
>>
>> RCUification already done on UDP two weeks ago.
>>
>> Using hlist_nulls permits us to avoid some memory barriers, both
>> at lookup time and delete time.
>>
>> Patch is large because it adds new macros to include/net/sock.h.
>> These macros will be used by TCP & DCCP in next patch.
>=20
> Looks good, one question below about the lockless searches.  If the
> answer is that the search must complete undisturbed by deletions and
> additions, then:
>=20
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>> ---
>> include/linux/rculist.h |   17 -----------
>> include/net/sock.h      |   57 ++++++++++++++++++++++++++++++-------=
-
>> include/net/udp.h       |    2 -
>> net/ipv4/udp.c          |   47 ++++++++++++++-----------------
>> net/ipv6/udp.c          |   26 +++++++++--------
>> 5 files changed, 83 insertions(+), 66 deletions(-)
>>
>=20
=2E..
>>  	result =3D NULL;
>>  	badness =3D -1;
>> -	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
>> -		/*
>> -		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
>> -		 * We must check this item was not moved to another chain
>> -		 */
>> -		if (udp_hashfn(net, sk->sk_hash) !=3D hash)
>> -			goto begin;
>> +	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
>>  		score =3D compute_score(sk, net, saddr, hnum, sport,
>>  				      daddr, dport, dif);
>>  		if (score > badness) {
>> @@ -285,6 +274,14 @@ begin:
>>  			badness =3D score;
>>  		}
>>  	}
>> +	/*
>> +	 * if the nulls value we got at the end of this lookup is
>> +	 * not the expected one, we must restart lookup.
>> +	 * We probably met an item that was moved to another chain.
>> +	 */
>> +	if (get_nulls_value(node) !=3D hash)
>> +		goto begin;
>> +
>=20
> Shouldn't this check go -after- the check for "result"?  Or is this a
> case where the readers absolutely must have traversed a chain without
> modification to be guaranteed of finding the correct result?

Very good question

Yes, we really have to look at all the sockets, to find the one with hi=
gher score, not
one with a low score, and the one with higher score being ignored becau=
se we didnt examined it.

So we really must check we finished our lookup on the right chain end, =
not an alien one.

(Previous UDP code had a shortcut if we found the socket with the maxim=
al possible score,
I deleted this test as it had basically 0.0001 % of chance being hit)

Thanks a lot for your patient review Paul.

