From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100,
 xircom_tulip_cb, iph5526
Date: Thu, 27 Jan 2005 15:31:14 -0800
Message-ID: <20050127153114.72be03e2.davem@davemloft.net>
References: <41F952F4.7040804@pobox.com>
	<20050127225725.F3036@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        greg@kroah.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20050127225725.F3036@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 22:57:25 +0000
Russell King <rmk+lkml@arm.linux.org.uk> wrote:

> Has e100 actually been fixed to use the PCI DMA API correctly yet?

It seems to be doing the right thing.  I see the DMA sync calls
(properly using cpu vs. device syncing variants) at the right
spots, and the only thing the chip really relies upon is ordering
of visibility and this is achieved via a combination of cpu memory
barriers and the correct DMA sync calls.

For example, a pci_dma_sync_single_for_cpu() is always performed before
peeking at the descriptors at RX interrupt time (see e100_rx_indicate).

When new descriptors are written to, then linked into the chain it
memory barriers the cpu writes then DMA syncs the previous descriptor
to the device.  This is occuring in e100_alloc_skb().

Therefore the only missing sync would be of the new RX descriptor
when linking things in like that, ie. at the end of e100_rx_alloc_skb()
if rx->prev->skb is non-NULL.
