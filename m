From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 19:41:59 +0100
Message-ID: <498349F7.4050300@cosmosbay.com>
References: <20090130112125.GA9908@ioremap.net>	<20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Evgeniy Polyakov <zbr@ioremap.net>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38708 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbZA3Sn3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 13:43:29 -0500
In-Reply-To: <20090130095737.103edbff@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Fri, 30 Jan 2009 23:53:37 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>=20
>> Evgeniy Polyakov <zbr@ioremap.net> wrote:
>>> So it is not explicit bind call, but port autoselection in the
>>> connect(). Can you check what errno is returned?
>>> Did I understand it right, that connect fails, you try different
>>> address, but then suddenly all those sockets become 'alive'?
>> Yes, I think a good strace vs. a bad strace would be really helpful
>> in these cases.
>>
>> Thanks,
>=20
> I have the strace but it comes up no different.
> What is different is that in the broken case (net-next), I see
> IPV6 being used:
>=20
> State      Recv-Q Send-Q      Local Address:Port          Peer Addres=
s:Port  =20
> ESTAB      23769  0        ::ffff:127.0.0.1:5900      ::ffff:127.0.0.=
1:55987  =20
> ESTAB      0      0               127.0.0.1:55987            127.0.0.=
1:5900
>=20
> and in the working case (2.6.29-rc3), IPV4 is being used
> State      Recv-Q Send-Q      Local Address:Port          Peer Addres=
s:Port  =20
> ESTAB      0      0               127.0.0.1:58894            127.0.0.=
1:5901   =20
> ESTAB      0      0               127.0.0.1:5901             127.0.0.=
1:58894=20
>=20

Reviewing commit a9d8f9110d7e953c2f2b521087a4179677843c2a

I see use of a hashinfo->bsockets field that :

- lacks proper lock/synchronization
- suffers from cache line ping pongs on SMP

Also there might be a problem at line 175

if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts >=3D 0) =
{=20
	spin_unlock(&head->lock);
	goto again;

If we entered inet_csk_get_port() with a non null snum, we can "goto ag=
ain"
while it was not expected.

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index df8e72f..752c6b2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -172,7 +172,8 @@ tb_found:
 		} else {
 			ret =3D 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN && --attempts >=3D=
 0) {
+				if (sk->sk_reuse && sk->sk_state !=3D TCP_LISTEN &&
+					smallest_size =3D=3D -1 &&  --attempts >=3D 0) {
 					spin_unlock(&head->lock);
 					goto again;
 				}


