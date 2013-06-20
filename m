From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Adding support for ARINC429 into the Linux kernel
Date: Thu, 20 Jun 2013 10:52:53 +0200
Message-ID: <201306201052.53898.arnd@arndb.de>
References: <20130619202954.GA5594@roeck-us.net> <201306192345.31106.arnd@arndb.de> <20130620041001.GA1099@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130620041001.GA1099@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 20 June 2013, Guenter Roeck wrote:
> On Wed, Jun 19, 2013 at 11:45:30PM +0200, Arnd Bergmann wrote:
> > On Wednesday 19 June 2013, Guenter Roeck wrote:
> > 
> > Since this is a standard protocol, a driver that just supports a specific
> > chip (1a) would be the worst option IMHO.
> > 
> It would not be optimal, but straightforward and easy to implement.

The most important aspect would be the user interface: We should not
merge a driver that implements a character device (or something else)
in a way that would not be compatible with a general subsystem. I think
designing a generic interface is the hard part here, much more so than
implementing an abstraction layer.

> > A character device and a network protocol both sound reasonable, but
> > it really depends on the use cases:
> > 
> > * Does Linux act both as the sender and receiver, or do you want to
> >   support just one of the cases (which?)?
> > 
> Both, depending on the use case. Some of those are
> 
> 1) ACARS -
>    http://en.wikipedia.org/wiki/Aircraft_Communications_Addressing_and_Reporting_System
>    Rx and tx
> 
> 2) CIDS - Cabin Intercommunication Data System
>    Rx and tx
> 
> 3) IRS (Inertial Reference System) and FMS (Flight Management System)
>    Rx only

Ok, I see.

> > * Would you expect to always just transfer a single 32-bit word, or
> >   are there larger chunks of logically contigous data? What are typical
> >   and maximum sizes for those?
> > 
> The raw protocol is chunks of 32 bit (Logical Data Unit, or LDU), which
> the protocol refers to as 'physical layer'. Broadcast messages such as
> those from IRS and FMS use this format.
> 
> There is also bit-oriented data. The two protocols I am aware of are "Bit-
> Oriented File Transfer Protocol", and "Bit-Oriented Media Access Control
> (MAC) Protocol", which is supposed to be IEEE 802 compliant. Packet size
> is 3 to 255 LDUs for FTP and 3 to 1023 LDUs for the MAC protocol.
> Both include a SOF and EOF marker, so the actual data size would be 1-253
> or 1-1021 LDUs. Each LDU carries 20 bit, and partial words are possible
> in 4-bit increments, which means the data transfer size is 4 to 20,420 bit
> (2,552.5 bytes) for the MAC protocol, and 4 to 5,060 bit (632.5 bytes)
> for FTP.
> 
> Bit-oriented data is commonly used for ACARS and CIDS, where bi-directional
> communication is used.
> 
> Details are available in Specification ARINC-429P3-19-2009, sections 2.5 and 3.0.
> You should be able to find it on the web if you are interested.

Ok, this sounds like it would make a network type interface more
practical, at least for the 802 specific parts.

> > * Would you expect the kernel to filter for specific data on the
> >   receiver side?
> > 
> Each LDU has an 8-bit label. Applications listen for specific sets of labels.
> The chips have a configurable hardware filter; if there are not enough hardware
> filters, the kernel would have to do the filtering. Either case, the kernel
> has to select protocol receivers (sockets or open file descriptors) based
> on bind/registration information. For example, one aplication may register
> for label 1,3,5, and 7, and another for labels 1, 3, 12, and 14. So there can
> be overlaps.

Ok

> > * Would a user space receiver want to always see all data from one
> >   sender, or only the latest word?
> > 
> The receiver would want to receive all data for the labels it has registered
> for.
> 
> Hope this helps. Note that, at least as first step, I only envision to handle
> 4-byte units and pass those to/from user-space. Implementing the two link layer
> protocols would probably make sense, especially with the socket interface,
> but that would be a second step.

My vote would be for a new socket family for the low-level protocol,
with room for extension later to support the advanced features.

This should be one of the simplest socket implementations possible, if
you just need to send and receive 32 bit words, and can bind to a
a set of labels for rx as you described above.

The only possible concern I see with that interface is slightly higher
latency than what you would be able to get with a straight read/write
based character device.

	Arnd
