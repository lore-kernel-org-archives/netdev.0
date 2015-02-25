From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 16:19:45 +0100
Message-ID: <20150225151945.GB7703@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 04:48:08PM +0000, Stathis Voukelatos wrote:
> This patch adds support for the Ethernet Packet Sniffer H/W module
> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
> The module allows Ethernet packets to be parsed, matched against
> a user-defined pattern and timestamped. It sits between a 100M
> Ethernet MAC and PHY and is completely passive with respect to
> Ethernet frames.

First off, please stop calling this device a "sniffer".  Real sniffers
are able to deliver whole frames.  Real sniffers are most commonly
used to inspect traffic between two or more nodes, but from a third
host.

Instead, this device really is a time stamping unit with a
programmable frame matching engine.  So, the approach of this driver
is totally wrong.  It runs contrary to how time stamping is handled in
the kernel.

- This driver delivers time stamps "out of band" from a separate
  interface.  The other kernel drivers deliver time stamps "in band",
  using the same socket from the requesting process.

- This driver requires user space to match time stamps with packets.
  The other kernel drivers perform the matching automatically.

- This driver requires user space to program a vendor specific
  matching engine.  The other kernel drivers program their matching
  engines automatically.

Let me suggest another approach that stays in line with the existing
frame work.  Based on the device's limitations and your own example,
it seems clear that the intended use case is synchronization for AVB
applications using gPTP.

Your time stamping unit is conceptually the same a PHY with hardware
time stamping, and you should treat it as such.  This means using the
CONFIG_NETWORK_PHY_TIMESTAMPING kernel option.  There is one mainline
PHY driver as an example, dp83640.c.

You will have to hard code command strings in the driver, one for each
of the SIOCSHWTSTAMP filter types that you want to support.  I would
recommend supporting just HWTSTAMP_FILTER_PTP_V2_EVENT.  You will
probably need different filters for L2, IPv4, and IPv6, with and
without VLAN.  For the transmit case, you can limit the match to PTP
events as well.  Your filters should at least return the sequenceId
and the messageType back to the driver.

The only (small) difficulty I can see would be how to arrange for your
driver to be called back just like a PHY driver would be.  We might
need to adapt or expand the internal PHY timestamping framework within
the kernel, but if you are willing to rework your driver, then I can
help with that part.

Thanks,
Richard
