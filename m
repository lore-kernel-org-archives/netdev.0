From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Tue, 30 Sep 2003 23:51:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930235117.2346c711.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222966E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com, cramerj@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222966E@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Sep 2003 10:27:08 -0700
"Feldman, Scott" <scott.feldman@intel.com> wrote:

> At this point, I'm leaning towards removing the offending code in the
> timer callback now, and taking a step back to solve the bigger problem,
> either with a better locking scheme, or a new plan on how to flush the
> "stuck" work.  We don't need kernel panics when you trip over the
> Ethernet cable!  Sound like a plan?

Why do you even need to use IRQ locking here?

Your e1000 netdev->hard_start_xmit method doesn't need to do anything
special, why does this timer code?  I suppose you need to synchronize
with e1000_clean_tx_irq() in the non-NAPI case right?  If so, that's
not being accomplished by what your code is doing.  If nobody else
takes that xmit_lock in an IRQ disabling manner, the e1000 timer code
doing so doesn't make any difference.

I have an idea for attacking the problem, once you figure out what
kind of locking you really need.  Do whatever you need to do to
synchronize on the hardware side, but instead of directly freeing
the SKB, add each one to a list.  A pointer to the head of this list
is stored on the stack of the timer routine, and passed down into
the TX purger.

Then at the top level you can drop all your locks, re-enable hw IRQs
and whatever else you need to do, then pass the SKBs in the list off
to dev_kfree_skb_irq() (this is the appropriate routine to call to
free an SKB from a timer handler, which runs in soft interrupt
context).
