From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: Update on problems with sundance driver
Date: Sun, 13 Oct 2002 11:23:50 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210131723.g9DHNov07599@vindaloo.ras.ucalgary.ca>
References: <200210121643.g9CGhCS12921@vindaloo.ras.ucalgary.ca>
	<Pine.LNX.4.44.0210130047040.1159-100000@beohost.scyld.com>
Cc: netdev@oss.sgi.com, Jason Lunz <lunz@falooley.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
In-Reply-To: <Pine.LNX.4.44.0210130047040.1159-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker writes:
> On Sat, 12 Oct 2002, Richard Gooch wrote:
> 
> > With 2.4.20-pre9 and the appended patch from D-Link (with corrections
> > by me to make the patch apply and compile), I was getting transmitter
> > timeouts every minute or so. This was causing traffic through the
> > firewall to stall each time.
> >
> > I've now forced eth1 to 100 Mb/s FD, and the machine has run overnight
> > with no transmitter timeouts. Before, eth1 was auto negotiated to 100
> > Mb/s HD (the other end doesn't do auto negotiation properly, but is
> > locked down to 100 Mb/s FD).
> 
> Ackk!!!!!
> 
> > So it seems that running an interface at HD while the other end is set
> > to FD causes transmitter timeouts. Why is this?
> 
> Uhmmm, perhaps because the duplex causes out-of-window collisions.  The
> transmitter is supposed to stop transmitting in this case.
> 
> You should never force full duplex.  If you have a switch with
> broken autonegotiation, leave the link at half duplex.  Speed
> autosensing will then allow a working configuration.

Maybe I didn't explain: the switch is a box I don't have control
over. It's been locked to 100 Mb/s FD. It's Campus IT policy to
disable auto negotiation (they claim it causes too much trouble
because people plug broken auto negotiation hardware into their
switches. Of course, it also happens to give them control, which might
possibly be related to them charging a minimum $125 fee for every
change).

So given this situation, what's the sensible thing for me to do?
When the interface auto configured to 100 Mb/s HD, I got transmitter
timeouts. Forcing it to 100 Mb/s FD fixed that. Should I really ask
for the switch to be locked down to 100 Mb/s HD and let the interface
auto configure? What do I gain, other than reduced bandwidth and the
pleasure of donating $125?

> > There is a problem with the D-Link patch, though: throughput has been
> > drastically reduced...
> 
> >     bonding and packet priority, and more than 128 requires modifying the
> >     Tx error recovery.
> >     Large receive rings merely waste memory. */
> > -#define TX_RING_SIZE	64
> > +#define TX_RING_SIZE	32
> >  #define TX_QUEUE_LEN	(TX_RING_SIZE - 1) /* Limit ring entries actually used.  */
> 
> Ackk!!!
> How come everyone thinks "if I make this number higher, things will work
> better"?  Has anyone, besides me, actually done measurements?  If not,
> don't change the settings.

Actually, the D-Link patch *dropped* the number, so what's the
problem?

> >  	/* Fix DFE-580TX packet drop issue */
> > -	writeb(0x01, ioaddr + DebugCtrl1);
> > +	if (np->pci_rev_id >= 0x14)
> > +		writeb(0x01, ioaddr + DebugCtrl1);
> >  	netif_start_queue(dev);
> 
> This is all of the magic.
> The chip is broken and requires an undocumented register setting.

Do you know in which way it is broken? Could it cause the machine to
lock up, hard? The problem I had with 2.4.19 + Jason's 1.01d patch was
the machine would lock up after a few days.

Of course, with 2.4.20-pre9 and the latest D-Link patch, it hasn't
been up quite that long yet...

> Except that this is a really bad condition to check.
> There should be a flag bit in the chip detection section.
> 
> >  	/* reset tx logic */
> > -	writel (0, dev->base_addr + TxListPtr);
> > +	writew (TxDisable, ioaddr + MACCtrl1);
> > +	mdelay(10);
> 
> I suspect that this is mdelay(10) is a similar hack/guess.

Hm. But that's just for Tx reset. It shouldn't affect normal
performance, right? The throughput dropped dramatically with the
D-Link patch.

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
