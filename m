From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 16:38:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031163843.6bcf4ca4.shemminger@osdl.org>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	<1067635446.11564.92.camel@localhost.localdomain>
	<20031031213159.GO3705@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20031031213159.GO3705@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Okay, here is the standard: (Inside Appletalk)

> The DDP checksum is provided to detect errors caused by faulty operation (such as memor
> data bus errors) within routers on the internet. Implementers of DDP should treat generati
> the checksum as an optional feature. The 16-bit DDP checksum is computed as follows:
> CkSum := 0 ;
> FOR each datagram byte starting with the byte immediately following th
> Checksum field
> REPEAT the following algorithm:
>           CkSum := CkSum + byte; (unsigned addition)
>           Rotate CkSum left one bit, rotating the most significant bit in
>                               least significant bit;
> IF, at the end, CkSum = 0 THEN
>           CkSum := $FFFF (all ones).
> Reception of a datagram with CkSum equal to 0 implies that a checksum is not performed.


Here is the old loop:

	while (len--) {
		sum += *data;
		sum <<=1;
		if (sum & 0x10000) {
			sum++;
			sum &= 0xffff;
		}
		data++;
	}

My buggy loop is:

	while (len--) {
		sum += *data++;
		sum <<= 1;
		sum = ((sum >> 16) + sum) & 0xFFFF;
	}

The problem is the carry from the first addition needs to be dropped
not folded back (like IP).  

Corrected fast code is:

	while (len--) {
		sum += *data++;
		sum <<= 1;
		sum = (((sum & 0x10000) >> 16) + sum) & 0xffff;
	}

At least it is correct on the standalone random data test, and the
new code is 30% faster for the cached memory case (13.7 clks/byte vs 18 clks/byte).
