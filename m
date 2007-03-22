From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 23:03:04 +0100
Message-ID: <4602FD18.7060902@cosmosbay.com>
References: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON>	<20070322182156.GB17793@2ka.mipt.ru>	<1199CE22A40740D28833A585014BE559@XEON> <20070322.135834.74723088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, nikb@webmaster.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.cosmosbay.com ([86.65.150.131]:35677 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934246AbXCVWDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 18:03:10 -0400
In-Reply-To: <20070322.135834.74723088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller a =E9crit :
> From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
> Date: Thu, 22 Mar 2007 12:44:09 -0700
>=20
>>     People _have_ had problems. _I_ have had problems. And when
>> someone with a few thousand drones under his control hoses your
>> servers because he can do math and he leaves you with 20000-item
>> long chains, _you_ will have problems.
>=20
> No need to further argue this point, the people that matter
> (ie. me :-) understand it, don't worry..

Yes, I recall having one big server hit two years ago by an attack on t=
cp hash=20
function. David sent me the patch to use jhash. It's performing well :)

Welcome to the club :)

=3D=3D=3D=3D=3D net/ipv4/tcp_ipv4.c 1.114 vs edited =3D=3D=3D=3D=3D
--- 1.114/net/ipv4/tcp_ipv4.c    2005-03-26 15:04:35 -08:00
+++ edited/net/ipv4/tcp_ipv4.c    2005-04-05 13:39:52 -07:00
@@ -103,14 +103,15 @@
   */
  int sysctl_local_port_range[2] =3D { 1024, 4999 };
  int tcp_port_rover =3D 1024 - 1;
+static u32 tcp_v4_hash_rand;

  static __inline__ int tcp_hashfn(__u32 laddr, __u16 lport,
                   __u32 faddr, __u16 fport)
  {
-    int h =3D (laddr ^ lport) ^ (faddr ^ fport);
-    h ^=3D h >> 16;
-    h ^=3D h >> 8;
-    return h & (tcp_ehash_size - 1);
+    return jhash_2words(laddr ^ faddr,
+                (lport << 16) | fport,
+                tcp_v4_hash_rand) &
+        (tcp_ehash_size - 1);
  }

 >  static __inline__ int tcp_sk_hashfn(struct sock *sk)
 > @@ -2626,6 +2627,9 @@
 >          panic("Failed to create the TCP control socket.\n");
 >      tcp_socket->sk->sk_allocation   =3D GFP_ATOMIC;
 >      inet_sk(tcp_socket->sk)->uc_ttl =3D -1;
 > +
 > +    get_random_bytes(&tcp_v4_hash_rand, 4);
 > +    tcp_v4_hash_rand ^=3D jiffies;
 >
 >      /* Unhash it so that IP input processing does not even
 >       * see it, we do not wish this socket to see incoming
 >
 >


