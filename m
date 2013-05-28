From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 2/3] ipv4: rate limit updating of next hop
 exceptions with same pmtu
Date: Tue, 28 May 2013 11:45:51 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305281127340.1693@ja.ssi.bg>
References: <20130527.233844.2081972819091665848.davem@davemloft.net> <1369723593-5307-1-git-send-email-timo.teras@iki.fi> <1369723593-5307-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="280144257-670708262-1369730752=:1693"
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:52183 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933529Ab3E1ImM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 May 2013 04:42:12 -0400
In-Reply-To: <1369723593-5307-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--280144257-670708262-1369730752=:1693
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Tue, 28 May 2013, Timo Teräs wrote:

> The tunnel devices call update_pmtu for each packet sent, this causes
> contention on the fnhe_lock. Ignore the pmtu update if pmtu is not
> actually changed, and there is still plenty of time before the entry
> expires.
> 
> Signed-off-by: Timo Teräs <timo.teras@iki.fi>
> ---
>  net/ipv4/route.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 561a378..a4082be 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -947,6 +947,10 @@ static void __ip_rt_update_pmtu(struct rtable *rt, struct flowi4 *fl4, u32 mtu)
>  	if (mtu < ip_rt_min_pmtu)
>  		mtu = ip_rt_min_pmtu;
>  
> +	if (rt->rt_pmtu == mtu &&
> +	    time_before(jiffies, dst->expires - ip_rt_mtu_expires / 2))
> +		return;
> +

	Can we also add logic in this patch in
update_or_create_fnhe, so that we avoid invalidation for cached
routes when only pmtu expiration is updated (same pmtu), i.e.:

+	if (gw || pmtu != fnhe->fnhe_pmtu) {
+		/* Exception created; mark the cached routes for the nexthop
+		...
+	}

	BTW, I now see that previous patch should
call for_each_possible_cpu for the both cases, not
only when fnhe is created but also on update:

	bool invalidate;

	if (fnhe) {
		invalidate = gw || pmtu != fnhe->fnhe_pmtu;
		...
	} else {
		...
		invalidate = true;
	}

	if (invalidate) {
		/* Exception created; mark the cached routes for the nexthop
		...
	}

Regards

--
Julian Anastasov <ja@ssi.bg>
--280144257-670708262-1369730752=:1693--
