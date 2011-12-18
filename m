From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Sat, 17 Dec 2011 23:37:01 -0500
Message-ID: <4EED6DED.50308@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <20111217.215630.640392276998191183.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:40166 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751224Ab1LREhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 23:37:55 -0500
In-Reply-To: <20111217.215630.640392276998191183.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2011 21:56, David Miller wrote:

> From: Joshua Kinard <kumba@gentoo.org>
> Date: Sat, 17 Dec 2011 19:56:29 -0500
> 
>> +/* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
>> + * MACE Ethernet uses a 64 element hash table based on the Ethernet CRC.
>> + */
>> +static int multicast_filter_limit = 32;
>> +
>> +
> 
> Unnecessary empty line, only one is sufficient.  I also don't see a reason
> to even define this value.  If it's a constant then use a const type.


Lifted straight out of another driver already in the tree and checked
against the docs.  I can spin a new patch to constify it, but the same fix
is needed for several other drivers, too.


>> +	/* Multicast filter. */
>> +	unsigned long mcast_filter;
>> +
>  ...
>> +		priv->mcast_filter = 0xffffffffffffffffUL;
> 
> You're assuming that unsigned long is 64-bits here.  You need to use a
> type which matches your expections regardless of the architecture that
> the code is built on.


MACE Ethernet only ever appears on the SGI O2 systems.  It's part of the
MACE chip and doesn't exist (as far as I know) in any kind of standalone
form.  It's virtually impossible for it to appear outside of any other
architecture/machine.

That said, would using 'u64' over 'unsigned long' work?  The O2 codebase is
far from pretty, and would need a LOT of cleanups along similar lines.  This
code simply matches what is already existing in-tree.


>> +		netdev_for_each_mc_addr(ha, dev)
>> +			set_bit((ether_crc(ETH_ALEN, ha->addr) >> 26),
>> +				    (volatile long unsigned int *)&priv->mcast_filter);
> 
> This makes an assumption not only about the size of the "unsigned long"
> type, but also of the endianness of the architecture this runs on.
> 
> Please recode this to remove both assumptions.

See note above regarding the 'unsigned long' bit.  The endian assumption is
not directly visible to me, however.  What, specifically, is incorrect?  The
call to ether_crc?  The bitwise right-shift?  set_bit?

I lifted this out of au1000_eth.c (which is a little-endian MIPS device, if
I recall correctly), and all the digging I could do states that the Ethernet
CRC algorithm is LE anyways (ether_crc() calls crc32_le, bitrev32, and
such).  I couldn't find anything big-endian about it, even when I tested it
against several other code samples that computed the 6-bit hash key from the
Dst MAC address.


Thanks,

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
