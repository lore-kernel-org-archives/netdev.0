From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Adding support for ARINC429 into the Linux kernel
Date: Wed, 19 Jun 2013 21:10:01 -0700
Message-ID: <20130620041001.GA1099@roeck-us.net>
References: <20130619202954.GA5594@roeck-us.net>
 <201306192345.31106.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201306192345.31106.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 11:45:30PM +0200, Arnd Bergmann wrote:
> On Wednesday 19 June 2013, Guenter Roeck wrote:
> > I have been asked to explore options for adding ARINC 429 support [1]
> > into the Linux kernel, primarily to support devices from Holt Integrated
> > Circuits [2] (the request is unrelated to the chip manufacturer).
> > 
> > ARINC429 is a protocol which is widely used in commercial airplanes. 
> > 
> > There are various chips supporting this protocol available, as well as
> > out-of-tree Linux support. The drivers I have looked at implement it
> > either as character device or misc device and typically pass raw receive
> > data to userspace.
> > 
> > I can see a number of options for going forward:
> > 1) Implement as character device (or possibly misc device) and pass
> >    raw data to/from user space
> >    1a) Just implement a driver for the specific chips
> >    2b) Implement some kind of generic infrastructure
> > 2) Implement as network driver with a new address family, similar to,
> >    say, AF_CAN.
> > 
> > Any thoughts / suggestions which approach would be better and, most of all,
> > which approach might have a better chance of being accepted upstream ?
> 
> Since this is a standard protocol, a driver that just supports a specific
> chip (1a) would be the worst option IMHO.
> 
It would not be optimal, but straightforward and easy to implement.

> A character device and a network protocol both sound reasonable, but
> it really depends on the use cases:
> 
> * Does Linux act both as the sender and receiver, or do you want to
>   support just one of the cases (which?)?
> 
Both, depending on the use case. Some of those are

1) ACARS -
   http://en.wikipedia.org/wiki/Aircraft_Communications_Addressing_and_Reporting_System
   Rx and tx

2) CIDS - Cabin Intercommunication Data System
   Rx and tx

3) IRS (Inertial Reference System) and FMS (Flight Management System)
   Rx only

> * Would you expect to always just transfer a single 32-bit word, or
>   are there larger chunks of logically contigous data? What are typical
>   and maximum sizes for those?
> 
The raw protocol is chunks of 32 bit (Logical Data Unit, or LDU), which
the protocol refers to as 'physical layer'. Broadcast messages such as
those from IRS and FMS use this format.

There is also bit-oriented data. The two protocols I am aware of are "Bit-
Oriented File Transfer Protocol", and "Bit-Oriented Media Access Control
(MAC) Protocol", which is supposed to be IEEE 802 compliant. Packet size
is 3 to 255 LDUs for FTP and 3 to 1023 LDUs for the MAC protocol.
Both include a SOF and EOF marker, so the actual data size would be 1-253
or 1-1021 LDUs. Each LDU carries 20 bit, and partial words are possible
in 4-bit increments, which means the data transfer size is 4 to 20,420 bit
(2,552.5 bytes) for the MAC protocol, and 4 to 5,060 bit (632.5 bytes)
for FTP.

Bit-oriented data is commonly used for ACARS and CIDS, where bi-directional
communication is used.

Details are available in Specification ARINC-429P3-19-2009, sections 2.5 and 3.0.
You should be able to find it on the web if you are interested.

> * Would you expect the kernel to filter for specific data on the
>   receiver side?
> 
Each LDU has an 8-bit label. Applications listen for specific sets of labels.
The chips have a configurable hardware filter; if there are not enough hardware
filters, the kernel would have to do the filtering. Either case, the kernel
has to select protocol receivers (sockets or open file descriptors) based
on bind/registration information. For example, one aplication may register
for label 1,3,5, and 7, and another for labels 1, 3, 12, and 14. So there can
be overlaps.

> * Would a user space receiver want to always see all data from one
>   sender, or only the latest word?
> 
The receiver would want to receive all data for the labels it has registered
for.

Hope this helps. Note that, at least as first step, I only envision to handle
4-byte units and pass those to/from user-space. Implementing the two link layer
protocols would probably make sense, especially with the socket interface,
but that would be a second step.

Thanks,
Guenter
