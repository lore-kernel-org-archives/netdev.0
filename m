From: Martin Devera <devik@cdi.cz>
Subject: PSCHED_TDIFF_SAFE bug introduced in 2.4.19-pre5
Date: Sun, 5 May 2002 17:41:19 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205051726480.12674-100000@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

Hello Alexey,

from this:
-          long __delta = (tv1) - (tv2); \
-          if ( __delta > (bound)) {  __delta = (bound); guard; } \
+          long long __delta = (tv1) - (tv2); \
+          if ( __delta > (long long)(bound)) {  __delta = (bound); guard;
} \

<kuznet@ms2.inr.ac.ru> (02/03/19 1.181.2.12)
        Make pkt_sched.h:PSCHED_TDIFF_SAFE behave sane when measuring

I think you are responsible for the change. I hope it wasn't me who
suggested this change ;) Old code was ok in
sense that in CBQ you used unsigned bound. Then the diff was safe
even if tv1<tv2 which can be true when time wraps (which is true
at least with PSCHED_TIME_SOURCE == JIFFIES) because comparison
is unsigned and result will never be negative.
Now the unsigned bound is converted into signed long long and _delta
can be negative AND unbounded ... I just started to seen it when
one HTB user switched to 2.4.19-pre7.

I'd suggest this change:
-          long long __delta = (tv1) - (tv2); \
-          if ( __delta > (long long)(bound)) {  __delta = (bound); guard;
+          long __delta = (tv1) - (tv2); \
+          if ( __delta > (u32)(bound)) {  __delta = (bound); guard; } \

Here the return value will be always positive and < bound.

any objections ?
devik
