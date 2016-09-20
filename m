From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 07:18:12 -0700
Message-ID: <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920133915.GJ1843@nanopsycho.orion>
         <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36205 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752703AbcITOSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:18:15 -0400
Received: by mail-pa0-f67.google.com with SMTP id my20so988895pab.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:18:15 -0700 (PDT)
In-Reply-To: <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 07:11 -0700, Eric Dumazet wrote:
> On Tue, 2016-09-20 at 15:39 +0200, Jiri Pirko wrote:
> 
> > I see. So how to silent the warning?
> > 
> 
> We can replace the atomic_add_return() and use a loop around
> atomic_read() and atomic_cmpxhg()
> 
> This would change the nice property of x86 xadd into a loop.
> 
> Or we also could fallback to random generation if the atomic_cmpxchg()
> fails.
> 
> I'll provide a patch, thanks.
> 

Could you try the following ?

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index
b52496fd51075821c39435f50ac62f813967aecc..91dc108ef6dc75df80f0e73b6fa062d98dc9a58a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -476,12 +476,19 @@ u32 ip_idents_reserve(u32 hash, int segs)
 	atomic_t *p_id = ip_idents + hash % IP_IDENTS_SZ;
 	u32 old = ACCESS_ONCE(*p_tstamp);
 	u32 now = (u32)jiffies;
-	u32 delta = 0;
+	u32 new, delta = 0;
 
 	if (old != now && cmpxchg(p_tstamp, old, now) == old)
 		delta = prandom_u32_max(now - old);
 
-	return atomic_add_return(segs + delta, p_id) - segs;
+	old = (u32)atomic_read(p_id);
+	new = old + delta + segs;
+	/* Do not try too hard, if multiple cpus are there,
+	 * just fallback to pseudo random number.
+	 */
+	if (unlikely(atomic_cmpxchg(p_id, old, new) != old))
+		new = prandom_u32();
+	return new;
 }
 EXPORT_SYMBOL(ip_idents_reserve);
 
