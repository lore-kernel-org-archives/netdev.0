From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 6/7] can: m_can: update to support CAN FD features
Date: Thu, 30 Oct 2014 21:32:49 +0100
Message-ID: <5452A071.2000307@hartkopp.net>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-6-git-send-email-b29396@freescale.com> <54513E38.4020703@hartkopp.net> <20141030024226.GA29572@shlinux1.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, mkl@pengutronix.de, wg@grandegger.com,
	varkabhadram@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20141030024226.GA29572@shlinux1.ap.freescale.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/30/2014 03:42 AM, Dong Aisheng wrote:
> On Wed, Oct 29, 2014 at 08:21:28PM +0100, Oliver Hartkopp wrote:

>> So first I would suggest to check the core release register (CREL) to be
>> version 3.0.x and quit the driver initialization if it doesn't fit this
>> version. I would suggest to provide a separate patch for that check. What
>> about printing the core release version into the kernel log at driver
>> initialization time?
>>
> 
> One question is that if v3.1.0 and v3.2.0 will be backward compatible with
> v3.0.1, if yes, how about let the driver still work for them instead of
> simply quit?

There are several important differences between 3.0.x and 3.1.x.
E.g. the CCCR, BTP, PSR and others are changed and a register for the
transmitter delay compensation is added.

I assume from 3.1.x to 3.2.x the controller registers will only change in
small details as the main update will be on the wire and not in the functionality.

> And then we can add new features according new released IP version.

Yes. We probably can wait for 3.[12].x to become available before adding the
special code that behaves according the core release register content.

>>> @@ -375,7 +414,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
>>>  		if (rxfs & RXFS_RFL)
>>>  			netdev_warn(dev, "Rx FIFO 0 Message Lost\n");
>>>  
>>> -		skb = alloc_can_skb(dev, &frame);
>>> +		skb = alloc_canfd_skb(dev, &frame);
>>
>> You are *always* allocating CAN FD frames now?
>>
> 
> Yes, currently it is.
> The test seemed ok using CAN FD frames even receive normal frame.

When you put CAN frame content into a CAN FD skb it becomes a CAN FD frame -
which is wrong.

CAN 2.0 frame (EDL is clear) -> alloc_can_skb()
CAN FD frame (EDL is set) -> alloc_canfd_skb()

You can have a CAN FD frame with a DLC of 8, which does *not* mean that you
have a CAN 2.0 frame.

> The issue i know is that candump seemed can not recognize remote frame reported
> by the driver.

Do you use the latest candump from

	https://gitorious.org/linux-can/can-utils/
??

The latest candump switches the CAN_RAW socket into the mode to accept both
CAN *and* CAN FD frames and displays the frames correctly.

> Not sure if it's caused by canfd_frame used.

Yes. CAN FD frames do not have a RTR bit.

> Will test and check.
> 
>> Depending on RX_BUF_EDL in the RX FIFO message you should create a CAN or CAN
>> FD frame.
>>
>> Of course you can use the struct canfd_frame in m_can_read_fifo() as the
>> layout of the struct can_frame is identical when filled with 'normal' CAN
>> frame content.
>>
>> But you need to distinguish whether it is a CAN or CAN FD frame when
>> allocating the skb based on the RX_BUF_EDL value.
>>
> 
> Yes, i think it's good to do that.
> One obvious benefit is it saves memory at least.

The main point is that CAN frames and CAN FD frames are separated by this
(MTU) length information. It's not about saving memory.
A CAN FD frame with DLC 8 still has 64 data bytes inside it's data structure.

Regards,
Oliver
