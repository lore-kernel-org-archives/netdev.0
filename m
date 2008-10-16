From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Thu, 16 Oct 2008 11:19:38 +0200
Message-ID: <48F7072A.908@cosmosbay.com>
References: <20081006225210.GA29794@hmsreliant.think-freely.org>	<48EAEFF9.1000606@cosmosbay.com>	<20081013182655.GA9505@hmsreliant.think-freely.org> <20081015.235556.61915120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080908030502000008050209"
Cc: nhorman@tuxdriver.com, billfink@mindspring.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([193.252.22.31]:23609 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbYJPJUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:20:01 -0400
In-Reply-To: <20081015.235556.61915120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080908030502000008050209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 13 Oct 2008 14:26:55 -0400
>=20
>> If this meets everyones approval I think we can follow up with a
>> patch to remove the secret interval code entirely.
>=20
> This patch looks pretty good to me.
>=20
> Just some minor coding style nits:
>=20
>> +static void rt_secret_rebuild_oneshot(struct net *net) {
>=20
> Openning brace on new line please.
>=20
>> +static void rt_emergency_hash_rebuild(struct net *net) {
>=20
> Likewise.
>=20
>=20

While browsing Neil patch, I found one missing rcu_assign_pointer()
in current code. I added a comment similar to other rcu_assign_pointer()
in rt_intern_hash() function.

[PATCH] ip: adds a missing rcu_assign_pointer()

rt_intern_hash() is doing an update of a RCU guarded hash chain
without using rcu_assign_pointer() or equivalent barrier.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------080908030502000008050209
Content-Type: text/plain;
 name="ipv4_route.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ipv4_route.patch"

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a6d7c58..377c6f9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1109,7 +1109,12 @@ restart:
 		printk("\n");
 	}
 #endif
-	rt_hash_table[hash].chain = rt;
+	/*
+	 * Since lookup is lockfree, we must make sure
+	 * previous writes to rt are comitted to memory
+	 * before making rt visible to other CPUS.
+	 */	
+	rcu_assign_pointer(rt_hash_table[hash].chain, rt);
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 	*rp = rt;
 	return 0;

--------------080908030502000008050209--


