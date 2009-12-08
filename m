From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes
 of heavy surfing
Date: Tue, 08 Dec 2009 04:03:30 +0100
Message-ID: <4B1DC202.20607@gmail.com>
References: <138412.20552.qm@web52903.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38542 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbZLHDEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 22:04:16 -0500
In-Reply-To: <138412.20552.qm@web52903.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Rankin a =C3=A9crit :
>=20
> I saw something interesting in 2.6.31.7 about a crash due to fragment=
ation:
>=20
> ipv4: additional update of dev_net(dev) to struct *net in ip_fragment=
=2Ec, NULL ptr OOPS
>=20
> I'll try applying that patch too, to see if it makes any difference. =
Along with that other UDP-related thing I noticed:
>=20
> udp: Fix udp_poll() and ioctl()
>=20

Its all two years old UDP bugs (I spot another one some hours ago), and=
 very rare.
I run heavy duty servers with lot of UDP trafic and never caught a _sin=
gle_ error,
I am quite suprised it could happen on your machine on demand.

1) Do you have another NIC adapter to try ? It might be a buggy driver.
  (Neil Horman found an error on Intel drivers some hours ago, that can=
 corrupt skbs)

2) Could you add following debugging aid ?

3) Any chance you can do a git bisect ?

Thanks


diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7d12c6a..5a7a456 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -147,10 +147,15 @@ void inet_sock_destruct(struct sock *sk)
 		return;
 	}
=20
-	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
-	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
-	WARN_ON(sk->sk_wmem_queued);
-	WARN_ON(sk->sk_forward_alloc);
+	WARN((atomic_read(&sk->sk_rmem_alloc) | atomic_read(&sk->sk_wmem_allo=
c) |
+	     sk->sk_wmem_queued | sk->sk_forward_alloc) !=3D 0,
+	     "%s socket sk_rmem_alloc=3D%d sk_wmem_alloc=3D%d "
+	     "sk_wmem_queued=3D%d sk_forward_alloc=3D%d\n",
+	     sk->sk_prot->name,
+	     atomic_read(&sk->sk_rmem_alloc),
+	     atomic_read(&sk->sk_wmem_alloc),
+	     sk->sk_wmem_queued,
+	     sk->sk_forward_alloc);
=20
 	kfree(inet->opt);
 	dst_release(sk->sk_dst_cache);
