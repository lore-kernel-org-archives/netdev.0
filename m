From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in rawv6_bind()
Date: Fri, 06 Nov 2009 18:01:17 +0100
Message-ID: <4AF4565D.2070207@gmail.com>
References: <4AF40022.6050100@gmail.com> <4AF4536E.7090803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34082 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758230AbZKFRBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:01:17 -0500
In-Reply-To: <4AF4536E.7090803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley a =E9crit :
> Eric Dumazet wrote:=20
>> @@ -257,6 +257,7 @@ static int rawv6_bind(struct sock *sk, struct so=
ckaddr *uaddr, int addr_len)
>>  	if (sk->sk_state !=3D TCP_CLOSE)
>>  		goto out;
>> =20
>> +	rcu_read_unlock();
>>  	/* Check if the address belongs to the host. */
>>  	if (addr_type !=3D IPV6_ADDR_ANY) {
>>  		struct net_device *dev =3D NULL;
>=20
> This was supposed to be rcu_read_lock(), right?
>=20

Oops ! Indeed ! Thanks for spotting this Brian.

[PATCH net-next2.6] ipv6: avoid dev_hold()/dev_put() in rawv6_bind()

Using RCU helps not touching device refcount in rawv6_bind()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/raw.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 818ef21..926ce8e 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -249,7 +249,7 @@ static int rawv6_bind(struct sock *sk, struct socka=
ddr *uaddr, int addr_len)
=20
 	/* Raw sockets are IPv6 only */
 	if (addr_type =3D=3D IPV6_ADDR_MAPPED)
-		return(-EADDRNOTAVAIL);
+		return -EADDRNOTAVAIL;
=20
 	lock_sock(sk);
=20
@@ -257,6 +257,7 @@ static int rawv6_bind(struct sock *sk, struct socka=
ddr *uaddr, int addr_len)
 	if (sk->sk_state !=3D TCP_CLOSE)
 		goto out;
=20
+	rcu_read_lock();
 	/* Check if the address belongs to the host. */
 	if (addr_type !=3D IPV6_ADDR_ANY) {
 		struct net_device *dev =3D NULL;
@@ -272,13 +273,13 @@ static int rawv6_bind(struct sock *sk, struct soc=
kaddr *uaddr, int addr_len)
=20
 			/* Binding to link-local address requires an interface */
 			if (!sk->sk_bound_dev_if)
-				goto out;
+				goto out_unlock;
=20
-			dev =3D dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
-			if (!dev) {
-				err =3D -ENODEV;
-				goto out;
-			}
+			err =3D -ENODEV;
+			dev =3D dev_get_by_index_rcu(sock_net(sk),
+						   sk->sk_bound_dev_if);
+			if (!dev)
+				goto out_unlock;
 		}
=20
 		/* ipv4 addr of the socket is invalid.  Only the
@@ -289,13 +290,9 @@ static int rawv6_bind(struct sock *sk, struct sock=
addr *uaddr, int addr_len)
 			err =3D -EADDRNOTAVAIL;
 			if (!ipv6_chk_addr(sock_net(sk), &addr->sin6_addr,
 					   dev, 0)) {
-				if (dev)
-					dev_put(dev);
-				goto out;
+				goto out_unlock;
 			}
 		}
-		if (dev)
-			dev_put(dev);
 	}
=20
 	inet->inet_rcv_saddr =3D inet->inet_saddr =3D v4addr;
@@ -303,6 +300,8 @@ static int rawv6_bind(struct sock *sk, struct socka=
ddr *uaddr, int addr_len)
 	if (!(addr_type & IPV6_ADDR_MULTICAST))
 		ipv6_addr_copy(&np->saddr, &addr->sin6_addr);
 	err =3D 0;
+out_unlock:
+	rcu_read_unlock();
 out:
 	release_sock(sk);
 	return err;
