From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] udp: Introduce special NULL pointers for hlist
 termination
Date: Thu, 30 Oct 2008 08:51:26 -0700
Message-ID: <20081030085126.0d9b956b@extreme>
References: <4908627C.6030001@acm.org>
	<490874F2.2060306@cosmosbay.com>
	<49088288.6050805@acm.org>
	<49088AD1.7040805@cosmosbay.com>
	<20081029163739.GB6732@linux.vnet.ibm.com>
	<49089BE5.3090705@acm.org>
	<4908A134.4040705@cosmosbay.com>
	<4908AB3F.1060003@acm.org>
	<20081029185200.GE6732@linux.vnet.ibm.com>
	<4908C0CD.5050406@cosmosbay.com>
	<20081029201759.GF6732@linux.vnet.ibm.com>
	<4908DEDE.5030706@cosmosbay.com>
	<4909D551.9080309@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Corey Minyard <minyard@acm.org>,
	David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk,
	netdev@vger.kernel.org,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46718 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753480AbYJ3Pvb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 11:51:31 -0400
In-Reply-To: <4909D551.9080309@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Oct 2008 16:40:01 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Paul E. McKenney a =C3=A9crit :
> >> On Wed, Oct 29, 2008 at 09:00:13PM +0100, Eric Dumazet wrote:
> >>> Hum... Another way of handling all those cases and avoid memory b=
arriers
> >>> would be to have different "NULL" pointers.
> >>>
> >>> Each hash chain should have a unique "NULL" pointer (in the case =
of=20
> >>> UDP, it
> >>> can be the 128 values : [ (void*)0 .. (void *)127 ]
> >>>
> >>> Then, when performing a lookup, a reader should check the "NULL" =
pointer
> >>> it get at the end of its lookup has is the "hash" value of its ch=
ain.
> >>>
> >>> If not -> restart the loop, aka "goto begin;" :)
> >>>
> >>> We could avoid memory barriers then.
> >>>
> >>> In the two cases Corey mentioned, this trick could let us avoid=20
> >>> memory barriers.
> >>> (existing one in sk_add_node_rcu(sk, &hslot->head); should be eno=
ugh)
> >>>
> >>> What do you think ?
> >>
> >> Kinky!!!  ;-)
> >>
> >> Then the rcu_dereference() would be supplying the needed memory ba=
rriers.
> >>
> >> Hmmm...  I guess that the only confusion would be if the element g=
ot
> >> removed and then added to the same list.  But then if its pointer =
was
> >> pseudo-NULL, then that would mean that all subsequent elements had=
 been
> >> removed, and all preceding ones added after the scan started.
> >>
> >> Which might well be harmless, but I must defer to you on this one =
at
> >> the moment.
> >>
> >> If you need a larger hash table, another approach would be to set =
the
> >> pointer's low-order bit, allowing the upper bits to be a full-size=
d
> >> index -- or even a pointer to the list header.  Just make very sur=
e
> >> to clear the pointer when freeing, or an element on the freelist
> >> could end up looking like a legitimate end of list...  Which again
> >> might well be safe, but why inflict this on oneself?
> >=20
>=20
> Ok, here is an updated and tested patch.
>=20
> Thanks everybody
>=20
> [PATCH] udp: Introduce special NULL pointers for hlist termination
>=20
> In order to safely detect changes in chains, we would like to have di=
fferent
> 'NULL' pointers. Each chain in hash table is terminated by an unique =
'NULL'
> value, so that the lockless readers can detect their lookups evaded f=
rom
> their starting chain.
>=20
> We introduce a new type of hlist implementation, named hlist_nulls, w=
ere
> we use the least significant bit of the 'ptr' to tell if its a "NULL"=
 value
> or a pointer to an object. We expect to use this new hlist variant fo=
r TCP
> as well.
>=20
> For UDP/UDP-Lite hash table, we use 128 different "NULL" values,
> (UDP_HTABLE_SIZE=3D128)
>=20
> Using hlist_nulls saves memory barriers (a read barrier to fetch 'nex=
t'
> pointers *before* checking key values) we added in commit=20
> 96631ed16c514cf8b28fab991a076985ce378c26
> (udp: introduce sk_for_each_rcu_safenext())
>=20
> This also saves a write memory barrier in udp_lib_get_port(), between
> sk->sk_hash update and sk->next update)
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---

IMHO this goes over the edge into tricky hack. Is it really worth it?
Is there a better simpler way?
