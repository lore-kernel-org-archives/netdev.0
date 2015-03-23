From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Mon, 23 Mar 2015 07:00:50 -0700
Message-ID: <55101C92.4030400@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net> <550C92F3.50302@cumulusnetworks.com> <20150320220946.GB31769@lunn.ch> <20150323002215.GA6074@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	sfeldma@gmail.com, jiri@resnulli.us, ronen.arad@intel.com,
	netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36621 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbCWOAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 10:00:52 -0400
Received: by padcy3 with SMTP id cy3so192579552pad.3
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 07:00:52 -0700 (PDT)
In-Reply-To: <20150323002215.GA6074@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/22/15, 5:22 PM, Guenter Roeck wrote:
> On Fri, Mar 20, 2015 at 11:09:46PM +0100, Andrew Lunn wrote:
>>> since we have discussed this problem multiple times in switchdev meetings,
>>> the intent of this RFC is to see get the code out and also see if
>>> rocker or any other in-kernel
>>> driver can use it.
>> The Marvell switches in DSA don't have any way to mark packets why
>> they where forwarded towards the host. So i don't see how we could use
>> this feature with these chips.
>>
> If we (re-)enable unknown address flooding in the Marvell switch chips,
> we could simply mark all packets received from the switch as "forwarded
> by hardware". Sure, there is no bit in the header, but we would know
> from the chip configuration that the packets were forwarded.
>
> There may be a different problem, though: The driver won't know if
> the packet still needs to be forwarded by the soft bridge, for
> example to a port of a switch on another network interface
> which is part of the same bridge group.
>
> 		+---+
> 		|br0|
> 		+---+
> 		 | |
> 	+--------+ +----+
> 	|		|
>        +---+	      +---+
>        |sw0|	      |sw1|
>        +---+	      +---+
>         | +---+	        |
>       +--+  +--+       +--+
>       |p0|  |p1|	      |p2|
>       +--+  +--+	      +--+
>
> In this scenarion, sw0 can only know that it forwarded a packet to ports
> on the same switch. It does not know know that the packet needs to be
> forwarded to p2 as well. It would forward the packet from p0 to p1, and
> thus presumably set the hw_fwded bit, but br0 still needs to forward it.
>
> Maybe the check should be "if the packet was HW forwarded, the destination
> is a switch, and the destination is the same switch, don't forward the packet".

correct. And that's why my patch had the check in the bridge driver and
the check included  check for 'hw forwarded' flag in the packet and also 
checked that the port being forwarded to was
a switch port (port has NETIF_F_HW_SWITCH_OFFLOAD). I don't have the 
'same switch' check yet
for simplicity.
> This would be expensive, but on the other side it should not affect too
> many packets.
>
agreed.
