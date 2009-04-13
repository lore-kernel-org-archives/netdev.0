From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 21:42:31 +0000
Message-ID: <1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
References: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
	 <20090413.143211.214694858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	mcarlson@broadcom.com, mchan@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:40333 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840AbZDMVma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 17:42:30 -0400
In-Reply-To: <20090413.143211.214694858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-04-13 at 14:32 -0700, David Miller wrote:
> From: James Bottomley <James.Bottomley@HansenPartnership.com>
> Date: Mon, 13 Apr 2009 15:29:54 +0000
> 
> > We noticed on parisc that our broadcoms all swapped MAC addresses going
> > from 2.6.29 to 2.6.30-rc1:
> > 
> > Apr 11 07:48:24 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:30:6e:4b:15:59
> > Apr 13 07:34:34 ion kernel: eth0: Tigon3 [partno(BCM95700A6) rev 0105] (PCI:66MHz:64-bit) MAC address 00:00:59:15:4b:6e
> > 
> > The problem patch is:
> > 
> > commit 6d348f2c1e0bb1cf7a494b51fc921095ead3f6ae
> > Author: Matt Carlson <mcarlson@broadcom.com>
> > Date:   Wed Feb 25 14:25:52 2009 +0000
> > 
> >     tg3: Eliminate tg3_nvram_read_swab()
> > 
> > With the root cause being the use of memcpy to set the mac address:
> > 
> >    memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2);
> >    memcpy(&dev->dev_addr[2], (char *)&lo, sizeof(lo));
> > 
> > This might work on little endian machines, but it can't on big endian
> > ones.  You have to use the original setting mechanism to be correct on
> > all architectures.
> > 
> > The attached patch fixes parisc.
> > 
> > Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> 
> I'm applying this, thanks a lot James!

Actually, hang on ... I fat fingered the list address first time around
and we've been replying on the wrong list.

Michael apparently has the code working for sparc and we're all a bit
stumped why it doesn't work on parisc since they should follow identical
code paths.

This is the latest state of play:

---
On Mon, 2009-04-13 at 11:37 -0700, Matt Carlson wrote:
> But that is exactly what the code is doing.  tg3_nvram_read_be32() will
> return the data in bytestream format.  A memcpy() should be all that is
> needed to transport the data to a different memory location.

But not the one you've done.  cpu_to_be32 is a nop pass through on our
architecture, so tg3_nvram_read_be32 is equivalent to tg3_nvram_read on
our architecture (i.e. identical to the code that was doing the read in
2.6.29).  However, the memcpy is the wrong way around for us.  If you
look at an example, the original code said

dev_addr[0] = hi >> 16;
dev_addr[1] = hi >> 24

So MSB-1 and MSB.  However, on a BE machine these are at offset one and
zero from the start of the word.  The replacement memcopy is:

memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2)

i.e. offset 3 and 4, which actually copies LSB-1 and LSB into there.
You can follow similar logic to show that the lo copy is wrong too.

Perhaps the fix is just to put the tg3_nvram_read() back as well as the
original by loads?
---

James


