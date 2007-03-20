From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 17:43:24 -0500
Message-ID: <20070320224324.GL10459@waste.org>
References: <1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
	<46000C7E.4070001@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
   "Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
   mingo@elte.hu, Linus Torvalds <torvalds@linux-foundation.org>,
   David Miller <davem@davemloft.net>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <46000C7E.4070001@goop.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2007 at 09:31:58AM -0700, Jeremy Fitzhardinge wrote:
> Linus Torvalds wrote:
> > On Tue, 20 Mar 2007, Eric W. Biederman wrote:
> >   =

> >> If that is the case.  In the normal kernel what would
> >> the "the oops, we got an interrupt code do?"
> >> I assume it would leave interrupts disabled when it returns?
> >> Like we currently do with the delayed disable of normal interrupts?
> >>     =

> >
> > Yeah, disable interrupts, and set a flag that the fake "sti" can test, =
and =

> > just return without doing anything.
> >
> > (You may or may not also need to do extra work to Ack the hardware =

> > interrupt etc, which may be irq-controller specific. Once the CPU has =

> > accepted the interrupt, you may not be able to just leave it dangling)
> >   =

> =

> So it would be something like:
> =

>     pda.intr_mask =3D 1;		/* disable interrupts */
>     ...
>     pda.intr_mask =3D 0;		/* enable interrupts */
>     if (xchg(&pda.intr_pending, 0))	/* check pending */
>     	asm("sti");		/* was pending; isr left cpu interrupts masked */

I don't know that you need an xchg there. If you're still on the same
CPU, it should all be nice and causal even across an interrupt handler.
So it could be:

   pda.intr_mask =3D 0; /* intr_pending can't get set after this */
   if (unlikely(pda.intr_pending)) {
      pda.intr_pending =3D 0;
      asm("sti");
   }

(This would actually need a C barrier, but I'll ignore that as this'd
end up being asm...)

But other interesting things could happen. If we never did a real CLI
and we get preempted and switched to another CPU between clearing
intr_mask and checking intr_pending, we get a little confused. =


But perhaps that doesn't matter because we'd by definition have no
pending interrupts on either processor?

Is it expensive to do an STI if interrupts are already enabled?

-- =

Mathematics is the supreme nostalgia of our time.
