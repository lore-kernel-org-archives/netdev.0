From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 17:24:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703201715470.6730@woody.linux-foundation.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
	<1174348905.11680.54.camel@localhost.localdomain>
	<45FF4043.4000805@vmware.com> <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<m1mz27sy82.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703200903500.6730@woody.linux-foundation.org>
	<46000C7E.4070001@goop.org> <46005B89.5070301@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, akpm@linux-foundation.org,
   virtualization@lists.osdl.org, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, chrisw@sous-sol.org, Andi Kleen <ak@muc.de>,
   "Eric W. Biederman" <ebiederm@xmission.com>, anthony@codemonkey.ws,
   mingo@elte.hu, David Miller <davem@davemloft.net>
To: Zachary Amsden <zach@vmware.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <46005B89.5070301@vmware.com>
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



On Tue, 20 Mar 2007, Zachary Amsden wrote:
> =

> void local_irq_restore(int enabled)
> {
>    pda.intr_mask =3D enabled;
>    /*
>     * note there is a window here where softirqs are not processed by
>     * the interrupt handler, but that is not a problem, since it will
>     * get done here in the outer enable of any nested pair.
>     */
>    if (enabled)
>        local_bh_enable();
> }

Actually, this one is more complicated. You also need to actually enable =

hardware interrupts again if they got disabled by an interrupt actually =

occurring while the "soft-interrupt" was disabled.

But since it's all a local-cpu issue, you can do things like test =

cpu-local memory flags for whetehr that has happened or not.

So it *should* be something as simple as

	local_irq_disable()
	{
		pda.irq_enable =3D 0;
	}

	handle_interrupt()
	{
		if (!pda.irq_enable) {
			pda.irq_queued =3D 1;
			queue_interrupt();
			.. make sure we return with hardirq's now =

			   disabled: just clear IF in the pt_regs ..
			return;
		}
		.. normal ..
	}

	local_irq_enable()
	{
		pda.irq_enable =3D 1;
		barrier();
		/* Common case - nothing happened while we were fake-disabled.. */
		if (!pda.irq_queued)
			return; =


		/* Ok, actually handle the things! */
		handle_queued_irqs();

		/*
		 * And enable the hw interrupts again, they got disabled =

		 * when we were queueing stuff.. =

		 */
		hardware_sti();
	}

but I haven't really gone over it in any detail, I may have missed =

something really obvious.

Anyway, it really *should* be pretty damn simple. No need to disable =

preemption, there should be no events that can *cause* it, since all =

interrupts get headed off at the pass.. (the return-from-interrupt thng =

should already notice that it's returning to an interrupts-disabled =

section and not try to do any preemption).

What did I miss?

		Linus
