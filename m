From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Tue, 30 Sep 2003 04:53:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930045306.5ac6be0d.davem@redhat.com>
References: <20030929143642.18b491ba.akpm@osdl.org>
	<20030929224929.4dc6ed4a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, netdev@oss.sgi.com, cramerj@intel.com,
        scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030929224929.4dc6ed4a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Sep 2003 22:49:29 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Mon, 29 Sep 2003 14:36:42 -0700
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > Oh, it's taking xmit_lock in a timer handler.  I give up.
> 
> I think e1000 should rethink what it is doing :-)

Sorry, in case it isn't painfully obvious, instead of hinting
at it let me state explicitly that ->xmit_lock is a BH disabling
lock not an IRQ disabling one.

Therefore, e1000's IRQ disabling when grabbing that lock is
buggy and need to be changed to BH disabling.

If it needs to disable IRQs for it's own internal locking, it
needs to do so such that such IRQ disabling internal locks
are not held while kfree_skb() is being invoked.

Calling kfree_skb() with IRQs disabled in the e1000 driver is
the cause of this bug.

Jeff, if you pushed these e1000 updates that make it grap
->xmit_lock() with disabling IRQs instead of BH into 2.4.x
trees too, beware!
