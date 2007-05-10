From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 19:56:02 +0530
Message-ID: <OFF6C86B0A.6A40B31A-ON652572D7.004EC8D4-652572D7.004F49D0@in.ibm.com>
References: <1178806376.4074.90.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Roberto Nibali <ratz@drugphish.ch>,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:37131 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580AbXEJO1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 10:27:16 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4AESuWa6582286
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:28:57 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AEUbpA113426
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:30:38 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AER5rR023934
	for <netdev@vger.kernel.org>; Fri, 11 May 2007 00:27:05 +1000
In-Reply-To: <1178806376.4074.90.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I would guess that even with this change, qdisc_restart can get called with
no
skbs in the queue due to softirq which was enabled (but by the time it ran,
more skbs enqueue could have dequeue'd those packets). But it would
definitely reduce by once each iteration of qdisc_run (if one packet then
50% reduction, if 9 packets then 10% reduction, and so on).

Herbert,

-            while (qdisc_restart(dev) < 0 && !netif_queue_stopped(dev))
-                        /* NOTHING */;
+            do {
+                        if (!qdisc_restart(dev))
+                                    break;
+            } while (!netif_queue_stopped(dev));

This could be changed to old format, if required :

+            while (qdisc_restart(dev)) && !netif_queue_stopped(dev))
+                 /* NOTHING */;

thanks,

- KK

J Hadi Salim <j.hadi123@gmail.com> wrote on 05/10/2007 07:42:55 PM:

> On Thu, 2007-10-05 at 23:52 +1000, Herbert Xu wrote:
> > On Thu, May 10, 2007 at 09:18:04AM -0400, jamal wrote:
> > >
> > > I wonder how much performance improvement this give now that the
extra
> > > incursion into qdisc_restart is avoided.
> >
> > Probably very little since the only way it can make a difference is if
> > there is lots of contention.  But if there is lots of contention we
> > should stay in the function anyway.
>
> Less to do with CPU contention and more with Krishna's change which
> avoids entering that region all together which is useful even in the
> absence of contention. In the past (based on some measurement i did)
> upto 50% of the executions of qdisc restart were on an empty queue
> depending on traffic rates.
>
> BTW, given that i couldnt recall the layout of the locks on qdisc
> restart; I think i will come back with the old patch i had to clean up
> the readability of qdisc restart so it is easy to tell just by quick
> inspection.
>
> Since Canada seems to be comfortably taking revenge on the Swiss (my
> condolonces to Thomas and Ratz) - i think it is time for me to head
> out ;-> ttl.
>
> cheers,
> jamal
>

