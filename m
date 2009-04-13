From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 15:17:39 -0700
Message-ID: <1239661059.9237.4.camel@HP1>
References: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
 <20090413.143211.214694858.davem@davemloft.net>
 <1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "James Bottomley" <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4478 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043AbZDMWX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2009 18:23:26 -0400
In-Reply-To: <1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2009-04-13 at 14:42 -0700, James Bottomley wrote:

> ---
> On Mon, 2009-04-13 at 11:37 -0700, Matt Carlson wrote:
> > But that is exactly what the code is doing.  tg3_nvram_read_be32() will
> > return the data in bytestream format.  A memcpy() should be all that is
> > needed to transport the data to a different memory location.
> 
> But not the one you've done.  cpu_to_be32 is a nop pass through on our
> architecture, so tg3_nvram_read_be32 is equivalent to tg3_nvram_read on
> our architecture (i.e. identical to the code that was doing the read in
> 2.6.29).  However, the memcpy is the wrong way around for us.  If you
> look at an example, the original code said

The old tg3_nvram_read() had a swab32() after the readl().  The new
tg3_nvram_read() no longer has the swab32().  There were too many layers
of swapping in the old code and that's why Matt wanted to clean it up.

James, can do dump out the nvram content on the parisc?

ethtool -e eth0 length 0x90

Thanks.

> 
> dev_addr[0] = hi >> 16;
> dev_addr[1] = hi >> 24
> 
> So MSB-1 and MSB.  However, on a BE machine these are at offset one and
> zero from the start of the word.  The replacement memcopy is:
> 
> memcpy(&dev->dev_addr[0], ((char *)&hi) + 2, 2)
> 
> i.e. offset 3 and 4, which actually copies LSB-1 and LSB into there.
> You can follow similar logic to show that the lo copy is wrong too.
> 
> Perhaps the fix is just to put the tg3_nvram_read() back as well as the
> original by loads?
> ---
> 
> James
> 
> 
> 


