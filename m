From: Donald Becker <becker@scyld.com>
Subject: Re: Update on problems with sundance driver
Date: Sun, 13 Oct 2002 00:58:39 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210130047040.1159-100000@beohost.scyld.com>
References: <200210121643.g9CGhCS12921@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Jason Lunz <lunz@falooley.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
In-Reply-To: <200210121643.g9CGhCS12921@vindaloo.ras.ucalgary.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Oct 2002, Richard Gooch wrote:

> With 2.4.20-pre9 and the appended patch from D-Link (with corrections
> by me to make the patch apply and compile), I was getting transmitter
> timeouts every minute or so. This was causing traffic through the
> firewall to stall each time.
>
> I've now forced eth1 to 100 Mb/s FD, and the machine has run overnight
> with no transmitter timeouts. Before, eth1 was auto negotiated to 100
> Mb/s HD (the other end doesn't do auto negotiation properly, but is
> locked down to 100 Mb/s FD).

Ackk!!!!!

> So it seems that running an interface at HD while the other end is set
> to FD causes transmitter timeouts. Why is this?

Uhmmm, perhaps because the duplex causes out-of-window collisions.  The
transmitter is supposed to stop transmitting in this case.

You should never force full duplex.  If you have a switch with broken
autonegotiation, leave the link at half duplex.  Speed autosensing will
then allow a working configuration.

> There is a problem with the D-Link patch, though: throughput has been
> drastically reduced...

>     bonding and packet priority, and more than 128 requires modifying the
>     Tx error recovery.
>     Large receive rings merely waste memory. */
> -#define TX_RING_SIZE	64
> +#define TX_RING_SIZE	32
>  #define TX_QUEUE_LEN	(TX_RING_SIZE - 1) /* Limit ring entries actually used.  */

Ackk!!!
How come everyone thinks "if I make this number higher, things will work
better"?  Has anyone, besides me, actually done measurements?  If not,
don't change the settings.

>  	/* Fix DFE-580TX packet drop issue */
> -	writeb(0x01, ioaddr + DebugCtrl1);
> +	if (np->pci_rev_id >= 0x14)
> +		writeb(0x01, ioaddr + DebugCtrl1);
>  	netif_start_queue(dev);

This is all of the magic.
The chip is broken and requires an undocumented register setting.
Except that this is a really bad condition to check.
There should be a flag bit in the chip detection section.

>  	/* reset tx logic */
> -	writel (0, dev->base_addr + TxListPtr);
> +	writew (TxDisable, ioaddr + MACCtrl1);
> +	mdelay(10);

I suspect that this is mdelay(10) is a similar hack/guess.

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
