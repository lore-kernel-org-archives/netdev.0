From: Martin Devera <devik@cdi.cz>
Subject: PSCHED_GET_TIME related bug: jiffies wraparound
Date: Thu, 23 May 2002 11:08:41 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205231058220.788-100000@luxik.cdi.cz>
References: <200205161708.VAA22517@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200205161708.VAA22517@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

Hello Alexey,

I hope the 0xffffffff change will go into pre9. I've another
potential bug for you ;)
The clock watcher uses this code in psched_tick:
    unsigned long now = jiffies;
    psched_time_base = ((u64)now)<<PSCHED_JSCALE;
    psched_time_mark = now;
    psched_timer.expires = now + 60*60*HZ;
    add_timer(&psched_timer);

psched_time_base is then added to jiffies-psched_time_mark in
PSCHED_GET_TIME.
Because on 32bit archs jiffies wraps after 497 days the psched_time_base
and thus PSCHED_GET_TIME's result will wrap too. And PSCHED_TIME_DIFF
will again return huge negative number.

I'd suggest to replace the second line by this one:

-psched_time_base = ((u64)now)<<PSCHED_JSCALE;
+psched_time_base += ((u64)(now-psched_time_mark))<<PSCHED_JSCALE;

Because now-psched_time_mark is done in unsigned arithmetic it should
be imune against jiffies wraparound.
Do you think that the patch is ok ?

best regards,
devik
