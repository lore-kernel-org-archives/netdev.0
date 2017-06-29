From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: CAN-FD Transceiver Limitations
Date: Thu, 29 Jun 2017 09:49:35 -0500
Message-ID: <5d4f2bcf-bd0f-4fa1-5d5a-d7b4a83cbc5e@ti.com>
References: <de1f6343-4b28-4a5f-c6df-4e54c09fcce2@ti.com>
 <20170629142142.GF9244@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170629142142.GF9244@lunn.ch>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

On 06/29/2017 09:21 AM, Andrew Lunn wrote:
> On Wed, Jun 28, 2017 at 05:14:42PM -0500, Franklin S Cooper Jr wrote:
>> Hi All,
>>
>> The various CAN transceivers I've seen that support CAN-FD appear to be
>> fairly limited in terms of their supported max speed. I've seen some
>> transceivers that only support upto 2 Mbps while others support up to  5
>> Mbps. This is a problem when the SoC's CAN IP can support even higher
>> values than the transceiver.
>>
>> Ideally I would think the MCAN driver should at the very least know what
>> the maximum speed supported by the transceiver it is connected to.
>> Therefore, either throwing an error if a request for a speed above the
>> transceiver capability or lower the requested speed to what ever the
>> transceiver is capability of doing.
> 
> Hi Franklin
> 
>> In either case I do not know if it makes sense to add a DT property
>> within the MCAN driver or create another subnode that contains this
>> information. For example I see some ethernet drivers support
>> "fixed-link" subnode which is trying to solve a similar issue.
> 
> Hi Franklin
> 
> I would say fixed-link is trying to solve a different issue. You use
> fixed-link when you don't have a PHY connected to the Ethernet MAC. A
> MAC driver will normally tell the PHY driver what speeds its supports,
> and ask the PHY to negotiate a speed both the MAC and PHY supports
> with the peer device. The MAC then gets told of the resulting speed.
> If this PHY does not exist, you cannot ask it to perform auto-neg, you
> have no idea what the peer is capable of. Hence you add a virtual PHY
> using fixed-link, which always returns the same speed. This works
> because if you don't have a PHY, the MAC is generally connected to
> another MAC on the same board, typically an Ethernet switch. Hence the
> speed is a board property and fixed.
> 
> You appear to have a different issue. I don't know the CAN
> subsystem. Is the transceiver part of the model? Is there an API
> between the CAN-MAC and the CAN-transceiver? It sounds like you need
> to add an API call from the MAC driver to the transceiver driver to
> ask it what it is capable of. I don't see this as being a DT property.
> The transceiver should know its own capabilities. And you have to
> think about non-DT systems, e.g. CAN devices on USB dongles.

Transceivers for CAN are not apart of any model. Traditional CAN didn't
have a problem because all transceivers from my understanding supported
the maximum speed of 1 Mbps defined by the spec. However, with the
introduction of CAN Flexible Datarate mode it seems that for
transceivers that supported CAN-FD the maximum supported speeds vary.

Unfortunately, their is no way to communicate with the transceiver to
understand its capabilities. You don't program it or configure a
transceiver. It simply has a fixed configuration. Now that I think of it
you also can't determine if the transceiver supports CAN-FD in the first
place. IP that supports CAN-FD is backwards compatible with standard
CAN. Therefore, its feasible that you may even use a transceiver that
doesn't support CAN-FD. So I would think something like the below would
be needed.

mcan@0 {
	...
	fixed-transceiver {
	      max-canfd-speed = <2000>
	};
	...
};

So the mcan driver can then check for this subnode and if found read in
the max canfd speed that is supported. A value of 0 could be used to
indicate that CAN-FD isn't supported by the transceiver.
> 
>       Andrew
> 
