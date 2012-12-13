From: Ulf Samuelsson <netdev@emagii.com>
Subject: RFC: Launch Time Support
Date: Thu, 13 Dec 2012 02:04:12 +0100
Message-ID: <50C9298C.1080600@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b21.telenor.se ([195.54.99.212]:40031 "EHLO
	smtprelay-b21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab2LMBXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 20:23:44 -0500
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-b21.telenor.se (Postfix) with ESMTP id 73B56C1D1
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2012 02:04:14 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, I am looking for some feedback on how to implement launchtime
in the kernel.

I.E: You define WHEN you want to send a packet,
and the driver will store the packet in a buffer and will send it out
on the net when the internal timestamp counter in the network controller
reaches the specified "launch time".

Some Ethernet controllers like the new Intel i210 support "launch time",

Support for launch time is desirable for any isochronous connection,
but I am currently interested in the NTP protocol to improve the timing.

Proposed Changes to the Kernel
===========================================================
The launchtime support will be dependent on CONFIG_NET_LAUNCHTIME
If this is not set, then the kernel functionality is not changed.

My current idea is to add a new bit to the "flags" field of 
"socket.c:sendto"
#define MSG_LAUNCHTIME 0x?????

struct msghdr gets an additional launchtime field.

sendto will check if the flags parameter contains MSG_LAUNCHTIME.
If it does, then the first 64 bit longword of the packet (buff) contains 
the launchtime.
The launchtime from the buffer is copied to the msghdr.launchtime field,
and the first 64 bits of the packet is then shaved off, before the address
is written to the msghdr.

Each network controller supporting launchtime needs to have an alternative
call to "send packet with launchtime" . This call adds the launchtime 
parameter.
If launchtime is supported the exported "ops" includes the new call.

The UDP/IP packet send will check the MSG_LAUNCHTIME and
if set, it will check if the "send packet with launchtime" call
is available for the driver and if so call it, otherwise it will call
the normal send packet and thus ignore the launchtime.

Before launchtime is used, the application should send an ioctl
to the driver, making sure that launchtime is configured,
and only if the driver ACKs , the application will use launchtime.

(Possibly the "ops" field for "send packet with launchtime" should be
NULL until that ioctl is complete. Comments?)

To me, this seems to be transparent for all other network stacks
so protocols and drivers not supporting launchtime should still work.

As far as I know, drivers do not support launch time today.
The Intel igb driver does not in the latest version on the intel web site,
There are some defines headers in the latest version  defining the registers
but so far, the code is not using it.

There is the linux_igb_avb project on sourceforge which  allows use of
launch time for user space applications, but not as part of the kernel.

Maybe there is more work done somewhere else, but i am not aware
of this, so any links to such work is appreciated.

There are some FPGA based PCIe boards that support launchtime (Endace DAG)
using proprietary APIs.
Talked to some vendors providing TCP/IP offload engines for FPGA
and they do not support launchtime and liuke Endace use proprietary APIs
so they are only useable by custom programs. Normal networking interfaces
are not supported.

Comment on above is appreciated.

BACKGROUND
For those that do not know how the NTP protocol works:
===================================================
The client sends an UDP packet to the NTP server using port 123
The NTP client reads the current systime and puts that in the outgoing 
packet.
There is a delay between the time the systime is read, and the time
the packet actually leaves the Ethernet controller adding jitter to the
NTP algorithm.

When the server receives the packet, it can be timestamped in H/W
and a CMSG is then created by the network stack containing that
timestamp for use by the server NTP daemon.

The server generates a reply, which needs to include the client
transmit time, the servers receive time, and the servers transmit time.
Again, the transmit time needs to be written into the NTP packet,
and then it needs to be processed through the network stack before it is
leaving the ethernet controller causing more jitter.

If launch time is supported, then the client NTP daemon would simply
read the systime, add a constant delay to create the transmit timestamp.
The delay needs to be sufficiently large to ensure that all processing 
is done,

The server will do something similar adding a constant to the server 
receive timestamp
to create the server transmit timestamp.
If both the client and the server uses H/W timestamping and launch time,
then the the jitter ideally is reduced to zero.

TRANSMIT TIMESTAMPING
========================
Support for TX timestamps in H/W is not really useful, since you need to 
provide
the TX timestamp in the packet you measure on, so when you know the 
timestamp
it is too late. Server to server  NTP connections support sending that 
timestamp
in a new packet, but there is no such support in client server 
communication.

The i210 supports putting the timestamp inside the packet as it leaves the
Ethernet controller, but that means that you screw up the UDP checksum, so
the packet will be rejected by the receiving NTP daemon.
In addition, the i210 timestamp measures seconds and nanoseconds
which is incompatible with the NTP timestamp which uses seconds
and a 32 bit fraction of a second so that does not work either.

Best Regards
Ulf Samuelsson
eMagii.
