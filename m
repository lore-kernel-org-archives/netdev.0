From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 22:41:09 +0100
Message-ID: <201511032241.09913.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <814845359.20151103232627@cogentembedded.com> <56392607.5060200@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:54733 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754871AbbKCVlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:41:19 -0500
In-Reply-To: <56392607.5060200@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 10:24:23 PM, Oliver Hartkopp wrote:
> Hi Andrey,
> 
> On 11/03/2015 09:26 PM, Vostrikov Andrey wrote:
> > Hi, Oliver.
> > 
> >> So when thinking about using PF_CAN as ARINC429 base ...
> >> 
> >> This is the CAN frame structure:
> >> 
> >> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tre
> >> e/Documentation/networking/can.txt?h=linux-4.2.y#n264
> >> 
> >>     struct can_frame {
> >>     
> >>             canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
> >>             __u8    can_dlc; /* frame payload length in byte (0 .. 8) */
> >>             __u8    __pad;   /* padding */
> >>             __u8    __res0;  /* reserved / padding */
> >>             __u8    __res1;  /* reserved / padding */
> >>             __u8    data[8] __attribute__((aligned(8)));
> >>     
> >>     };
> >> 
> >> So what about defining an arinc429_frame like this:
> >>     struct a429_frame {
> >>     
> >>             __u32   label;   /* ARINC 429 label */
> >>             __u8    length;  /* always set to 3 */
> >>             __u8    __pad;   /* padding */
> >>             __u8    __res0;  /* reserved / padding */
> >>             __u8    __res1;  /* reserved / padding */
> >>             __u8    data[8] __attribute__((aligned(8)));
> >>     
> >>     };
> > 
> > What  would  be  the  benefit  besides  reusing  CAN tools to have
> > arinc429 frame structure four times larger that it needs to be?
> 
> Comparing to typical ethernet frames with 1500 bytes the 16 bytes for CAN
> frames or 72 bytes for CAN FD frames are already too small in relation to
> the socket buffer overhead.
> 
> If you want to improve the memory efficiency for arinc290 you should
> probably consider to implement a character device based driver instead of
> creating a new network protocol family.

See discussion:

http://comments.gmane.org/gmane.linux.kernel/1512019

Which is why I picked the socket variant.

> > It just adds complexity to implement translation in device driver from
> > can-like  structures  to  native  4-bytes message. Similar translation
> > will be needed in application as well.
> 
> That's BS. You put the data into a struct a429_frame at driver level and
> you read the data from struct a429_frame on application level.
> 
> Where is the 'translation'?
> 
> You would need to do the same with every other data structure in the world
> too.
> 
> > There   is   no   real   processing  needed for ARINC429 frames inside
> > framework. Almost all features  are  done  by  HW  itself  (label 
> > filters, label  priority matching,   label   bit  flipping,  rate 
> > selection,  parity and  sdi decoding) or by application.
> 
> From what I've read so far there's also the sending of cyclic messages and
> label filtering outside the HW - or why did you copy/paste the can_id/label
> filter mechanism from af_can.c ?

I think you might be mixing two people together here, I sent the patch and
Andrey and Aleksander are working for some other interested company.

The label filtering makes sense if you want to separate what you receive on 
which socket in userland, which allows an application to receive only relevant 
traffic.

Hardware-accelerated filtering is another thing and at this point, we should
not mix these two things. Does CAN framework have any such support for hardware
assisted can_id filtering btw ?

> > I'd  prefer to have ARINC framework simple as it could be and separate
> > from  CAN,  as  these  buses are not similar, besides desire to re-use
> > SocketCAN interface/API to expose ARINC429 bus.
> 
> From what I've seen so far the ARINC429 requirements can be handled with
> the PF_CAN infrastructure only by defining a matching data structure and
> by adding some arinc device specific configuration interface.
> 
> The latter is probably completely independent from the current CAN netlink
> interface for configuration.

Right.

> But the suggested arinc429 stuff for the network layer looks just like a
> needless code duplication.

Yes.

> Maybe you don't need that fancy stuff that comes with PF_CAN. Did you ever
> thought about implementing a chardev driver for the ARINC429 hardware?
> There are out-of-tree CAN drivers (e.g. can4linux or PEAK System Linux
> driver) that handle the transfer of data structures (CAN frames) from/to
> kernel space via character device. See an example at
> https://en.wikipedia.org/wiki/Can4linux

I guess I can answer that -- yes, I did, see above.
