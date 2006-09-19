From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 09:24:29 +1000
Message-ID: <1158708269.6002.186.camel@localhost.localdomain>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
	 <20060919184243.GL29167@austin.ibm.com>  <45103C62.4080003@genesi-usa.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@austin.ibm.com>, akpm@osdl.org,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	ppc-dev <linuxppc-dev@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:46037 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1750749AbWISXZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 19:25:49 -0400
To: Matt Sealey <matt@genesi-usa.com>
In-Reply-To: <45103C62.4080003@genesi-usa.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-19 at 20:52 +0200, Matt Sealey wrote:
> Some northbridges and PCI bridges have "clever" byteswapping in 
> hardware, maybe this is just an effect of that. In theory depending on 
> the host bridge, you should pass in big endian data and have it swap or 
> not swap, not pick that way in the driver, UNLESS your driver expects 
> bigendian data, in which case on a bigendian platform you can tell it to 
> write without swapping. Voila, two functions.

It's generally considered pretty bad for a northbridge to try to muck
around with byte order. There are fairly well defined rules to plug a
little endian bus (PCI, ISA, ...) on a big endian machine.

The trick that some people didn't get a while ago is that while
accessors like inw/inl shall return a byteswapped data, string
operations like in insw/insl who are copying from a fifo basically to
memory (and opposite write versions) shall -not- byteswap since the data
isn't interpreted. it's a byte stream. It doesn't have any endian
semantic associated to it until it's actually read back from memory in
which case the appropriate endian swap (if any) has to be used depending
on the endianness and size of a given field read/written.

Since some people didn't get it, in the early days, some BE
architectures like ppc had versions of insw/insl that did byteswap,
which was wrong. The bits in this driver are remains from that era.

Note that to aggravate the problem, it still happens that HW engineers
try to be "smart" when hooking a 16 bits or 32 bits FIFO to a BE machine
and byteswap it in hardware. This is of course totally bogus but did
happen with IDE controllers typically (I think atari or amiga has one of
these, the Tivo is like that too, and a bunch of embedded  things). The
net result is that you have to pump the data fifo using a byteswapping
accessor and you cannot use DMA unless you DMA controller can re-swap
the other way around.... But lots of HW people still don't get it :) 

> However the existance of these PCI bridges these days? I haven't seen 
> one in years, and when I have nobody has ever enabled the magic swappy 
> thing as it's unreliable and can't always tell how you present the data.
> 
> One wishes that there was a ntoh and hton style macro in standard use 
> for PCI access.. hang on though that jsut wouldn't work would it.

Nah. We have the basic rule that readl/writel are little endian. PowerPC
additionally provides arch specific low level in_{be,le}32 type
accessors with explicit endianness. Or you can also use
cpu_to_le32/le32_to_cpu kind of macros to convert between native and
explicit endianness.

Ben.


