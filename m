From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: usbnet transmit path problems
Date: Wed, 11 Sep 2013 13:56:48 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7326@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com><1378894312.28160.15.camel@linux-fkkt.site> <20130911193430.0825ac95@tom-ThinkPad-T410>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Ming Lei" <ming.lei@canonical.com>,
	"Oliver Neukum" <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56521 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752718Ab3IKM6I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 08:58:08 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28246-08 for <netdev@vger.kernel.org>;
 Wed, 11 Sep 2013 13:58:04 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130911193430.0825ac95@tom-ThinkPad-T410>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
> > >    the extra byte isn't added correctly (the code probably falls off
> > >    the end of the scatter-gather list).
> >
> > Indeed. Ming Lei, should usbnet handle this in the sg case or better
> > leave it to the subdriver you introduced this for?

Is the ZLP issue a problem with the host or with the target?
If it is a host problem then the necessity comes from the host,
but the fix needs to be target dependant.
If it is a common target problem then generic code can apply
a common fix.

AFICT there are at least 3 fixes:
1) Extend the ethernet frame by one byte and hope the receiving
   system doesn't object to the padding.
   This is probably the only option if tx_fixup() doesn't
   add a header.
2) Put the ethernet frame length in the header and have the
   target discard the added pad byte (ax88179_178a.c).
3) Add a second zero-length frame in the same USB data block
   (ax88172a.c).

Only the third requires that tx_fixup() append to the packet.
For the other two actual pad can be added by usbnet.
 
> IMO, it should be handled by usbnet, could you comment on below patch?

Seems excessive to kmalloc() one byte!
If you can't assume that the 'dev' structure itself can be dma'd from
allocate the extra byte in the sg list.

	David
