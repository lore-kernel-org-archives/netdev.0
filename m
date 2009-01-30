From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 23:30:22 +0100
Message-ID: <49837F7E.90306@cosmosbay.com>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42603 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbZA3Wax convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:30:53 -0500
In-Reply-To: <20090130215008.GB12210@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Fri, Jan 30, 2009 at 07:41:59PM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>> Reviewing commit a9d8f9110d7e953c2f2b521087a4179677843c2a
>>
>> I see use of a hashinfo->bsockets field that :
>>
>> - lacks proper lock/synchronization
>=20
> It should contain rough number of sockets, there is no need to be ver=
y
> precise because of this hueristic.

Denying there is a bug is... well... I dont know what to say.

I wonder why we still use atomic_t all over the kernel.

>=20
>> - suffers from cache line ping pongs on SMP
>=20
> I used free alignment slot so that socket structure would not be
> icreased.

Are you kidding ?

bsockets is not part of socket structure, but part of "struct inet_hash=
info",
shared by all cpus and accessed several thousand times per second on ma=
ny
machines.

Please read the comment three lines after 'the free alignemnt slot'
you chose.... You just introduced one write on a cache line
that is supposed to *not* be written.

        unsigned int                    bhash_size;
        int                             bsockets;

        struct kmem_cache               *bind_bucket_cachep;

        /* All the above members are written once at bootup and
         * never written again _or_ are predominantly read-access.
         *
         * Now align to a new cache line as all the following members
         * might be often dirty.
         */



>=20
>> Also there might be a problem at line 175
>>
>> if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts >=3D =
0) {=20
>> 	spin_unlock(&head->lock);
>> 	goto again;
>>
>> If we entered inet_csk_get_port() with a non null snum, we can "goto=
 again"
>> while it was not expected.
>>
>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connect=
ion_sock.c
>> index df8e72f..752c6b2 100644
>> --- a/net/ipv4/inet_connection_sock.c
>> +++ b/net/ipv4/inet_connection_sock.c
>> @@ -172,7 +172,8 @@ tb_found:
>>  		} else {
>>  			ret =3D 1;
>>  			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
>> -				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts =
>=3D 0) {
>> +				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN &&
>> +					smallest_size =3D=3D -1 &&  --attempts >=3D 0) {
>=20
> I think it should be smallest_size !=3D -1, since we really want to g=
oto
> to the again label when hueristic is used, which in turn changes
> smallest_size.
>=20

Yep


