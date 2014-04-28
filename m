From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH net-next RESEND 2/2] FDDI: DEC FDDIcontroller 700
 TURBOchannel card support
Date: Mon, 28 Apr 2014 12:37:08 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1404280048540.11598@eddie.linux-mips.org>
References: <alpine.LFD.2.11.1404250159220.11598@eddie.linux-mips.org> <20140427.191346.2115795102984045600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140427.191346.2115795102984045600.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 27 Apr 2014, David Miller wrote:

> > +	/* Reset the board. */
> > +	wmb();
> > +	writew(FZA_RESET_INIT, &fp->regs->reset);
> > +	iob();
> > +	readw(&fp->regs->reset);	/* Read it back for a small delay. */
> > +	iob();
> > +	writew(FZA_RESET_CLR, &fp->regs->reset);
> 
> Using memory barriers around MMIO operations makes zero sense.
> 
> wmb() and friends order physical memory operations, and are only
> to be used when the cpu must be synchronized with some other entity
> looking at the same physical memory the cpu is, such as a device.
> 
> But that absolutely is not what is happening here, you're doing one
> MMIO to non-physical memory after another.

 This is not perfect, I admit, the issue here however is the MIPS R4400 
processor that is used with some systems that support this FDDI adapter 
has a weakly ordered write buffer, an uncached read issued to an MMIO 
device can be reordered in front of an earlier uncached write, bypassing 
the buffer.  Additionally the MIPS R3000 processor used on other systems 
has the R3220 write buffer that can merge multiple writes into one, or 
supply a value previously written from the buffer before it has reached 
the destination.  Therefore a synchronisation barrier is required.

 The architecturally guaranteed barrier operation for the R4400 processor 
is the SYNC processor instruction.  For the R3000 processor the barrier is 
platform specific, we have suitable handlers in place (traditionally 
called wbflush, as they simply spin-wait until the write buffer has 
drained by itself).

 Additionally in some cases, where an immediate effect is required we need 
to issue a read (to any location) so that the SYNC instruction actually 
drains the write buffer (for the R3000 obviously the lone wbflush 
suffices, and this is reflected in the handlers).

 This has been discussed before and we lack a general abstraction layer -- 
the assumptions we have throughout suitable e.g. for PCI systems do not 
necessarily stand for non-PCI MIPS systems.  It happens however that for 
systems this driver can support (i.e. MIPS, plus possibly Alpha and VAX; I 
have actually successfully used an earlier version of this driver with a 
VAX) these barrier handlers are good enough:

1. For Alpha, where these handlers originate from, MB and WMB are hardware 
   instructions defined both for MP memory and I/O (even UP), with the 
   usual semantics.

2. For MIPS we have equivalent handlers in place, also working with both 
   MP memory and I/O.

3. VAX is strongly ordered, all these handlers are nil.

4. iob is an extension defined for MIPS so far that uses the fastest read 
   operation available -- this is needed by the CPU and its any write 
   buffers only (TURBOchannel itself doesn't do write posting), so 
   with the read-back there's little sense in e.g. going down to 
   TURBOchannel that is always slower than the CPU bus and in some cases 
   much slower.

This approach has already been used with other TURBOchannel and DECstation 
support code, however as I noted above I wouldn't mind a cleaner solution.

 I have now dug deeper and I can see the PPC port (only) has these:

#define iobarrier_rw() eieio()
#define iobarrier_r()  eieio()
#define iobarrier_w()  eieio()

which look like the right starting point to me.  I would then add:

#define iobarrier_rw()   mb()
#define iobarrier_r()    rmb()
#define iobarrier_w()    wmb()
#define iobarrier_sync() iob()

(or any equivalent code on the RHS as I see fit) for the MIPS platform if 
we agree this is the right internal API, and update the driver and any 
other code I look after accordingly.  Platform maintainers could then add 
implementations as they consider required -- the strongly-ordered default 
could simply be:

#define iobarrier_rw()

etc.

 I can see we have a mmiowb handler too, defined across all ports, 
analogous to iobarrier_w, but its definition is IIUC wrong for some, e.g. 
it's empty for Alpha and PPC, where it should be defined to wmb() and 
eieio() respectively.  Anyway the name does not matter, I can take votes 
for iobarrier_* vs mmio*b as long as we agree on the API itself. :)

 I've added some CCs so that non-networking people can chime in on this 
