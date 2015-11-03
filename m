From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 03 Nov 2015 22:24:23 +0100
Message-ID: <56392607.5060200@hartkopp.net>
References: <1446419775-5215-1-git-send-email-marex@denx.de>   <201511021916.18117.marex@denx.de>  <666821254.20151102231521@cogentembedded.com>  <201511022125.47892.marex@denx.de>  <CAAP7uc+3sJRJ9khC6x58ULy2vR8fTCi6gMwtgV_0GAWW49AwLg@mail.gmail.com>  <56389C38.4080508@pengutronix.de>  <CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>  <5638CF74.7030001@pengutronix.de>  <CAAP7ucKWT++AbPPA2kvm965JSjsgCm0OMf0-Vnjwe-ck+xjZZQ@mail.gmail.com>  <5638EF9C.9070503@hartkopp.net> <814845359.20151103232627@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Marek Vasut <marex@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:16135 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304AbbKCVY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:24:29 -0500
In-Reply-To: <814845359.20151103232627@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrey,

On 11/03/2015 09:26 PM, Vostrikov Andrey wrote:
> Hi, Oliver.
> 
>> So when thinking about using PF_CAN as ARINC429 base ...
> 
>> This is the CAN frame structure:
> 
>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/Documentation/networking/can.txt?h=linux-4.2.y#n264
> 
>>     struct can_frame {
>>             canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
>>             __u8    can_dlc; /* frame payload length in byte (0 .. 8) */
>>             __u8    __pad;   /* padding */
>>             __u8    __res0;  /* reserved / padding */
>>             __u8    __res1;  /* reserved / padding */
>>             __u8    data[8] __attribute__((aligned(8)));
>>     };
> 
> 
>> So what about defining an arinc429_frame like this:
> 
>>     struct a429_frame {
>>             __u32   label;   /* ARINC 429 label */
>>             __u8    length;  /* always set to 3 */
>>             __u8    __pad;   /* padding */
>>             __u8    __res0;  /* reserved / padding */
>>             __u8    __res1;  /* reserved / padding */
>>             __u8    data[8] __attribute__((aligned(8)));
>>     };
> What  would  be  the  benefit  besides  reusing  CAN tools to have
> arinc429 frame structure four times larger that it needs to be?

Comparing to typical ethernet frames with 1500 bytes the 16 bytes for CAN
frames or 72 bytes for CAN FD frames are already too small in relation to the
socket buffer overhead.

If you want to improve the memory efficiency for arinc290 you should probably
consider to implement a character device based driver instead of creating a
new network protocol family.

> It just adds complexity to implement translation in device driver from
> can-like  structures  to  native  4-bytes message. Similar translation
> will be needed in application as well.

That's BS. You put the data into a struct a429_frame at driver level and you
read the data from struct a429_frame on application level.

Where is the 'translation'?

You would need to do the same with every other data structure in the world too.

> There   is   no   real   processing  needed for ARINC429 frames inside
> framework. Almost all features  are  done  by  HW  itself  (label  filters,
> label  priority matching,   label   bit  flipping,  rate  selection,  parity
> and  sdi decoding) or by application.

>From what I've read so far there's also the sending of cyclic messages and
label filtering outside the HW - or why did you copy/paste the can_id/label
filter mechanism from af_can.c ?

> I'd  prefer to have ARINC framework simple as it could be and separate
> from  CAN,  as  these  buses are not similar, besides desire to re-use
> SocketCAN interface/API to expose ARINC429 bus.

>From what I've seen so far the ARINC429 requirements can be handled with the
PF_CAN infrastructure only by defining a matching data structure and by adding
some arinc device specific configuration interface.

The latter is probably completely independent from the current CAN netlink
interface for configuration.

But the suggested arinc429 stuff for the network layer looks just like a
needless code duplication.
Maybe you don't need that fancy stuff that comes with PF_CAN. Did you ever
thought about implementing a chardev driver for the ARINC429 hardware? There
are out-of-tree CAN drivers (e.g. can4linux or PEAK System Linux driver) that
handle the transfer of data structures (CAN frames) from/to kernel space via
character device. See an example at https://en.wikipedia.org/wiki/Can4linux

Best regards,
Oliver
