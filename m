From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: LLTX and netif_stop_queue
Date: Wed, 19 Jan 2005 15:41:32 -0800
Message-ID: <20050119154132.68f0bb4f.davem@davemloft.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, eric.lemoine@gmail.com, hadi@cyberus.ca,
	ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <openib-general-bounces@openib.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050119151853.259de49a@dxpl.pdx.osdl.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 15:18:53 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Wondering, why not just have the drivers have a way to lock dev->queue_lock
> in the interrupt handler, and change the xmit to do spin_lock_irqsave?
> 
> Any driver that assumes it is being called with irq's enabled in transmit
> is probably already busted anyway.

Yes, that's an idea.

Effectively, LLTX is working around the fact that dev->xmit_lock is
BH disabling instead of IRQ disabling.  And there is no fundamental
reason for that.

Usually we strive for BH disabling locks in order to decrease the
amount of hard IRQ disabling time in the kernel.  But here, as soon
as we call into ->hard_start_xmit(), the driver typically turns hard
IRQs off anyways.

There are other things using this though, such as multicast list
upload.

If we change dev->xmit_lock to be an IRQ disabling lock, then drivers
can use it in place of their private tx_lock.

We would still need something special for loopback, which wants and
needs no locking at all.

Also, changing dev->xmit_lock to be IRQ disabling is not %100 trivial.
We'd need to verify the side-effects this has on gems like the
spin_unlock_wait(&dev->xmit_lock) in the Tulip winbond power management
code.  There is another fun case in the 6pack hamradio driver where it
is doing IRQ disabling when taking dev->xmit_lock.

Originally, dev->xmit_lock was added so that drivers that were SMP dumb
could stay that way.  Thus preserving the guarentee that there would be
only one active call into the dev->hard_start_xmit method across the
entire system.  I don't think any of that is relevant any longer.  All
of our network drivers are pretty clean in this regard.
