From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 01:43:31 +0200
Message-ID: <48B5E6A3.6@cosmosbay.com>
References: <20080827223410.GC26610@one.firstfloor.org>	<20080827.153907.157997966.davem@davemloft.net>	<48B5DE9F.4010000@cosmosbay.com> <20080827.161504.183610665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010802030508030605060406"
Cc: andi@firstfloor.org, davej@redhat.com, netdev@vger.kernel.org,
	j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.49]:8684 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753929AbYH0Xnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 19:43:39 -0400
In-Reply-To: <20080827.161504.183610665.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010802030508030605060406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 28 Aug 2008 01:09:19 +0200
>=20
>> Not really, I suspect commit (a7ab4b501f9b8a9dc4d5cee542db67b6ccd1088b=
 [TCPv4]: Improve BH latency in /proc/net/tcp) is responsible for longer =
delays.
>> Note that its rather old :
>  ...
>> We used to disable bh once, while reading the table. This sucked.
>>
>> In case machine is handling trafic, we now are preemptable by softirqs=

>> while reading /proc/net/tcp. Thats a good thing.
>=20
> Yes, that would account for it, good spotting.
>=20
>> By the way, I find Andi patch usefull. Same thing could be done for /p=
roc/net/rt_cache.
>=20
> Fair enough.  If you can cook up a quick rt_cache patch I'll toss it an=
d
> Andi's patch into net-next so it can cook for a while.

Well, first patch I would like to submit is about letting netlink being a=
ble to be=20
faster than /proc/net/tcp again :)

Thank you

[PATCH] tcp: speedup tcp hash table lookups for NETLINK

Avoid taking locks for empty buckets.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------010802030508030605060406
Content-Type: text/plain;
 name="inet_diag.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="inet_diag.patch"

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index c10036e..0fa690c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -778,10 +778,13 @@ skip_listen_ht:
 
 	for (i = s_i; i < hashinfo->ehash_size; i++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[i];
-		rwlock_t *lock = inet_ehash_lockp(hashinfo, i);
+		rwlock_t *lock;
 		struct sock *sk;
 		struct hlist_node *node;
 
+		if (hlist_empty(&head->chain) && hlist_empty(&head->twchain))
+			continue;
+		lock = inet_ehash_lockp(hashinfo, i);
 		if (i > s_i)
 			s_num = 0;
 

--------------010802030508030605060406--


