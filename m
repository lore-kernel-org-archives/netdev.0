From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Sun, 22 Mar 2015 18:33:49 -0700
Message-ID: <550F6D7D.7030403@gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <20150320.163655.474336751434677390.davem@davemloft.net> <550C92F3.50302@cumulusnetworks.com> <20150320220946.GB31769@lunn.ch> <20150323002215.GA6074@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, roopa <roopa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	jiri@resnulli.us, ronen.arad@intel.com, netdev@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:36491 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950AbbCWBeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 21:34:10 -0400
Received: by oigv203 with SMTP id v203so129482008oig.3
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 18:34:10 -0700 (PDT)
In-Reply-To: <20150323002215.GA6074@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/22/2015 05:22 PM, Guenter Roeck wrote:
> On Fri, Mar 20, 2015 at 11:09:46PM +0100, Andrew Lunn wrote:
>>> since we have discussed this problem multiple times in switchdev meetings,
>>> the intent of this RFC is to see get the code out and also see if
>>> rocker or any other in-kernel
>>> driver can use it.
>>
>> The Marvell switches in DSA don't have any way to mark packets why
>> they where forwarded towards the host. So i don't see how we could use
>> this feature with these chips.
>>
>
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
> This would be expensive, but on the other side it should not affect too
> many packets.

I think you might get away with only forwarding if the switch_id is
different then the ingress switch_id if they are the same then drop it
and assume the hardware already did the forward operation. We could
also add a port setting to turn it on/off if that is important.

I'm not sure why you would want to forward a packet back on a switch
port of the same switch it was received on. If you want to do this I
think its a special case and can be handled outside the bridge software
via 'tc', 'ovs', 'netfilters', etc. Maybe I missed a case though so
would be glad to hear it if there is one.

>
> Guenter
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
