From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 19:46:49 +0200
Message-ID: <20160920174649.GN1843@nanopsycho.orion>
References: <20160920120000.GI1843@nanopsycho.orion>
 <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160920133915.GJ1843@nanopsycho.orion>
 <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36381 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754246AbcITRqw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 13:46:52 -0400
Received: by mail-wm0-f67.google.com with SMTP id b184so4606699wma.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 10:46:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 20, 2016 at 04:18:12PM CEST, eric.dumazet@gmail.com wrote:
>On Tue, 2016-09-20 at 07:11 -0700, Eric Dumazet wrote:
>> On Tue, 2016-09-20 at 15:39 +0200, Jiri Pirko wrote:
>> 
>> > I see. So how to silent the warning?
>> > 
>> 
>> We can replace the atomic_add_return() and use a loop around
>> atomic_read() and atomic_cmpxhg()
>> 
>> This would change the nice property of x86 xadd into a loop.
>> 
>> Or we also could fallback to random generation if the atomic_cmpxchg()
>> fails.
>> 
>> I'll provide a patch, thanks.
>> 
>
>Could you try the following ?
>
>diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>index
>b52496fd51075821c39435f50ac62f813967aecc..91dc108ef6dc75df80f0e73b6fa062d98dc9a58a 100644
>--- a/net/ipv4/route.c
>+++ b/net/ipv4/route.c
>@@ -476,12 +476,19 @@ u32 ip_idents_reserve(u32 hash, int segs)
> 	atomic_t *p_id = ip_idents + hash % IP_IDENTS_SZ;
> 	u32 old = ACCESS_ONCE(*p_tstamp);
> 	u32 now = (u32)jiffies;
>-	u32 delta = 0;
>+	u32 new, delta = 0;
> 
> 	if (old != now && cmpxchg(p_tstamp, old, now) == old)
> 		delta = prandom_u32_max(now - old);
> 
>-	return atomic_add_return(segs + delta, p_id) - segs;
>+	old = (u32)atomic_read(p_id);
>+	new = old + delta + segs;
>+	/* Do not try too hard, if multiple cpus are there,
>+	 * just fallback to pseudo random number.
>+	 */
>+	if (unlikely(atomic_cmpxchg(p_id, old, new) != old))
>+		new = prandom_u32();
>+	return new;
> }
> EXPORT_SYMBOL(ip_idents_reserve);
> 

This patch makes ubsan silent.


>
>
