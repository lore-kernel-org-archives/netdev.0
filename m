From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: use of preempt_count instead of in_atomic() at leds-gpio.c
Date: Fri, 21 Mar 2008 14:16:24 +0100
Message-ID: <47E3B528.6010200@s5r6.in-berlin.de>
References: <20080316184349.GA28543@khazad-dum.debian.net> <200803161246.23909.david-b@pacbell.net> <20080318001429.896acf51.akpm@linux-foundation.org> <20080320225612.GB20788@khazad-dum.debian.net> <20080320164741.734e838c.akpm@linux-foundation.org> <20080321003604.GC20788@khazad-dum.debian.net> <20080320180802.426ad2d1.akpm@linux-foundation.org> <47E37E04.3080303@s5r6.in-berlin.de> <20080321123708.GE5586@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	Richard Purdie <rpurdie@rpsys.net>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	video4linux-list@redhat.com, lm-sensors@lm-sensors.org
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:57036 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbYCUNSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 09:18:41 -0400
In-Reply-To: <20080321123708.GE5586@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Henrique de Moraes Holschuh wrote:
> On Fri, 21 Mar 2008, Stefan Richter wrote:
>> and eth1394 to deal with temporary lack of of tlabels.  Alas I just  
>> recently received a report that eth1394's workaround is unsuccessful on  
>> non-preemptible uniprocessor kernels.  
> 
> Which, I think, is exactly the config where in_atomic() can't be used to
> mean "in_scheduleable_context()" ?

That's coincidence.

The mentioned workaround fails this way:
   - tlabel consumer eth1394 (IPv4 over FireWire) grabs lots of tlabels
     in soft IRQ context.
   - tlabel recycler khpsbpkt (a kthread of ieee1394) sleeps even though
     it could start putting tlabels back into the pool.
   - eth1394 can't get tlabels anymore, stops the transmit queue,
     schedules a workqueue job.
   - eth1394's workqueue job (run by the events kthread) tries to acquire
     a tlabel.  It does so in non-atomic context and hence sleeps in
     hpsb_get_tlabel() until the tlabel pool is nonempty again.  It would
     then wake up the eth1394 transmit queue again.
   - Normally, khpsbpkt would have been woken up by now and would have
     released a lot of now unused tlabels back into the pool again.
     However, on UP preempt_none kernels, khpsbpkt continues to sleep.
     (The 1394 stack's lower level runing in IRQ context or perhaps
     tasklet context wakes up khpsbpkt.)
   - Since it doesn't get a tlabel, eth1394's workqueue jobs sleeps
     forever as well.

Result is that all other tasks of the shared workqueue can't be 
serviced, notably the keyboard is stuck, and that the eth1394 connection 
breaks down.  (I haven't started working on a fix, or opened a bugzilla 
ticket for it yet.  The reporter currently switched his kernel to 
PREEMPT which is not affected.)

IOW:
The failure in the workaround is *not* about the in_atomic() being the 
wrong question asked in hpsb_get_tlabel() --- no, ieee1394's in_atomic() 
abuse works just fine even on UP PREEMPT_NONE.  Instead, the failure is 
about kthreads not being scheduled in the way that I thought they would.
-- 
Stefan Richter
-=====-==--- --== =-=-=
http://arcgraph.de/sr/
