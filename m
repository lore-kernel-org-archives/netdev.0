From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 17:46:33 +0100
Message-ID: <200709101746.34513.vda.linux@googlemail.com>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709101516.03234.vda.linux@googlemail.com> <alpine.LFD.0.999.0709100807260.16478@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kyle Moffett <mrmacman_g4@mac.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.230]:6731 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099AbXIJQqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 12:46:47 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1200184qbe
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 09:46:46 -0700 (PDT)
In-Reply-To: <alpine.LFD.0.999.0709100807260.16478@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 10 September 2007 16:09, Linus Torvalds wrote:
> On Mon, 10 Sep 2007, Denys Vlasenko wrote:
> > static inline int
> > qla2x00_wait_for_loop_ready(scsi_qla_host_t *ha)
> > {
> >         int      return_status =3D QLA_SUCCESS;
> >         unsigned long loop_timeout ;
> >         scsi_qla_host_t *pha =3D to_qla_parent(ha);
> >=20
> >         /* wait for 5 min at the max for loop to be ready */
> >         loop_timeout =3D jiffies + (MAX_LOOP_TIMEOUT * HZ);
> >=20
> >         while ((!atomic_read(&pha->loop_down_timer) &&
> >             atomic_read(&pha->loop_state) =3D=3D LOOP_DOWN) ||
> >             atomic_read(&pha->loop_state) !=3D LOOP_READY) {
> >                 if (atomic_read(&pha->loop_state) =3D=3D LOOP_DEAD)=
 {
> ...
> > Is above correct or buggy? Correct, because msleep is a barrier.
> > Is it obvious? No.
>=20
> It's *buggy*. But it has nothing to do with any msleep() in the loop,=
 or=20
> anything else.
>=20
> And more importantly, it would be equally buggy even *with* a "volati=
le"=20
> atomic_read().

I am not saying that this code is okay, this isn't the point.
(The code is in fact awful for several more reasons).

My point is that people are confused as to what atomic_read()
exactly means, and this is bad. Same for cpu_relax().
=46irst one says "read", and second one doesn't say "barrier".

This is real code from current kernel which demonstrates this:

"I don't know that cpu_relax() is a barrier already":

drivers/kvm/kvm_main.c
=A0 =A0 =A0 =A0 while (atomic_read(&completed) !=3D needed) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 barrier();
=A0 =A0 =A0 =A0 }

"I think that atomic_read() is a read from memory and therefore
I don't need a barrier":

arch/x86_64/kernel/crash.c
=A0 =A0 =A0 =A0 msecs =3D 1000; /* Wait at most a second for the other =
cpus to stop */
=A0 =A0 =A0 =A0 while ((atomic_read(&waiting_for_crash_ipi) > 0) && mse=
cs) {
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdelay(1);
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msecs--;
=A0 =A0 =A0 =A0 }

Since neither camp seems to give up, I am proposing renaming
them to something less confusing, and make everybody happy.

cpu_relax_barrier()
atomic_value(&x)
atomic_fetch(&x)

I'm not native English speaker, do these sound better?
--
vda
