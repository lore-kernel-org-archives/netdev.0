From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: pktgen
Date: Thu, 30 Nov 2006 09:45:46 +0100
Message-ID: <17774.39482.949953.625608@robur.slu.se>
References: <20061121212251.GA5084@martell.zuzino.mipt.ru>
	<20061128.153325.10304536.davem@davemloft.net>
	<20061129200437.GA5152@martell.zuzino.mipt.ru>
	<20061129.174943.112291690.davem@davemloft.net>
	<b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, pavol.gono@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:13729 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1759165AbWK3Ipw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 03:45:52 -0500
To: "Alexey Dobriyan" <adobriyan@gmail.com>
In-Reply-To: <b6fcc0a0611292330n42fb1485h59804cc94a332f19@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hello!

Seems you found a race when rmmod is done before it's fully started

Try:

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 733d86d..ac0b4b1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -160,7 +160,7 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.69: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a)
@@ -3673,6 +3673,8 @@ static void __exit pg_cleanup(void)
 	struct list_head *q, *n;
 	wait_queue_head_t queue;
 	init_waitqueue_head(&queue);
+	
+	schedule_timeout_interruptible(msecs_to_jiffies(125));
 
 	/* Stop all interfaces & threads */
 


for i in 1 2 3 4 5 ; do modprobe pktgen ; rmmod pktgen ; done

In dmesg
pktgen v2.69: Packet Generator for packet performance testing.
pktgen v2.69: Packet Generator for packet performance testing.
pktgen v2.69: Packet Generator for packet performance testing.
pktgen v2.69: Packet Generator for packet performance testing.
pktgen v2.69: Packet Generator for packet performance testing.

Cheers.
					--ro



Alexey Dobriyan writes:
 > On 11/30/06, David Miller <davem@davemloft.net> wrote:
 > > From: Alexey Dobriyan <adobriyan@gmail.com>
 > > Date: Wed, 29 Nov 2006 23:04:37 +0300
 > >
 > > > Looks like worker thread strategically clears it if scheduled at wrong
 > > > moment.
 > > >
 > > > --- a/net/core/pktgen.c
 > > > +++ b/net/core/pktgen.c
 > > > @@ -3292,7 +3292,6 @@ static void pktgen_thread_worker(struct
 > > >
 > > >  	init_waitqueue_head(&t->queue);
 > > >
 > > > -	t->control &= ~(T_TERMINATE);
 > > >  	t->control &= ~(T_RUN);
 > > >  	t->control &= ~(T_STOP);
 > > >  	t->control &= ~(T_REMDEVALL);
 > >
 > > Good catch Alexey.  Did you rerun the load/unload test with
 > > this fix applied?  If it fixes things, I'll merge it.
 > 
 > Well, yes, it fixes things, except Ctrl+C getting you out of
 > modprobe/rmmod loop will spit
 > backtrace again. And other flags: T_RUN, T_STOP. Clearance is not
 > needed due to kZalloc and
 > create bugs as demostrated.
 > 
 > Give me some time.
 > -
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