part.

> > +{
> > +	uint status, state;
> > +
> > +	unsigned long int flags;
> > +	long int t;
> > +
> 
> Use "unsigned int" and "long", and also please do not put empty lines
> in the middle of the function variable declarations.

 Done.

> > +
> > +	pr_info("%s: resetting the board...\n", fp->name);
> 
> Do not put more than one empty line between the local variables
> and the first non-declaration statement of the function.

 Likewise.

 [This and the above (except from "long int", that was an oversight) was 
done for readability purposes, but I won't insist, it's not important 
enough to me.]

> > +static struct fza_ring_cmd __iomem *fza_cmd_send(struct net_device *dev,
> > +						 int command)
> 
> When a function declaration or definition or call spans multiple lines,
> the second and subsequent lines should be indented to exactly the first
> column after the openning parenthesis.

 The line you quoted however is exactly right. :)  Please mind the + added 
by diff offsetting the first but not the second line quoted.

> You must use the appropriate number of TAB and SPACE characters necessary
> to do so.  Generally speaking, if you are only using TAB characters you
> are indenting it incorrectly.

 Or I am good at hitting columns at multiples of 8 with the opening 
bracket perhaps? ;)

> I'm sure there are lots of other coding style issues, please run
> checkpatch on your changes unless you want to go back and forth
> in review several more times as we find them too :-)

 Well, I tried my best and the last time I ran it on this change the 
script only had issues with the barriers we've been discussing at the 
beginning (and which hopefully we'll settle on one way or another), and 
comments.  The latter of which I consider a result of the script being too 
picky or maybe even entirely wrong, given e.g.:

#define FZA_EVENT_HB_PARITY_ERR	0x0100	/* host bus parity error */
#define FZA_EVENT_NXM_ERR	0x0080	/* non-existent memory access error;
					   also raised for unaligned and
					   unsupported partial-word accesses */
#define FZA_EVENT_LINK_ST_CHG	0x0040	/* link status change */

where the three comments are simply consistent with one another.  If you 
want them changed to:

#define FZA_EVENT_HB_PARITY_ERR	0x0100	/* host bus parity error */
#define FZA_EVENT_NXM_ERR	0x0080	/* non-existent memory access error;
					 * also raised for unaligned and
					 * unsupported partial-word accesses
					 */
#define FZA_EVENT_LINK_ST_CHG	0x0040	/* link status change */

though, then I won't insist on keeping my style, that's not important 
enough for me, even though the latter version hurts my eye a bit.

 Ah, it had something to say about 2 messages split between lines too, but 
I refuse to go beyond 79 columns, sorry.

> As per these SMT packets, don't even publish them to network taps.
> 
> We would have never seen them anyways, so keep them completely
> internal to your driver.
> 
> That way you have no reason ti poke into internals like ptype_all
> and dev_queue_xmit_nit().

 That however I would like to keep -- I find it particularly valuable and 
a great advantage of this piece of hardware to be able to tap into all the 
SMT traffic crossing this adapter, both incoming and outgoing, for 
educational and diagnostic purposes.  Without this capability a second 
FDDI station is required to be able to see both traffic streams, and also 
it has to be exactly the next downstream neighbour or some traffic will 
undoubtedly be stripped from the ring by intermediate stations.

 Therefore I would like to retain this capability.  If you're unhappy with 
tapping in directly, then I think sending them back down the usual receive 
path would do, although at some performance hit.  So I'd prefer to avoid 
it if possible -- can you propose an alternative by any chance?

 Thanks for your review, please let me know how to proceed with the issues 
that remain open.  I'll send updated code once we've settled, I think 
there's little point in publishing an update before then.

  Maciej
