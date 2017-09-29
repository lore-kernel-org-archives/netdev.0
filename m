From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 18:24:36 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4112CB89@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928193416.GH14940@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
 <20170929121201.GD19710@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <andrew@lunn.ch>, <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929121201.GD19710@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The actual SPI access performance will depend on the SPI host controller.
The SPI access speed, ranging from 12 MHz to 50 MHz depending on the
chip, is a factor but the performance of the SPI host controller is more
important.  Generally the SPI host controller scales down the clock by a
factor of 2.  So if the maximum 50 Mhz does not work for the chip the next
speed is 25 Mhz.  Most of the SPI host controllers work in range of 20-30 Mhz
with Microchip SPI switches.

For example, Raspberry Pi 2 has 2 SPI host controllers.  The new code uses the
newer host controller which has better performance even when running in
slower SPI speed.

It is hard to measure the actual SPI performance of the switch, but for SPI
Ethernet controller the performance can be viewed by running throughput test
as SPI is responsible for passing network frames between system and device.

The ODROID C1 (A Raspberry Pi like SoC) has the best SPI performance, even not
running in the highest SPI speed.

Typical SPI register read takes about 120 microseconds.

Now back to my concern about SPI access.  It is not accessible in interrupt context.
Even in a timer callback a work queue has to be scheduled to program the hardware
registers.  My concern is if a task is already running with SPI access to a lot of registers
like reading the 32 MIB counters in every port of the switch, another register access
has to wait until they are finished.  This normally does not pose a problem in
regular switch operation, but there are some situations it will create a problem.

One of the situations is running RSTP Conformance Test.  The test case sends a BPDU
to open/close the port and then send traffic to test if the port is really opened/closed.
For software implementation which receives the BPDU and all network traffic it is
reasonable to expect the software opens/closes the port and then can regulate the
network traffic whatever it wants, but for a hardware implementation which programs
a register to open/close the port then it is critical this register write can be executed as
soon as possible.

Another situation is getting the PTP transmit timestamp of a PTP event message.
The Microchip PTP switch uses registers to store the Sync, Delay_Req, and Pdelay_Resp
timestamps.  If this register is not read as soon as possible and another message of the
same type is sent, the last timestamp is lost.  Software can regulate the sending of
these messages and this situation does not happen in normal operation.  But in a stress
test this PTP operation definitely cannot handle it.

I know this MIB counter reading implementation cannot guarantee those urgent register
access to happen promptly, but it minimizes the chance of blocking those accesses in normal
operation.


> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Friday, September 29, 2017 5:12 AM
> To: David Laight
> Cc: Tristram Ha - C24268; muvarov@gmail.com; pavel@ucw.cz;
> nathan.leigh.conrad@gmail.com; vivien.didelot@savoirfairelinux.com;
> f.fainelli@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Woojung Huh - C21699
> Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
> 
> On Fri, Sep 29, 2017 at 09:14:26AM +0000, David Laight wrote:
> > From: Andrew Lunn
> > > Sent: 28 September 2017 20:34
> > ...
> > > > There are 34 counters.  In normal case using generic bus I/O or PCI to
> read them
> > > > is very quick, but the switch is mostly accessed using SPI, or even I2C.
> As the SPI
> > > > access is very slow.
> > >
> > > How slow is it? The Marvell switches all use MDIO. It is probably a
> > > bit faster than I2C, but it is a lot slower than MMIO or PCI.
> > >
> > > ethtool -S lan0 takes about 25ms.
> >
> > Is the SPI access software bit-banged?
> 
> That will depend on the board design. I've used mdio bit banging, and
> that was painfully slow for stats.
> 
> But we should primarily think about average hardware. It is going to
> have hardware SPI or I2C. If statistics reading with hardware I2C is
> reasonable, i would avoid caching, and just ensure other accesses are
> permitted between individual statistic reads.
> 
> It also requires Microchip also post new code. They have been very
> silent for quite a while....
> 
> 	  Andrew
