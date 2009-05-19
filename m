From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: use a deferred timer in rt_check_expire
Date: Tue, 19 May 2009 20:56:35 +0200
Message-ID: <4A1300E3.1000809@cosmosbay.com>
References: <1F18D6510CF0474A8C9500565A7E41A20544D923FF@NOK-EUMSG-02.mgdnok.nokia.com> <4A127608.5020109@cosmosbay.com> <1F18D6510CF0474A8C9500565A7E41A20544D9255A@NOK-EUMSG-02.mgdnok.nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tero.Kristo@nokia.com" <Tero.Kristo@nokia.com>,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59969 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbZESS4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 14:56:37 -0400
In-Reply-To: <1F18D6510CF0474A8C9500565A7E41A20544D9255A@NOK-EUMSG-02.mgdnok.nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tero.Kristo@nokia.com a =E9crit :
> =20
>=20
>> -----Original Message-----
>> From: ext Eric Dumazet [mailto:dada1@cosmosbay.com]=20
>> Sent: 19 May, 2009 12:04
>> To: Kristo Tero (Nokia-D/Tampere)
>> Cc: netdev@vger.kernel.org
>> Subject: Re: Network stack timer hacks for power saving
>>
>> Tero.Kristo@nokia.com a =E9crit :
>>> Hi,
>>>
>>> I have been looking at network stack timer optimization for power=20
>>> saving in embedded ARM environment, basically trying to=20
>> avoid as many=20
>>> wakeups as possible. I have changed several timers in the network=20
>>> stack into deferred ones, i.e. they do not wake up the=20
>> device from low=20
>>> power modes but instead they are deferred until next wakeup=20
>>from some=20
>>> other source, like another (non-deferred) timer or some I/O.=20
>> Attached=20
>>> a patch about the changes I've done, is something like this safe to=
=20
>>> do?
>>>
>>> -Tero


Here is the patch I cooked and tested on a machine where ip_rt_gc_inter=
val=20
is set to minimal value (1 second), where equilibrium depends on garbag=
e collection
done in time.

I found that delayed timers could be *really* delayed so I think we mus=
t take
into account the elapsed time (in jiffies) between two rt_check_expire(=
)
calls, to "guarantee" a full scan of rt cache in a ip_rt_gc_timeout per=
iod.


Not for inclusion, as undergoing work is happening in this function
for a bug correction. I'll redo the patch later once stabilized.

[PATCH] net: use a deferred timer in rt_check_expire

=46or the sake of power saver lovers, use a deferrable timer to fire rt=
_check_expire()

As some big routers cache equilibrium depends on garbage collection don=
e in time,
we take into account elapsed time between two rt_check_expire() invocat=
ions=20
to adjust the amount of slots we have to check.

Based on an initial idea and patch from Tero Kristo

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Tero Kristo <tero.kristo@nokia.com>
---
 net/ipv4/route.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c4c60e9..b2c6793 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -131,8 +131,8 @@ static int ip_rt_min_advmss __read_mostly	=3D 256;
 static int ip_rt_secret_interval __read_mostly	=3D 10 * 60 * HZ;
 static int rt_chain_length_max __read_mostly	=3D 20;
=20
-static void rt_worker_func(struct work_struct *work);
-static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
+static struct delayed_work expires_work;
+static unsigned long expires_ljiffies;
=20
 /*
  *	Interface to generic destination cache.
@@ -787,9 +787,12 @@ static void rt_check_expire(void)
 	struct rtable *rth, **rthp;
 	unsigned long length =3D 0, samples =3D 0;
 	unsigned long sum =3D 0, sum2 =3D 0;
+	unsigned long delta;
 	u64 mult;
=20
-	mult =3D ((u64)ip_rt_gc_interval) << rt_hash_log;
+	delta =3D jiffies - expires_ljiffies;
+	expires_ljiffies =3D jiffies;
+	mult =3D ((u64)delta) << rt_hash_log;
 	if (ip_rt_gc_timeout > 1)
 		do_div(mult, ip_rt_gc_timeout);
 	goal =3D (unsigned int)mult;
@@ -3410,6 +3413,8 @@ int __init ip_rt_init(void)
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.
 	 */
+	INIT_DELAYED_WORK_DEFERRABLE(&expires_work, rt_worker_func);
+	expires_ljiffies =3D jiffies;
 	schedule_delayed_work(&expires_work,
 		net_random() % ip_rt_gc_interval + ip_rt_gc_interval);
=20

