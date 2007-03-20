From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 18:41:50 -0500
Message-ID: <20070320234150.GL4892@waste.org>
References: <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
	<46000C7E.4070001@goop.org> <20070320224324.GL10459@waste.org>
	<46006963.1020401@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
   "Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
   mingo@elte.hu, Linus Torvalds <torvalds@linux-foundation.org>,
   David Miller <davem@davemloft.net>
To: Zachary Amsden <zach@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <46006963.1020401@vmware.com>
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

On Tue, Mar 20, 2007 at 03:08:19PM -0800, Zachary Amsden wrote:
> Matt Mackall wrote:
> >I don't know that you need an xchg there. If you're still on the same
> >CPU, it should all be nice and causal even across an interrupt handler.
> >So it could be:
> >
> >   pda.intr_mask =3D 0; /* intr_pending can't get set after this */
> >  =

> =

> Why not?  Oh, I see.  intr_mask is inverted form of EFLAGS_IF.

It's not even that. There are two things that can happen:

case 1:

  intr_mask =3D 1;
            <interrupt occurs and is deferred>
  intr_mask =3D 0;
  /* intr_pending is already set and CLI is in effect */
  if(intr_pending)

case 2:

  intr_mask =3D 1;
  intr_mask =3D 0;
            <interrupt occurs and is processed>
  /* intr_pending remains cleared */
  if(intr_pending)

As this is all about local interrupts, it's all on a single CPU and
out of order issues aren't visible..
 =

> >(This would actually need a C barrier, but I'll ignore that as this'd
> >end up being asm...)

..unless the compiler is doing the reordering, of course.

> >But other interesting things could happen. If we never did a real CLI
> >and we get preempted and switched to another CPU between clearing
> >intr_mask and checking intr_pending, we get a little confused. =

> =

> I think Jeremy's idea was to have interrupt handlers leave interrupts =

> disabled on exit if pda.intr_mask was set.  In which case, they would =

> bypass all work and we could never get preempted.

I was actually worrying about the case where the interrupt came in
"late". But I don't think it's a problem there either.

> I don't think leaving =

> hardware interrupts disabled for such a long time is good though.

It can only be worse than the current situation by the amount of time
it takes to defer an interrupt once. On average, it'll be a lot
better as most critical sections are -tiny-.

-- =

Mathematics is the supreme nostalgia of our time.
