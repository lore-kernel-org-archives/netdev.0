From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-2.6] can: Fix data length code handling in rx path
Date: Sat, 12 Dec 2009 19:06:20 +0100
Message-ID: <4B23DB9C.8020607@grandegger.com>
References: <4B23A501.9000208@hartkopp.net> <4B23C602.7050302@grandegger.com> <4B23D4CE.30005@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Barry Song <21cnbao@gmail.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42697 "HELO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932980AbZLMBSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2009 20:18:11 -0500
In-Reply-To: <4B23D4CE.30005@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> Wolfgang Grandegger wrote:
>> Hi Oliver,
>>
>> Oliver Hartkopp wrote:
>>> A valid CAN dataframe can have a data length code (DLC) of 0 .. 8 data bytes.
>>>
>>> When reading the CAN controllers register the 4-bit value may contain values
>>> from 0 .. 15 which may exceed the reserved space in the socket buffer!
>>>
>>> The ISO 11898-1 Chapter 8.4.2.3 (DLC field) says that register values > 8
>>> should be reduced to 8 without any error reporting or frame drop.
>>>
>>> This patch introduces a new helper macro to cast a given 4-bit data length
>>> code (dlc) to __u8 and ensure the DLC value to be max. 8 bytes.
>>>
>>> The different handlings in the rx path of the CAN netdevice drivers are fixed.
>>>
>>> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
>> Please send you patches inline next time please. For the bfin_can and
>> the ems_usb driver your patch now masks the dlc with 0xf. Are you sure
>> this is needed or even correct?
> 
> Yes. Both needed to be fixed.
> 
> The bfin_can has an u16 value which is not reduced to 4-bits before.

The relevant bits are hardware specific.

> The ems_usb driver gets a u8 value via USB urb, which comes from a SJA1000 and
> needs the same handling as in the sja1000 driver. There's no guarantee that
> the USB adapter handles the values correctly - so masking is appropriate here.
> 
>> Also, s/__u8/u8/, please.
> 
> can_frame.can_dlc is the target and it is defined as '__u8' in
> include/linux/can.h.

OK.

> As discussed on SocketCAN-ML we agreed the at91_can.c to be the 'correct'
> implementation - and that's what i posted here on your request ... :-)

The spoke about how to handle "dlc > 8". The additional masking is
hardware specific and you need to check the manual to understand if it's
really required.

> IMO the patch remains 100% correct.

I just checked the bfin manual. The DLC value uses a 4 bit field and
there is also written:

 "Any DLC value greater than 8 is treated the same as a value of 8."

That's exactly what this patch fixes. I didn't figure out though, if the
masking is really required or if the higher bits are undefined (or "0").
At least it does not harm.

Wolfgang.

