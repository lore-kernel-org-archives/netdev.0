From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [ANN] removal of certain net drivers coming soon: eepro100, xircom_tulip_cb, iph5526
Date: Thu, 27 Jan 2005 22:57:25 +0000
Message-ID: <20050127225725.F3036@flint.arm.linux.org.uk>
References: <41F952F4.7040804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Netdev <netdev@oss.sgi.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41F952F4.7040804@pobox.com>; from jgarzik@pobox.com on Thu, Jan 27, 2005 at 03:45:40PM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 03:45:40PM -0500, Jeff Garzik wrote:
> 3) eepro100
> 
> Unmaintained; users should use e100.
> 
> When I last mentioned eepro100 was going away, I got a few private 
> emails saying complaining about issues not yet taken care of in e100. 
> eepro100 will not be removed until these issues are resolved.

Has e100 actually been fixed to use the PCI DMA API correctly yet?
Looking at it, it doesn't look like it, so until it does, eepro100
is the far better bet for platforms needing working DMA API.

What I'm talking about is e100's apparant belief that it can modify
rfd's in the receive ring on a non-cache coherent architecture and
expect the data around it to remain unaffected (see e100_rx_alloc_skb):

struct rfd {
        u16 status;
        u16 command;
        u32 link;
        u32 rbd;
        u16 actual_size;
        u16 size;
};

it touches command and link.  This means that the whole rfd plus
maybe the following or preceding 16 bytes get loaded into a cache
line (assuming cache lines of 32 bytes), and that data written
out again at sync.  However, it does this on what seems to be an
active receive chain.

So, both the CPU _and_ the device own the same data.  Which is a
violation of the DMA API.

So, eepro100 works.  e100 is a dead loss for non-cache coherent
architectures.  Therefore, I say eepro100 stays until e100 is
fixed.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
