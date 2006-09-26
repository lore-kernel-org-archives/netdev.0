From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 20:10:50 +0200
Message-ID: <200609262010.50420.mb@bu3sch.de>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <1159289374.2782.39.camel@ux156> <20060926174915.GA12512@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:4256
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932396AbWIZSK7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 14:10:59 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060926174915.GA12512@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 September 2006 19:49, Francois Romieu wrote:
> Johannes Berg <johannes@sipsolutions.net> :
> [...]
> > Now, arguably the correct fix would be to make the b44_read_eeprom
> > routine read an array of u16 as stored, and then use byte shifting
> > everywhere to fix up for the fact that Broadcom stores things into the
> 
> Yes.

That is damn unnecessary. Why change semantics and not _fix_ _current_
semantics? (Espacially, if fixing current semantics is a _lot_ easier).

> > high/low byte of a u16 (yes, they always use a u16 layout even if the
> > data they want to store is just a u8 or less, then they stuff it into a
> > u16 and store it, they don't store byte-wise).
> >
> > Now, making that fix would result in quite some ugly code along the
> > lines of:
> >         bp->dev->dev_addr[0] = eeprom[39] >> 8;
> >         bp->dev->dev_addr[1] = eeprom[39] & 0xFF;
> >         bp->dev->dev_addr[2] = eeprom[40] >> 8;
> >         bp->dev->dev_addr[3] = eeprom[40] & 0xFF;
> > etc.
> 
> 1 - see drivers/net/tg3.c. The drivers/net code does not swaps register
>     a lot: one can find some cpu_to_{l/b}e or {l/b}e_to_cpu which go
>     along read/write but they do not look like the norm.

Well, so maybe tg3 is broken, too.
But that does not matter now. We are talking about b44.

> 2 - The code is extracting an u8 from an u16. Nothing shocking (ok, the
>     capitalized 0xFF _is_ shocking :o) ).

o_O No comment, really.

> 3 - The data in the eeprom contains u16 and it has a known endianness.
>     It can be annotated as such (__be16 eeprom[]). I do not know how to
>     do the same with an u8 [].

No. The eeprom is mostly not be16. The eeprom is mostly little
endian, except the mac address and some wireless specific bits
I forgot.
But more important: This does _NOT_ matter here, as that's not
related to the acutual bug in b44.

The bug is:
Reading u16 values with readw, casting them into an u8 array
and accessing this u8 array as an u8 (byte) array.
The correct fix is to swap the CPU-ordering value returned
by readw into little endian, as the u8 array is little
endian.
This compiles to nothing on little endian hardware (so it
does not change b44 code on LE hardware), but _fixes_
code on BE hardware.

-- 
Greetings Michael.
