From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 18:49:34 +0200
Message-ID: <1159289374.2782.39.camel@ux156>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net>
	 <45186D66.1000508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, mb@bu3sch.de,
	Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2025 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751562AbWIZQs4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 12:48:56 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45186D66.1000508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-25 at 19:59 -0400, Jeff Garzik wrote:

> Seems like a better solution would be to remove the manual swap from the 
> caller of b44_read_eeprom().

No.

You're not looking at the problem from the right angle.

The thing is that Broadcom decided to store the EEPROM data as an array
of u16s:
  u16 eeprom_data_as_stored[64];

In there, you have, for example, the mac address in 3 u16s at offsets
39-41:
  | offset | ... | 39     | 40     | 41     | ...
  | data   | ... | MAC 01 | MAC 23 | MAC 45 | ...

which together forms MAC 012345 (6 bytes)

Broadcom further assumes that things are in little endian, so it's
actually necessary to byteswap the MAC bytes 01, 23, 45 which I have
omitted from above pictures because it's an array of u16 so endianness
doesn't matter as long as you store it to the mac in big endian.


Now come along the current code which didn't understand this and
overlayed the eeprom_data_as_stored with a new array:
    u8 eeprom[128];

That's fine on little endian machines because each u16 will be
represented in exactly the same way, and it all works out.

However, because of Broadcom always thinking "little endian u16" *and*
the current code using "u8" there's a mismatch on big endian machines
which Michael fixed up by making the u8 "overlay" the driver is using
see "little endian u16". Insofar, it is the correct fix because the
current code wants to use a u8 overlay over an array that was intended
to be a "little endian u16" array.

Now, arguably the correct fix would be to make the b44_read_eeprom
routine read an array of u16 as stored, and then use byte shifting
everywhere to fix up for the fact that Broadcom stores things into the
high/low byte of a u16 (yes, they always use a u16 layout even if the
data they want to store is just a u8 or less, then they stuff it into a
u16 and store it, they don't store byte-wise).

Now, making that fix would result in quite some ugly code along the
lines of:
        bp->dev->dev_addr[0] = eeprom[39] >> 8;
        bp->dev->dev_addr[1] = eeprom[39] & 0xFF;
        bp->dev->dev_addr[2] = eeprom[40] >> 8;
        bp->dev->dev_addr[3] = eeprom[40] & 0xFF;
etc.

Similar for the other parameters (which you seem to be forgetting by
advocating the byte swap here, but they too are stored into u16s!)

The current code obviously didn't want to do that so they overlaid the
u16 array with a u8 array to read out the bytes directly. This results
in the manual-seeming byte-swapping for some parameters of course.

Now, Michaels fix works differently instead, it properly reads out the
sprom data so that the overlaid u8 array gets what it expects, a view
into a "little endian u16" array. You really have to think of it as a
view. This is obviously what the original authors intended to do but
they were unaware of the endianness complications with that approach.

johannes
