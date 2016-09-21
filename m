From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: get rid of an signed integer overflow in
 ip_idents_reserve()
Date: Tue, 20 Sep 2016 18:06:17 -0700
Message-ID: <1474419977.23058.53.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35455 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754049AbcIUBGU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 21:06:20 -0400
Received: by mail-pa0-f65.google.com with SMTP id hi10so1541362pac.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 18:06:20 -0700 (PDT)
In-Reply-To: <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Jiri Pirko reported an UBSAN warning happening in ip_idents_reserve()

[] UBSAN: Undefined behaviour in ./arch/x86/include/asm/atomic.h:156:11
[] signed integer overflow:
[] -2117905507 + -695755206 cannot be represented in type 'int'

Since we do not have uatomic_add_return() yet, use atomic_cmpxchg()
so that the arithmetics can be done using unsigned int.

Fixes: 04ca6973f7c1 ("ip: make IP identifiers less predictable")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Jiri Pirko <jiri@resnulli.us>
---
David, Jiri, I removed the prandom_u32() stuff in favor of a traditional
loop to meet stable requirements. Thanks !

 net/ipv4/route.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index b52496fd51075821c39435f50ac62f813967aecc..654a9af201366887652a4e19a6f1261e5e747056 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -476,12 +476,18 @@ u32 ip_idents_reserve(u32 hash, int segs)
 	atomic_t *p_id = ip_idents + hash % IP_IDENTS_SZ;
 	u32 old = ACCESS_ONCE(*p_tstamp);
 	u32 now = (u32)jiffies;
-	u32 delta = 0;
+	u32 new, delta = 0;
 
 	if (old != now && cmpxchg(p_tstamp, old, now) == old)
 		delta = prandom_u32_max(now - old);
 
-	return atomic_add_return(segs + delta, p_id) - segs;
+	/* Do not use atomic_add_return() as it makes UBSAN unhappy */
+	do {
+		old = (u32)atomic_read(p_id);
+		new = old + delta + segs;
+	} while (atomic_cmpxchg(p_id, old, new) != old);
+
+	return new - segs;
 }
 EXPORT_SYMBOL(ip_idents_reserve);
 
