From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 1/3] rcu: Introduce hlist_nulls variant of hlist
Date: Thu, 13 Nov 2008 14:44:07 +0100
Message-ID: <491C2F27.2000908@cosmosbay.com>
References: <4908627C.6030001@acm.org> <490874F2.2060306@cosmosbay.com>	 <49088288.6050805@acm.org> <49088AD1.7040805@cosmosbay.com>	 <20081029163739.GB6732@linux.vnet.ibm.com> <49089BE5.3090705@acm.org>	 <4908A134.4040705@cosmosbay.com> <4908AB3F.1060003@acm.org>	 <20081029185200.GE6732@linux.vnet.ibm.com> <4908C0CD.5050406@cosmosbay.com>	 <20081029201759.GF6732@linux.vnet.ibm.com> <4908DEDE.5030706@cosmosbay.com>	 <4909D551.9080309@cosmosbay.com>  <491C282A.5050802@cosmosbay.com> <1226582997.7685.4786.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Corey Minyard <minyard@acm.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	benny+usenet@amorsen.dk,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Christian Bell <christian@myri.com>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41131 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086AbYKMNow convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 08:44:52 -0500
In-Reply-To: <1226582997.7685.4786.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra a =E9crit :
> On Thu, 2008-11-13 at 14:14 +0100, Eric Dumazet wrote:
>> hlist uses NULL value to finish a chain.
>>
>> hlist_nulls variant use the low order bit set to 1 to signal an end-=
of-list marker.
>>
>> This allows to store many different end markers, so that some RCU lo=
ckless
>> algos (used in TCP/UDP stack for example) can save some memory barri=
ers in
>> fast paths.
>>
>> Two new files are added :
>>
>> include/linux/list_nulls.h
>>   - mimics hlist part of include/linux/list.h, derived to hlist_null=
s variant
>=20
> How is the !rcu variant useful?

=46or example, if a process holds a lock, it doesnt need rcu version.

/proc/net/tcp comes to mind


>=20
>> include/linux/rculist_nulls.h
>>   - mimics hlist part of include/linux/rculist.h, derived to hlist_n=
ulls variant
>>
>>    Only four helpers are declared for the moment :
>>
>>      hlist_nulls_del_init_rcu(), hlist_nulls_del_rcu(),
>>      hlist_nulls_add_head_rcu() and hlist_nulls_for_each_entry_rcu()
>>
>> prefetches() were removed, since an end of list is not anymore NULL =
value.
>> prefetches() could trigger useless (and possibly dangerous) memory t=
ransactions.
>>

>=20
> So by not using some memory barriers (would be nice to have it
> illustrated which ones), we can race and end up on the wrong chain, i=
n
> case that happens we detect this by using this per-chain terminator a=
nd
> try again.
>=20
> It would be really good to have it explained in the rculist_nulls.h
> comments what memory barriers are missing, what races they open, and =
how
> the this special terminator trick closes that race.

OK, maybe I should add a Documentation/RCU/rculist_nulls.txt file with
appropriate examples and documentation.

(Say the lookup/insert algorithms, with standard hlist and memory barri=
ers,
and with hlist_nulls without those two memory barriers.

(These two memory barriers can be found in commits :

c37ccc0d4e2a4ee52f1a40cff1be0049f2104bba :

udp: add a missing smp_wmb() in udp_lib_get_port()

Corey Minyard spotted a missing memory barrier in udp_lib_get_port()

We need to make sure a reader cannot read the new 'sk->sk_next' value
and previous value of 'sk->sk_hash'. Or else, an item could be deleted
from a chain, and inserted into another chain. If new chain was empty
before the move, 'next' pointer is NULL, and lockless reader can
not detect it missed following items in original chain.

This patch is temporary, since we expect an upcoming patch
to introduce another way of handling the problem.


And commit 96631ed16c514cf8b28fab991a076985ce378c26 :

udp: introduce sk_for_each_rcu_safenext()

Corey Minyard found a race added in commit 271b72c7fa82c2c7a795bc168961=
49933110672d
(udp: RCU handling for Unicast packets.)

 "If the socket is moved from one list to another list in-between the
 time the hash is calculated and the next field is accessed, and the
 socket has moved to the end of the new list, the traversal will not
 complete properly on the list it should have, since the socket will
 be on the end of the new list and there's not a way to tell it's on a
 new list and restart the list traversal.  I think that this can be
 solved by pre-fetching the "next" field (with proper barriers) before
 checking the hash."

This patch corrects this problem, introducing a new
sk_for_each_rcu_safenext() macro.


>=20
> I'm sure most of us understand it now, but will we still in a few
> months? - how about new people?
>=20
> Other than that, very cool stuff! :-)

Thanks Peter ;)


