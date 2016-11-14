From: Sebastian Frias <sf84@laposte.net>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 14:03:59 +0100
Message-ID: <5829B63F.9050306@laposte.net>
References: <5827AD4A.7010908@free.fr> <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr> <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Florian Fainelli <f.fainelli@gmail.com>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz29.laposte.net ([194.117.213.104]:56492 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933542AbcKNNEE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 08:04:04 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout017 (Postfix) with ESMTP id 3D5BCA020BF
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:04:02 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout017 (Postfix) with ESMTP id 2F534A047B5
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:04:02 +0100 (CET)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
        by lpn-prd-vrout017 (Postfix) with ESMTP id 23724A020BF
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:04:02 +0100 (CET)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
        by lpn-prd-vrin001 (Postfix) with ESMTP id 0AFE4366D7E
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 14:04:02 +0100 (CET)
In-Reply-To: <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2016 08:55 PM, Florian Fainelli wrote:
> Le 13/11/2016 à 11:51, Mason a écrit :
>> On 13/11/2016 04:09, Andrew Lunn wrote:
>>
>>> Mason wrote:
>>>
>>>> When connected to a Gigabit switch
>>>> 3.4 negotiates a LAN DHCP setup instantly
>>>> 4.7 requires over 5 seconds to do so
>>>
>>> When you run tcpdump on the DHCP server, are you noticing the first
>>> request is missing?
>>>
>>> What can happen is the dhclient gets started immediately and sends out
>>> its first request before auto-negotiation has finished. So this first packet
>>> gets lost. The retransmit after a few seconds is then successful.
>>
>> I will run tcpdump on the server as I run udhcpc on the client
>> for Linux 3.4 vs 4.7
>>
>> Do you know what would make auto-negotiation fail at 100 Mbps
>> on 4.7? (whereas it succeeds on 3.4)
>>
>> (Thinking out loud) If the problem were in auto-negotiation,
>> then if should work if I hard-code speed and duplex using
>> ethtool, right? (IIRC, hard-coding doesn't help.)
> 
> I would start with checking basic things:
> 
> - does your Ethernet driver get a link UP being reported correctly
> (netif_carrier_ok returns 1)?
> - if you let the bootloader configure the PHY and utilize the Generic
> PHY driver instead of the Atheros PHY driver, does the problem appear as
> well?

Would using a "fixed-link" serve the same?

It appears that using a fixed-link

&eth0 {
	#address-cells = <1>;
	#size-cells = <0>;

#ifdef WITH_FIXED_LINK
	phy-connection-type = "rgmii";

	fixed-link {
		   speed = <100>;
		   full-duplex;
	};
#else
	phy-connection-type = "rgmii";
	phy-handle = <&eth0_phy>;

	/* Atheros AR8035 */
	eth0_phy: ethernet-phy@4 {
		interrupt-parent = <&irq0>;
		compatible = "ethernet-phy-id004d.d072",
			     "ethernet-phy-ieee802.3-c22";
		interrupts = <37 IRQ_TYPE_EDGE_RISING>;
		reg = <4>;
	};
#endif
};

works.


----

For what is worth, the patch that Mason was talking about earlier
in the thread:

  "...After much hair-pulling, it turned out that *some* of the breakage
was caused by a local patch..."

was setting changing the following delay in 'drivers/net/phy/phy.c:phy_state_machine()'

	/* Only re-schedule a PHY state machine change if we are polling the
	 * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
	 * between states from phy_mac_interrupt()
	 */
	if (phydev->irq == PHY_POLL)
		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
				   PHY_STATE_TIME * HZ);

from "PHY_STATE_TIME * HZ" to "0".

That caused 2 of 3 types of boards to fail, while one of them always worked
regardless of the delay.

In a nutshell:
- Board A, chip X: works with delay "PHY_STATE_TIME * HZ" or "0".
- Board B, chip X: does not work with delay "0"
- Board C, chip Y: does not work with delay "0"

Does board A works by "luck" when this delay is "0"?
(this delay has always been there, but it is not clear why)

> - what do transmit/receive counters on the Ethernet driver/MAC return?
> 
