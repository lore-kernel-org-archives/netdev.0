From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Thu, 31 Oct 2013 08:10:41 -0700
Message-ID: <1383232241.4857.73.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131030172341.19203.93490.stgit@dragon>
	 <1383156104.4857.49.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131031151551.675ab908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54653 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755052Ab3JaPKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 11:10:43 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so2644687pab.34
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 08:10:43 -0700 (PDT)
In-Reply-To: <20131031151551.675ab908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-31 at 15:15 +0100, Jesper Dangaard Brouer wrote:

> Okay, I'll cook up another patch, after work.
> 
> Adding all the typecheck() stuff, just bloats the code.
> 
> Would it be better/okay just to do?:
>  (s32)((u32)(a) - (u32)(b)) > 0)
> 
> 

What about using the existing codel types ?

diff --git a/include/net/codel.h b/include/net/codel.h
index 389cf62..89a7781 100644
--- a/include/net/codel.h
+++ b/include/net/codel.h
@@ -72,7 +72,12 @@ static inline codel_time_t codel_get_time(void)
 	return ns >> CODEL_SHIFT;
 }
 
-#define codel_time_after(a, b)		((s32)(a) - (s32)(b) > 0)
+static inline bool codel_time_after(codel_time_t a, codel_time_t b)
+{
+	codel_tdiff_t delta = a - b;
+
+	return delta >= 0;
+}
 #define codel_time_after_eq(a, b)	((s32)(a) - (s32)(b) >= 0)
 #define codel_time_before(a, b)		((s32)(a) - (s32)(b) < 0)
 #define codel_time_before_eq(a, b)	((s32)(a) - (s32)(b) <= 0)


You need of course something similar for all variants.
