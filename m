From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Sat, 17 Jan 2004 13:53:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040117135302.A13453@electric-eye.fr.zoreil.com>
References: <200401152039.00182.harisri@bigpond.com> <20040115220827.A22007@electric-eye.fr.zoreil.com> <200401171234.33778.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401171234.33778.harisri@bigpond.com>; from harisri@bigpond.com on Sat, Jan 17, 2004 at 12:34:33PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
[memory stats]

Ok, the driver does not seem to leak.

[...]
> > You can try 2.6.1-bk2 + Jeff Garzik's -netdev4 +
> > http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch
> 
> I shall try this and then report the status.

Please (see "Scenario" below).

> > If it does not perform better, you can try against 2.6.1-bk1 the set at
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b
> 
> OK. I have tried 2.6.1-mm4 which includes the most recent -netdev updates
> from Jeff Garzik and it behaves the same way.
> 
> > If I remember correctly, you are the first report of a non-completely
> > disfunctional driver for the new version of the r8169. Things improve.
> 
> Sorry I am unable to understand your statement.

Tests have shown that stock r8169 is foobar on amd64 without Realtek's
changes.  The r8169 in -mm, -netdev merge various changes made by Realtek
and several contributors. Tests have shown that this modified r8169 was
completely broken. Your report indicates that the last modified r8169 (slowly)
returns to sanity on amd64. Nice :o)

r8169-tx-index-overflow.patch has not been included in -mm nor in -netdev
so far. It has only been moderately tested on x86 so amd64 users are welcome.
I do not claim it will solve everything but nasty things [*] can happen
without it.

[*] Scenario:
While submitting sbk, start_xmit crosses the end of the Tx descriptor ring and
feeds the start of the ring again (so far, so good). It is possible/expected
that several skbs are pending, especially as the start_xmit function uses
posted pci writes to tell that asic that it must wake up. Later, the Tx irq
handler notifes that the first pending buffer was sent. Now, depending on the
state of the memory just after the end of the Tx descriptor ring, interesting
things (deadlock included) can happen.

Take a look at rtl8169_tx_interrupt(), assume that tp->dirty_tx = 63,
tp->cur_tx = 63 + 48. "entry" starts at tp->cur_tx % NUM_TX_DESC = 47 and
can be incremented from tp->cur_tx - tp->dirty_tx = 48 units, thus ending
waaaaayyy beyond the end of the allowed Tx descriptor ring (NUM_TX_DESC = 64
entries). If something in this memory area looks like a Tx descriptor which
is owned by the asic, the irq handler loops for life. If this memory area
looks like a Tx descriptor which belongs to the cpu, the irq handler will
free the skb and the asic may simply send crap on the wire.

If this explanation is right, it applies on 2.4.x as well. However it is
suprizing as Robert Olsson was able to send packets at rather high rates
with the Realtek variant of this driver (where the start_xmit/tx_interrupt
functions are identical).

So, please, please, test in a sane environment (no binary modules) and tell
me if things behave the same/better/worse.

--
Ueimor
