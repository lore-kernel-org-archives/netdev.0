From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.5.66-mm3+debug] traces.
Date: Fri, 04 Apr 2003 18:27:16 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030404.182716.06393733.davem@redhat.com>
References: <20030404172927.2b449167.akpm@digeo.com>
	<20030404.173538.03688224.davem@redhat.com>
	<20030404181427.5cf0c127.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@digeo.com
In-Reply-To: <20030404181427.5cf0c127.akpm@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Fri, 4 Apr 2003 18:14:27 -0800

   "David S. Miller" <davem@redhat.com> wrote:
   >
   > You simply cannot take BH locks inside of IRQ disabling
   > ones, this is true 2.4.x too it just doesn't BUG() on you there
   > (you get a potential deadlock instead).
   
   I don't recall seeing a description or discussion of this deadlock.
   Any pointers?

Search the archives for the subject "BUG or not? GFP_KERNEL with
interrupts disabled."  unfortunately it appears a lot of that
thread got privatized and I don't have any logs.

The long and short of it is:

	spin_lock_irq();

		anything which does local_bh_{enable,disable}()

	spin_unlock_irq();

and similar are illegal.

local_bh_enable() invokes do_softirq() if softints are pending,
do_softirq() enables cpu interrupts, which would result in a deadlock
in the above case (because an interrupt could arrive and try to take
the IRQ spinlock taken by spin_lock_irq()).

Therefore it's a bug, and it's a bug everywhere BUG() check or not. :-)
