From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 13:34:20 -0800
Message-ID: <20050120133420.317bea31.davem@davemloft.net>
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
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<1106229084.5812.40.camel@tsc-6.cph.tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: roland@topspin.com, shemminger@osdl.org, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <1106229084.5812.40.camel@tsc-6.cph.tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 14:51:25 +0100
Tommy Christensen <tommy.christensen@tpack.net> wrote:

> A lot more serious is the fact that ->tx_timeout() and
> ->hard_start_xmit() are no longer allowed to do this:
> 
>   spin_lock_irq()
>   ...
>   spin_unlock_irq()
> 
> since that would leave us with irq's enabled while still
> holding the xmit_lock.
> This would have to be fixed for non-LLTX drivers as well.

Even worse is that this breaks the acenic driver too because
it does this:

	unsigned long maxjiff = jiffies + 3*HZ;

	if (time_before(jiffies, maxjiff)) {
		barrier();
		cpu_relax();
		goto restart;
	}

in it's ->hard_start_xmit() routine.

I was auditing spin_lock_irq() usage in ->hard_start_xmit()
routines when I caught this.

This one isn't impossible to fix though.  We can replace the
jiffies games with a udelay/mdelay and a "maxloop" variable.
Any takers?

I'll keep working on the spin_lock_irq() audit then work on
the other problems Tommy found.
