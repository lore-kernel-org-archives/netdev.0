From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: inter-packet gap in pktgen
Date: Wed, 8 Dec 2004 12:15:49 +0100
Message-ID: <20041208111549.GA5703@xi.wantstofly.org>
References: <20041207222522.GA30266@xi.wantstofly.org> <41B632F3.1090104@candelatech.com> <20041208073858.GA4027@xi.wantstofly.org> <16822.54722.755218.745451@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16822.54722.755218.745451@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2004 at 11:21:54AM +0100, Robert Olsson wrote:

>  > Another option is:
>  > 
>  > 	next_tx = get_time_in_ns();
>  > 	while (--count) {
>  > 		tx_packet();
>  > 		next_tx += 1e9/intended_pps;
>  > 		nanospin(next_tx - get_time_in_ns());
>  > 	}
> 
>  Hello!
> 
>  I think this what Ben is doing with his userland app. Ev. adjusting
>  the ipg delay in runtime? A kind of control system.

I think what Ben is doing is just measuring the # of pps and then
using a PI-controller or something like that to adjust the ipg.

What I mean is something like this (warning: whitespace damaged.)  But
this gives me an IPG that is consistently too small.  Are the nanospin()
and pg_udelay() functions accurate?


--L


--- pktgen.c.04111.orig 2004-12-08 11:57:03.627392497 +0100
+++ pktgen.c    2004-12-08 12:11:35.777150214 +0100
@@ -2794,7 +2794,13 @@
                                pkt_dev->last_ok = 0;
                                pkt_dev->next_tx_ns = getRelativeCurNs(); /* TODO */
                }
-               pkt_dev->next_tx_ns = getRelativeCurNs() + pkt_dev->ipg;
+               if (now == 0)
+                       now = getRelativeCurNs();
+               pkt_dev->next_tx_ns += pkt_dev->ipg;
+               if (pkt_dev->next_tx_ns < now) {
+                       pkt_dev->next_tx_ns = now;
+                       pkt_dev->errors++;         /* missed ipg deadline */
+               }
        }

        else {  /* Retry it next time */
