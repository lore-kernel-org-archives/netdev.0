From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: [PATCH 2/2] net: at91_ether.c - Allow transmitter interrupt to be handled first in ISR
Date: Wed, 13 Jan 2010 16:13:59 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD3674028974BF@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD367402897491@MAILSRV.intcomgrp.com> <4B4E0C2C.1000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server109j.appriver.com ([72.32.253.94]:1725 "EHLO
	server109.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756421Ab0AMVMQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 16:12:16 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B4E0C2C.1000101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
>From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-owner@vg=
er.kernel.org] On >Behalf Of Eric Dumazet
>Sent: Wednesday, January 13, 2010 1:09 PM
>To: James Kosin
>Cc: linux-kernel@vger.kernel.org; Linux Netdev List
>Subject: Re: [PATCH 2/2] net: at91_ether.c - Allow transmitter interru=
pt to be handled >first in ISR
>
>Le 13/01/2010 18:46, James Kosin a =E9crit :
>> Ok,
>>=20
>> This next patch is optional....
>>=20
>
>Are we sure chip doesnt report TUND forever in some situations ?
>Should'nt we have a retry limit for each skb ?
>

Directly from the documentation for the AT91RM9200 MAC registers:

=46or the transmitter status register:
* UND: Transmit Underrun
Set when transmit DMA was not able to read data from memory in time. If=
 this happens, the transmitter forces bad CRC.
Cleared by writing a one to this bit.

=46or the interrupt status register:
* TUND: Transmit Buffer Underrun
Ethernet transmit buffer underrun. The transmit DMA did not complete fe=
tch frame data in time for it to be transmitted.
Cleared on read.

In section 36.5.4.1

The transmit address register must be written before the transmit contr=
ol register. While a frame is being transmitted, it is possible to set =
up one other frame for transmission by writing new values to the transm=
it address and control registers. Reading the transmit address register=
 returns the address of the buffer currently being accessed by the tran=
smit FIFO.

This is where we may be able to exploit multiple transmit frames.
I'm not sure how to handle this in the confines of the kernel for this =
ARM part.  Currently, the architecture strictly limits the number of fr=
ames to (1) one only!  I'm not sure why; since there is no comment on t=
his in the source for the driver.  My only guess, is that the authors w=
here worried that if an error occurred on a frame they would not be abl=
e to determine which frame was effected by the error.

---


=46rom the AT91SAM9G20 MAC registers:

* UND: Transmit Underrun
Set when transmit DMA was not able to read data from memory, either bec=
ause the bus was not granted in time, because
a not OK hresp(bus error) was returned or because a used bit was read m=
idway through frame transmission. If this
occurs, the transmitter forces bad CRC. Cleared by writing a one to thi=
s bit.

* TUND: Ethernet Transmit Buffer Underrun
The transmit DMA did not fetch frame data in time for it to be transmit=
ted or hresp returned not OK. Also set if a used bit
is read mid-frame or when a new transmit queue pointer is written. Clea=
red on read.


The 91SAM9G20 MAC supports transmitter DMA queues; and I don't believe =
this driver should be used with that part; but, the descriptions on the=
 events causing the error are consistent.
The error should only happen if the MAC is unable to transfer the frame=
 from shared memory due to some situations where the processor or other=
 device is accessing the same memory area.  I'm also guessing if the sh=
ared memory area is in SDRAM instead of internal SRAM this could also b=
e caused by mandated SDRAM refresh cycles.

=3D=3D=3D=3D

Sorry about the patch submitting... it is really my first time and I'm =
in the process of installing Cygwin to be able to submit a more formal =
patch and to be able to verify the performance and particulars.  I'll g=
et the git tree ASAP; so, I can diff and compile against that.  Thanks =
for the tips on this.

I can attach the source file and copy you to look at, if you wish?

Thanks,
James
