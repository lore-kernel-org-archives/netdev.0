From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 3.1-rc9
Date: Wed, 02 Nov 2011 18:27:34 +0100
Message-ID: <1320254854.2292.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318874090.4172.84.camel@twins>
	 <CA+55aFwCBy=4YK6amE=H-BYu9-boj4Po2Zkgf4V261mCx0DC4A@mail.gmail.com>
	 <1318879396.4172.92.camel@twins> <alpine.LFD.2.02.1110172237030.3240@ionos>
	 <alpine.LFD.2.02.1110181037120.3240@ionos> <1318928713.21167.4.camel@twins>
	 <20111018182046.GF1309@hostway.ca>
	 <alpine.LFD.2.02.1110182146440.3240@ionos>
	 <20111024190203.GA24410@hostway.ca> <20111025202049.GB25043@hostway.ca>
	 <20111031173246.GA10614@hostway.ca>
	 <alpine.LFD.2.02.1111021725550.2829@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@hostway.ca>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Network Development <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35291 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810Ab1KBR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 13:27:40 -0400
In-Reply-To: <alpine.LFD.2.02.1111021725550.2829@ionos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 17:40 +0100, Thomas Gleixner a =C3=A9=
crit :
> On Mon, 31 Oct 2011, Simon Kirby wrote:
> > On Tue, Oct 25, 2011 at 01:20:49PM -0700, Simon Kirby wrote:
> >=20
> > > On Mon, Oct 24, 2011 at 12:02:03PM -0700, Simon Kirby wrote:
> > >=20
> > > > Ok, hit the hang about 4 more times, but only this morning on a=
 box with
> > > > a serial cable attached. Yay!
> > >=20
> > > Here's lockdep output from another box. This one looks a bit diff=
erent.
> >=20
> > One more, again a bit different. The last few lockups have looked l=
ike
> > this. Not sure why, but we're hitting this at a few a day now. Thom=
as,
> > this is without your patch, but as you said, that's right before a =
free
> > and should print a separate lockdep warning.
> >=20
> > No "huh" lines until after the trace on this one. I'll move to 3.1 =
with
>=20
> That means that the lockdep warning hit in the same net_rx cycle
> before the leak was detected by the softirq code.
>=20
> > cherry-picked b0691c8e now.
>=20
> Can you please add the debug patch below and try the following:
>=20
> Enable CONFIG_FUNCTION_TRACER & CONFIG_FUNCTION_GRAPH_TRACER
>=20
> # cd $DEBUGFSMOUNTPOINT/tracing
> # echo sk_clone >set_ftrace_filter
> # echo function >current_tracer
> # echo 1 >options/func_stack_trace
>=20
> Now wait until it reproduces (which stops the trace) and read out
>=20
> # cat trace >/tmp/trace.txt
>=20
> Please provide the trace file along with the lockdep splat. That
> should tell us which callchain is responsible for the spinlock
> leakage.
>=20
> Thanks,
>=20
> 	tglx
>=20
> --------------->
>  kernel/softirq.c |    1 +
>  1 file changed, 1 insertion(+)
>=20
> Index: linux-2.6/kernel/softirq.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/kernel/softirq.c
> +++ linux-2.6/kernel/softirq.c
> @@ -238,6 +238,7 @@ restart:
>  			h->action(h);
>  			trace_softirq_exit(vec_nr);
>  			if (unlikely(prev_count !=3D preempt_count())) {
> +				tracing_off();
>  				printk(KERN_ERR "huh, entered softirq %u %s %p"
>  				       "with preempt_count %08x,"
>  				       " exited with %08x?\n", vec_nr,


I believe it might come from commit 0e734419
(ipv4: Use inet_csk_route_child_sock() in DCCP and TCP.)

In case inet_csk_route_child_sock() returns NULL, we dont release socke=
t
lock.
