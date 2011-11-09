From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH]  flow_cache_flush soft lockup with heavy ipsec traffic
Date: Wed, 09 Nov 2011 14:16:04 +0100
Message-ID: <1320844564.3916.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EBA7038.4050702@mt.lv>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Maris Paupe <marisp@mt.lv>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:60484 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab1KINQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 08:16:09 -0500
Received: by bke11 with SMTP id 11so1321212bke.19
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 05:16:08 -0800 (PST)
In-Reply-To: <4EBA7038.4050702@mt.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 novembre 2011 =C3=A0 14:21 +0200, Maris Paupe a =C3=A9cr=
it :
> During ipsec packet processing flow_cache_flush() may get called whic=
h=20
> creates flow_cache_gc_taklet(), this function is guarded by mutex and=
=20
> waits until all tasklets are finished before releasing it, another=20
> softirq may happen during flow_cache_gc_taklet(), in case when this i=
rq=20
> is packet reading from a device, it can happen that flow_cache_flush(=
)=20
> gets called again and a deadlock occurs.
> Here i purpose a simple fix to this problem by disabling softirqs dur=
ing=20
> tasklet process. It could also be fixed in ipsec processing code, but=
 I=20
> am too unfamiliar with it to touch it.
>=20
> Signed-off-by: Maris Paupe <marisp@mt.lv>
>=20
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 8ae42de..19ff283 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -105,6 +105,7 @@ static void flow_cache_gc_task(struct work_struct=
 *work)
>   	struct list_head gc_list;
>   	struct flow_cache_entry *fce, *n;
>=20
> +	local_bh_disable();
>   	INIT_LIST_HEAD(&gc_list);
>   	spin_lock_bh(&flow_cache_gc_lock);
>   	list_splice_tail_init(&flow_cache_gc_list, &gc_list);
> @@ -112,6 +113,7 @@ static void flow_cache_gc_task(struct work_struct=
 *work)
>=20
>   	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
>   		flow_entry_kill(fce);
> +	local_bh_enable();
>   }

Sorry, I dont understand your patch.

BH are disabled by the spin_lock_bh() call.

Once flow_cache_entry are in garbage list, nothing but garbage collecto=
r
can access them. I see no possible deadlock. Or there is a bug somewher=
e
and your patch avoid it.

Whole point of using a work queue to perform garbage collect was to not
hold BH too long (allowing sotirq to process incoming packets), so you
basically remove what was done in commit 8e4795605d.

Could you explain the problem you have ? Any stack trace or something ?
