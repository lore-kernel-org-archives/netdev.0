From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: fix eeprom endianess issue
Date: Wed, 23 Aug 2006 20:06:55 +0200
Message-ID: <200608232006.55531.mb@bu3sch.de>
References: <200608231232.05750.mb@bu3sch.de> <200608231238.49783.mb@bu3sch.de> <44EC8866.9050704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, zambrano@broadcom.com,
	netdev@vger.kernel.org, davem@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44427
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S965089AbWHWSHh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 14:07:37 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44EC8866.9050704@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 23 August 2006 18:55, Jeff Garzik wrote:
> Michael Buesch wrote:
> >> Please note that this test is only compile tested, as
> >> I don't have a b44 device.
> 
> >> @@ -2055,7 +2055,7 @@
> >>  	u16 *ptr = (u16 *) data;
> >>  
> >>  	for (i = 0; i < 128; i += 2)
> >> -		ptr[i / 2] = readw(bp->regs + 4096 + i);
> >> +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
> >>  
> 
> 
> This looks a bit weird.  readw() swaps on big-endian already.
> 
> This patch swaps each word -again- on big-endian, even though the only 
> user of the eeprom data is the get-invariants code that reads the MAC 
> address and phy id.

Yeah. But look at where the data is stored.
The data ends up in a _byte_ array. A byte array is litte endian
(little end first). array[0] is low and array[1] is high.
Look at the pointer cast above:

u16 *ptr = (u16 *) data;

We store data in _cpu_ order in this byte array.
That's wrong.
If we are on a little endian machine, that's ok. But if
we are on a big endian machine, this will write bytes swapped.

LE will result in an array:
ABABABABABABAB
BE will result in an array:
BABABABABABABA

But only the first result (LE) is valid, because that's
expected later when interpreting the data.

-- 
Greetings Michael.
