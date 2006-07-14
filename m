From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Fri, 14 Jul 2006 11:24:38 -0400
Message-ID: <200607141524.k6EFOcS0025630@cmf.nrl.navy.mil>
References: <20060713.134735.23014475.davem@davemloft.net>
Reply-To: chas3@users.sourceforge.net
Cc: hch@lst.de, shemminger@osdl.org, netdev@vger.kernel.org,
	support@pathscale.com, samuel@sortiz.org, kkeil@suse.de,
	kai.germaschewski@gmx.de, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.12.161]:50393 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161121AbWGNP0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 11:26:42 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060713.134735.23014475.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <20060713.134735.23014475.davem@davemloft.net>,David Miller writes:
>From: Christoph Hellwig <hch@lst.de>
>Date: Thu, 13 Jul 2006 22:36:16 +0200
>>  - drivers/atm/{idt77252.c, nicstar.c}, drivers/usb/atm/usbatm.c:
>> 	These use private skb queues and do odd things.  I can't see
>> 	any point for using dev_alloc_skb with it's additional headroom
>> 	reservation here.

as i recall, for simple rfc1483 encapsulation, the LLC/SNAP header of 8
bytes needs to be replaced by an ether header of 14 bytes.  its likely
this is the reason dev_alloc_skb() is used.  most of the other drivers
use atm_alloc_charge() which does a skb_reserve(), but these drivers
dont dma directly into a skb.

>Any of these cases that DMA into the skb allocated will need
>the headroom, as explained by the PowerPC folks.

this only works for "ordinary" ip traffic (which i admit is the most
common case).  but since the nicstar/idt77252 devices have a peak
speed of 155Mb/s i doubt they would suffer much.  considering they still
use virt_to_bus/bus_to_virt i would be a bit surprised if they worked
(atleast on ppc64).  they can be simply converted to alloc_skb() and
manually skb_reserve() a little overhead.

usbatm should probably be converted to use atm_alloc_charge() since
the vcc is known at this point unlike the nicstar/idt77252 case.
