From: Anton Blanchard <anton@samba.org>
Subject: alignment of SKBs
Date: Tue, 11 Mar 2003 14:29:50 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030311032950.GB1132@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

Linux likes to align TCP/IP headers for the benefit of the CPU. No
problems there. However, especially with gigabit, it is important to try
and minimise the number of PCI transactions.

As an example, the e1000 driver currently starts most transmit packets
14 bytes from the start of a cacheline and all receive packets 18 bytes
from the start of a cacheline. On ppc64 this is going to be expensive on
the PCI bus, especially for DMA writes as we work our way up to
cacheline aligment.

Unaligned loads and stores on the headers should be reasonably quick
on recent ppc64 machines, so the tradeoff is definitely towards
optimising for the PCI bus. Unfortunately we cant do anything about it
because skb_reserve() is used everywhere. Perhaps if we had another
macro (skb_align?) we could override it on a per arch basis.

While the receive side is easy to fix (modify the skb_reserve in the
e1000 and dev_skb_alloc routines), the transmit side is more difficult.
Luckily DMA reads tend to be less of an issue. 

>From my reading of the code, on transmits we copy the data in before we
put the TCP header together. I guess we could arrange things so that the
common case would fall on a cacheline boundary and the uncommon case
would overflow into the cacheline before.

Anton
