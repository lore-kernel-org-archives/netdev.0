From: Donald Becker <becker@scyld.com>
Subject: Re: Patch: link state detection for 8139too against 2.5.41
Date: Sat, 12 Oct 2002 00:14:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com>
References: <3DA764D8.FCDF34F8@isg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@mandrakesoft.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
In-Reply-To: <3DA764D8.FCDF34F8@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 12 Oct 2002, Stefan Rompf wrote:

> Date: Sat, 12 Oct 2002 01:55:04 +0200
> From: Stefan Rompf <srompf@isg.de>
> To: jgarzik@mandrakesoft.com
> Cc: netdev@oss.sgi.com
> Subject: Patch: link state detection for 8139too against 2.5.41
> 
> Hi Jeff,
> 
> attached you find a patch that enables link state detection for the
> 8139too driver. It applies cleanly against 2.5.41 and with some line
> offset against 2.4.19.
> 
> I've written this stuff on a friends' computer using 2.4.18, so it is
> only slightly tested.

Uhmmm, you don't need to poll with the rtl8139.  There is a link change
interrupt.  Here is the recently added from rtl8139.c

	if (status & RxUnderrun){
		/* This might actually be a link change event. */
		if ((tp->drv_flags & HAS_LNK_CHNG)  &&  link_changed) {
			/* Really link-change on new chips. */
			int lpar = inw(ioaddr + NWayLPAR);
			int duplex = (lpar&0x0100) || (lpar & 0x01C0) == 0x0040
				|| tp->duplex_lock;
			/* Do not use MII_BMSR as that clears sticky bit. */
			if (inw(ioaddr + GPPinData) & 0x0004) {
				netif_link_down(dev);
			} else
				netif_link_up(dev);
			if (tp->msg_level & NETIF_MSG_LINK)
				printk(KERN_DEBUG "%s: Link changed, link partner "
					   "%4.4x new duplex %d.\n",
					   dev->name, lpar, duplex);
			tp->full_duplex = duplex;
			/* Only count as errors with no link change. */
			status &= ~RxUnderrun;
		} else {


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
