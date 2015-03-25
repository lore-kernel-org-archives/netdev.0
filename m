From: Ulf Samuelsson <ulf.samuelsson@ericsson.com>
Subject: RFC: Use of "jiffies" vs "jiffies64" in the neighbour system.
Date: Wed, 25 Mar 2015 11:11:45 +0100
Message-ID: <551289E1.8090609@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:46483 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbCYKLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 06:11:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If you run HZ = 1000, then jiffies will wrap around after 49,71 days.
This means that all time compares in the neighbour system will fail.

 From what I can see from "jiffies,h" there is no attempt to detect the 
wrap-around.

#define time_after(a,b)        \
     (typecheck(unsigned long, a) && \
      typecheck(unsigned long, b) && \
      ((long)(b) - (long)(a) < 0))
#define time_before(a,b)    time_after(b,a)

#define time_after_eq(a,b)    \
     (typecheck(unsigned long, a) && \
      typecheck(unsigned long, b) && \
      ((long)(a) - (long)(b) >= 0))
#define time_before_eq(a,b)    time_after_eq(b,a)

While the problem is not big for most users, I suspect it will
affect quality at the time of wrap-around.

It looks like garbage collection will stop in neigh_alloc,
since time has not passed time of last flush.

reachable time will no longer be recomputed in periodic_work

When you are in REACHABLE state, you will stay there,
since "now" will be before "confirmed" +"reachable_time",
so the entry will not be moved to DELAY or STALE,

If you are in delay state, you will move the entry
into REACHABLE even if you did not get a response.

and so on....

-- 
Best Regards,
Ulf Samuelsson
